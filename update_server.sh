#!/bin/bash

# Set the working directory to the project root
cd "$(dirname "$0")"

echo "Updating server with automation, logging, and health check features..."

# Create/update main.py
cat <<EOF > main.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import asyncio
import logging
from pathlib import Path
import sys

# Add witta-core to the Python path
sys.path.append(str(Path.cwd() / "witta-core"))

from app.core.orchestrator import main as orchestrator_main

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(message)s",
    handlers=[logging.FileHandler("server.log"), logging.StreamHandler()]
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

@app.on_event("startup")
async def startup_event():
    logger.info("Server is starting...")
    asyncio.create_task(periodic_task_scheduler())

async def periodic_task_scheduler():
    while True:
        logger.info("Running periodic tasks")
        # Example: Automatically add a task every 60 seconds
        await orchestrator.add_task("fetch_crypto_data", {"symbol": "BTC"})
        await asyncio.sleep(60)

@app.get("/")
async def root():
    return {"message": "Server is running"}

@app.post("/tasks/")
async def add_task(task_type: str, payload: dict):
    try:
        # Add a task to the orchestrator
        await orchestrator.add_task(task_type, payload)
        return {"status": "Task added"}
    except Exception as e:
        logger.error(f"Error adding task: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/tasks/{task_id}")
async def get_task_status(task_id: int):
    # Check task status in orchestrator
    if task_id in orchestrator.task_results:
        return orchestrator.task_results[task_id]
    else:
        raise HTTPException(status_code=404, detail="Task not found")

@app.get("/run/")
async def run_tasks():
    try:
        # Run the orchestrator
        asyncio.create_task(orchestrator.run())
        return {"status": "Task execution started"}
    except Exception as e:
        logger.error(f"Error running tasks: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/logs")
async def get_logs():
    try:
        with open("server.log", "r") as log_file:
            return {"logs": log_file.readlines()[-20:]}  # Return the last 20 log lines
    except FileNotFoundError:
        return {"logs": []}

@app.get("/health")
async def health_check():
    return {"status": "ok", "tasks_in_queue": orchestrator.task_queue.qsize()}
EOF

echo "Updated main.py with new features."

# Update orchestrator.py to include in-memory task results
cat <<EOF > witta-core/app/core/orchestrator.py
import asyncio
import logging
from .tasks.generate_proposal import generate_proposal
from .tasks.fetch_crypto_data import fetch_crypto_data

logger = logging.getLogger(__name__)

class TaskOrchestratorAsync:
    def __init__(self):
        self.task_queue = asyncio.Queue()
        self.task_results = {}

    async def add_task(self, task_type, payload):
        task_id = len(self.task_results) + 1
        task = {"id": task_id, "type": task_type, "payload": payload}
        await self.task_queue.put(task)
        logger.info(f"Task added: {task}")
        self.task_results[task_id] = {"status": "pending"}

    async def run(self):
        while True:
            task = await self.task_queue.get()
            logger.info(f"Executing task: {task}")

            task_id = task["id"]
            task_type = task["type"]
            payload = task["payload"]

            try:
                if task_type == "generate_proposal":
                    await generate_proposal(payload)
                elif task_type == "fetch_crypto_data":
                    await fetch_crypto_data(payload)
                else:
                    logger.warning(f"Unknown task type: {task_type}")
                    raise Exception("Unknown task type")

                self.task_results[task_id]["status"] = "completed"
            except Exception as e:
                self.task_results[task_id]["status"] = f"failed: {e}"

            self.task_queue.task_done()
EOF

echo "Updated orchestrator.py with in-memory task results."

# Install required dependencies
echo "Installing FastAPI and Uvicorn..."
pip install fastapi uvicorn

echo "Update complete. Run the server using:"
echo "uvicorn main:app --reload --host 0.0.0.0 --port 8000"
