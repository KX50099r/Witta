import sys
from pathlib import Path

# Add witta-core to the Python path
sys.path.append(str(Path.cwd() / "witta-core"))

# Print sys.path for debugging
print("\n".join(sys.path))

from app.core.orchestrator import main as orchestrator_main
