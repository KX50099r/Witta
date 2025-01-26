from .agents.data_agent import DataAgent
from .agents.proposal_agent import ProposalAgent
import asyncio
import logging
import traceback

logger = logging.getLogger(__name__)

"""
Task Orchestrator Module

This module defines the TaskOrchestratorAsync class, which manages the execution of tasks using different agents.
"""

class TaskOrchestratorAsync:
    """
    Asynchronous Task Orchestrator

    This class manages a queue of tasks and executes them using specified agents.
    """
    def __init__(self):
        """
        Initialize the TaskOrchestratorAsync.

        Sets up the task queue, task results, and available agents.
        """
        logger.debug("Initializing TaskOrchestratorAsync")
        self.task_queue = asyncio.Queue()
        self.task_results = {}
        self.agents = {
            "data": DataAgent("DataAgent"),
            "proposal": ProposalAgent("ProposalAgent"),
        }
        self.running = True  # Flag to control the loop

    async def add_task(self, agent_type, payload):
        """
        Add a task to the orchestrator.

        Args:
            agent_type (str): The type of agent to execute the task.
            payload (dict): The data payload for the task.

        Raises:
            ValueError: If the input types are invalid or the task ID already exists.
        """
        """
        Add a task to the orchestrator.

        Args:
            agent_type (str): The type of agent to execute the task.
            payload (dict): The data payload for the task.

        Raises:
            ValueError: If the input types are invalid or the task ID already exists.
        """
        try:
            if not isinstance(agent_type, str):
                raise ValueError("Invalid input type: 'agent_type' must be a string")
            if not isinstance(payload, dict):
                raise ValueError("Invalid input type: 'payload' must be a dictionary")

            task_id = len(self.task_results) + 1
            if task_id in self.task_results:
                raise ValueError(f"Task ID {task_id} already exists")
            task = {"id": task_id, "agent": agent_type, "payload": payload}
            await self.task_queue.put(task)
            logger.debug(f"Task added: {task}")
            self.task_results[task_id] = {"status": "pending"}
        except ValueError as e:
            logger.error(f"ValueError while adding task: {e}")
            logger.debug(traceback.format_exc())
            raise
        except Exception as e:
            logger.error(f"Unexpected error while adding task: {e}")
            logger.debug(traceback.format_exc())
            raise

    async def run(self):
        """
        Run the task orchestrator.

        Continuously processes tasks from the queue and executes them using the appropriate agents.
        """
        """
        Run the task orchestrator.

        Continuously processes tasks from the queue and executes them using the appropriate agents.
        """
        logger.info("TaskOrchestratorAsync is starting the run loop")
        logger.info("TaskOrchestratorAsync is starting the run loop")
        while self.running:
            await asyncio.sleep(0)  # Yield control to the event loop
            try:
                # Use asyncio timeout to allow graceful shutdown
                logger.info("Waiting for the next task")
                tasks = []
                while not self.task_queue.empty() and len(tasks) < 5:  # Process up to 5 tasks at once
                    tasks.append(await self.task_queue.get())
                if not tasks:
                    continue
                logger.info(f"Retrieved tasks: {tasks}")
            except asyncio.TimeoutError:
                continue  # Check running flag again after timeout
            except Exception as e:
                logger.error(f"Error retrieving task from queue: {e}")
                logger.debug(traceback.format_exc())
                continue

                for task in tasks:
                    logger.info(f"Executing task: {task}")

                    task_id = task["id"]
                    agent_type = task["agent"]
                    payload = task["payload"]

                    retries = 3
                    for attempt in range(retries):
                        try:
                            agent = self.agents.get(agent_type)
                            if not agent:
                                raise Exception(f"Unknown agent type: {agent_type}")

                            logger.debug(f"Executing task {task_id} with agent {agent_type}, attempt {attempt + 1}")
                            await agent.execute(payload)
                            logger.debug(f"Execution of task {task_id} completed")
                            if self.task_results[task_id]["status"] == "pending":
                                self.task_results[task_id]["status"] = "completed"
                                logger.info(f"Task {task_id} status updated to completed")
                            logger.info(f"Task {task_id} completed successfully")
                            break
                        except Exception as e:
                            logger.error(f"Task {task_id} failed on attempt {attempt + 1}: {e}")
                            logger.debug(traceback.format_exc())
                            if attempt == retries - 1:
                                self.task_results[task_id]["status"] = f"failed: {e}"
                                logger.error(f"Task {task_id} failed after {retries} attempts")
                            else:
                                logger.info(f"Retrying task {task_id} (attempt {attempt + 2})")

                    self.task_queue.task_done()
            except asyncio.CancelledError:
                logger.info("TaskOrchestratorAsync.run cancelled. Exiting gracefully.")
            finally:
                logger.info("TaskOrchestratorAsync has stopped.")

    async def shutdown(self):
        """
        Shutdown the task orchestrator.

        Stops the task processing loop and waits for all tasks to be processed.
        """
        """
        Shutdown the task orchestrator.

        Stops the task processing loop and waits for all tasks to be processed.
        """
        self.running = False  # Stop the loop
        logger.debug("Initiating shutdown of TaskOrchestratorAsync")
        await self.task_queue.join()  # Wait for all tasks to be processed
        logger.info("All tasks have been processed")

main = TaskOrchestratorAsync()
