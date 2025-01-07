import logging

logger = logging.getLogger(__name__)

async def fetch_crypto_data(payload):
    logger.info(f"Fetching crypto data with payload: {payload}")
    # Simulated task logic
    await asyncio.sleep(1)
