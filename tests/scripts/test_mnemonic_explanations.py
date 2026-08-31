from __future__ import annotations

import copy
import importlib.machinery
import json
import pathlib
import tempfile
import unittest
import zipfile


ROOT = pathlib.Path(__file__).resolve().parents[2]
CHECK = importlib.machinery.SourceFileLoader(
    "check_mnemonic_explanations",
    str(ROOT / "scripts/check-mnemonic-explanations"),
).load_module()
GENERATE = importlib.machinery.SourceFileLoader(
    "generate_mnemonic_description_inventory",
    str(ROOT / "scripts/generate-mnemonic-description-inventory"),
).load_module()


class MnemonicExplanationTests(unittest.TestCase):
    maxDiff = None

    def test_dynamic_page_predicate_and_frozen_archive_inventory(self):
        self.assertTrue(CHECK.is_page_path("nested/PAGE.HTML"))
        self.assertTrue(CHECK.is_page_path("README.md"))
        self.assertFalse(CHECK.is_page_path("page.html.css"))
        self.assertFalse(CHECK.is_page_path("directory"))
        with tempfile.TemporaryDirectory() as directory:
            archive = pathlib.Path(directory) / "anonymous.zip"
            with zipfile.ZipFile(archive, "w") as output:
                output.writestr("nested/PAGE.HTML", "page")
                output.writestr("README.md", "readme")
                output.writestr("asset.css", "css")
            with self.assertRaisesRegex(CHECK.CheckError, "archive digest mismatch"):
                CHECK.derive_archive(archive)

    def test_archive_resource_limits_reject_ratio_and_symlink_before_digest(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            ratio_archive = root / "ratio.zip"
            with zipfile.ZipFile(ratio_archive, "w", compression=zipfile.ZIP_DEFLATED) as output:
                output.writestr("page.html", b"0" * (1024 * 1024))
            with self.assertRaisesRegex(CHECK.CheckError, "compression ratio exceeds"):
                CHECK.derive_archive(ratio_archive)
            symlink_archive = root / "symlink.zip"
            link = zipfile.ZipInfo("page.html")
            link.external_attr = (0o120777 << 16)
            with zipfile.ZipFile(symlink_archive, "w") as output:
                output.writestr(link, "target")
            with self.assertRaisesRegex(CHECK.CheckError, "symlink entries"):
                CHECK.derive_archive(symlink_archive)

    def test_source_inventory_is_anonymous_and_defaults_to_rewrite(self):
        inventory = CHECK.read_json(
            ROOT / "spec/evidence/mnemonic-descriptions/sources/anonymous-source-001.json"
        )
        ids = CHECK.validate_source_inventory(inventory, None, None, False)
        self.assertEqual(len(ids), 697)
        self.assertEqual(inventory["default_copyright_disposition"], "current-owner-rewrite")
        public = json.dumps(inventory)
        self.assertNotIn("DavinciOO", public)
        self.assertNotIn("/Users/", public)
        self.assertEqual(
            len(CHECK.validate_source_inventory(inventory, None, None, True)), 697
        )

    def test_source_inventory_rejects_duplicates_unknown_fields_and_implicit_mapping(self):
        inventory = CHECK.read_json(
            ROOT / "spec/evidence/mnemonic-descriptions/sources/anonymous-source-001.json"
        )
        duplicate = copy.deepcopy(inventory)
        duplicate["pages"].append(copy.deepcopy(duplicate["pages"][0]))
        with self.assertRaisesRegex(CHECK.CheckError, "duplicate anonymous page ID"):
            CHECK.validate_source_inventory(duplicate, None, None, False)
        unknown = copy.deepcopy(inventory)
        unknown["raw_path"] = "forbidden"
        with self.assertRaisesRegex(CHECK.CheckError, "unknown fields"):
            CHECK.validate_source_inventory(unknown, None, None, False)
        implicit = copy.deepcopy(inventory)
        implicit["pages"][0]["mapping_basis"] = "filename-similarity"
        with self.assertRaisesRegex(CHECK.CheckError, "implicit filename mapping"):
            CHECK.validate_source_inventory(implicit, None, None, False)
        unauthorized = copy.deepcopy(inventory)
        unauthorized["authorization"]["licensed_copy_allowed"] = True
        with self.assertRaisesRegex(CHECK.CheckError, "durable authorization"):
            CHECK.validate_source_inventory(unauthorized, None, None, False)

    def test_supplementary_extraction_allows_generated_sections_after_end(self):
        markdown = (
            "# Unit\n<!-- SUPPLEMENTARY-BEGIN -->\nReader guide\n"
            "<!-- SUPPLEMENTARY-END -->\n## Assembly\n```asm\nunit\n```\n"
        )
        self.assertEqual(CHECK.supplementary_body(markdown), "Reader guide")

    def test_headings_are_claim_capable_nodes(self):
        _, nodes = CHECK.parse_reader_blocks(
            "<!-- PTO-READER-BLOCK: purpose role=purpose -->\n"
            "## Architectural rule\nThe current owner defines this rule."
        )
        self.assertEqual([node["kind"] for node in nodes], ["heading", "paragraph"])

    def test_commonmark_fence_close_requires_whitespace_only(self):
        marker = "<!-- PTO-READER-BLOCK: example role=example -->\n"
        with self.assertRaisesRegex(CHECK.CheckError, "unterminated reader-guide code fence"):
            CHECK.parse_reader_blocks(
                marker + "```text\ncode\n```not-a-commonmark-close\nfollowing prose"
            )
        _, nodes = CHECK.parse_reader_blocks(
            marker + "```text\ncode\n```not-a-commonmark-close\nfollowing prose\n```"
        )
        self.assertEqual(len(nodes), 1)
        self.assertIn("```not-a-commonmark-close", nodes[0]["text"])

    def test_inline_code_allows_asl_braces_but_prose_mdx_expression_fails(self):
        marker = "<!-- PTO-READER-BLOCK: mechanism role=mechanism -->\n"
        _, nodes = CHECK.parse_reader_blocks(marker + "Use `Zeros{5} + 2`.")
        self.assertEqual(nodes[0]["kind"], "paragraph")
        with self.assertRaisesRegex(CHECK.CheckError, "MDX expressions"):
            CHECK.parse_reader_blocks(marker + "Use {danger}.")

    def test_protected_literals_derive_from_renderable_nodes_without_marker_fragments(self):
        body = (
            "<!-- PTO-READER-BLOCK: mechanism role=mechanism -->\n"
            "ACR-local and PE-local use `Zeros{5} + 2`, PTO_XLEN, 17, and $x+1$."
        )
        literals = CHECK.derived_protected_literals({"mnemonic": "TEST"}, body)
        self.assertIn("Zeros{5} + 2", literals)
        self.assertIn("PTO_XLEN", literals)
        self.assertIn("17", literals)
        self.assertIn("x+1", literals)
        self.assertIn("TEST", literals)
        self.assertNotIn("ACR-", literals)
        self.assertNotIn("PE-", literals)
        self.assertFalse(any("PTO-READER-BLOCK" in literal for literal in literals))

    def test_all_renderable_node_kinds_share_the_safe_content_policy(self):
        unsafe = {
            "heading": "## [unsafe](https://example.invalid)",
            "list": "- <script>alert(1)</script>",
            "table": "| [unsafe](https://example.invalid) |",
            "image": "## ![unsafe](https://example.invalid/image.png)",
            "fence-metadata": "```html<script>\ntext\n```",
            "javascript": "[unsafe](javascript:alert(1))",
            "data": "[unsafe](data:text/html,unsafe)",
            "expression": "{globalThis.process?.env}",
            "import": "import Unsafe from './unsafe'",
            "comment": "<!-- arbitrary comment -->",
            "inline-comment": "text <!-- arbitrary comment -->",
            "reference-link": "[unsafe][target]\n[target]: javascript:alert(1)",
        }
        marker = "<!-- PTO-READER-BLOCK: purpose role=purpose -->\n"
        for kind, content in unsafe.items():
            with self.subTest(kind=kind), self.assertRaises(CHECK.CheckError):
                CHECK.parse_reader_blocks(marker + content)
        _, nodes = CHECK.parse_reader_blocks(marker + "```text\n<script>shown as text</script>\n```")
        self.assertEqual(nodes[0]["kind"], "code-block")

    def test_reader_links_audit_relative_targets_and_root_routes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            document = pathlib.PurePosixPath("docs/scalar/family/UNIT.md")
            sibling = root / "docs/scalar/OTHER.md"
            sibling.parent.mkdir(parents=True)
            sibling.write_text("# Other\n", encoding="utf-8")
            marker = "<!-- PTO-READER-BLOCK: purpose role=purpose -->\n"
            CHECK.parse_reader_blocks(marker + "[safe](../OTHER.md)", root, document)
            CHECK.parse_reader_blocks(marker + "[route](/reference/scalar/)", root, document)
            with self.assertRaisesRegex(CHECK.CheckError, "target does not exist"):
                CHECK.parse_reader_blocks(marker + "[missing](MISSING.md)", root, document)
            with self.assertRaisesRegex(CHECK.CheckError, "escapes the repository"):
                CHECK.parse_reader_blocks(marker + "[escape](../../../../outside.md)", root, document)

    def test_unclassified_heading_fails_unit_closure(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            doc = root / expected["documentation"]
            text = doc.read_text(encoding="utf-8").replace(
                "<!-- PTO-READER-BLOCK: purpose role=purpose -->",
                "<!-- PTO-READER-BLOCK: purpose role=purpose -->\n## Architectural rule",
                1,
            )
            doc.write_text(text, encoding="utf-8")
            blocks, nodes = CHECK.parse_reader_blocks(CHECK.supplementary_body(text))
            shard["status"] = "decision-gap"
            shard["presentation_blocks"] = blocks
            shard["atomic_claims"] = []
            shard["node_dispositions"] = [
                {
                    "node_id": f"NODE-{index}", "block_id": node["block_id"],
                    "ast_path": node["ast_path"], "node_kind": node["kind"],
                    "fragment_sha256": node["fragment_sha256"],
                    "node_disposition": "connective", "connective_reason": "orientation",
                }
                for index, node in enumerate(nodes) if node["kind"] != "heading"
            ]
            with self.assertRaisesRegex(CHECK.CheckError, "unclassified claim-capable nodes"):
                CHECK.validate_unit_shard(shard, expected, root, set(), False)

    def test_regeneration_without_archive_requires_frozen_inventory(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(SystemExit, "requires explicit --archive"):
                GENERATE.frozen_inventory(pathlib.Path(directory))

    def complete_fixture(self, root: pathlib.Path):
        asl_path = pathlib.Path("asl/scalar/TEST.asl")
        doc_path = pathlib.Path("docs/scalar/TEST.md")
        (root / asl_path).parent.mkdir(parents=True)
        (root / doc_path).parent.mkdir(parents=True)
        (root / asl_path).write_text(
            "// NDF-BEGIN: PTO-INST-SCALAR-TEST\n"
            "// owner\n"
            "// NDF-END: PTO-INST-SCALAR-TEST\n",
            encoding="utf-8",
        )
        blocks = [
            ("purpose", "Why this operation exists."),
            ("mechanism", "It applies the current-owner operation."),
            ("inputs-outputs", "Inputs are read before the result is published."),
            ("effects", "The current owner defines the architectural effect."),
            ("constraints", "Reserved encodings remain illegal under the owner."),
            ("example", "Non-normative example for orientation only."),
        ]
        guide = "\n\n".join(
            f"<!-- PTO-READER-BLOCK: {role} role={role} -->\n{text}"
            for role, text in blocks
        )
        (root / doc_path).write_text(
            "# TEST\n\n<!-- SUPPLEMENTARY-BEGIN -->\n"
            + guide
            + "\n<!-- SUPPLEMENTARY-END -->\n",
            encoding="utf-8",
        )
        parsed_blocks, nodes = CHECK.parse_reader_blocks(guide)
        node_dispositions = []
        for index, node in enumerate(nodes):
            item = {
                "node_id": f"NODE-{index}",
                "block_id": node["block_id"],
                "ast_path": node["ast_path"],
                "node_kind": node["kind"],
                "fragment_sha256": node["fragment_sha256"],
                "node_disposition": "connective",
                "connective_reason": "Reader orientation without an independent rule.",
            }
            node_dispositions.append(item)
        node_dispositions[0] = {
            "node_id": "NODE-0",
            "block_id": nodes[0]["block_id"],
            "ast_path": nodes[0]["ast_path"],
            "node_kind": nodes[0]["kind"],
            "fragment_sha256": nodes[0]["fragment_sha256"],
            "node_disposition": "semantic-claim",
            "claim_id": "CLAIM-0",
        }
        expected = {
            "id": "PTO-SCALAR-TEST",
            "mnemonic": "TEST",
            "surface": "scalar",
            "source": str(asl_path),
            "documentation": str(doc_path),
            "instruction_contract": {
                "artifact": "spec/evidence/instruction-contract-closure.json",
                "ndf_clause": "PTO-INST-SCALAR-TEST",
            },
        }
        shard = {
            "schema_version": 1,
            "unit_id": expected["id"],
            "mnemonic": "TEST",
            "surface": "scalar",
            "page_contract": "mnemonic-reader-v1",
            "status": "complete",
            "risk_tier": "ordinary",
            "owner": {
                "asl_path": str(asl_path),
                "documentation_path": str(doc_path),
                "ndf_clause": "PTO-INST-SCALAR-TEST",
                "contract_artifact": "spec/evidence/instruction-contract-closure.json",
            },
            "migration": {
                "source_id": "anonymous-source-001",
                "source_page_ids": [],
                "mapping_status": "current-owner-only",
                "mapping_basis": "current-owner-only",
                "copyright_disposition": "current-owner-rewrite",
            },
            "reader_roles": [role for role, _ in blocks],
            "presentation_blocks": parsed_blocks,
            "node_dispositions": node_dispositions,
            "atomic_claims": [{
                "claim_id": "CLAIM-0",
                "block_id": nodes[0]["block_id"],
                "ast_path": nodes[0]["ast_path"],
                "fragment_sha256": nodes[0]["fragment_sha256"],
                "disposition": "current-owner-rewrite",
                "owner_reference": {"kind": "asl", "path": str(asl_path), "clause": None},
                "portability_class": "portable",
                "source_section_ids": [],
            }],
            "decision_gaps": [],
        }
        return expected, shard

    def validate_fixture(self, root, expected, shard):
        return CHECK.validate_unit_shard(shard, expected, root, set(), True)

    def test_complete_unit_accepts_adaptive_blocks_and_exhaustive_ast_bindings(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            result = self.validate_fixture(root, expected, shard)
            self.assertEqual(result["status"], "complete")
            self.assertEqual(result["claim_ids"], ["CLAIM-0"])

    def test_mnemonic_instruction_contract_clause_need_not_be_embedded_ndf(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            (root / expected["source"]).write_text("// mnemonic owner\n", encoding="utf-8")
            result = self.validate_fixture(root, expected, shard)
            self.assertEqual(result["status"], "complete")

    def test_unit_schema_rejects_reviewer_fields_and_invalid_disposition(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            shard["reviewer"] = "writer-owned shards cannot attest themselves"
            with self.assertRaisesRegex(CHECK.CheckError, "unknown fields"):
                self.validate_fixture(root, expected, shard)
            del shard["reviewer"]
            shard["migration"]["copyright_disposition"] = "copy-if-convenient"
            with self.assertRaisesRegex(CHECK.CheckError, "invalid copyright disposition"):
                self.validate_fixture(root, expected, shard)

    def test_complete_claim_rejects_nonpublishable_disposition_and_mismatched_owner_kind(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            shard["atomic_claims"][0]["disposition"] = "omit-old"
            with self.assertRaisesRegex(CHECK.CheckError, "non-publishable claim disposition"):
                self.validate_fixture(root, expected, shard)
            shard["atomic_claims"][0]["disposition"] = "current-owner-rewrite"
            shard["atomic_claims"][0]["owner_reference"] = {
                "kind": "ndf", "path": expected["source"], "clause": "WRONG-NDF"
            }
            with self.assertRaisesRegex(CHECK.CheckError, "NDF claim reference"):
                self.validate_fixture(root, expected, shard)
            expected["instruction_contract"] = {}
            shard["owner"]["ndf_clause"] = None
            shard["owner"]["contract_artifact"] = None
            shard["atomic_claims"][0]["owner_reference"] = {
                "kind": "instruction-contract", "path": None, "clause": None
            }
            with self.assertRaisesRegex(CHECK.CheckError, "instruction-contract claim"):
                self.validate_fixture(root, expected, shard)

    def test_high_risk_owner_cannot_be_downgraded_by_writer(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            expected["classification"] = ["memory"]
            shard["risk_tier"] = "ordinary"
            with self.assertRaisesRegex(CHECK.CheckError, "risk tier is downgraded"):
                self.validate_fixture(root, expected, shard)

    def test_scalar_alu_negative_boundary_words_do_not_inflate_risk(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            expected["classification"] = ["alu"]
            shard["risk_tier"] = "ordinary"
            document = root / expected["documentation"]
            document.write_text(
                document.read_text(encoding="utf-8").replace(
                    "The current owner defines the architectural effect.",
                    "The operation has no memory, ordering, or numeric-status effect.",
                ),
                encoding="utf-8",
            )
            blocks, nodes = CHECK.parse_reader_blocks(
                CHECK.supplementary_body(document.read_text(encoding="utf-8"))
            )
            shard["presentation_blocks"] = blocks
            for disposition, node in zip(shard["node_dispositions"], nodes, strict=True):
                disposition["block_id"] = node["block_id"]
                disposition["ast_path"] = node["ast_path"]
                disposition["node_kind"] = node["kind"]
                disposition["fragment_sha256"] = node["fragment_sha256"]
            semantic_node = next(
                node for node in shard["node_dispositions"]
                if node["node_disposition"] == "semantic-claim"
            )
            claim = shard["atomic_claims"][0]
            claim["block_id"] = semantic_node["block_id"]
            claim["ast_path"] = semantic_node["ast_path"]
            claim["fragment_sha256"] = semantic_node["fragment_sha256"]
            self.validate_fixture(root, expected, shard)

    def test_ast_bindings_reject_orphan_overlap_unclassified_and_digest_mismatch(self):
        mutations = {}
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, original = self.complete_fixture(root)
            orphan = copy.deepcopy(original)
            orphan["node_dispositions"][0]["ast_path"] = "/blocks/99/nodes/99"
            mutations["orphan AST binding"] = orphan
            overlap = copy.deepcopy(original)
            duplicate = copy.deepcopy(overlap["node_dispositions"][0])
            duplicate["node_id"] = "NODE-OVERLAP"
            overlap["node_dispositions"].append(duplicate)
            mutations["overlapping AST binding"] = overlap
            unclassified = copy.deepcopy(original)
            unclassified["node_dispositions"].pop()
            mutations["unclassified claim-capable nodes"] = unclassified
            mismatch = copy.deepcopy(original)
            mismatch["node_dispositions"][1]["fragment_sha256"] = "0" * 64
            mutations["fragment digest mismatch"] = mismatch
            for error, shard in mutations.items():
                with self.subTest(error=error), self.assertRaisesRegex(CHECK.CheckError, error):
                    self.validate_fixture(root, expected, shard)

    def test_required_definition_gap_blocks_complete_status(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            shard["decision_gaps"] = [{
                "gap_id": "GAP-1", "required": True, "status": "open",
                "owner_reference": "PTO-INST-SCALAR-TEST",
            }]
            shard["risk_tier"] = "high-risk"
            with self.assertRaisesRegex(CHECK.CheckError, "unresolved required definition gaps"):
                self.validate_fixture(root, expected, shard)

    def test_semantic_node_and_atomic_claim_require_exact_tuple_binding(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            second = shard["node_dispositions"][1]
            claim = shard["atomic_claims"][0]
            claim.update({
                "block_id": second["block_id"], "ast_path": second["ast_path"],
                "fragment_sha256": second["fragment_sha256"],
            })
            with self.assertRaisesRegex(CHECK.CheckError, "tuple mismatch"):
                self.validate_fixture(root, expected, shard)

    def test_one_atomic_claim_cannot_cover_multiple_nodes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            second = shard["node_dispositions"][1]
            second.pop("connective_reason")
            second["node_disposition"] = "semantic-claim"
            second["claim_id"] = "CLAIM-0"
            with self.assertRaisesRegex(CHECK.CheckError, "claim covers multiple nodes"):
                self.validate_fixture(root, expected, shard)

    def test_claim_source_must_be_reviewed_for_the_same_unit(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            page_id = "SRC-PAGE-" + "A" * 24
            shard["atomic_claims"][0]["source_section_ids"] = [page_id]
            with self.assertRaisesRegex(CHECK.CheckError, "not reviewed for unit"):
                CHECK.validate_unit_shard(shard, expected, root, {page_id}, True)

    def review_fixture(self, unit_count=30):
        units = {
            f"U-{index}": {
                "risk_tier": "ordinary", "claim_ids": [f"C-{index}"],
                "node_ids": [f"N-{index}"],
                "status": "complete",
                "shard_sha256": f"{index:064x}", "guide_sha256": f"{index + 1000:064x}",
            }
            for index in range(unit_count)
        }
        review = {
            "schema_version": 1,
            "batch_id": "BATCH-1",
            "rubric_version": "mnemonic-reader-v1",
            "source_commit": "1" * 40,
            "unit_risks": {unit_id: "ordinary" for unit_id in units},
            "reviewed_claim_ids": [f"C-{index}" for index in range(unit_count)],
            "reviewed_claim_count": unit_count,
            "reviewed_node_ids": [f"N-{index}" for index in range(unit_count)],
            "reviewed_node_count": unit_count,
            "deep_reviewed_unit_ids": [],
            "verifier_sample_unit_ids": [f"U-{index}" for index in range(min(6, unit_count))],
            "verifier_sample_count": min(6, unit_count),
            "unresolved_question_count": 0,
            "verdict": "accepted",
            "contexts": {"writer": "writer-1", "semantic_reviewer": "reviewer-1", "verifier": "verifier-1"},
            "artifact_digests": {},
        }
        review["artifact_digests"] = CHECK.expected_review_artifact_digests(review, units)
        return units, review

    def write_review(self, root, review):
        root.mkdir(parents=True, exist_ok=True)
        (root / "batch.json").write_bytes(CHECK.canonical_json_bytes(review))

    def test_risk_tier_attestation_enforces_sampling_counts_and_independence(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            units, review = self.review_fixture()
            self.write_review(root, review)
            self.assertEqual(CHECK.validate_reviews(root, units, True)["accepted"], 1)
            review["verifier_sample_unit_ids"] = review["verifier_sample_unit_ids"][:5]
            review["verifier_sample_count"] = 5
            review["artifact_digests"] = CHECK.expected_review_artifact_digests(review, units)
            self.write_review(root, review)
            with self.assertRaisesRegex(CHECK.CheckError, "ordinary verifier sample is too small"):
                CHECK.validate_reviews(root, units, True)

    def test_accepted_english_attestation_is_exhaustive_in_structural_mode(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            units, review = self.review_fixture()
            review["reviewed_claim_ids"].pop()
            review["reviewed_claim_count"] -= 1
            review["artifact_digests"] = CHECK.expected_review_artifact_digests(review, units)
            self.write_review(root, review)
            with self.assertRaisesRegex(CHECK.CheckError, "100% claim review"):
                CHECK.validate_reviews(root, units, False)

    def test_structural_mode_rejects_complete_english_unit_without_accepted_review(self):
        with tempfile.TemporaryDirectory() as directory:
            units, _ = self.review_fixture(1)
            with self.assertRaisesRegex(CHECK.CheckError, "complete units lack accepted review"):
                CHECK.validate_reviews(pathlib.Path(directory), units, False)

    def test_accepted_english_attestation_rejects_self_declared_artifact_digest(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            units, review = self.review_fixture()
            review["artifact_digests"]["writer"] = "f" * 64
            self.write_review(root, review)
            with self.assertRaisesRegex(CHECK.CheckError, "computed inputs"):
                CHECK.validate_reviews(root, units, False)
            units, review = self.review_fixture()
            review["contexts"]["verifier"] = review["contexts"]["writer"]
            self.write_review(root, review)
            with self.assertRaisesRegex(CHECK.CheckError, "contexts must be distinct"):
                CHECK.validate_reviews(root, units, True)

    def test_high_risk_requires_deep_review_and_verifier_coverage(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            units, review = self.review_fixture(5)
            units["U-0"]["risk_tier"] = "high-risk"
            review["unit_risks"]["U-0"] = "high-risk"
            review["artifact_digests"] = CHECK.expected_review_artifact_digests(review, units)
            self.write_review(root, review)
            with self.assertRaisesRegex(CHECK.CheckError, "high-risk deep/verifier coverage"):
                CHECK.validate_reviews(root, units, True)
            review["deep_reviewed_unit_ids"] = ["U-0"]
            review["artifact_digests"] = CHECK.expected_review_artifact_digests(review, units)
            self.write_review(root, review)
            self.assertEqual(CHECK.validate_reviews(root, units, True)["accepted"], 1)

    def test_current_owner_inventory_tracks_release_add_and_retire(self):
        traceability = json.loads(
            (ROOT / "spec/evidence/release-traceability-readiness.json").read_text(encoding="utf-8")
        )
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / "traceability.json"
            path.write_text(json.dumps(traceability), encoding="utf-8")
            baseline = GENERATE.current_units(path)
            self.assertEqual(len(baseline), traceability["summary"]["mnemonic_count"])
            targets = GENERATE.target_units(path)
            self.assertEqual(len(targets), 707)
            self.assertEqual(sum(unit["surface"] == "arch" for unit in targets), 72)
            retired = baseline[0]["id"]
            traceability["units"] = [unit for unit in traceability["units"] if unit["id"] != retired]
            traceability["units"].append({
                "id": "PTO-TILE-NEW", "mnemonic": "TNEW", "surface": "tile",
                "source": "asl/tile/TNEW.asl", "documentation": "docs/tile/TNEW.md",
            })
            path.write_text(json.dumps(traceability), encoding="utf-8")
            changed = GENERATE.current_units(path)
            self.assertEqual(len(changed), len(baseline))
            self.assertNotIn(retired, {unit["id"] for unit in changed})
            self.assertIn("PTO-TILE-NEW", {unit["id"] for unit in changed})

    def test_scalar_mapper_uses_internal_titles_and_only_reviewed_alias_rules(self):
        def page(title, eyebrow="scalar"):
            return (
                "<!doctype html><html><head><title>Unrelated wrapper</title></head>"
                f"<body><main><p class='eyebrow'>{eyebrow}</p><h2>{title}</h2>"
                "</main></body></html>"
            )

        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            archive = root / "anonymous.zip"
            entries = {
                "random-a.html": page("add"),
                "random-b.html": page("FGE"),
                "random-c.html": page("L.FGE"),
                "random-d.html": page("CASP"),
                "random-e.html": page("B.ADD"),
                "random-f.html": page("Scalar Overview"),
                "random-g.html": page("TADD", "tile"),
            }
            with zipfile.ZipFile(archive, "w") as output:
                for name, content in entries.items():
                    output.writestr(name, content)
            inventory_pages = []
            for name, content in entries.items():
                path_digest = GENERATE.sha256_bytes(name.encode("utf-8"))
                inventory_pages.append({
                    "page_id": f"SRC-PAGE-{path_digest[:24].upper()}",
                    "path_sha256": path_digest,
                    "content_sha256": GENERATE.sha256_bytes(content.encode("utf-8")),
                    "kind": "auxiliary", "disposition": "pending",
                    "mapped_unit_ids": [], "mapping_basis": "unreviewed",
                })
            inventory = {"pages": inventory_pages}
            traceability = root / "traceability.json"
            traceability.write_text(json.dumps({"units": [
                {"id": "PTO-SCALAR-ADD", "mnemonic": "ADD", "surface": "scalar"},
                {"id": "PTO-SCALAR-FGE", "mnemonic": "FGE", "surface": "scalar"},
                {"id": "PTO-BLOCK-B-ADD", "mnemonic": "B.ADD", "surface": "block"},
            ]}), encoding="utf-8")
            mapped, unit_pages, summary = GENERATE.scalar_mapping_plan(
                archive, traceability, copy.deepcopy(inventory)
            )
            by_path = {}
            for name in entries:
                path_digest = GENERATE.sha256_bytes(name.encode("utf-8"))
                page_id = f"SRC-PAGE-{path_digest[:24].upper()}"
                by_path[name] = next(page for page in mapped["pages"] if page["page_id"] == page_id)
            self.assertEqual(by_path["random-a.html"]["mapped_unit_ids"], ["PTO-SCALAR-ADD"])
            self.assertEqual(by_path["random-c.html"]["mapped_unit_ids"], ["PTO-SCALAR-FGE"])
            self.assertEqual(by_path["random-d.html"]["disposition"], "omit-old")
            self.assertEqual(by_path["random-e.html"]["disposition"], "omit-old")
            self.assertEqual(by_path["random-f.html"]["disposition"], "non-mnemonic-input")
            self.assertEqual(by_path["random-g.html"]["disposition"], "pending")
            self.assertEqual(len(unit_pages["PTO-SCALAR-FGE"]), 2)
            self.assertEqual(summary["multiple_page_units"], 1)
            mapped_again, unit_pages_again, summary_again = GENERATE.scalar_mapping_plan(
                archive, traceability, copy.deepcopy(inventory)
            )
            self.assertEqual(
                GENERATE.canonical_bytes([mapped_again, unit_pages_again, summary_again]),
                GENERATE.canonical_bytes([mapped, unit_pages, summary]),
            )

    def test_scalar_mapper_refreshes_only_pending_translation_dependency_hash(self):
        english = {"unit_id": "PTO-SCALAR-ADD", "migration": {"mapping_status": "mapped-current"}}
        translation = {
            "status": "pending",
            "english_unit_shard_sha256": "0" * 64,
            "protected_literals": ["ADD"],
            "custom_pending_field": {"preserve": True},
        }
        refreshed = GENERATE.refresh_pending_translation_shard(translation, english)
        self.assertEqual(
            refreshed["english_unit_shard_sha256"],
            GENERATE.sha256_bytes(GENERATE.canonical_bytes(english)),
        )
        self.assertEqual(refreshed["protected_literals"], ["ADD"])
        self.assertEqual(refreshed["custom_pending_field"], {"preserve": True})
        self.assertEqual(translation["english_unit_shard_sha256"], "0" * 64)
        for status in ("complete", "retired"):
            blocked = copy.deepcopy(translation)
            blocked["status"] = status
            with self.subTest(status=status), self.assertRaisesRegex(
                SystemExit, "only pending zh-CN translations"
            ):
                GENERATE.refresh_pending_translation_shard(blocked, english)

    def test_block_tile_mapper_uses_exact_internal_titles_without_alias_guessing(self):
        def page(title, eyebrow):
            return (
                "<!doctype html><html><body><main>"
                f"<p class='eyebrow'>{eyebrow}</p><h2>{title}</h2>"
                "</main></body></html>"
            )

        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            archive = root / "anonymous.zip"
            entries = {
                "a.html": page("b.catr", "header"),
                "b.html": page("B.ATTR", "header"),
                "c.html": page("Block / Header ISA", "header"),
                "d.html": page("tadd Intrinsic", "tile"),
                "e.html": page("TOLD Intrinsic", "tile"),
                "f.html": page("Tile Intrinsic Reference", "tile"),
                "g.html": page("ADD", "scalar"),
            }
            with zipfile.ZipFile(archive, "w") as output:
                for name, content in entries.items():
                    output.writestr(name, content)
            inventory = {"pages": []}
            for name, content in entries.items():
                digest = GENERATE.sha256_bytes(name.encode("utf-8"))
                inventory["pages"].append({
                    "page_id": f"SRC-PAGE-{digest[:24].upper()}",
                    "path_sha256": digest,
                    "content_sha256": GENERATE.sha256_bytes(content.encode("utf-8")),
                    "kind": "auxiliary", "disposition": "pending",
                    "mapped_unit_ids": [], "mapping_basis": "unreviewed",
                })
            traceability = root / "traceability.json"
            traceability.write_text(json.dumps({"units": [
                {"id": "PTO-BLOCK-B-CATR", "mnemonic": "B.CATR", "surface": "block"},
                {"id": "PTO-TILE-TADD", "mnemonic": "TADD", "surface": "tile"},
                {"id": "PTO-SCALAR-ADD", "mnemonic": "ADD", "surface": "scalar"},
            ]}), encoding="utf-8")
            mapped, mappings, summary = GENERATE.block_tile_mapping_plan(
                archive, traceability, copy.deepcopy(inventory)
            )
            by_name = {}
            for name in entries:
                digest = GENERATE.sha256_bytes(name.encode("utf-8"))
                page_id = f"SRC-PAGE-{digest[:24].upper()}"
                by_name[name] = next(page for page in mapped["pages"] if page["page_id"] == page_id)
            self.assertEqual(by_name["a.html"]["mapped_unit_ids"], ["PTO-BLOCK-B-CATR"])
            self.assertEqual(by_name["d.html"]["mapped_unit_ids"], ["PTO-TILE-TADD"])
            self.assertEqual(by_name["b.html"]["disposition"], "omit-old")
            self.assertEqual(by_name["e.html"]["disposition"], "omit-old")
            self.assertEqual(by_name["c.html"]["disposition"], "non-mnemonic-input")
            self.assertEqual(by_name["f.html"]["disposition"], "non-mnemonic-input")
            self.assertEqual(by_name["g.html"]["disposition"], "pending")
            self.assertEqual(mappings["block"]["PTO-BLOCK-B-CATR"], [by_name["a.html"]["page_id"]])
            self.assertEqual(mappings["tile"]["PTO-TILE-TADD"], [by_name["d.html"]["page_id"]])
            self.assertEqual(summary["block"]["ambiguous_pages"], 0)
            self.assertEqual(summary["tile"]["ambiguous_pages"], 0)

    def test_auxiliary_closure_accepts_aggregates_and_rejects_unresolved_mnemonics(self):
        def inventory_for(entries):
            pages = []
            for name, content in entries.items():
                digest = GENERATE.sha256_bytes(name.encode("utf-8"))
                pages.append({
                    "page_id": f"SRC-PAGE-{digest[:24].upper()}",
                    "path_sha256": digest,
                    "content_sha256": GENERATE.sha256_bytes(content.encode("utf-8")),
                    "kind": "wrapper", "disposition": "pending",
                    "mapped_unit_ids": [], "mapping_basis": "unreviewed",
                })
            return {"pages": pages}

        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            aggregate_entries = {
                "a.html": "<html><body><main><p class='eyebrow'>overview</p><h2>Overview</h2></main></body></html>",
                "b.md": "# Aggregate Reference\n",
            }
            archive = root / "aggregate.zip"
            with zipfile.ZipFile(archive, "w") as output:
                for name, content in aggregate_entries.items():
                    output.writestr(name, content)
            closed, summary = GENERATE.auxiliary_page_closure_plan(
                archive, inventory_for(aggregate_entries)
            )
            self.assertEqual(summary, {"closed_non_mnemonic": 2, "remaining_pending": 0})
            self.assertTrue(all(
                page["disposition"] == "non-mnemonic-input"
                and not page["mapped_unit_ids"]
                for page in closed["pages"]
            ))
            unresolved_entries = {
                "unknown.html": "<html><body><main><h2>UNRESOLVED</h2></main></body></html>"
            }
            unresolved_archive = root / "unresolved.zip"
            with zipfile.ZipFile(unresolved_archive, "w") as output:
                for name, content in unresolved_entries.items():
                    output.writestr(name, content)
            with self.assertRaisesRegex(SystemExit, "explicit mnemonic review"):
                GENERATE.auxiliary_page_closure_plan(
                    unresolved_archive, inventory_for(unresolved_entries)
                )

    def translation_fixture(self, root: pathlib.Path):
        repo = root / "repo"
        evidence = repo / "spec/evidence/mnemonic-descriptions"
        english_path = evidence / "scalar/PTO-SCALAR-TEST.json"
        english_path.parent.mkdir(parents=True)
        english = {
            "schema_version": 1, "unit_id": "PTO-SCALAR-TEST", "mnemonic": "TEST",
            "surface": "scalar", "page_contract": "mnemonic-reader-v1",
            "status": "complete", "risk_tier": "ordinary",
            "owner": {"documentation_path": "docs/scalar/TEST.md"},
            "migration": {}, "reader_roles": [],
            "presentation_blocks": [{"block_id": "purpose", "role": "purpose"}],
            "node_dispositions": [{
                "node_id": "NODE-0", "node_disposition": "semantic-claim",
                "claim_id": "CLAIM-0",
            }],
            "atomic_claims": [{"claim_id": "CLAIM-0"}], "decision_gaps": [],
        }
        english_path.write_bytes(CHECK.canonical_json_bytes(english))
        english_doc = repo / "docs/scalar/TEST.md"
        english_doc.parent.mkdir(parents=True)
        english_doc.write_text(
            "# TEST\n<!-- SUPPLEMENTARY-BEGIN -->\n"
            "<!-- PTO-READER-BLOCK: purpose role=purpose -->\nEnglish guide\n"
            "<!-- SUPPLEMENTARY-END -->\n",
            encoding="utf-8",
        )
        unit = {"id": english["unit_id"], "surface": "scalar"}
        translation = GENERATE.pending_translation_shard(unit, english)
        translation["english_block_ids"] = ["purpose"]
        translation["english_node_ids"] = ["NODE-0"]
        translation["english_claim_ids"] = ["CLAIM-0"]
        translation_path = evidence / "translations/zh-CN/scalar/PTO-SCALAR-TEST.json"
        translation_path.parent.mkdir(parents=True)
        translation_path.write_bytes(CHECK.canonical_json_bytes(translation))
        return repo, english, english_path, translation, translation_path

    def test_bilingual_shard_detects_english_staleness_and_protected_literal_digest(self):
        with tempfile.TemporaryDirectory() as directory:
            repo, english, english_path, translation, translation_path = self.translation_fixture(
                pathlib.Path(directory)
            )
            result = CHECK.validate_translation_shard(
                translation, english, translation_path, repo, False
            )
            self.assertEqual(result["status"], "pending")
            english["mnemonic"] = "TEST2"
            english_path.write_bytes(CHECK.canonical_json_bytes(english))
            with self.assertRaisesRegex(CHECK.CheckError, "English change stales"):
                CHECK.validate_translation_shard(translation, english, translation_path, repo, False)
            english["mnemonic"] = "TEST"
            english_path.write_bytes(CHECK.canonical_json_bytes(english))
            translation["protected_literals"] = ["PTO_XLEN"]
            with self.assertRaisesRegex(CHECK.CheckError, "protected literal digest mismatch"):
                CHECK.validate_translation_shard(translation, english, translation_path, repo, False)
            translation["owner_reference"] = {"path": "asl/scalar/TEST.asl"}
            with self.assertRaisesRegex(CHECK.CheckError, "unknown fields"):
                CHECK.validate_translation_shard(translation, english, translation_path, repo, False)

    def test_architecture_units_use_the_architecture_page_contract(self):
        traceability = json.loads(
            (ROOT / "spec/evidence/release-traceability-readiness.json").read_text(encoding="utf-8")
        )
        arch = next(unit for unit in traceability["units"] if unit["surface"] == "arch")
        shard = CHECK.read_json(
            ROOT / "spec/evidence/mnemonic-descriptions/arch" / f"{arch['id']}.json"
        )
        self.assertIsNone(shard["mnemonic"])
        self.assertEqual(shard["page_contract"], "architecture-reader-v1")
        self.assertEqual(CHECK.required_roles("architecture-reader-v1"), {
            "purpose-scope", "concepts-state", "rules-interactions", "boundaries",
            "example-usage", "related-owners-navigation",
        })
        self.assertEqual(CHECK.required_roles("mnemonic-reader-v1"), {
            "purpose", "mechanism", "inputs-outputs", "effects", "constraints", "example",
        })

    def test_architecture_complete_uses_exact_architecture_roles(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            expected, shard = self.complete_fixture(root)
            expected["surface"] = "arch"
            shard["surface"] = "arch"
            shard["page_contract"] = "architecture-reader-v1"
            replacements = {
                "purpose": "purpose-scope",
                "mechanism": "concepts-state",
                "inputs-outputs": "rules-interactions",
                "effects": "boundaries",
                "constraints": "example-usage",
                "example": "related-owners-navigation",
            }
            doc = root / expected["documentation"]
            text = doc.read_text(encoding="utf-8")
            for old, new in replacements.items():
                text = text.replace(
                    f"PTO-READER-BLOCK: {old} role={old}",
                    f"PTO-READER-BLOCK: {new} role={new}",
                )
            doc.write_text(text, encoding="utf-8")
            blocks, nodes = CHECK.parse_reader_blocks(CHECK.supplementary_body(text))
            shard["reader_roles"] = list(replacements.values())
            shard["presentation_blocks"] = blocks
            for disposition, node in zip(shard["node_dispositions"], nodes, strict=True):
                disposition["block_id"] = node["block_id"]
                disposition["ast_path"] = node["ast_path"]
                disposition["node_kind"] = node["kind"]
                disposition["fragment_sha256"] = node["fragment_sha256"]
            shard["atomic_claims"][0]["block_id"] = nodes[0]["block_id"]
            shard["atomic_claims"][0]["ast_path"] = nodes[0]["ast_path"]
            shard["atomic_claims"][0]["fragment_sha256"] = nodes[0]["fragment_sha256"]
            CHECK.validate_unit_shard(shard, expected, root, set(), True)
            expected["instruction_contract"] = {}
            shard["owner"]["ndf_clause"] = None
            shard["owner"]["contract_artifact"] = None
            asl_path = root / expected["source"]
            asl_path.write_text(
                asl_path.read_text(encoding="utf-8")
                + "// NDF-BEGIN: PTO-ARCH-EXTRA-001\n"
                + "// second architecture clause\n"
                + "// NDF-END: PTO-ARCH-EXTRA-001\n",
                encoding="utf-8",
            )
            shard["atomic_claims"][0]["owner_reference"] = {
                "kind": "ndf", "path": expected["source"], "clause": "PTO-ARCH-EXTRA-001"
            }
            CHECK.validate_unit_shard(shard, expected, root, set(), True)
            shard["reader_roles"] = sorted(CHECK.MNEMONIC_REQUIRED_ROLES)
            with self.assertRaisesRegex(CHECK.CheckError, "roles outside its page contract"):
                CHECK.validate_unit_shard(shard, expected, root, set(), True)

    def test_bilingual_complete_claim_set_is_a_bijection(self):
        with tempfile.TemporaryDirectory() as directory:
            repo, english, _, translation, translation_path = self.translation_fixture(
                pathlib.Path(directory)
            )
            locale_path = pathlib.Path(
                "docs/site/i18n/zh-CN/docusaurus-plugin-content-docs-reference/current/"
                "scalar/TEST.md"
            )
            (repo / locale_path).parent.mkdir(parents=True)
            (repo / "docs/scalar/OTHER.md").write_text("# Other\n", encoding="utf-8")
            locale_body = (
                "<!-- PTO-READER-BLOCK: zh-purpose role=purpose -->\n"
                "TEST 中文说明；参见[相关归属单元](OTHER.md)。"
            )
            (repo / locale_path).write_text(
                "# TEST\n<!-- SUPPLEMENTARY-BEGIN -->\n" + locale_body
                + "\n<!-- SUPPLEMENTARY-END -->\n",
                encoding="utf-8",
            )
            _, locale_nodes = CHECK.parse_reader_blocks(locale_body)
            locale_node_id = "zh-purpose:/blocks/0/nodes/0"
            translation.update({
                "status": "complete",
                "locale_documentation_path": str(locale_path),
                "locale_guide_sha256": CHECK.sha256_bytes(locale_body.encode("utf-8")),
                "protected_literals": ["TEST"],
                "protected_literals_sha256": CHECK.sha256_bytes(
                    CHECK.canonical_json_bytes(["TEST"])
                ),
                "block_mappings": [{"english_block_id": "purpose", "locale_block_id": "zh-purpose", "locale_fragment_sha256": CHECK.sha256_bytes(CHECK.canonical_json_bytes([locale_nodes[0]["fragment_sha256"]]))}],
                "node_mappings": [{"english_node_id": "NODE-0", "locale_node_id": locale_node_id, "locale_fragment_sha256": locale_nodes[0]["fragment_sha256"]}],
                "claim_mappings": [{"english_claim_id": "CLAIM-0", "locale_node_id": locale_node_id}],
            })
            translation_path.write_bytes(CHECK.canonical_json_bytes(translation))
            missing_literals = copy.deepcopy(translation)
            missing_literals["protected_literals"] = []
            missing_literals["protected_literals_sha256"] = CHECK.sha256_bytes(
                CHECK.canonical_json_bytes([])
            )
            with self.assertRaisesRegex(CHECK.CheckError, "not derived from English"):
                CHECK.validate_translation_shard(
                    missing_literals, english, translation_path, repo, True
                )
            CHECK.validate_translation_shard(translation, english, translation_path, repo, True)
            translation["claim_mappings"] = []
            with self.assertRaisesRegex(CHECK.CheckError, "claim mapping is not a bijection"):
                CHECK.validate_translation_shard(translation, english, translation_path, repo, True)

    def test_translation_change_stales_separate_attestation(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            repo, _, _, _, translation_path = self.translation_fixture(root)
            review_root = repo / "spec/evidence/mnemonic-descriptions/translation-reviews/zh-CN"
            review_root.mkdir(parents=True)
            translations = {"PTO-SCALAR-TEST": {
                "path": translation_path, "claim_ids": ["CLAIM-0"],
                "node_ids": ["NODE-0"], "risk_tier": "ordinary",
                "locale_guide_sha256": None,
                "status": "complete",
            }}
            review = {
                "schema_version": 1, "locale": "zh-CN", "batch_id": "ZH-BATCH-1",
                "rubric_version": "mnemonic-translation-v1", "source_commit": "1" * 40,
                "unit_ids": ["PTO-SCALAR-TEST"],
                "unit_risks": {"PTO-SCALAR-TEST": "ordinary"},
                "translation_artifact_digests": {"PTO-SCALAR-TEST": CHECK.sha256_bytes(translation_path.read_bytes())},
                "reviewed_claim_ids": ["CLAIM-0"], "reviewed_claim_count": 1,
                "reviewed_node_ids": ["NODE-0"], "reviewed_node_count": 1,
                "protected_literal_unit_ids": ["PTO-SCALAR-TEST"],
                "verifier_sample_unit_ids": ["PTO-SCALAR-TEST"], "verifier_sample_count": 1,
                "unresolved_question_count": 0, "verdict": "accepted",
                "contexts": {"translator": "translator-1", "language_reviewer": "reviewer-1", "verifier": "verifier-1"},
                "artifact_digests": {},
            }
            review["artifact_digests"] = CHECK.expected_translation_review_artifact_digests(
                review, translations
            )
            (review_root / "batch.json").write_bytes(CHECK.canonical_json_bytes(review))
            self.assertEqual(CHECK.validate_translation_reviews(review_root, translations, True)["accepted"], 1)
            translation_path.write_bytes(translation_path.read_bytes() + b"\n")
            with self.assertRaisesRegex(CHECK.CheckError, "stales translation attestation"):
                CHECK.validate_translation_reviews(review_root, translations, True)

    def test_accepted_translation_attestation_is_exhaustive_in_structural_mode(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            repo, _, _, _, translation_path = self.translation_fixture(root)
            review_root = repo / "spec/evidence/mnemonic-descriptions/translation-reviews/zh-CN"
            review_root.mkdir(parents=True)
            translations = {"PTO-SCALAR-TEST": {
                "path": translation_path, "claim_ids": ["CLAIM-0"],
                "node_ids": ["NODE-0"], "risk_tier": "ordinary",
                "locale_guide_sha256": None,
                "status": "complete",
            }}
            review = {
                "schema_version": 1, "locale": "zh-CN", "batch_id": "ZH-BAD",
                "rubric_version": "mnemonic-translation-v1", "source_commit": "1" * 40,
                "unit_ids": ["PTO-SCALAR-TEST"], "unit_risks": {"PTO-SCALAR-TEST": "ordinary"},
                "translation_artifact_digests": {"PTO-SCALAR-TEST": CHECK.sha256_bytes(translation_path.read_bytes())},
                "reviewed_claim_ids": ["CLAIM-0"], "reviewed_claim_count": 1,
                "reviewed_node_ids": [], "reviewed_node_count": 0,
                "protected_literal_unit_ids": ["PTO-SCALAR-TEST"],
                "verifier_sample_unit_ids": ["PTO-SCALAR-TEST"], "verifier_sample_count": 1,
                "unresolved_question_count": 0, "verdict": "accepted",
                "contexts": {"translator": "translator", "language_reviewer": "reviewer", "verifier": "verifier"},
                "artifact_digests": {},
            }
            review["artifact_digests"] = CHECK.expected_translation_review_artifact_digests(
                review, translations
            )
            (review_root / "bad.json").write_bytes(CHECK.canonical_json_bytes(review))
            with self.assertRaisesRegex(CHECK.CheckError, "node review is not exhaustive"):
                CHECK.validate_translation_reviews(review_root, translations, False)

    def test_structural_mode_rejects_complete_translation_without_accepted_review(self):
        with tempfile.TemporaryDirectory() as directory:
            translation_path = pathlib.Path(directory) / "translation.json"
            translation_path.write_text("{}\n", encoding="utf-8")
            translations = {"PTO-SCALAR-TEST": {
                "path": translation_path, "claim_ids": [], "node_ids": [],
                "risk_tier": "ordinary", "locale_guide_sha256": "0" * 64,
                "status": "complete",
            }}
            with self.assertRaisesRegex(CHECK.CheckError, "complete zh-CN translations lack"):
                CHECK.validate_translation_reviews(pathlib.Path(directory) / "reviews", translations, False)

    def test_accepted_translation_attestation_rejects_self_declared_artifact_digest(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            repo, _, _, _, translation_path = self.translation_fixture(root)
            review_root = repo / "spec/evidence/mnemonic-descriptions/translation-reviews/zh-CN"
            review_root.mkdir(parents=True)
            translations = {"PTO-SCALAR-TEST": {
                "path": translation_path, "claim_ids": ["CLAIM-0"],
                "node_ids": ["NODE-0"], "risk_tier": "ordinary",
                "locale_guide_sha256": None,
                "status": "complete",
            }}
            review = {
                "schema_version": 1, "locale": "zh-CN", "batch_id": "ZH-DIGEST",
                "rubric_version": "mnemonic-translation-v1", "source_commit": "1" * 40,
                "unit_ids": ["PTO-SCALAR-TEST"], "unit_risks": {"PTO-SCALAR-TEST": "ordinary"},
                "translation_artifact_digests": {"PTO-SCALAR-TEST": CHECK.sha256_bytes(translation_path.read_bytes())},
                "reviewed_claim_ids": ["CLAIM-0"], "reviewed_claim_count": 1,
                "reviewed_node_ids": ["NODE-0"], "reviewed_node_count": 1,
                "protected_literal_unit_ids": ["PTO-SCALAR-TEST"],
                "verifier_sample_unit_ids": ["PTO-SCALAR-TEST"], "verifier_sample_count": 1,
                "unresolved_question_count": 0, "verdict": "accepted",
                "contexts": {"translator": "translator", "language_reviewer": "reviewer", "verifier": "verifier"},
                "artifact_digests": {"translation": "f" * 64, "language_review": "e" * 64, "verification": "d" * 64},
            }
            (review_root / "digest.json").write_bytes(CHECK.canonical_json_bytes(review))
            with self.assertRaisesRegex(CHECK.CheckError, "computed inputs"):
                CHECK.validate_translation_reviews(review_root, translations, False)


if __name__ == "__main__":
    unittest.main()
