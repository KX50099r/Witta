import pytest
from witta_core.app.core.orchestrator import TaskOrchestratorAsync
from unittest.mock import AsyncMock

@pytest.mark.asyncio
async def test_add_task():
    orchestrator = TaskOrchestratorAsync()
    await orchestrator.add_task("data", {"key": "value"})
    assert len(orchestrator.task_results) == 1
    assert orchestrator.task_results[1]["status"] == "pending"

@pytest.mark.asyncio
async def test_add_task_invalid_agent():
    orchestrator = TaskOrchestratorAsync()
    with pytest.raises(ValueError):
        await orchestrator.add_task("invalid_agent", {"key": "value"})

@pytest.mark.asyncio
async def test_run_task():
    orchestrator = TaskOrchestratorAsync()
    orchestrator.agents["data"] = AsyncMock()
    await orchestrator.add_task("data", {"key": "value"})
    await orchestrator.run()
    assert orchestrator.task_results[1]["status"] == "completed"

@pytest.mark.asyncio
async def test_run_task_failure():
    orchestrator = TaskOrchestratorAsync()
    orchestrator.agents["data"] = AsyncMock(side_effect=Exception("Execution failed"))
    await orchestrator.add_task("data", {"key": "value"})
    await orchestrator.run()
    assert "failed" in orchestrator.task_results[1]["status"]
