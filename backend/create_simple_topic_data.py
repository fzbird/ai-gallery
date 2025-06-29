#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app import crud, models
from app.schemas.topic import TopicCreate

def create_simple_topics():
    """创建简化的专题数据"""
    db: Session = SessionLocal()
    
    try:
        # 获取一些图集
        galleries = db.query(models.Gallery).limit(10).all()
        if not galleries:
            print("❌ 没有找到图集，请先创建图集数据")
            return
        
        print("📚 开始创建简化的专题数据...")
        
        # 定义专题数据
        topics_data = [
            {
                "name": "自然风光",
                "slug": "natural-scenery",
                "description": "汇集最美的自然风光图集，包含山川、湖泊、森林等各种自然景观",
                "cover_image_url": "http://localhost:8000/uploads/mountain_clouds.jpg",
                "is_featured": True
            },
            {
                "name": "城市印象",
                "slug": "city-impressions",
                "description": "记录城市的美好瞬间，从繁华街区到静谧小巷",
                "cover_image_url": "http://localhost:8000/uploads/city_night.jpg",
                "is_featured": True
            },
            {
                "name": "人文摄影",
                "slug": "human-photography",
                "description": "捕捉人文情怀，展现生活中的温暖时刻",
                "cover_image_url": None,
                "is_featured": False
            },
            {
                "name": "建筑艺术",
                "slug": "architecture-art",
                "description": "欣赏建筑之美，从古典到现代的建筑艺术",
                "cover_image_url": None,
                "is_featured": False
            },
            {
                "name": "抽象艺术",
                "slug": "abstract-art",
                "description": "探索抽象艺术的无限可能，感受色彩与形状的魅力",
                "cover_image_url": None,
                "is_featured": False
            }
        ]
        
        created_topics = []
        
        # 创建专题
        for topic_data in topics_data:
            # 检查是否已存在
            existing = crud.topic.get_by_slug(db=db, slug=topic_data["slug"])
            if existing:
                print(f"⚠️ 专题 '{topic_data['name']}' 已存在，跳过")
                created_topics.append(existing)
                continue
            
            topic_create = TopicCreate(**topic_data)
            topic = crud.topic.create(db=db, obj_in=topic_create)
            created_topics.append(topic)
            print(f"✅ 创建专题: {topic.name}")
        
        # 为图集分配专题
        print("\n📸 开始为图集分配专题...")
        
        for i, gallery in enumerate(galleries):
            # 为每个图集随机分配一个专题
            topic_index = i % len(created_topics)
            topic = created_topics[topic_index]
            
            # 更新图集的topic_id
            gallery.topic_id = topic.id
            db.add(gallery)
            print(f"  ➕ 将图集 '{gallery.title}' 分配到专题 '{topic.name}'")
        
        db.commit()
        
        print(f"\n🎉 简化专题数据创建完成!")
        print(f"   - 创建了 {len(created_topics)} 个专题")
        print(f"   - 其中 {sum(1 for t in created_topics if t.is_featured)} 个为推荐专题")
        
        # 显示专题统计
        print("\n📊 专题统计:")
        for topic in created_topics:
            gallery_count = db.query(models.Gallery).filter(models.Gallery.topic_id == topic.id).count()
            print(f"   - {topic.name}: {gallery_count} 个图集")
        
    except Exception as e:
        print(f"❌ 创建专题数据时出错: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_simple_topics() 