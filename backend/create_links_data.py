import asyncio
import sys
from pathlib import Path

# 添加项目根目录到Python路径
sys.path.append(str(Path(__file__).parent))

from sqlalchemy.orm import Session
from app.db.session import get_db
from app.models.link import Link

def create_links_data():
    """创建友情链接测试数据"""
    db = next(get_db())
    
    # 检查是否已有友情链接数据
    existing_count = db.query(Link).count()
    if existing_count > 0:
        print(f"已存在 {existing_count} 个友情链接，跳过创建")
        return
    
    links_data = [
        {
            "title": "摄影网",
            "url": "https://example.com/photography",
            "description": "专业摄影作品分享平台",
            "sort_order": 10
        },
        {
            "title": "在线工具",
            "url": "https://example.com/tools", 
            "description": "实用在线工具集合",
            "sort_order": 9
        },
        {
            "title": "贴图素材",
            "url": "https://example.com/textures",
            "description": "高质量贴图素材下载",
            "sort_order": 8
        },
        {
            "title": "DNS解析",
            "url": "https://example.com/dns",
            "description": "免费DNS解析服务",
            "sort_order": 7
        },
        {
            "title": "数据恢复大师",
            "url": "https://example.com/recovery",
            "description": "专业数据恢复服务",
            "sort_order": 6
        },
        {
            "title": "整形平台",
            "url": "https://example.com/beauty",
            "description": "医美整形信息平台",
            "sort_order": 5
        },
        {
            "title": "mg动画制作",
            "url": "https://example.com/animation",
            "description": "专业MG动画制作服务",
            "sort_order": 4
        },
        {
            "title": "书法字典",
            "url": "https://example.com/calligraphy",
            "description": "在线书法字典查询",
            "sort_order": 3
        },
        {
            "title": "企业网站设计",
            "url": "https://example.com/webdesign",
            "description": "专业企业网站设计服务",
            "sort_order": 2
        },
        {
            "title": "品牌策划公司",
            "url": "https://example.com/branding",
            "description": "专业品牌策划服务",
            "sort_order": 1
        }
    ]
    
    print("开始创建友情链接数据...")
    
    for link_data in links_data:
        link = Link(**link_data)
        db.add(link)
    
    db.commit()
    print(f"成功创建 {len(links_data)} 个友情链接")
    
    # 验证创建结果
    total_links = db.query(Link).count()
    print(f"数据库中共有 {total_links} 个友情链接")

if __name__ == "__main__":
    create_links_data() 