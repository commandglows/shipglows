#!/usr/bin/env python3
"""Scenario-first tests for the registry-owned skill activation graph."""

from copy import deepcopy
import json
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from tools.skill_invocation_check import check, validate_activation_graph


ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "skills" / "references" / "skill-invocation-registry.json"


class SkillActivationGraphTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.registry = json.loads(REGISTRY.read_text(encoding="utf-8"))

    def test_canonical_graph_owns_every_expert(self) -> None:
        graph = validate_activation_graph(self.registry)
        self.assertEqual("valid", graph["status"], graph["errors"])
        self.assertEqual(14, graph["public_skills"])
        self.assertEqual(52, graph["expert_skills"])
        self.assertEqual(52, graph["owned_experts"])
        for engine in ("306-sg-scaffold", "407-sg-translate", "707-name", "708-sg-auto", "emailing"):
            self.assertIn(engine, graph["owners"])

    def test_missing_engine_blocks_graph_and_invocation(self) -> None:
        with TemporaryDirectory() as temporary:
            root = Path(temporary)
            skills = root / "skills"
            skills.mkdir()
            for name in ("sg-alpha", "engine-alpha"):
                folder = skills / name
                folder.mkdir()
                (folder / "SKILL.md").write_text(f"---\nname: {name}\ndescription: test\n---\n", encoding="utf-8")
            registry = {
                "public_catalog": {
                    "domains": [{"id": "x", "skills": [{
                        "id": "sg-alpha", "public_skill": "sg-alpha",
                        "runtime_skill": "engine-alpha", "modes": ["default"],
                        "internal_engines": ["missing-engine"],
                    }]}]
                },
                "internal_catalog": {"require_owned_expert_coverage": True},
                "rules": {},
            }
            graph = validate_activation_graph(registry, skills)
            self.assertEqual("invalid", graph["status"])
            self.assertIn("missing_engine:sg-alpha.internal_engines:missing-engine", graph["errors"])

            registry_path = root / "registry.json"
            registry_path.write_text(json.dumps(registry), encoding="utf-8")
            index_path = root / "index.md"
            index_path.write_text("", encoding="utf-8")
            payload = check("sg-alpha", index_path, registry_path, skills)
            self.assertEqual("activation_graph_invalid", payload["error"])

    def test_unowned_expert_is_visible(self) -> None:
        registry = deepcopy(self.registry)
        content = next(
            entry
            for domain in registry["public_catalog"]["domains"]
            for entry in domain["skills"]
            if entry["id"] == "sg-content"
        )
        content["internal_engines"].remove("407-sg-translate")
        graph = validate_activation_graph(registry)
        self.assertIn("unowned_expert:407-sg-translate", graph["errors"])

    def test_alias_engine_must_belong_to_its_owner(self) -> None:
        registry = deepcopy(self.registry)
        registry["codex_expert_aliases"]["spec"]["runtime_engine"] = "407-sg-translate"
        graph = validate_activation_graph(registry)
        self.assertIn(
            "alias_engine_not_owned:spec:sg-planning:407-sg-translate",
            graph["errors"],
        )

    def test_public_mode_route_must_be_declared_and_resolve_to_an_engine(self) -> None:
        registry = deepcopy(self.registry)
        router = registry["public_catalog"]["router"]
        router["mode_routes"]["surprise"] = {"runtime_engine": "missing-engine"}
        graph = validate_activation_graph(registry)
        self.assertIn("undeclared_public_mode_route:shipglows:surprise", graph["errors"])
        self.assertIn("missing_engine:shipglows.mode_routes.surprise:missing-engine", graph["errors"])

    def test_execution_tag_graph_fails_on_unknown_implication_or_mode_alias(self) -> None:
        registry = deepcopy(self.registry)
        registry["execution_tags"]["ci"]["implies"] = ["imaginary"]
        router = registry["public_catalog"]["router"]
        router["modes"].append("nolocal")
        graph = validate_activation_graph(registry)
        self.assertIn("unknown_execution_tag_implies:ci:imaginary", graph["errors"])
        self.assertIn("legacy_execution_alias_is_mode:shipglows:nolocal", graph["errors"])


if __name__ == "__main__":
    unittest.main()
