from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.core.config import settings
from app.api.v1.api import api_router
from app.services.background_tasks import background_task_manager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # 启动后台任务管理器
    await background_task_manager.start()
    yield
    # 停止后台任务管理器
    await background_task_manager.stop()

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan
)

# Set all CORS enabled origins
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

# Mount the 'uploads' directory to serve static files
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIRECTORY), name="uploads")

@app.get("/")
async def read_root():
    return {"message": "欢迎来到MyGallery在线图片分享系统 API"}

# 后续将在这里挂载各个模块的路由
app.include_router(api_router, prefix=settings.API_V1_STR) 