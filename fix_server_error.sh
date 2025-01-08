#!/bin/bash

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

echo "Starting Fix for Server Shutdown Error..."

# Step 1: Backup existing files
echo "Backing up main.py and orchestrator.py..."
cp /home/ubuntu/Witta/main.py /home/ubuntu/Witta/main.py.bak
cp /home/ubuntu/Witta/witta-core/app/core/orchestrator.py /home/ubuntu/Witta/witta-core/app/core/orchestrator.py.bak

# Step 2: Update main.py
echo "Updating main.py..."
cat <<'EOF' > /home/ubuntu/Witta/main.py
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import asyncio
import logging
from pathlib import Path
from contextlib import asynccontextmanager
import sys

# Dynamically add the witta-core directory to sys.path
sys.path.append(str(Path(__file__).resolve().parent / "witta-core"))

from app.core.orchestrator import main as orchestrator_main

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger("witta")

# Use a lifespan event handler to start and stop the orchestrator
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup logic
    logger.info("Starting Witta server...")
    orchestrator_task = asyncio.create_task(orchestrator_main.run())  # Run orchestrator
    app.state.orchestrator_task = orchestrator_task
    yield
    # Shutdown logic
    logger.info("Shutting down Witta server...")
    orchestrator_task.cancel()
    try:
        await orchestrator_task  # Wait for the task to complete
    except asyncio.CancelledError:
        logger.info("Orchestrator task cancelled gracefully.")

# Initialize FastAPI app
app = FastAPI(lifespan=lifespan)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Define API endpoints
@app.get("/")
async def read_root():
    return {"message": "Welcome to Witta API"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
EOF

# Step 3: Update orchestrator.py
echo "Updating orchestrator.py..."
cat <<'EOF' > /home/ubuntu/Witta/witta-core/app/core/orchestrator.py
from .agents.data_agent import DataAgent
from .agents.proposal_agent import ProposalAgent
import asyncio
import logging

logger = logging.getLogger(__name__)

class TaskOrchestratorAsync:
    def __init__(self):
        self.task_queue = asyncio.Queue()
        self.task_results = {}
        self.agents = {
            "data": DataAgent("DataAgent"),
            "proposal": ProposalAgent("ProposalAgent"),
        }

    async def add_task(self, agent_type, payload):
        task_id = len(self.task_results) + 1
        task = {"id": task_id, "agent": agent_type, "payload": payload}
        await self.task_queue.put(task)
        logger.info(f"Task added: {task}")
        self.task_results[task_id] = {"status": "pending"}

    async def run(self):
        try:
            while True:
                task = await self.task_queue.get()
                logger.info(f"Executing task: {task}")

                task_id = task["id"]
                agent_type = task["agent"]
                payload = task["payload"]

                try:
                    agent = self.agents.get(agent_type)
                    if not agent:
                        raise Exception(f"Unknown agent type: {agent_type}")

                    await agent.execute(payload)
                    self.task_results[task_id]["status"] = "completed"
                except Exception as e:
                    self.task_results[task_id]["status"] = f"failed: {e}"

                self.task_queue.task_done()
        except asyncio.CancelledError:
            logger.info("TaskOrchestratorAsync.run cancelled. Exiting gracefully.")

# Create an instance of the orchestrator
main = TaskOrchestratorAsync()
EOF

# Step 4: Restart the server
echo "Restarting FastAPI server..."
pkill -f "uvicorn"  # Stop any running server
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > /home/ubuntu/Witta/server.log 2>&1 &

echo "Server restarted. Check the logs using 'tail -f /home/ubuntu/Witta/server.log'."
