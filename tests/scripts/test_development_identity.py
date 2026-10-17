import copy
import json
import unittest
from collections import Counter
from unittest.mock import patch

from scripts.development_identity import ROOT, build, digest, generator


class DevelopmentIdentityTests(unittest.TestCase):
    def test_current_identity_cannot_impersonate_publication(self):
        current = build()
        published = json.loads((ROOT / "spec/release-manifest.json").read_text())
        self.assertEqual(current["status"], "development-not-published")
        self.assertIsNone(current["publication"])
        self.assertNotEqual(current["identity"]["encoding_projection_sha256"], published["encoding_projection_sha256"])
        self.assertEqual(current["catalog_counts"], {
            "scalar_forms": 473, "command_forms": 105,
            "tile_operations": 119, "reservations": 50,
        })

    def test_frozen_release_guards_still_reject_development_inventory(self):
        module = generator(ROOT)
        tiles = module.load_json("spec/catalog/tile-operations.json")
        with self.assertRaisesRegex(SystemExit, "exactly 466"):
            module.encoding_projection(tiles)

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
