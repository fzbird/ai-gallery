from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.db.base import Base

class Category(Base):
    __tablename__ = 'category'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), unique=True, index=True, nullable=False)
    description = Column(String(500), nullable=True)
    
    # 多级分类支持
    parent_id = Column(Integer, ForeignKey('category.id'), nullable=True, index=True)
    level = Column(Integer, default=0, nullable=False)  # 分类层级，0为根级
    sort_order = Column(Integer, default=0, nullable=False)  # 同级排序

    # 统一的内容关系
    contents = relationship("ContentBase", back_populates="category")
    
    # 分类层次关系
    parent = relationship("Category", remote_side=[id], back_populates="children")
    children = relationship("Category", back_populates="parent", cascade="all, delete-orphan")
    
    # 为了向后兼容，保留原有属性访问
    @property
    def images(self):
        """获取分类下的所有图片"""
        return [content for content in self.contents if content.content_type == 'IMAGE']
    
    @property
    def galleries(self):
        """获取分类下的所有图集"""
        return [content for content in self.contents if content.content_type == 'GALLERY']
    
    @property
    def is_root(self):
        """判断是否为根分类"""
        return self.parent_id is None
    
    @property
    def has_children(self):
        """判断是否有子分类"""
        return len(self.children) > 0
    
    def get_ancestors(self):
        """获取祖先分类路径（从根到父级）"""
        ancestors = []
        current = self.parent
        while current:
            ancestors.insert(0, current)
            current = current.parent
        return ancestors
    
    def get_descendants(self):
        """获取所有后代分类（包括子分类的子分类）"""
        descendants = []
        for child in self.children:
            descendants.append(child)
            descendants.extend(child.get_descendants())
        return descendants
    
    def get_full_path(self):
        """获取完整路径名称（如：艺术 > 绘画 > 油画）"""
        path_names = [ancestor.name for ancestor in self.get_ancestors()]
        path_names.append(self.name)
        return " > ".join(path_names)
    
    def get_all_content_count(self):
        """获取包含子分类在内的所有内容数量"""
        count = len(self.contents)
        for child in self.children:
            count += child.get_all_content_count()
        return count 