from .agents.data_agent import DataAgent
from .agents.proposal_agent import ProposalAgent
import asyncio
import logging
import traceback

logger = logging.getLogger(__name__)

class TaskOrchestratorAsync:
    def __init__(self):
        logger.info("Initializing TaskOrchestratorAsync")
        self.task_queue = asyncio.Queue()
        self.task_results = {}
        self.agents = {
            "data": DataAgent("DataAgent"),
            "proposal": ProposalAgent("ProposalAgent"),
        }
        self.running = True  # Flag to control the loop

    async def add_task(self, agent_type, payload):
        try:
            task_id = len(self.task_results) + 1
            task = {"id": task_id, "agent": agent_type, "payload": payload}
            await self.task_queue.put(task)
            logger.info(f"Task added: {task}")
            self.task_results[task_id] = {"status": "pending"}
        except Exception as e:
            logger.error(f"Failed to add task: {e}")
            logger.debug(traceback.format_exc())

    async def run(self):
        logger.info("TaskOrchestratorAsync is starting")
        while self.running:
            try:
                # Use asyncio timeout to allow graceful shutdown
                task = await asyncio.wait_for(self.task_queue.get(), timeout=1.0)
            except asyncio.TimeoutError:
                continue  # Check running flag again after timeout
            except Exception as e:
                logger.error(f"Error retrieving task from queue: {e}")
                logger.debug(traceback.format_exc())
                continue

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
                    logger.info(f"Task {task_id} completed successfully")
                except Exception as e:
                    logger.error(f"Task {task_id} failed: {e}")
                    self.task_results[task_id]["status"] = f"failed: {e}"
                    logger.error(f"Error executing task {task_id}: {e}")
                    logger.debug(traceback.format_exc())

                self.task_queue.task_done()
            except asyncio.CancelledError:
                logger.info("TaskOrchestratorAsync.run cancelled. Exiting gracefully.")
            finally:
                logger.info("TaskOrchestratorAsync has stopped.")

    async def shutdown(self):
        self.running = False  # Stop the loop
        logger.info("Shutting down TaskOrchestratorAsync")
        await self.task_queue.join()  # Wait for all tasks to be processed
        logger.info("All tasks have been processed")

main = TaskOrchestratorAsync()
