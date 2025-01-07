from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import asyncio
import logging
from pathlib import Path
import sys

# Dynamically add the witta-core directory to sys.path
sys.path.append(str(Path(__file__).resolve().parent / "witta-core"))

from app.core.orchestrator import main as orchestrator_main

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(message)s",
    handlers=[logging.FileHandler("server.log"), logging.StreamHandler()],
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI()

# Enable CORS for testing (adjust origins in production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Update with specific domains in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize orchestrator
orchestrator = orchestrator_main

class Task(BaseModel):
    task_type: str
    payload: dict

@app.on_event("startup")
async def startup_event():
    logger.info("Server is starting...")
    asyncio.create_task(periodic_task_scheduler())

@app.on_event("shutdown")
async def shutdown_event():
    logger.info("Server is shutting down...")

async def periodic_task_scheduler():
    while True:
        try:
            logger.info("Running periodic tasks")
            await orchestrator.add_task("fetch_crypto_data", {"symbol": "BTC"})
        except Exception as e:
            logger.error(f"Error in periodic task: {e}")
        await asyncio.sleep(60)

@app.get("/")
async def root():
    return {"message": "Server is running"}

@app.post("/tasks/")
async def add_task(task: Task):
    try:
        await orchestrator.add_task(task.task_type, task.payload)
        return {"status": "Task added"}
    except Exception as e:
        logger.error(f"Error adding task: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/tasks/{task_id}")
async def get_task_status(task_id: int):
    if task_id in orchestrator.task_results:
        return orchestrator.task_results[task_id]
    else:
        raise HTTPException(status_code=404, detail="Task not found")

@app.get("/run/")
async def run_tasks():
    try:
        asyncio.create_task(orchestrator.run())
        return {"status": "Task execution started"}
    except Exception as e:
        logger.error(f"Error running tasks: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/logs")
async def get_logs(limit: int = 20):
    try:
        with open("server.log", "r") as log_file:
            lines = log_file.readlines()
            return {"logs": lines[-limit:]}
    except FileNotFoundError:
        return {"logs": []}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
