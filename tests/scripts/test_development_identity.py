import copy
import json
from collections import Counter
from pathlib import Path
import unittest
from unittest.mock import patch

from scripts.development_identity import ROOT, build, digest, generator


class DevelopmentIdentityTests(unittest.TestCase):
    def test_current_identity_matches_candidate_without_claiming_publication(self):
        current = build()
        tracked = json.loads((ROOT / "spec/development-manifest.json").read_text())
        self.assertEqual(current, tracked)
        self.assertEqual(current["status"], "development-not-published")
        self.assertIsNone(current["publication"])
        self.assertEqual(current["identity"]["release"], "0.59.0")
        self.assertEqual(
            current["identity"]["encoding_abi"],
            "pto-isa-0.59.0-mode-function-v1",
        )
        self.assertEqual(current["catalog_counts"], {
            "scalar_forms": 473, "command_forms": 105,
            "tile_operations": 119, "reservations": 50,
        })

    def test_historical_release_manifest_cannot_affect_development_identity(self):
        expected = build()
        historical = (ROOT / "spec/release-manifest.json").resolve()
        original_read_text = Path.read_text

        for value, unavailable in (
            ('{"encoding_projection_sha256":"mutated historical value"}', False),
            (None, True),
        ):
            reads = 0

            def controlled_read(path, *args, **kwargs):
                nonlocal reads
                if path.resolve() == historical:
                    reads += 1
                    if unavailable:
                        raise FileNotFoundError(path)
                    return value
                return original_read_text(path, *args, **kwargs)

            with self.subTest(unavailable=unavailable):
                with patch.object(
                    Path, "read_text", autospec=True, side_effect=controlled_read
                ):
                    self.assertEqual(build(), expected)
                self.assertEqual(
                    reads, 0, "development identity must not read publication state"
                )

    def test_release_guards_accept_only_the_reviewed_candidate_inventory(self):
        module = generator(ROOT)
        tiles = module.load_json("spec/catalog/tile-operations.json")
        projection = module.encoding_projection(tiles)
        self.assertEqual(len(projection["scalar_and_command_forms"]), 578)
        self.assertEqual(len(projection["extension_encoding_reservations"]), 50)
        self.assertEqual(len(projection["tile_operations"]), 119)

    def test_encoding_mutation_changes_development_identity(self):
        module = generator(ROOT)
        tiles = module.load_json("spec/catalog/tile-operations.json")
        scalar = module.load_json("spec/catalog/scalar-forms.json")
        commands = module.load_json("spec/catalog/command-forms.json")
        arguments = dict(form_counts={"scalar_forms": 473, "command_forms": 105},
                         command_family_counts=dict(Counter(x["semantic_family"] for x in commands["forms"])))
        before = digest(module.encoding_projection(tiles, **arguments))
        modified = copy.deepcopy(scalar)
        modified["forms"][0]["encoding"][0]["match"] = "0xffffffff"
        original = module.load_json
        with patch.object(module, "load_json", side_effect=lambda path: modified if path.endswith("scalar-forms.json") else original(path)):
            after = digest(module.encoding_projection(tiles, **arguments))
        self.assertNotEqual(before, after)


if __name__ == "__main__":
    unittest.main()
