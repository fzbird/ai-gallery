import asyncio
import logging
from typing import Dict, Set
from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.services.ai_service import ai_analysis_service

logger = logging.getLogger(__name__)

class BackgroundTaskManager:
    """后台任务管理器"""
    
    def __init__(self):
        self.running_tasks: Set[int] = set()
        self.task_queue: asyncio.Queue = asyncio.Queue()
        self._running = False
        
    async def start(self):
        """启动后台任务处理器"""
        if self._running:
            return
            
        self._running = True
        logger.info("Background task manager started")
        
        # 启动任务处理协程
        asyncio.create_task(self._process_tasks())
    
    async def stop(self):
        """停止后台任务处理器"""
        self._running = False
        logger.info("Background task manager stopped")
    
    async def add_ai_analysis_task(self, image_id: int):
        """添加AI分析任务"""
        if image_id not in self.running_tasks:
            await self.task_queue.put({
                'type': 'ai_analysis',
                'image_id': image_id
            })
            logger.info(f"Added AI analysis task for image {image_id}")
    
    async def _process_tasks(self):
        """处理任务队列"""
        while self._running:
            try:
                # 从队列获取任务
                task = await asyncio.wait_for(self.task_queue.get(), timeout=1.0)
                
                if task['type'] == 'ai_analysis':
                    await self._process_ai_analysis_task(task['image_id'])
                    
            except asyncio.TimeoutError:
                # 超时继续循环
                continue
            except Exception as e:
                logger.error(f"Error processing background task: {e}")
    
    async def _process_ai_analysis_task(self, image_id: int):
        """处理AI分析任务"""
        if image_id in self.running_tasks:
            logger.warning(f"AI analysis task for image {image_id} is already running")
            return
        
        try:
            self.running_tasks.add(image_id)
            logger.info(f"Starting AI analysis for image {image_id}")
            
            # 创建数据库会话
            db: Session = SessionLocal()
            try:
                # 执行AI分析
                success = await ai_analysis_service.process_image_analysis(db, image_id)
                if success:
                    logger.info(f"AI analysis completed for image {image_id}")
                else:
                    logger.error(f"AI analysis failed for image {image_id}")
            finally:
                db.close()
                
        except Exception as e:
            logger.error(f"Error in AI analysis task for image {image_id}: {e}")
        finally:
            self.running_tasks.discard(image_id)

# 全局任务管理器实例
background_task_manager = BackgroundTaskManager() 