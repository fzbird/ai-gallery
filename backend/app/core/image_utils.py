from PIL import Image, ImageDraw, ImageFont
import os
from pathlib import Path
from app.core.config import settings
from app.models.image import Image as ImageModel

def generate_image_url(image: ImageModel) -> str:
    """根据Image模型对象生成可访问的URL"""
    if not image:
        return ""
    
    if image.filepath and str(image.filepath).strip():
        # 将filepath转换为相对于uploads目录的路径
        # 例如: "E:/Cursor/Gallery/backend/uploads/gallery_56/filename.jpg" -> "gallery_56/filename.jpg"
        file_path = Path(str(image.filepath))
        upload_dir = Path(settings.UPLOAD_DIRECTORY)
        try:
            # 计算相对路径
            relative_path = file_path.relative_to(upload_dir)
            return f"/uploads/{relative_path}".replace("\\", "/")
        except ValueError:
            # 如果filepath不在uploads目录下，使用filename
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