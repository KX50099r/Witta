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

# Create an instance of the orchestrator
main = TaskOrchestratorAsync()
