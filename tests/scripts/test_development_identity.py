import copy
import json
import unittest
from collections import Counter
from unittest.mock import patch

from scripts.development_identity import ROOT, build, digest, generator


class DevelopmentIdentityTests(unittest.TestCase):
    def test_current_identity_matches_candidate_without_claiming_publication(self):
        current = build()
        candidate = json.loads((ROOT / "spec/release-manifest.json").read_text())
        self.assertEqual(current["status"], "development-not-published")
        self.assertIsNone(current["publication"])
        self.assertEqual(current["identity"]["release"], "0.59.0")
        self.assertEqual(
            current["identity"]["encoding_abi"],
            "pto-isa-0.59.0-mode-function-v1",
        )
        self.assertEqual(
            current["identity"]["encoding_projection_sha256"],
            candidate["encoding_projection_sha256"],
        )
        self.assertEqual(current["catalog_counts"], {
            "scalar_forms": 473, "command_forms": 105,
            "tile_operations": 119, "reservations": 50,
        })

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
