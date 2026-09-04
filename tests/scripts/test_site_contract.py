import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SITE = ROOT / "docs/site"


class SiteContractTests(unittest.TestCase):
    def test_site_uses_exact_reviewed_dependencies(self) -> None:
        package = json.loads((SITE / "package.json").read_text(encoding="utf-8"))
        self.assertEqual(package["dependencies"]["@docusaurus/core"], "3.10.2")
        self.assertEqual(
            package["dependencies"]["@docusaurus/plugin-client-redirects"],
            "3.10.2",
        )
        self.assertEqual(package["dependencies"]["react"], "19.2.8")
        self.assertEqual(
            package["dependencies"]["plotly.js"],
            "npm:plotly.js-gl2d-dist-min@4.0.0",
        )
        self.assertEqual(package["devDependencies"]["@playwright/test"], "1.62.1")
        self.assertEqual(package["devDependencies"]["@axe-core/playwright"], "4.13.0")
        self.assertEqual(package["devDependencies"]["lighthouse"], "13.4.1")
        self.assertEqual(
            package["pnpm"]["overrides"]["serialize-javascript"], "7.1.0"
        )
        for group in ("dependencies", "devDependencies"):
            for name, version in package[group].items():
                self.assertNotIn("latest", version, name)
                self.assertNotIn("*", version, name)

    def test_site_configuration_preserves_release_and_locale_contracts(self) -> None:
        config = (SITE / "docusaurus.config.ts").read_text(encoding="utf-8")
        for term in (
            "url: 'https://pto-isa.github.io'",
            "baseUrl: '/'",
            "locales: ['en', 'zh-CN']",
            "beforeDefaultRemarkPlugins",
            "sidebarItemsGenerator",
            "'./plugins/pto-content/index.ts'",
        ):
            self.assertIn(term, config)
        navigation = [
            config.index("label: 'Architecture'"),
            config.index("label: 'Instructions'"),
            config.index("label: 'NDF'"),
            config.index("label: 'Decisions'"),
            config.index("label: 'Search'"),
        ]
        self.assertEqual(navigation, sorted(navigation))
        self.assertIn("defaultMode: 'dark'", config)
        self.assertIn("'arch/**'", config)
        self.assertIn("legacyReferenceRoute(unit.documentation)", config)

    def test_homepage_is_a_human_reading_path(self) -> None:
        homepage = (SITE / "src/pages/index.tsx").read_text(encoding="utf-8")
        for term in (
            "Architecture",
            "Scalar, then Block, then Tile",
            "ADR explains why. NDF points to what is current.",
            "surface=scalar",
            "surface=block",
            "surface=tile",
            "surfaceCounts",
            "recordCounts",
        ):
            self.assertIn(term, homepage)

    def test_source_backed_routes_use_page_specific_data(self) -> None:
        plugin = (SITE / "plugins/pto-content/index.ts").read_text(encoding="utf-8")
        self.assertIn("actions.createData", plugin)
        self.assertIn("modules: {unitData: unit.module}", plugin)
        self.assertIn("component: '@site/src/routes/UnitWorkbench'", plugin)
        self.assertIn("modules: {graph: graphDataModule}", plugin)
        self.assertIn("modules: {search: searchDataModule}", plugin)
        self.assertIn("component: '@site/src/routes/NdfIndexPage'", plugin)
        self.assertIn("component: '@site/src/routes/Architecture'", plugin)
        self.assertIn("modules: {architecture: architectureDataModule}", plugin)
        self.assertIn("component: '@site/src/routes/InstructionIndex'", plugin)
        self.assertIn("component: '@site/src/routes/NdfCatalog'", plugin)
        self.assertIn("component: '@site/src/routes/NdfDetail'", plugin)
        self.assertIn("pto.site-architecture-guide.v1", plugin)
        self.assertIn("pto.site-unit-routes.v1", plugin)
        self.assertIn("pto-unit-routes.json", plugin)
        self.assertIn("PTO-EVIDENCE-RELEASE-TRACEABILITY", plugin)
        self.assertIn("clauseSha256", plugin)
        self.assertIn("PTO_SITE_REQUIRE_RELEASE", plugin)
        self.assertIn("--porcelain=v1", plugin)
        self.assertNotIn("setGlobalData(content)", plugin)
        portal_shell = (SITE / "src/components/PortalShell.tsx").read_text(
            encoding="utf-8"
        )
        navigation = (SITE / "src/components/SpecNavigation.tsx").read_text(
            encoding="utf-8"
        )
        architecture = (SITE / "src/routes/Architecture.tsx").read_text(
            encoding="utf-8"
        )
        self.assertIn("Left specification navigation", portal_shell)
        self.assertIn("Browse specification", portal_shell)
        self.assertIn("aria-current", navigation)
        self.assertIn("Architecture mental model", architecture)
        self.assertIn("Sources and release identity", architecture)
        repository_links = (
            SITE / "plugins/pto-content/remark-repository-links.ts"
        ).read_text(encoding="utf-8")
        self.assertIn(
            "return `/${relative}${suffix}`",
            repository_links,
        )
        self.assertNotIn("pathname://", repository_links)
        publication_hygiene = (
            ROOT / "scripts/check-publication-hygiene"
        ).read_text(encoding="utf-8")
        self.assertIn("canonical_markdown_source(path).parent", publication_hygiene)

    def test_reader_guides_are_typed_locale_specific_non_normative_projections(self) -> None:
        plugin = (SITE / "plugins/pto-content/index.ts").read_text(encoding="utf-8")
        types = (SITE / "src/types/pto.ts").read_text(encoding="utf-8")
        workbench = (SITE / "src/components/UnitWorkbenchView.tsx").read_text(
            encoding="utf-8"
        )
        renderer = (SITE / "src/components/ReaderGuide.tsx").read_text(
            encoding="utf-8"
        )
        for term in (
            "PTO-READER-BLOCK",
            "safeReaderHref",
            "raw HTML is forbidden",
            "complete zh-CN translation lacks a current accepted review",
            "guide_content_locale",
            "localized_documentation_sha256",
            "reference_route",
        ):
            self.assertIn(term, plugin)
        self.assertIn("interface PtoDocumentationIdentity", types)
        self.assertNotIn("text: string;\n  githubUrl: string;\n  locale", types)
        self.assertIn(
            "<ReaderGuide guide={unitData.readerGuide} mnemonic={Boolean(presentation.mnemonic)} />",
            workbench,
        )
        overview = (SITE / "src/components/InstructionOverview.tsx").read_text(
            encoding="utf-8"
        )
        asl_viewer = (SITE / "src/components/ASLViewer.tsx").read_text(
            encoding="utf-8"
        )
        ledger = (SITE / "src/components/SourceLedger.tsx").read_text(
            encoding="utf-8"
        )
        self.assertNotIn("What this instruction is", overview)
        self.assertNotIn("At a glance", overview)
        self.assertIn("Assembly syntax", overview)
        self.assertIn("Behavior", renderer)
        self.assertIn("ASL pseudocode", asl_viewer)
        self.assertIn("Sources and release identity", ledger)
        self.assertIn("sourceLedgerDetails", ledger)
        self.assertIn("Show commit, paths, hashes, version", ledger)
        for retired_copy in (
            "Reader guide · non-normative explanation",
            "Understand this instruction",
            "理解这条指令",
        ):
            self.assertNotIn(retired_copy, renderer)
        self.assertLess(workbench.index("<InstructionOverview"), workbench.index("<InstructionComposition"))
        self.assertLess(workbench.index("<InstructionComposition"), workbench.index("<AssemblerSymbols"))
        self.assertLess(workbench.index("<AssemblerSymbols"), workbench.index("<EncodingBitfield"))
        self.assertLess(workbench.index("<EncodingBitfield"), workbench.index("<InstructionContractSummary"))
        self.assertLess(workbench.index("<InstructionContractSummary"), workbench.index("<SemanticExecution"))
        self.assertLess(workbench.index("<SemanticExecution"), workbench.index("<ReaderGuide"))
        self.assertLess(workbench.index("<EncodingBitfield"), workbench.index("<SourceLedger"))
        self.assertNotIn("dangerouslySetInnerHTML", renderer)

    def test_tload_bundle_and_semantic_depth_are_source_backed(self) -> None:
        owner = (
            ROOT / "asl/tile/memory-and-data-movement/regular/TLOAD.asl"
        ).read_text(encoding="ascii")
        projection = json.loads(
            (SITE / "data/instruction-projections/PTO-TILE-TLOAD.json").read_text(
                encoding="utf-8"
            )
        )
        plugin = (SITE / "plugins/pto-content/index.ts").read_text(encoding="utf-8")
        workbench = (SITE / "src/components/UnitWorkbenchView.tsx").read_text(
            encoding="utf-8"
        )
        ndf = (SITE / "src/components/NdfClause.tsx").read_text(encoding="utf-8")
        identity = (SITE / "src/components/SemanticIdPath.tsx").read_text(
            encoding="utf-8"
        )
        for term in (
            "canonicalMinCommands",
            "minimumSequence",
            "Ordinary Local destination",
            "Local CUBE conversion",
            "Ordinary Shared destination",
        ):
            self.assertIn(term, json.dumps(projection))
        self.assertEqual(projection["schema"], "pto.site-instruction-projection.v1")
        self.assertEqual(projection["ownerSource"], "asl/tile/memory-and-data-movement/regular/TLOAD.asl")
        projection_text = json.dumps(projection)
        self.assertIn("complete Shared logical parent", projection_text)
        self.assertIn("B.ASSEMBLE", projection_text)
        self.assertIn(
            "Capacity code 1..10: 128 B through 64 KiB per participating PE.",
            projection_text,
        )
        self.assertNotIn(
            "Capacity code 1..12: 128 B through 256 KiB per participating PE.",
            projection_text,
        )
        self.assertNotIn("selected Shared quarters", projection_text)
        self.assertNotIn("selected Shared quarter", projection_text)
        self.assertNotIn("PTO-PAGE-COMPOSITION", owner)
        self.assertNotIn("PTO-PAGE-SEMANTICS", owner)
        for term in (
            "parseInstructionComposition",
            "loadSiteInstructionProjection",
            "parseSemanticExecutionProjection",
            "extractAslFunctionRegion",
            "ownerSourceSha256",
            "fragmentSha256",
            "composition command has no owning unit",
            "shared source is invalid or outside ASL",
        ):
            self.assertIn(term, plugin)
        self.assertLess(workbench.index("<InstructionComposition"), workbench.index("<AssemblerSymbols"))
        self.assertIn("semanticExecution", workbench)
        self.assertIn("draggable", ndf)
        self.assertIn("Restore default order", ndf)
        self.assertIn("canonicalIds", ndf)
        self.assertIn("navigator.clipboard.writeText(identity.fullId)", identity)
        self.assertIn("identity.facets.slice(-4)", identity)
        self.assertIn("facts", projection["semanticExecution"]["stages"][0])

    def test_reader_guide_fences_and_locale_hashes_fail_closed(self) -> None:
        plugin = (SITE / "plugins/pto-content/index.ts").read_text(encoding="utf-8")
        self.assertIn("isCommonMarkFenceClose(line, fenceToken)", plugin)
        self.assertIn("renderedReaderSyntax(line)", plugin)
        self.assertIn("text.replace(/`[^`\\n]*`/g, '')", plugin)
        self.assertIn("candidate.length < opener.length", plugin)
        self.assertIn(
            "character === opener[0]",
            plugin,
            "a closing fence may contain only the opener character",
        )
        self.assertNotIn("line.trim().startsWith(fenceToken)", plugin)
        self.assertRegex(plugin, re.compile(r"fenceToken = opening\[1\]"))
        self.assertIn(
            "translation.locale_guide_sha256 !== localizedGuide.sha256",
            plugin,
        )
        self.assertNotIn(
            "translation.locale_guide_sha256 !== localizedDocumentationSha256",
            plugin,
        )

    def test_architecture_reader_guide_links_every_owned_ndf_clause(self) -> None:
        plugin = (SITE / "plugins/pto-content/index.ts").read_text(encoding="utf-8")
        self.assertIn("[...requirementIds]", plugin)
        self.assertIn("reader guide cannot locate exact NDF owner", plugin)
        self.assertIn("href: identity.sourceUrl", plugin)

    def test_tile_high_level_assembly_dimensions_are_structured_and_fail_closed(self) -> None:
        plugin = (SITE / "plugins/pto-content/index.ts").read_text(encoding="utf-8")
        traceability = json.loads(
            (ROOT / "spec/evidence/release-traceability-readiness.json").read_text(
                encoding="utf-8"
            )
        )
        self.assertIn("has non-structured B.DIM projection", plugin)
        self.assertIn("dimensionBindings", plugin)
        self.assertNotIn("line.matchAll(/LB", plugin)

        owners = []
        ambiguous_owners = []
        structured_dimension = re.compile(
            r"^B\.DIM (?:"
            r"LB[0-2]\s*(?:/|=)\s*[A-Za-z][A-Za-z0-9_]*,\s*"
            r"LB[0-2]\s*(?:/|=)\s*[A-Za-z][A-Za-z0-9_]*,\s*"
            r"LB[0-2]\s*(?:/|=)\s*[A-Za-z][A-Za-z0-9_]*(?:\s+\([^)]*\))?"
            r"|LB[0-2](?:\s*=\s*|\s+)[A-Za-z][A-Za-z0-9_]*"
            r"(?:\s+or\s+cooperative\s+group_M)?(?:\s+\([^)]*\))?"
            r"|LB[0-2]/LB[0-2]/LB[0-2](?:\s+\(optional\))?"
            r"|LB[0-2](?:\s+\(optional\))?)$"
        )
        for source_path in sorted((ROOT / "asl/tile").rglob("*.asl")):
            first_line = source_path.read_text(encoding="ascii").splitlines()[0]
            if not first_line.startswith("// PTO-INSTRUCTION: "):
                continue
            metadata = json.loads(first_line.removeprefix("// PTO-INSTRUCTION: "))
            if metadata.get("mnemonic") is not None:
                owners.append(metadata["id"])
                block = list(dict.fromkeys([
                    *metadata.get("block", []),
                    *metadata.get("contract", {}).get("block_composition", []),
                ]))
                invalid = [
                    line for line in block
                    if line.startswith("B.DIM") and structured_dimension.fullmatch(line) is None
                ]
                if invalid:
                    ambiguous_owners.append((metadata["mnemonic"], invalid))
        expected_owners = {
            unit["id"] for unit in traceability["units"]
            if unit["surface"] == "tile" and unit["mnemonic"] is not None
        }
        self.assertSetEqual(set(owners), expected_owners)
        self.assertEqual(ambiguous_owners, [])
        for bad_form in (
            "B.DIM (LB1/LB2 for 2D)",
            "B.DIM LB1/LB2 for 2D",
            "B.DIM dimensions depend on shape",
            "B.DIM LB0 and maybe LB1",
            "B.DIM use rows and columns",
            "B.DIM as required",
        ):
            self.assertIsNone(structured_dimension.fullmatch(bad_form), bad_form)

    def test_ndf_catalog_and_detail_cover_release_traceability(self) -> None:
        plugin = (SITE / "plugins/pto-content/index.ts").read_text(encoding="utf-8")
        types = (SITE / "src/types/pto.ts").read_text(encoding="utf-8")
        catalog = (SITE / "src/routes/NdfCatalog.tsx").read_text(encoding="utf-8")
        detail = (SITE / "src/routes/NdfDetail.tsx").read_text(encoding="utf-8")
        traceability = json.loads(
            (ROOT / "spec/evidence/release-traceability-readiness.json").read_text(
                encoding="utf-8"
            )
        )
        requirement_ids = [row["id"] for row in traceability["requirements"]]
        self.assertGreater(len(requirement_ids), 0)
        self.assertEqual(len(requirement_ids), len(set(requirement_ids)))
        self.assertIn("...instructionContracts.keys()", plugin)
        self.assertNotIn("filter((id) => !instructionContractIds.has(id))", plugin)
        self.assertIn("entryKind: 'instruction-contract'", plugin)
        self.assertIn("the link opens its canonical unit workbench directly", catalog)
        for field in ("adrs", "tests", "evidence", "relationships", "relationshipFallbackRoute"):
            self.assertIn(f"  {field}:", types)
        self.assertIn("Local relationship neighborhood", detail)
        self.assertIn("<EvidenceIndex", detail)
        self.assertIn("Open the complete NDF relationship explorer", detail)

    def test_interactive_routes_keep_static_fallbacks(self) -> None:
        explorer = (SITE / "src/components/NdfGlobalExplorer.tsx").read_text(
            encoding="utf-8"
        )
        workbench = (SITE / "src/components/UnitWorkbenchView.tsx").read_text(
            encoding="utf-8"
        )
        self.assertIn("BrowserOnly", explorer)
        self.assertIn("GraphIndex", explorer)
        self.assertIn("api.purge", explorer)
        self.assertIn("TloadStateTransitionDemo", workbench)
        self.assertIn("EvidenceIndex", workbench)

    def test_artifact_gate_exhaustively_checks_bilingual_unit_routes(self) -> None:
        checker = (ROOT / "scripts/check-site-artifact").read_text(encoding="utf-8")
        for term in (
            "validate_unit_routes",
            "validate_instruction_coverage",
            'pto.site-unit-routes.v1',
            'pto.site-instruction-coverage.v1',
            'zh-CN/pto-unit-routes.json',
            'zh-CN/pto-instruction-coverage.json',
            'UnitWorkbenchView.arm-style.v1',
            'unexplained_omissions',
            'search index does not route',
            'documentation_sha256',
            'expected_reader_projection',
            'guide_content_locale',
            'localized_documentation_sha256',
            'MAX_UNIT_HTML_BYTES',
            'evidence/test-sources',
            'WaveDrom must remain exact-pinned to 3.6.1',
            'WaveDrom leaked into the homepage JavaScript',
            'site artifact has no lazy WaveDrom rendering chunk',
        ):
            self.assertIn(term, checker)

        lighthouse = (ROOT / "scripts/check-site-lighthouse").read_text(
            encoding="utf-8"
        )
        self.assertIn("largest_unit_route", lighthouse)
        self.assertIn("largest unit desktop", lighthouse)

    def test_design_contract_is_active(self) -> None:
        self.assertIn("- Status: Active", DESIGN_TEXT)
        self.assertIn("asl/**/*.asl", DESIGN_TEXT)
        self.assertIn("site validity is release-blocking", DESIGN_TEXT.lower())

    def test_site_workflow_is_read_only_and_commit_pinned(self) -> None:
        workflow = (ROOT / ".github/workflows/site.yml").read_text(encoding="utf-8")
        self.assertIn("on:\n  workflow_dispatch:", workflow)
        self.assertNotIn("pull_request:", workflow)
        self.assertNotIn("push:", workflow)
        self.assertIn("permissions:\n  contents: read", workflow)
        self.assertIn(
            "actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803",
            workflow,
        )
        self.assertIn(
            "actions/setup-node@2028fbc5c25fe9cf00d9f06a71cc4710d4507903",
            workflow,
        )
        self.assertIn("pnpm@10.30.0", workflow)
        self.assertNotIn("contents: write", workflow)

    def test_release_workflow_blocks_on_site_validity(self) -> None:
        workflow = (ROOT / ".github/workflows/release.yml").read_text(
            encoding="utf-8"
        )
        self.assertIn("release-site:", workflow)
        self.assertIn("name: pto-site-preview-${{ inputs.commit }}", workflow)
        self.assertIn("artifact-digest: ${{ steps.site-preview.outputs.artifact-digest }}", workflow)
        self.assertIn("SITE_ARTIFACT_DIGEST", workflow)
        self.assertIn("RELEASE_SITE_RESULT", workflow)
        self.assertIn("PTO_SITE_CROSS_BROWSER=1", workflow)
        self.assertIn("PTO_SITE_REQUIRE_CLEAN=1", workflow)
        self.assertIn("PTO_SITE_RELEASE_COMMIT: ${{ inputs.commit }}", workflow)
        self.assertIn("python3 scripts/check-site-lighthouse", workflow)
        self.assertIn('test "$RELEASE_SITE_RESULT" = success', workflow)

    def test_site_security_policy_mitigates_unpatched_image_parsers(self) -> None:
        security = (ROOT / "scripts/check-site-security").read_text(encoding="utf-8")
        self.assertIn('MITIGATED_ADVISORIES = {"1138808", "1138809"}', security)
        for suffix in ('.icns', '.jxl', '.heif'):
            self.assertIn(f'"{suffix}"', security)
        for magic in ("ICNS", "JXL", "HEIF", "vulnerable_image_magic"):
            self.assertIn(magic, security)
        self.assertIn("site image reference escapes docs/", security)
        self.assertIn("unquote(parsed.path)", security)
        self.assertIn('decoded.startswith("@site/")', security)
        self.assertNotIn('"--prod"', security)
        self.assertIn("pnpm", security)
        self.assertIn("audit", security)
        publication = (ROOT / "scripts/check-publication-hygiene").read_text(
            encoding="utf-8"
        )
        self.assertIn('Path("docs/site/pnpm-lock.yaml")', publication)

    def test_redirect_manifest_is_nonempty_and_unique(self) -> None:
        redirects = json.loads((SITE / "redirects.json").read_text(encoding="utf-8"))
        sources = [source for redirect in redirects for source in redirect["from"]]
        self.assertGreaterEqual(len(sources), 8)
        self.assertEqual(len(sources), len(set(sources)))
        for redirect in redirects:
            self.assertTrue(redirect["to"].startswith("/"))

    def test_publication_handoff_is_content_addressed(self) -> None:
        generator = (ROOT / "scripts/generate-site-publication-manifest").read_text(
            encoding="utf-8"
        )
        checker = (ROOT / "scripts/check-site-artifact").read_text(encoding="utf-8")
        handoff = (SITE / "deployment/README.md").read_text(encoding="utf-8")
        for field in (
            "architecture_version",
            "publication_version",
            "site_tree_sha256",
            "redirect_manifest_sha256",
            "dependency_lock_sha256",
            "source_commit",
            "release_eligible",
        ):
            self.assertIn(field, generator)
            self.assertIn(field, handoff)
        self.assertIn("PTO_SITE_RELEASE_COMMIT must equal HEAD", generator)
        self.assertIn("PTO_SITE_RELEASE_COMMIT must equal HEAD", checker)

    def test_release_boundary_graph_omits_only_retired_baseline_impacts(self) -> None:
        plugin = (SITE / "plugins/pto-content/index.ts").read_text(encoding="utf-8")
        self.assertIn("release_boundary?: boolean", plugin)
        self.assertEqual(
            plugin.count(
                "if (!nodes.has(id) && record.release_boundary === true) continue;"
            ),
            2,
        )
        self.assertIn(
            "fail(`graph edge ${kind} references missing node ${source} -> ${target}`)",
            plugin,
        )


DESIGN_TEXT = (ROOT / "DESIGN.md").read_text(encoding="utf-8")


if __name__ == "__main__":
    unittest.main()
