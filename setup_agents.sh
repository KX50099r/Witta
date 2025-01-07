#!/bin/bash

# Create the directory structure
mkdir -p witta-core/app/core/agents
mkdir -p witta-core/app/core/tasks

# Add __init__.py files to make directories Python packages
touch witta-core/app/__init__.py
touch witta-core/app/core/__init__.py
touch witta-core/app/core/agents/__init__.py
touch witta-core/app/core/tasks/__init__.py

# Create base_agent.py
cat <<EOF > witta-core/app/core/agents/base_agent.py
import logging

logger = logging.getLogger(__name__)

class BaseAgent:
    def __init__(self, name):
        self.name = name
        logger.info(f"Agent '{self.name}' initialized")

    async def execute(self, *args, **kwargs):
        raise NotImplementedError("Execute method must be implemented by subclasses")
EOF

# Create data_agent.py
cat <<EOF > witta-core/app/core/agents/data_agent.py
from .base_agent import BaseAgent
from ..tasks.fetch_crypto_data import fetch_crypto_data

class DataAgent(BaseAgent):
    async def execute(self, payload):
        # Perform specific tasks related to data
        await fetch_crypto_data(payload)
EOF

# Create proposal_agent.py
cat <<EOF > witta-core/app/core/agents/proposal_agent.py
from .base_agent import BaseAgent
from ..tasks.generate_proposal import generate_proposal

class ProposalAgent(BaseAgent):
    async def execute(self, payload):
        # Perform specific tasks related to proposals
        await generate_proposal(payload)
EOF

# Update orchestrator.py
cat <<EOF > witta-core/app/core/orchestrator.py
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
EOF

# Create fetch_crypto_data.py
cat <<EOF > witta-core/app/core/tasks/fetch_crypto_data.py
import logging

logger = logging.getLogger(__name__)

async def fetch_crypto_data(payload):
    logger.info(f"Fetching crypto data with payload: {payload}")
    # Simulated task logic
    await asyncio.sleep(1)
EOF

# Create generate_proposal.py
cat <<EOF > witta-core/app/core/tasks/generate_proposal.py
import logging

logger = logging.getLogger(__name__)

async def generate_proposal(payload):
    logger.info(f"Generating proposal with payload: {payload}")
    # Simulated task logic
    await asyncio.sleep(1)
EOF

echo "Agents and tasks have been set up successfully!"
