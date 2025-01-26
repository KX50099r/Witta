from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, validator
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
    await orchestrator_main.shutdown()  # Gracefully stop the orchestrator
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

class TaskPayload(BaseModel):
    agent_type: str
    payload: dict

    @validator('agent_type')
    def validate_agent_type(cls, v):
        if v not in ["data", "proposal"]:
            raise ValueError('agent_type must be "data" or "proposal"')
        return v

    @validator('payload')
    def validate_payload(cls, v):
        if not isinstance(v, dict):
            raise ValueError('payload must be a dictionary')
        return v
@app.get("/")
async def read_root():
    return {"message": "Welcome to Witta API"}

@app.post("/tasks")
async def add_task(task: TaskPayload):
    if task.agent_type not in orchestrator_main.agents:
        raise HTTPException(status_code=400, detail="Invalid agent type")
    await orchestrator_main.add_task(task.agent_type, task.payload)
    return {"message": "Task added successfully"}
async def health_check():
    return {"status": "healthy"}
