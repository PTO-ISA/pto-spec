from __future__ import annotations

from collections import Counter
import copy
import json
from pathlib import Path
import re
import runpy
import subprocess
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
GENERATOR = ROOT / "scripts/generate-tile-macro-assembly"
CATALOG = ROOT / "spec/catalog/tile-macro-assembly.json"
TILE_OPERATIONS = ROOT / "spec/catalog/tile-operations.json"
REFERENCE = ROOT / "docs/virtual-isa/tileop-macro-assembly.md"


class TileMacroAssemblyTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
        cls.operations = cls.catalog["operations"]
        cls.by_name = {operation["mnemonic"]: operation for operation in cls.operations}
        cls.generator = runpy.run_path(str(GENERATOR))

    def test_generator_outputs_are_current(self) -> None:
        result = subprocess.run(
            [sys.executable, str(GENERATOR), "--check"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_catalog_matches_the_current_direct_operation_inventory(self) -> None:
        inventory = json.loads(TILE_OPERATIONS.read_text(encoding="utf-8"))
        expected = {
            operation["name"]: operation["engine"]
            for operation in inventory["operations"]
        }
        actual = {
            operation["mnemonic"]: operation["engine"]
            for operation in self.operations
        }
        self.assertEqual(inventory["operation_count"], 117)
        self.assertEqual(actual, expected)
        self.assertEqual(
            Counter(actual.values()),
            {"VEC": 31, "SFU": 46, "TLSU": 28, "CUBE": 12},
        )
        self.assertEqual(
            self.catalog["summary"], {"operation_count": 117, "form_count": 141}
        )

    def test_every_macro_instruction_is_exactly_one_line(self) -> None:
        self.assertEqual(
            self.catalog["line_grammar"],
            {
                "instruction_lines": 1,
                "newline_terminates_instruction": True,
                "continuations_allowed": False,
                "canonical_output_wraps": False,
            },
        )
        for operation in self.operations:
            for form in operation["forms"]:
                macro = form["macro_format"]
                self.assertNotIn("\n", macro, operation["mnemonic"])
                self.assertNotIn("\r", macro, operation["mnemonic"])
                self.assertTrue(macro.startswith(form["spelling"]), macro)

    def test_macro_formats_do_not_leak_physical_bundle_commands(self) -> None:
        forbidden = ("BSTART", "BSTOP", "B.I", ".reuse", "completion boundary")
        for operation in self.operations:
            for form in operation["forms"]:
                for fragment in forbidden:
                    self.assertNotIn(fragment, form["macro_format"], operation["mnemonic"])

    def test_every_format_records_its_derivation_and_boundaries(self) -> None:
        expected_source = (
            "PTO-TILEOP-MACRO owner record in "
            "PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION"
        )
        for operation in self.operations:
            self.assertEqual(operation["format_source"], expected_source)
            self.assertEqual(
                operation["commit_boundaries"],
                ["explicit BSTOP", "next BSTART"],
            )
            bundle = " ".join(operation["physical_bundle"])
            if "B.IOT" in bundle or "B.IOS" in bundle:
                self.assertTrue(
                    all("PEMask" in form["macro_format"] for form in operation["forms"]),
                    operation["mnemonic"],
                )

    def test_exact_forms_are_owned_in_asl_not_the_generator(self) -> None:
        owner = (
            ROOT / "asl/arch/overview/instruction-classification.asl"
        ).read_text(encoding="utf-8")
        self.assertEqual(owner.count("// PTO-TILEOP-MACRO: "), 117)
        self.assertIn("are the sole owners of canonical", owner)
        definitions = self.generator["load_macro_form_definitions"]()
        for definition in definitions.values():
            for form in definition["forms"]:
                self.assertTrue(form["configuration_bindings"])
                self.assertTrue(form["operand_bindings"])
        generator = GENERATOR.read_text(encoding="utf-8")
        self.assertNotIn("FORMAT_OVERRIDES", generator)
        self.assertNotIn("FORMAT_VARIANTS", generator)
        self.assertNotIn("def config_fields", generator)

    def test_every_form_has_a_complete_physical_plan(self) -> None:
        form_ids = set()
        for operation in self.operations:
            fixture_ids = set(operation["physical_schema"]["fixture_case_ids"])
            for form in operation["forms"]:
                expansion = form["expansion"]
                self.assertNotIn(expansion["form_id"], form_ids)
                form_ids.add(expansion["form_id"])
                self.assertEqual(
                    len(expansion["configuration_bindings"]),
                    len(form["configuration"]),
                )
                self.assertEqual(
                    len(expansion["operand_bindings"]),
                    len(form["sources"]) + len(form["destinations"]),
                )
                self.assertEqual(
                    len(expansion["argument_bindings"]),
                    len(operation["physical_schema"]["arguments"]),
                )
                self.assertEqual(
                    expansion["fold"]["policy"],
                    "unique-exact-match-or-physical",
                )
                self.assertTrue(expansion["fold"]["requires_complete_boundary"])
                self.assertTrue(expansion["operand_commands"])
                for binding in expansion["operand_bindings"]:
                    self.assertTrue(binding["members"])
                    for member in binding["members"]:
                        for modifier in member["eligible_modifiers"]:
                            self.assertIn(binding["command"], {"B.IOT", "B.IOS"})
                            self.assertIn(modifier["evidence_case"], fixture_ids)
                            self.assertEqual(
                                modifier["modifier"],
                                "B.ASSEMBLE INIT_LAST"
                                if member["physical_role"].startswith("destination")
                                else "B.SUBVIEW",
                            )

    def test_grouped_bindings_expand_to_ordered_physical_members(self) -> None:
        tload = self.by_name["TLOAD"]["forms"][0]
        address_group = next(
            binding
            for binding in tload["expansion"]["operand_bindings"]
            if binding["field"] == "macro_source0"
        )
        self.assertEqual(address_group["command"], "B.IOR")
        self.assertEqual(
            [
                (
                    member["physical_role"],
                    member["slot"],
                    member["optional"],
                    member["default"],
                )
                for member in address_group["members"]
            ],
            [
                ("address", "RegSrc0", True, "zero"),
                ("scalar0", "RegSrc1", True, None),
            ],
        )
        shared_right = next(
            form
            for form in self.by_name["TMATMUL_MX"]["forms"]
            if form["spelling"] == "TMATMUL_MX.SHARED_RIGHT"
        )
        right_group = next(
            binding
            for binding in shared_right["expansion"]["operand_bindings"]
            if binding["field"] == "SharedRightGroup"
        )
        self.assertEqual(right_group["command"], "B.IOS")
        self.assertEqual(
            [member["physical_role"] for member in right_group["members"]],
            ["source2", "source3"],
        )
        self.assertTrue(
            all(not member["eligible_modifiers"] for member in right_group["members"])
        )

    def test_cube_and_gpr_variants_map_to_exact_physical_roles(self) -> None:
        for mnemonic in ("TLOAD", "TSTORE"):
            cube = next(
                form
                for form in self.by_name[mnemonic]["forms"]
                if form["spelling"].endswith(".CUBE")
            )
            targets = {
                item["field"]: item["targets"]
                for item in cube["expansion"]["configuration_bindings"]
            }
            self.assertEqual(targets["DTYPE_NONE"][0]["command"], f"BSTART.{mnemonic}")
            self.assertEqual(
                (targets["CubeLayout"][0]["command"], targets["CubeLayout"][0]["slot"]),
                ("B.DATR", "Layout"),
            )
            self.assertEqual(
                (targets["PadValue"][0]["command"], targets["PadValue"][0]["slot"]),
                ("B.DATR", "PadValueOrByteId"),
            )

        tsel_gpr = self.by_name["TSEL"]["forms"][2]["expansion"]["operand_bindings"]
        physical_roles = {
            binding["field"]: [member["physical_role"] for member in binding["members"]]
            for binding in tsel_gpr
        }
        self.assertEqual(physical_roles["PredicateGPR0"], ["source0"])
        self.assertEqual(physical_roles["PredicateGPR1"], ["source0"])
        self.assertEqual(physical_roles["SrcTile1"], ["source1"])
        self.assertEqual(physical_roles["SrcTile2"], ["source2"])
        for field in ("SrcTile1", "SrcTile2"):
            member = next(
                binding for binding in tsel_gpr if binding["field"] == field
            )["members"][0]
            self.assertEqual(member["eligible_modifiers"][0]["modifier"], "B.SUBVIEW")

    def test_range_modifiers_are_attached_to_exact_bindings(self) -> None:
        local_load, shared_load, cube_load = self.by_name["TLOAD"]["forms"]

        def member(form: dict[str, object], role: str) -> tuple[dict, dict]:
            for binding in form["expansion"]["operand_bindings"]:
                for candidate in binding["members"]:
                    if candidate["physical_role"] == role:
                        return binding, candidate
            self.fail(f"missing physical role {role}")

        local_binding, local_destination = member(local_load, "destination0")
        shared_binding, shared_destination = member(shared_load, "destination0")
        cube_binding, _ = member(cube_load, "destination0")
        self.assertEqual(
            local_destination["eligible_modifiers"][0]["modifier"],
            "B.ASSEMBLE INIT_LAST",
        )
        self.assertEqual(local_binding["command"], "B.IOT")
        self.assertEqual(shared_binding["command"], "B.IOS")
        self.assertEqual(
            shared_destination["eligible_modifiers"][0]["modifier"],
            "B.ASSEMBLE INIT_LAST",
        )
        self.assertEqual(cube_binding["command"], "B.IOT")
        shared_store = self.by_name["TSTORE"]["forms"][1]
        shared_store_binding, shared_store_source = member(shared_store, "source0")
        self.assertEqual(shared_store_binding["command"], "B.IOS")
        self.assertEqual(
            shared_store_source["eligible_modifiers"][0]["modifier"],
            "B.SUBVIEW",
        )

    def test_catalog_validation_fails_closed(self) -> None:
        validate = self.generator["validate_catalog"]

        def mutation(path: tuple[object, ...], value: object) -> dict[str, object]:
            catalog = copy.deepcopy(self.catalog)
            current: object = catalog
            for key in path[:-1]:
                current = current[key]  # type: ignore[index]
            current[path[-1]] = value  # type: ignore[index]
            return catalog

        tadd_index = next(
            index
            for index, operation in enumerate(self.operations)
            if operation["mnemonic"] == "TADD"
        )
        tload_index = next(
            index
            for index, operation in enumerate(self.operations)
            if operation["mnemonic"] == "TLOAD"
        )
        tadd = ("operations", tadd_index, "forms", 0, "expansion")
        invalid_catalogs = {
            "unencodable destination generation": mutation(
                ("destination_forms", 0, "concrete_example"), "->T#3<2KB>"
            ),
            "line break": mutation(
                ("operations", tadd_index, "forms", 0, "macro_format"),
                self.by_name["TADD"]["macro_format"] + "\nBSTOP",
            ),
            "stale form ID": mutation(tadd + ("form_id",), "pto0586-tadd-stale"),
            "configuration field": mutation(
                tadd + ("configuration_bindings", 0, "field"), "LB9"
            ),
            "configuration command": mutation(
                tadd + ("configuration_bindings", 0, "targets", 0, "command"),
                "BSTART.VEC",
            ),
            "header command": mutation(
                tadd + ("header", "command"), "BSTART.SFU"
            ),
            "operand syntax": mutation(
                tadd + ("operand_bindings", 0, "syntax"), "WrongTile"
            ),
            "operand physical role": mutation(
                tadd
                + ("operand_bindings", 0, "members", 0, "physical_role"),
                "source9",
            ),
            "argument binding": mutation(
                tadd + ("argument_bindings", 0, "physical_role"),
                "destination9",
            ),
            "command order": mutation(tadd + ("command_order",), ["header", "boundary"]),
            "incomplete mapping": mutation(tadd + ("operand_bindings",), []),
            "missing boundary": mutation(
                tadd + ("boundary",), {"accepted": ["explicit BSTOP"]}
            ),
            "fold policy": mutation(
                tadd + ("fold",),
                {"policy": "guess", "requires_complete_boundary": False},
            ),
            "fold signature": mutation(
                tadd + ("fold_signature_sha256",), "0" * 64
            ),
            "modifier summary": mutation(tadd + ("modifier_bindings",), []),
            "physical schema": mutation(
                ("operations", tadd_index, "physical_schema", "command_mnemonic"),
                "BSTART.WRONG",
            ),
        }
        missing_shared_modifier = copy.deepcopy(self.catalog)
        shared_destination = next(
            binding
            for binding in missing_shared_modifier["operations"][tload_index]["forms"][1][
                "expansion"
            ]["operand_bindings"]
            if binding["role_kind"] == "destination"
        )
        shared_destination["members"][0]["eligible_modifiers"] = []
        invalid_catalogs["missing Shared modifier"] = missing_shared_modifier
        for label, catalog in invalid_catalogs.items():
            with self.subTest(label=label), self.assertRaises(ValueError):
                validate(catalog)

    def test_representative_current_formats(self) -> None:
        self.assertEqual(
            self.by_name["TADD"]["macro_format"],
            "TADD <LB0:ValidCol, LB1:ValidRow?, LB2:Col?, DataType, "
            "PadValue?, PEMask>, SrcTile0, SrcTile1, ->DstTile<Size>",
        )
        self.assertIn("[BaseGPR=zero, RowStrideGPR?]", self.by_name["TLOAD"]["macro_format"])
        self.assertIn("FPAttrs", self.by_name["TMATMUL"]["macro_format"])
        self.assertIn("->DstTile<Size>", self.by_name["MGATHER_ADD"]["macro_format"])
        self.assertNotIn("->", self.by_name["MSCATTER_ADD"]["macro_format"])
        self.assertIn("ScalarGPR0", self.by_name["TPACK"]["macro_format"])
        self.assertIn(
            "ScalarGPR0, ScalarGPR1, ScalarGPR2, ScalarGPR3",
            self.by_name["TGPR2T"]["macro_format"],
        )
        self.assertNotIn("SrcTile0", self.by_name["TGPR2T"]["macro_format"])

    def test_compare_and_select_carrier_variants_are_explicit(self) -> None:
        for mnemonic in ("TCMP", "TCMPS", "TSEL", "TSELS"):
            forms = self.by_name[mnemonic]["forms"]
            self.assertEqual(len(forms), 3, mnemonic)
            first, second, gpr = (form["expansion"] for form in forms)
            self.assertEqual(
                first["fold_signature_sha256"], second["fold_signature_sha256"]
            )
            for expansion in (first, second):
                self.assertFalse(expansion["fold"]["unique_without_runtime_state"])
                self.assertEqual(
                    expansion["fold"]["on_ambiguity"], "retain physical assembly"
                )
            self.assertTrue(gpr["fold"]["unique_without_runtime_state"])

        tcmp_kinds = [
            form["destinations"][0]["binding_kind"]
            for form in self.by_name["TCMP"]["forms"]
        ]
        self.assertEqual(
            tcmp_kinds,
            [
                "predicate-tile-destination",
                "predicate-cell-destination",
                "predicate-gpr-destination",
            ],
        )
        tsel_gpr = self.by_name["TSEL"]["forms"][2]
        predicate_sources = [
            source for source in tsel_gpr["sources"]
            if source["binding_kind"] == "predicate-gpr-source"
        ]
        self.assertEqual(len(predicate_sources), 2)
        self.assertEqual(predicate_sources[1]["condition"], "DataType=U8")

    def test_transport_and_cube_variants_follow_current_0586_contract(self) -> None:
        self.assertEqual(
            [form["spelling"] for form in self.by_name["TLOAD"]["forms"]],
            ["TLOAD", "TLOAD.SHARED", "TLOAD.CUBE"],
        )
        self.assertEqual(
            [form["spelling"] for form in self.by_name["TSTORE"]["forms"]],
            ["TSTORE", "TSTORE.SHARED", "TSTORE.CUBE"],
        )
        shared_store_mask = next(
            field for field in self.by_name["TSTORE"]["forms"][1]["configuration"]
            if field["field"] == "PEMask"
        )
        self.assertIsNone(shared_store_mask["constraint"])
        self.assertEqual(
            [form["spelling"] for form in self.by_name["TMATMUL"]["forms"]],
            ["TMATMUL", "TMATMUL.SHARED_RIGHT", "TMATMUL.SHARED_BOTH"],
        )
        shared_matmul_mask = next(
            field for field in self.by_name["TMATMUL"]["forms"][1]["configuration"]
            if field["field"] == "PEMask"
        )
        self.assertEqual(shared_matmul_mask["constraint"], "1111")

    def test_structured_fields_are_complete(self) -> None:
        keys = {
            "field", "syntax", "role", "binding_kind", "ordinal", "optional",
            "default", "condition", "constraint", "size", "configuration_kind",
            "value_style",
        }
        for operation in self.operations:
            for form in operation["forms"]:
                for field in form["configuration"]:
                    self.assertEqual(set(field), keys)
                    self.assertEqual(field["binding_kind"], "bundle-configuration")
                for source in form["sources"]:
                    self.assertEqual(set(source), keys)
                    self.assertFalse(source["syntax"].startswith("->"))
                for destination in form["destinations"]:
                    self.assertEqual(set(destination), keys)
                    self.assertTrue(destination["syntax"].startswith("->"))

        row_scale = next(
            source for source in self.by_name["TMATMUL_MX"]["forms"][0]["sources"]
            if source["field"] == "RowScaleTile"
        )
        self.assertEqual(row_scale["condition"], "AType requires MX scale")
        row_max = next(
            destination for destination in self.by_name["TMATMUL"]["forms"][0]["destinations"]
            if destination["field"] == "RowMaxOut"
        )
        self.assertEqual((row_max["condition"], row_max["size"]), ("RowMaxEn", "Size"))

    def test_destination_grammar_matches_current_carriers(self) -> None:
        forms = {entry["kind"]: entry for entry in self.catalog["destination_forms"]}
        self.assertEqual(
            set(forms),
            {
                "tile",
                "shared-tile",
                "scalar",
                "predicate-tile",
                "predicate-cell",
                "predicate-gpr",
            },
        )
        for kind in ("tile", "predicate-tile", "predicate-cell"):
            form = forms[kind]
            match = re.fullmatch(r"->([TUMN])<[^<>]+>", form["concrete_example"])
            self.assertIsNotNone(match, kind)
            self.assertEqual(form["physical_binding"], "B.IOT.DstTile")
            self.assertEqual(form["resulting_generation"], f"{match.group(1)}#1")
        shared_match = re.fullmatch(
            r"->S([0-9]|[1-5][0-9]|6[0-3])<[^<>]+>",
            forms["shared-tile"]["concrete_example"],
        )
        self.assertIsNotNone(shared_match)
        self.assertEqual(
            forms["shared-tile"]["physical_binding"], "B.IOS.SharedTileID"
        )
        self.assertEqual(forms["scalar"]["concrete_example"], "->a0")
        self.assertEqual(forms["scalar"]["physical_binding"], "B.IOR.RegDst")
        self.assertEqual(forms["predicate-tile"]["syntax"], "->PredicateTile<Size>")
        self.assertEqual(forms["predicate-cell"]["syntax"], "->PredicateCell<Size>")
        self.assertEqual(forms["predicate-gpr"]["syntax"], "->PredicateGPR")
        self.assertEqual(forms["predicate-gpr"]["concrete_example"], "->a0")
        self.assertEqual(forms["predicate-gpr"]["physical_binding"], "B.IOR.RegDst")
        self.assertNotIn("predicate-register", forms)

    def test_reference_is_0586_and_uses_one_line_examples(self) -> None:
        reference = REFERENCE.read_text(encoding="utf-8")
        self.assertIn("all 117 current direct Tile operations", reference)
        self.assertIn("exactly one source line", reference)
        self.assertIn("`FP32`, not `DataType:FP32`", reference)
        self.assertIn("`->PredicateCell<Size>`", reference)
        self.assertIn("`->PredicateGPR`", reference)
        self.assertIn(
            "TADD <LB0:100, LB1:a0, LB2:a1+10, FP32, Null, 1111>, T#1, T#2, ->T<2KB>",
            reference,
        )
        self.assertNotIn("canonical 0.59", reference)
        self.assertNotIn("requires an accepted 0.59", reference)


if __name__ == "__main__":
    unittest.main()
