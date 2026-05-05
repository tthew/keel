import importlib.util
from pathlib import Path

_SOURCE = Path(__file__).resolve().parent.parent / "bootstrap-bmad-agents.py"
_spec = importlib.util.spec_from_file_location("bootstrap_bmad_agents", _SOURCE)
module = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(module)


def test_module_loads_with_constants():
    assert "Edit" in module.EXECUTION_TOOLS
    assert "Read" in module.ADVISORY_TOOLS
