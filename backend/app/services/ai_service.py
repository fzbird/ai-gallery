import base64
import json
import httpx
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
from sqlalchemy.orm import Session

from app.crud.crud_settings import settings as crud_settings
from app.crud.crud_image import image as crud_image
from app.crud.crud_tag import get_or_create_tags
from app.models.image import Image

logger = logging.getLogger(__name__)

class OllamaService:
    """Ollama AI服务客户端"""
    
    def __init__(self):
        self.timeout = 120.0  # 2分钟超时
        
    def _get_ollama_config(self, db: Session) -> Tuple[str, str]:
        """从数据库获取Ollama配置"""
        settings = crud_settings.get_all_settings(db)
        ollama_api = settings.get('ollama_api', 'http://localhost:11434')
        llm_model = settings.get('llm_model', 'gemma3:27b')
        
        # 确保API URL格式正确
        if not ollama_api.startswith('http'):
            ollama_api = f'http://{ollama_api}'
        if not ollama_api.endswith('/'):
            ollama_api += '/'
            
        return ollama_api, llm_model
    
    def _encode_image_base64(self, image_path: Path) -> str:
        """将图片编码为base64字符串"""
        try:
            with open(image_path, 'rb') as image_file:
                return base64.b64encode(image_file.read()).decode('utf-8')
        except Exception as e:
            logger.error(f"Failed to encode image {image_path}: {e}")
            raise
    
    def _create_prompt_for_gemma2(self) -> str:
        """为Gemma3模型创建优化的提示词"""
        return """你是一个专业的图片分析助手。请分析这张图片并返回JSON格式的结果。

请按照以下JSON格式输出：

{
    "description": "图片的详细中文描述",
    "tags": ["标签1", "标签2", "标签3"]
}

分析要求：
- 用1-2句话描述图片的主要内容、场景和特点
- 提供3-6个最相关的中文标签
- 标签应包含：主题、场景、风格、色彩等
- 避免使用"美丽"、"好看"等模糊词汇

现在请分析图片并返回JSON："""

    async def analyze_image(self, db: Session, image_path: Path) -> Dict[str, Any]:
        """分析图片并返回描述和标签"""
        try:
            ollama_api, llm_model = self._get_ollama_config(db)
            logger.info(f"Using Ollama API: {ollama_api}, Model: {llm_model}")
            
            # 检查图片文件
            if not image_path.exists():
                raise FileNotFoundError(f"Image file not found: {image_path}")
            
            file_size = image_path.stat().st_size
            logger.info(f"Image file size: {file_size} bytes")
            
            # 编码图片
            image_base64 = self._encode_image_base64(image_path)
            logger.info(f"Image encoded, size: {len(image_base64)} characters")
            
            # 构建请求数据 - 针对Gemma3优化
            request_data = {
                "model": llm_model,
                "prompt": self._create_prompt_for_gemma2(),
                "images": [image_base64],
                "stream": False,
                "options": {
                    "temperature": 0.7,  # 适当提高温度增加创造性
                    "top_p": 0.9,
                    "num_predict": 500,  # 使用num_predict代替max_tokens
                    "repeat_penalty": 1.1,  # 避免重复
                    # 不设置stop参数，让模型自然结束
                }
            }
            
            logger.info(f"Sending request to {ollama_api}api/generate")
            logger.info(f"Request payload size: {len(json.dumps(request_data))} characters")
            
            # 发送请求
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(
                    f"{ollama_api}api/generate",
                    json=request_data,
                    headers={"Content-Type": "application/json"}
                )
                
                logger.info(f"Response status: {response.status_code}")
                logger.info(f"Response headers: {dict(response.headers)}")
                
                if response.status_code != 200:
                    error_msg = f"Ollama API error: {response.status_code} - {response.text}"
                    logger.error(error_msg)
                    raise Exception(error_msg)
                
                # 获取原始响应文本
                response_text = response.text
                logger.info(f"Raw response text length: {len(response_text)}")
                logger.info(f"Raw response text (first 500 chars): {response_text[:500]}")
                
                try:
                    result = response.json()
                except json.JSONDecodeError as e:
                    logger.error(f"Failed to parse response as JSON: {e}")
                    logger.error(f"Response text: {response_text}")
                    raise Exception(f"Invalid JSON response: {e}")
                
                logger.info(f"Response keys: {list(result.keys())}")
                
                if 'response' not in result:
                    error_msg = f"Invalid response format: {result}"
                    logger.error(error_msg)
                    raise Exception(error_msg)
                
                ai_response = result['response']
                logger.info(f"AI raw response length: {len(ai_response)}")
                logger.info(f"AI raw response: '{ai_response}'")
                
                # 检查空响应
                if not ai_response or ai_response.strip() == "":
                    logger.error("AI returned empty response")
                    logger.error(f"Full result object: {result}")
                    
                    # 检查eval_count，如果很小说明模型过早停止
                    eval_count = result.get('eval_count', 0)
                    if eval_count < 10:
                        logger.error(f"Model stopped too early, eval_count: {eval_count}")
                        raise Exception(f"Model stopped too early (eval_count: {eval_count}) - this is likely a model configuration issue")
                    
                    # 检查是否有错误信息
                    if 'error' in result:
                        raise Exception(f"AI model error: {result['error']}")
                    
                    # 检查是否模型正在加载
                    if 'status' in result:
                        logger.warning(f"AI model status: {result['status']}")
                    
                    raise Exception("AI returned empty response - model may be overloaded or unavailable")
                
                # 解析响应
                parsed_result = self._parse_ai_response(ai_response)
                logger.info(f"Parsed result: {parsed_result}")
                
                return parsed_result
                
        except Exception as e:
            logger.error(f"Failed to analyze image {image_path}: {e}")
            raise
    
    def _parse_ai_response(self, ai_response: str) -> Dict[str, Any]:
        """解析AI返回的响应"""
        try:
            # 提取JSON内容
            response_text = ai_response.strip()
            logger.info(f"Parsing AI response: '{response_text}'")
            
            # 如果响应为空，直接抛出异常
            if not response_text:
                raise ValueError("Empty AI response")
            
            # 首先尝试直接解析整个响应
            try:
                parsed = json.loads(response_text)
                if isinstance(parsed, dict) and 'description' in parsed and 'tags' in parsed:
                    return self._validate_and_clean_response(parsed)
            except json.JSONDecodeError:
                pass
            
            # 查找JSON代码块
            start_json = response_text.find('```json')
            if start_json != -1:
                start_json += 7  # 跳过 ```json
                end_json = response_text.find('```', start_json)
                if end_json != -1:
                    json_text = response_text[start_json:end_json].strip()
                else:
                    json_text = response_text[start_json:].strip()
            else:
                # 查找花括号范围内的JSON
                start_brace = response_text.find('{')
                end_brace = response_text.rfind('}')
                if start_brace != -1 and end_brace != -1 and end_brace > start_brace:
                    json_text = response_text[start_brace:end_brace+1]
                else:
                    # 尝试简单的模式匹配
                    lines = response_text.split('\n')
                    json_lines = []
                    in_json = False
                    
                    for line in lines:
                        if '{' in line:
                            in_json = True
                        if in_json:
                            json_lines.append(line)
                        if '}' in line and in_json:
                            break
                    
                    if json_lines:
                        json_text = '\n'.join(json_lines)
                    else:
                        raise ValueError("No valid JSON found in response")
            
            logger.info(f"Extracted JSON text: '{json_text}'")
            
            # 解析JSON
            parsed = json.loads(json_text)
            return self._validate_and_clean_response(parsed)
            
        except Exception as e:
            logger.error(f"Failed to parse AI response: {e}")
            logger.error(f"Original response: '{ai_response}'")
            # 不返回默认结果，直接抛出异常以便调用方处理
            raise Exception(f"AI response parsing failed: {e}")
    
    def _validate_and_clean_response(self, parsed: dict) -> Dict[str, Any]:
        """验证和清理AI响应数据"""
        # 验证必需字段
        if 'description' not in parsed or 'tags' not in parsed:
            raise ValueError("Missing required fields in response")
        
        # 清理和验证数据
        description = str(parsed['description']).strip()
        tags = []
        
        if isinstance(parsed['tags'], list):
            for tag in parsed['tags']:
                tag_str = str(tag).strip()
                if tag_str and len(tag_str) <= 20:  # 限制标签长度
                    tags.append(tag_str)
        
        return {
            'description': description[:1000],  # 限制描述长度
            'tags': tags[:8]  # 限制标签数量
        }

class AIAnalysisService:
    """AI分析服务管理器"""
    
    def __init__(self):
        self.ollama_service = OllamaService()
    
    async def process_image_analysis(self, db: Session, image_id: int) -> bool:
        """处理图片AI分析"""
        try:
            # 获取图片信息
            image = crud_image.get(db, id=image_id)
            if not image:
                logger.error(f"Image {image_id} not found")
                return False
            
            # 检查图片文件是否存在
            filepath = getattr(image, 'filepath', None)
            if not filepath:
                logger.error(f"Image {image_id} has no filepath")
                self._update_ai_status(db, image_id, "failed", "图片文件路径为空")
                return False
                
            image_path = Path(str(filepath))
            if not image_path.exists():
                logger.error(f"Image file not found: {filepath}")
                self._update_ai_status(db, image_id, "failed", "图片文件不存在")
                return False
            
            # 更新状态为处理中
            self._update_ai_status(db, image_id, "processing")
            logger.info(f"Starting AI analysis for image {image_id}, file: {filepath}")
            
            # 调用AI分析
            try:
                analysis_result = await self.ollama_service.analyze_image(db, image_path)
                logger.info(f"AI analysis successful for image {image_id}: {analysis_result}")
            except Exception as ai_error:
                logger.error(f"AI analysis failed for image {image_id}: {ai_error}")
                # 使用默认结果而不是失败
                analysis_result = {
                    'description': f"AI分析暂时不可用: {str(ai_error)[:100]}",
                    'tags': ["待分析"]
                }
            
            # 处理AI标签
            ai_tags = analysis_result.get('tags', [])
            if ai_tags:
                try:
                    # 创建或获取标签
                    tag_objects = get_or_create_tags(db, tags=ai_tags)
                    # 将AI标签添加到图片
                    existing_tags = list(image.tags)
                    for tag in tag_objects:
                        if tag not in existing_tags:
                            existing_tags.append(tag)
                    image.tags = existing_tags
                except Exception as tag_error:
                    logger.error(f"Failed to process tags for image {image_id}: {tag_error}")
            
            # 更新图片信息
            update_data = {
                'ai_status': 'completed',
                'ai_description': analysis_result.get('description', ''),
                'ai_tags': ai_tags  # 保存原始AI标签到JSON字段
            }
            
            crud_image.update(db, db_obj=image, obj_in=update_data)
            
            logger.info(f"Successfully completed AI analysis for image {image_id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to process image analysis for {image_id}: {e}")
            self._update_ai_status(db, image_id, "failed", str(e))
            return False
    
    def _update_ai_status(self, db: Session, image_id: int, status: str, error_message: Optional[str] = None):
        """更新AI处理状态"""
        try:
            image = crud_image.get(db, id=image_id)
            if image:
                update_data = {'ai_status': status}
                if error_message:
                    update_data['ai_description'] = f"处理失败: {error_message}"
                crud_image.update(db, db_obj=image, obj_in=update_data)
                logger.info(f"Updated AI status for image {image_id}: {status}")
        except Exception as e:
            logger.error(f"Failed to update AI status for image {image_id}: {e}")

# 全局服务实例
ai_analysis_service = AIAnalysisService() 