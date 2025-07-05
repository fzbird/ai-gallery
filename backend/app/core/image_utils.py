from PIL import Image, ImageDraw, ImageFont
import os
from pathlib import Path
from sqlalchemy.orm import Session
from app.core.config import settings
from app.models.image import Image as ImageModel

def generate_image_url(image: ImageModel) -> str:
    """根据Image模型对象生成可访问的URL"""
    if not image:
        return ""
    
    # 安全获取filepath字符串
    filepath_str = ""
    if hasattr(image, 'filepath') and image.filepath is not None:
        filepath_str = str(image.filepath).strip()
    
    if filepath_str:
        # 将filepath转换为相对于uploads目录的路径
        # 例如: "E:/Cursor/Gallery/backend/uploads/gallery_56/filename.jpg" -> "gallery_56/filename.jpg"
        file_path = Path(filepath_str)
        upload_dir = Path(settings.UPLOAD_DIRECTORY)
        try:
            # 计算相对路径
            relative_path = file_path.relative_to(upload_dir)
            return f"/uploads/{relative_path}".replace("\\", "/")
        except ValueError:
            # 如果relative_to失败，尝试从filepath中手动提取相对路径
            normalized_filepath = filepath_str.replace("\\", "/")
            uploads_str = "uploads/"
            
            # 查找uploads/在路径中的位置
            uploads_index = normalized_filepath.find(uploads_str)
            if uploads_index != -1:
                # 提取从uploads/之后的部分作为相对路径
                relative_part = normalized_filepath[uploads_index + len(uploads_str):]
                return f"/uploads/{relative_part}"
            else:
                # 如果filepath中没有uploads，使用filename
                return f"/uploads/{image.filename}"
    else:
        # 如果没有filepath，使用filename
        return f"/uploads/{image.filename}"

def compress_image(image_path: Path, quality: int = 85, max_size: tuple = (1920, 1080)):
    """
    Compresses an image by reducing its quality and resizing it if it exceeds max_size.
    """
    try:
        with Image.open(image_path) as img:
            if img.size[0] > max_size[0] or img.size[1] > max_size[1]:
                img.thumbnail(max_size, Image.Resampling.LANCZOS)

            # Convert RGBA to RGB for saving as JPEG
            if img.mode in ('RGBA', 'P'):
                img = img.convert('RGB')
            
            img.save(image_path, 'JPEG', quality=quality, optimize=True)
    except Exception as e:
        # Handle exceptions, e.g., logging
        print(f"Error compressing image {image_path}: {e}")


def add_watermark(image_path: Path):
    """
    Adds a text watermark to an image.
    """
    if not settings.WATERMARK_TEXT:
        return # Skip if no watermark text is set

    try:
        with Image.open(image_path).convert("RGBA") as base:
            txt = Image.new("RGBA", base.size, (255, 255, 255, 0))

            # Check if font file exists
            font_path = Path(settings.WATERMARK_FONT_PATH)
            if not font_path.exists():
                print(f"Warning: Watermark font not found at {font_path}, skipping watermark.")
                return

            fnt = ImageFont.truetype(str(font_path), settings.WATERMARK_FONT_SIZE)
            
            # Use textbbox to get bounding box of the text
            text_bbox = ImageDraw.Draw(txt).textbbox((0, 0), settings.WATERMARK_TEXT, font=fnt)
            text_width = text_bbox[2] - text_bbox[0]
            text_height = text_bbox[3] - text_bbox[1]

            # Position at the bottom right
            position = (base.width - text_width - 10, base.height - text_height - 10)
            
            # Draw text on transparent layer
            d = ImageDraw.Draw(txt)
            d.text(position, settings.WATERMARK_TEXT, font=fnt, fill=(255, 255, 255, 128))

            # Composite the text layer onto the base image
            out = Image.alpha_composite(base, txt)
            
            # Convert back to RGB for saving
            if out.mode in ('RGBA', 'P'):
                out = out.convert('RGB')

            out.save(image_path)

    except Exception as e:
        print(f"Error adding watermark to image {image_path}: {e}")

def safe_delete_image_file(db: Session, filepath: str) -> bool:
    """
    安全删除图片文件，只有当文件没有其他引用时才删除
    
    Args:
        db: 数据库会话
        filepath: 要删除的文件路径
        
    Returns:
        bool: 是否删除了物理文件
    """
    if not filepath or not os.path.exists(filepath):
        return False
    
    # 统计有多少个图片记录引用这个文件路径
    reference_count = db.query(ImageModel).filter(ImageModel.filepath == filepath).count()
    
    # 只有当引用计数为0时才删除物理文件
    if reference_count == 0:
        try:
            os.remove(filepath)
            print(f"Physical file deleted: {filepath}")
            return True
        except OSError as e:
            print(f"Warning: Could not delete file {filepath}: {e}")
            return False
    else:
        print(f"File {filepath} is referenced by {reference_count} records, skipping physical deletion")
        return False


def safe_delete_gallery_folder(db: Session, gallery_id: int) -> bool:
    """
    安全删除图集文件夹，只有当文件夹为空时才删除
    
    Args:
        db: 数据库会话
        gallery_id: 图集ID
        
    Returns:
        bool: 是否删除了图集文件夹
    """
    try:
        # 构建图集文件夹路径
        gallery_folder_name = f"gallery_{gallery_id}"
        gallery_folder_path = Path(settings.UPLOAD_DIRECTORY) / gallery_folder_name
        
        if not gallery_folder_path.exists():
            print(f"Gallery folder {gallery_folder_path} does not exist")
            return False
        
        # 检查文件夹是否为空
        if not any(gallery_folder_path.iterdir()):
            # 文件夹为空，可以安全删除
            gallery_folder_path.rmdir()
            print(f"Gallery folder deleted: {gallery_folder_path}")
            return True
        else:
            # 文件夹不为空，列出剩余文件
            remaining_files = list(gallery_folder_path.iterdir())
            print(f"Gallery folder {gallery_folder_path} is not empty, contains {len(remaining_files)} files: {[f.name for f in remaining_files]}")
            return False
            
    except OSError as e:
        print(f"Warning: Could not delete gallery folder {gallery_folder_path}: {e}")
        return False 