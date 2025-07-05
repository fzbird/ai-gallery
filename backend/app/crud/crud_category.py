from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, and_, desc
from typing import Optional, List

from app.models.category import Category
from app.schemas.category import CategoryCreate, CategoryUpdate, CategoryTreeNode
from app.crud.base import CRUDBase

class CRUDCategory(CRUDBase[Category, CategoryCreate, CategoryUpdate]):
    def get_by_name(self, db: Session, *, name: str) -> Optional[Category]:
        return db.query(Category).filter(Category.name == name).first()
    
    def get_root_categories(self, db: Session) -> List[Category]:
        """获取所有根分类（parent_id为空的分类）"""
        return (
            db.query(Category)
            .filter(Category.parent_id.is_(None))
            .order_by(Category.sort_order, Category.name)
            .all()
        )
    
    def get_children(self, db: Session, *, parent_id: int) -> List[Category]:
        """获取指定分类的直接子分类"""
        return (
            db.query(Category)
            .filter(Category.parent_id == parent_id)
            .order_by(Category.sort_order, Category.name)
            .all()
        )
    
    def get_tree(self, db: Session, *, max_level: Optional[int] = None) -> List[CategoryTreeNode]:
        """获取完整的分类树结构"""
        # 获取所有分类，按层级和排序排列
        query = db.query(Category).order_by(Category.level, Category.sort_order, Category.name)
        if max_level is not None:
            query = query.filter(Category.level <= max_level)
        
        categories = query.all()
        
        # 为了正确统计图集数量，需要导入Gallery模型
        from app.models.gallery import Gallery
        
        # 构建树形结构
        category_map = {}
        tree_nodes = []
        
        for category in categories:
            # 统计直接属于该分类的图集数量
            direct_galleries = db.query(Gallery).filter(
                Gallery.category_id == category.id
            ).count()
            
            # 统计包含所有子分类的图集数量
            all_descendants = category.get_descendants()
            descendant_ids = [desc.id for desc in all_descendants] + [category.id]
            
            all_galleries = db.query(Gallery).filter(
                Gallery.category_id.in_(descendant_ids)
            ).count()
            
            node = CategoryTreeNode(
                id=category.id,
                name=category.name,
                description=category.description,
                parent_id=category.parent_id,
                level=category.level,
                sort_order=category.sort_order,
                full_path=category.get_full_path(),
                content_count=direct_galleries,  # 直接图集数量
                all_content_count=all_galleries,  # 包含子分类的总图集数量
                children=[]
            )
            category_map[category.id] = node
            
            if category.parent_id is None:
                tree_nodes.append(node)
            else:
                parent_node = category_map.get(category.parent_id)
                if parent_node:
                    parent_node.children.append(node)
        
        return tree_nodes
    
    def get_ancestors(self, db: Session, *, category_id: int) -> List[Category]:
        """获取指定分类的所有祖先分类"""
        category = self.get(db, id=category_id)
        if not category:
            return []
        return category.get_ancestors()
    
    def get_descendants(self, db: Session, *, category_id: int) -> List[Category]:
        """获取指定分类的所有后代分类"""
        category = self.get(db, id=category_id)
        if not category:
            return []
        return category.get_descendants()
    
    def create_with_parent(self, db: Session, *, obj_in: CategoryCreate) -> Category:
        """创建分类，自动计算层级"""
        # 如果有父分类，计算层级
        level = 0
        if obj_in.parent_id:
            parent = self.get(db, id=obj_in.parent_id)
            if parent:
                level = parent.level + 1
        
        # 创建分类数据
        category_data = obj_in.model_dump()
        category_data['level'] = level
        
        db_obj = Category(**category_data)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj
    
    def move_category(self, db: Session, *, category_id: int, new_parent_id: Optional[int]) -> Category:
        """移动分类到新的父分类下"""
        category = self.get(db, id=category_id)
        if not category:
            raise ValueError("Category not found")
        
        # 防止循环引用
        if new_parent_id:
            if new_parent_id == category_id:
                raise ValueError("Cannot move category to itself")
            
            # 检查是否会创建循环引用
            descendants = category.get_descendants()
            if any(desc.id == new_parent_id for desc in descendants):
                raise ValueError("Cannot move category to its descendant")
        
        # 计算新的层级
        new_level = 0
        if new_parent_id:
            parent = self.get(db, id=new_parent_id)
            if parent:
                new_level = parent.level + 1
        
        # 更新分类及其所有后代的层级
        old_level = category.level
        level_diff = new_level - old_level
        
        category.parent_id = new_parent_id
        category.level = new_level
        
        # 递归更新所有后代的层级
        def update_descendants_level(cat: Category, diff: int):
            for child in cat.children:
                child.level += diff
                update_descendants_level(child, diff)
        
        if level_diff != 0:
            update_descendants_level(category, level_diff)
        
        db.commit()
        db.refresh(category)
        return category
    
    def get_category_stats(self, db: Session) -> dict:
        """获取分类统计信息"""
        total_categories = db.query(func.count(Category.id)).scalar() or 0
        max_level = db.query(func.max(Category.level)).scalar() or 0
        root_categories = db.query(func.count(Category.id)).filter(Category.parent_id.is_(None)).scalar() or 0
        
        # 统计有内容的分类数量
        categories_with_content = (
            db.query(func.count(func.distinct(Category.id)))
            .join(Category.contents)
            .scalar() or 0
        )
        
        return {
            "total_categories": total_categories,
            "max_level": max_level,
            "root_categories": root_categories,
            "categories_with_content": categories_with_content
        }
    
    def delete_with_children(self, db: Session, *, id: int, move_content_to: Optional[int] = None) -> Category:
        """删除分类及其子分类，可选择将内容移动到其他分类"""
        category = self.get(db, id=id)
        if not category:
            raise ValueError("Category not found")
        
        # 如果指定了内容移动目标
        if move_content_to:
            target_category = self.get(db, id=move_content_to)
            if not target_category:
                raise ValueError("Target category not found")
            
            # 移动当前分类和所有子分类的内容
            all_categories = [category] + category.get_descendants()
            for cat in all_categories:
                for content in cat.contents:
                    content.category_id = move_content_to
        
        # 删除分类（子分类会因为级联删除而自动删除）
        db.delete(category)
        db.commit()
        return category

    def has_children(self, db: Session, *, category_id: int) -> bool:
        """检查分类是否有子分类"""
        return db.query(
            db.query(Category).filter(Category.parent_id == category_id).exists()
        ).scalar()

    def remove(self, db: Session, *, id: int, move_content_to: Optional[int] = None) -> Category:
        """
        删除一个分类。
        - 如果 move_content_to 被指定，将该分类的内容移动到目标分类。
        - 该方法假定调用前已经检查过没有子分类。
        """
        category_to_delete = db.query(Category).get(id)
        if not category_to_delete:
            raise ValueError("Category not found")

        # 移动内容
        if move_content_to is not None:
            for content in category_to_delete.contents:
                content.category_id = move_content_to
        
        # 删除分类
        db.delete(category_to_delete)
        db.commit()
        return category_to_delete

category = CRUDCategory(Category)
