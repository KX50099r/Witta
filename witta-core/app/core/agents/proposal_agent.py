from .base_agent import BaseAgent
from ..tasks.generate_proposal import generate_proposal

class ProposalAgent(BaseAgent):
    async def execute(self, payload):
        # Perform specific tasks related to proposals
        await generate_proposal(payload)
