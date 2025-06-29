from .user import User  # noqa
from .content_base import ContentBase, ContentType  # noqa
from .image import Image  # noqa
from .gallery import Gallery  # noqa
from .tag import Tag  # noqa
from .comment import Comment  # noqa
from .setting import Setting # noqa
from .category import Category # noqa
from .department import Department # noqa
from .link import Link # noqa
from .topic import Topic # noqa

# 统一的内容交互表
from .content_interactions import content_likes, content_bookmarks, content_tags, user_follows # noqa

# 保留原有的关联表以支持向后兼容（已清理完毕）
from .follower import followers

# 移除重复的gallery关联表，因为现在使用统一的content交互表
# from .gallery_like import gallery_likes # noqa
# from .gallery_bookmark import gallery_bookmarks # noqa 