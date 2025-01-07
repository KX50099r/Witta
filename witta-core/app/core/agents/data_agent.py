from .base_agent import BaseAgent
from ..tasks.fetch_crypto_data import fetch_crypto_data

class DataAgent(BaseAgent):
    async def execute(self, payload):
        # Perform specific tasks related to data
        await fetch_crypto_data(payload)
