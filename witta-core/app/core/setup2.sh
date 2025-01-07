#!/usr/bin/env bash

# Create the tasks directory
mkdir -p tasks

# Create empty __init__.py to make 'tasks' a package
touch tasks/__init__.py

# Create generate_proposal.py
cat <<EOF > tasks/generate_proposal.py
import logging

logger = logging.getLogger(__name__)

async def generate_proposal(payload):
    logger.info(f"Generating proposal with payload: {payload}")
    # Perform I/O-bound calls (e.g., OpenAI API) here using await
    # Simulated async I/O operation
    await asyncio.sleep(1)
EOF

# Create fetch_crypto_data.py
cat <<EOF > tasks/fetch_crypto_data.py
import logging

logger = logging.getLogger(__name__)

async def fetch_crypto_data(payload):
    logger.info(f"Fetching crypto data with payload: {payload}")
    # Perform I/O-bound calls here (e.g., calling Robinhood or other APIs) using await
    # Simulated async I/O operation
    await asyncio.sleep(1)
EOF

# Create orchestrator.py
cat <<EOF > orchestrator.py
import asyncio
import logging

from tasks.generate_proposal import generate_proposal
from tasks.fetch_crypto_data import fetch_crypto_data

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s")
logger = logging.getLogger(__name__)

class TaskOrchestratorAsync:
    def __init__(self):
        self.task_queue = asyncio.Queue()
        self.running = True  # Flag for graceful shutdown

    async def add_task(self, task_type, payload):
        task = {"type": task_type, "payload": payload}
        await self.task_queue.put(task)
        logger.info(f"Task added: {task}")

    async def process_task(self, task):
        try:
            logger.info(f"Executing task: {task}")
            task_type = task["type"]
            payload = task["payload"]

            if task_type == "generate_proposal":
                await generate_proposal(payload)
            elif task_type == "fetch_crypto_data":
                await fetch_crypto_data(payload)
            else:
                logger.warning(f"Unknown task type: {task_type}")
        except Exception as e:
            logger.error(f"Error executing task {task}: {e}")
        finally:
            self.task_queue.task_done()

    async def run(self):
        while self.running or not self.task_queue.empty():
            try:
                task = await asyncio.wait_for(self.task_queue.get(), timeout=1)
                await self.process_task(task)
            except asyncio.TimeoutError:
                continue

    async def shutdown(self):
        logger.info("Shutting down Task Orchestrator...")
        self.running = False
        await self.task_queue.join()  # Ensure all tasks are completed
        logger.info("Task Orchestrator has shut down.")

async def main():
    orchestrator = TaskOrchestratorAsync()

    # Add example tasks
    await orchestrator.add_task("generate_proposal", {"title": "AI Budget Allocation"})
    await orchestrator.add_task("fetch_crypto_data", {"symbol": "BTC"})

    # Run orchestrator in the background
    orchestrator_task = asyncio.create_task(orchestrator.run())

    # Simulate orchestrator running for 5 seconds
    await asyncio.sleep(5)

    # Shutdown orchestrator
    await orchestrator.shutdown()

    # Wait for orchestrator task to finish
    await orchestrator_task

if __name__ == "__main__":
    asyncio.run(main())
EOF

echo "Updated project structure with improved error handling, graceful shutdown, and logging created successfully."
