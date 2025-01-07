import logging

logger = logging.getLogger(__name__)

class BaseAgent:
    def __init__(self, name):
        self.name = name
        logger.info(f"Agent '{self.name}' initialized")

    async def execute(self, *args, **kwargs):
        raise NotImplementedError("Execute method must be implemented by subclasses")
