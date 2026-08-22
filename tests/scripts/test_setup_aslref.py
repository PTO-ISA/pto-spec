from __future__ import annotations

import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SETUP = ROOT / "scripts/setup-aslref"


class SetupAslrefContractTest(unittest.TestCase):
    def test_hosted_build_dependencies_are_exactly_pinned(self) -> None:
        source = SETUP.read_text(encoding="utf-8")
        for assignment in (
            "readonly dune_version=3.21.1",
            "readonly menhir_version=20250912",
            "readonly ocamlfind_version=1.9.8",
            "readonly zarith_version=1.14",
        ):
            self.assertIn(assignment, source)

        self.assertIn('"dune.$dune_version"', source)
        self.assertIn('"menhir.$menhir_version"', source)
        self.assertIn('"ocamlfind.$ocamlfind_version"', source)
        self.assertIn('"zarith.$zarith_version"', source)
        self.assertNotIn("opam install --yes dune menhir zarith", source)

    def test_installed_versions_are_checked_before_build(self) -> None:
        source = SETUP.read_text(encoding="utf-8")
        prepare_offset = source.index('"$repo_root/scripts/prepare-aslref"')
        for package in ("dune", "menhir", "ocamlfind", "zarith"):
            check = (
                "opam list --installed --short --columns=package "
                f"{package}"
            )
            self.assertIn(check, source)
            self.assertLess(source.index(check), prepare_offset)


if __name__ == "__main__":
    unittest.main()
