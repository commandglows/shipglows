#!/usr/bin/env python3
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from cli.environment.versions import evaluate_version_constraint  # noqa: E402


assert evaluate_version_constraint("24.0.0", ">=24.0.0 <25") == "ready"
assert evaluate_version_constraint("24.99.0", ">=24.0.0 <25") == "ready"
assert evaluate_version_constraint("23.99.9", ">=24.0.0 <25") == "incompatible"
assert evaluate_version_constraint("25.0.0", ">=24.0.0 <25") == "incompatible"
assert evaluate_version_constraint("8.11.0", "8.11.0") == "ready"
assert evaluate_version_constraint("8.11.1", "8.11.0") == "incompatible"
assert evaluate_version_constraint("1.97.1", ">=1.88.0") == "ready"
assert evaluate_version_constraint("1.87.9", ">=1.88.0") == "incompatible"
assert evaluate_version_constraint("11.14.1", "*") == "ready"
assert evaluate_version_constraint("not-a-version", "*") == "unknown"
assert evaluate_version_constraint("24.0.0", "^24") == "unknown"
assert evaluate_version_constraint("24.0.0", "999") == "unknown"
assert evaluate_version_constraint("9" * 5000 + ".0.0", "*") == "unknown"
assert evaluate_version_constraint("24.0.0", ">=" + "9" * 5000) == "unknown"

print("ShipGlows supported version constraint contract: OK")
