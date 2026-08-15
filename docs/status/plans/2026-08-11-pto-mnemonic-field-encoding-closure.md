# PTO Mnemonic and Field Encoding Closure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. This plan MUST be executed inline; the user explicitly prohibited subagent execution.

**Goal:** Make ASL the complete source for every PTO mnemonic, encoded-field value, reserved encoding, block composition, and generated instruction explanation, then publish a clean exact-head PTO release.

**Architecture:** Extend the existing ASL metadata graph with shared field-domain contracts and resolved per-instruction contracts. Keep executable ASL authoritative for decode and effects, generate catalogs/Markdown/navigation/tests from the same graph, and split lightweight structural checks from exhaustive release-only ASLRef execution.

**Tech Stack:** ASL1, Python 3 standard library, JSON metadata embedded in ASL comments, `unittest`, Make, MkDocs generation, GitHub Actions exact-head release workflow.

## Global Constraints

- Normative instruction facts MUST have one authored home under `asl/`; no second hand-maintained JSON or Markdown instruction source is permitted.
- `B.DATR.DataType` is five bits with exactly 25 assigned values and reserved codes `15,21,22,23,29,30,31`.
- Reserved values MUST reject before architectural effects and MUST NOT have accepted assembly or canonical disassembly spellings.
- Code zero means FP64; no code means `NONE`, `NULL`, inheritance, or absence.
- The five-bit block DataType namespace MUST remain distinct from scalar numeric namespaces and the six-bit TLSU transfer-type namespace.
- Every `PTO-INSTRUCTION` MUST declare one encoding class and a complete resolved explanation contract.
- Every selector-encoded Tile operation MUST state that it has no standalone opcode and MUST define exact block composition and defaults.
- PR validation remains lightweight; exhaustive ASLRef validation and coverage remain manual release gates.
- A failed, missing, skipped, or pending release check MUST NOT count as success.
- Existing masks, matches, selectors, assembly behavior, and semantics MUST remain unchanged unless an additional accepted architecture decision explicitly changes them.
- All edits occur in `/private/tmp/pto-spec-mnemonic-contract-design` on `codex/mnemonic-field-encoding-closure-design`; `/Users/zhoubot/github/pto-spec` remains untouched.

---

### Task 1: Parse shared field domains and instruction explanation contracts

**Files:**
- Create: `scripts/instruction_contracts.py`
- Modify: `scripts/asl_units.py`
- Modify: `scripts/instruction_docs.py`
- Modify: `scripts/check-repository`
- Test: `tests/scripts/test_instruction_contracts.py`
- Test: `tests/scripts/test_instruction_docs.py`

**Interfaces:**
- Consumes: `AslUnit.metadata`, instruction catalog records, ASL source paths.
- Produces: `FieldDomainContract`, `ResolvedInstructionContract`, `load_field_domains(units)`, `resolve_instruction_contract(unit, domains)`, and `check_instruction_contracts(root, surface=None)`.

- [ ] **Step 1: Write parser and validation tests that demonstrate the missing contract**

```python
def test_five_bit_domain_requires_all_32_dispositions(self) -> None:
    domain = metadata_domain(width=5, assigned=range(25), reserved=range(25, 31))
    self.assertIn("field domain is missing value 31", validate_domain(domain))

def test_instruction_rejects_placeholder_role(self) -> None:
    metadata = instruction_metadata(role="encoded operand or control")
    self.assertIn("placeholder architectural role", validate_instruction(metadata))

def test_selector_operation_requires_no_standalone_and_composition(self) -> None:
    metadata = tile_metadata(encoding_class="selector-encoded-block-operation")
    self.assertIn("missing block composition", validate_instruction(metadata))
```

- [ ] **Step 2: Run the focused tests and verify they fail for missing interfaces**

Run: `python3 -m unittest tests.scripts.test_instruction_contracts tests.scripts.test_instruction_docs -v`

Expected: FAIL because `scripts.instruction_contracts` and the new resolved-contract fields do not exist.

- [ ] **Step 3: Implement the contract data model and fail-closed validators**

```python
@dataclass(frozen=True)
class FieldDomainContract:
    contract_id: str
    width: int
    role: str
    zero_meaning: str
    assigned: tuple[tuple[int, str], ...]
    reserved: tuple[int, ...]
    rejection: str

@dataclass(frozen=True)
class ResolvedInstructionContract:
    encoding_class: str
    canonical_assembly: tuple[str, ...]
    field_domains: tuple[tuple[str, FieldDomainContract], ...]
    operands: tuple[dict[str, object], ...]
    defaults: tuple[str, ...]
    legality: tuple[str, ...]
    state_effects: tuple[str, ...]
    memory_effects: tuple[str, ...]
    ordering: tuple[str, ...]
    exceptions: tuple[str, ...]
    examples: tuple[str, ...]
    block_composition: tuple[str, ...]
    standalone_opcode: bool

def validate_domain(domain: FieldDomainContract) -> list[str]:
    maximum = 1 << domain.width
    assigned = {value for value, _ in domain.assigned}
    reserved = set(domain.reserved)
    errors = []
    if assigned & reserved:
        errors.append(f"{domain.contract_id}: assigned and reserved values overlap")
    missing = sorted(set(range(maximum)) - assigned - reserved)
    if missing:
        errors.append(f"{domain.contract_id}: field domain is missing values {missing}")
    return errors
```

The validator MUST reject unknown encoding classes, unresolved domain IDs, out-of-width values, duplicate meanings, missing zero semantics, placeholder prose, empty required subjects, selector operations with `standalone_opcode=true`, and catalog fields without resolved domains.

- [ ] **Step 4: Integrate validation without making every current instruction fail yet**

Add `--surface` and `--require-complete` support to the checker. Repository validation invokes schema parsing for all records immediately, while global completeness becomes mandatory only after Tasks 4–8 remove the temporary explicit family allowlist stored in `instruction_contracts.py`.

Run: `python3 -m unittest tests.scripts.test_instruction_contracts tests.scripts.test_instruction_docs -v`

Expected: PASS.

- [ ] **Step 5: Run lightweight repository checks**

Run: `make pr-check && make repo-check`

Expected: PASS with unchanged catalog and binary fingerprints.

- [ ] **Step 6: Commit the schema boundary**

```bash
git add scripts/instruction_contracts.py scripts/asl_units.py scripts/instruction_docs.py \
  scripts/check-repository tests/scripts/test_instruction_contracts.py \
  tests/scripts/test_instruction_docs.py
git commit -m "spec: add instruction contract schema"
```

### Task 2: Make the five-bit Tile DataType namespace total

**Files:**
- Modify: `asl/arch/data-types/tile-data-types.asl`
- Modify: `asl/tile/model/definedness/elements.asl`
- Modify: `asl/block/attributes/B.DATR.asl`
- Modify: `asl/block/model/schema/attributes.asl`
- Modify: `asl/block/model/dispatch/numeric-control.asl`
- Test: `tests/asl/block/attributes/B.DATR/block-exec-data-attributes-001.asl`
- Create: `tests/asl/arch/data-types/tile-data-types/arch-bound-tiledatatype-reserved-001.asl`
- Modify: `tests/scripts/test_common_v058_contract.py`

**Interfaces:**
- Consumes: `PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES` and `FieldDomainContract` schema.
- Produces: `type TileDataTypeEncoding of bits(5)`, `TileDataTypeEncodingValid`, `TileDataTypeFromEncoding`, `TileDataTypeToEncoding`, and shared domain ID `PTO-FIELD-BLOCK-DATATYPE`.

- [ ] **Step 1: Add failing totality and reserved-rejection tests**

```asl
func TestTileDataTypeReservedEncodings()
begin
    for code = 0 to 31 looplimit 32 do
        let encoded = code as bits(5);
        let expected_reserved = code == 15 || (21 <= code && code <= 23) ||
                                (29 <= code && code <= 31);
        assert TileDataTypeEncodingValid(encoded) == !expected_reserved;
    end;
end;
```

The decoded B.DATR test MUST execute each of the seven reserved words and assert `Fault_IllegalInstruction`, unchanged bundle attributes, unchanged TPC/BPC except trap entry, and no Tile or memory effect.

- [ ] **Step 2: Run focused tests and confirm the six-bit owner/implicit-reserved gap**

Run: `python3 -m unittest tests.scripts.test_common_v058_contract -v && ./scripts/run-asl-test --id PTO-AVS-ARCH-TILEDATATYPE-RESERVED-001`

Expected: FAIL because the five-bit functions and explicit reserved contract are absent.

- [ ] **Step 3: Move encoding ownership to the arch data-type unit**

```asl
type TileDataTypeEncoding of bits(5);

pure func TileDataTypeEncodingValid(encoded: TileDataTypeEncoding) => boolean
begin
    let code = UInt(encoded);
    return code <= 14 || (16 <= code && code <= 20) ||
           (24 <= code && code <= 28);
end;
```

Move the mapping functions out of `elements.asl`. Add `PTO-FIELD-BLOCK-DATATYPE` metadata with the exact 25 assigned rows and reserved values `[15,21,22,23,29,30,31]`. Make every consumer depend on the arch unit and accept only `bits(5)` for this namespace.

- [ ] **Step 4: Bind B.DATR to the shared domain and explicit before-effects rejection**

Add to B.DATR metadata:

```json
"encoding_class":"standalone-encoded",
"canonical_assembly":["B.DATR {layout, datatype, padvalue_or_byteid, cmode, rmode, sat, canonicalize}"],
"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}}
```

Preserve the existing match, mask, pieces, and accepted constraint. The handler MUST not use a fallback type for a reserved value.

- [ ] **Step 5: Run the focused tests and regenerate projections**

Run: `python3 scripts/project_asl_catalogs.py --root . --write && python3 scripts/instruction_docs.py generate && python3 scripts/generate-mnemonic-avs.py --write`

Run: `python3 -m unittest tests.scripts.test_common_v058_contract tests.scripts.test_instruction_contracts -v`

Expected: PASS with 25 assigned, seven reserved, and no `NONE` value.

- [ ] **Step 6: Run the B.DATR ASL point and repository checks**

Run: `./scripts/run-asl-test --id PTO-AVS-BLOCK-TESTBUNDLEDATAATTRIBUTES-EXECUTION-001`

Run: `make pr-check && make repo-check`

Expected: PASS; binary masks, matches, and selectors unchanged.

- [ ] **Step 7: Commit the DataType closure**

```bash
git add asl/arch/data-types/tile-data-types.asl \
  asl/tile/model/definedness/elements.asl asl/block/attributes/B.DATR.asl \
  asl/block/model/schema/attributes.asl asl/block/model/dispatch/numeric-control.asl \
  tests/asl/arch/data-types/tile-data-types \
  tests/asl/block/attributes/B.DATR tests/scripts/test_common_v058_contract.py \
  spec/catalog docs/arch docs/block docs/mkdocs tests/asl
git commit -m "spec: reserve unassigned block datatype values"
```

### Task 3: Render complete field/value and explanation sections

**Files:**
- Modify: `scripts/instruction_docs.py`
- Modify: `scripts/instruction_contracts.py`
- Test: `tests/scripts/test_instruction_docs.py`
- Test: `tests/scripts/test_instruction_contracts.py`

**Interfaces:**
- Consumes: `ResolvedInstructionContract` from Task 1.
- Produces: generated sections `Encoding class`, `Field value dispositions`, `Defaults and zero`, `Operation`, `State effects`, `Memory and ordering`, `Legality and exceptions`, `Examples`, and `Block composition`.

- [ ] **Step 1: Write failing rendering tests for B.DATR and a selector Tile operation**

```python
def test_b_datr_renders_all_datatype_values(self) -> None:
    page = render_fixture("B.DATR")
    self.assertIn("| 31 | reserved | future extension |", page)
    self.assertIn("Code zero means `FP64`", page)
    self.assertNotIn("encoded operand or control", page)

def test_tadd_declares_selector_encoding_and_no_standalone_opcode(self) -> None:
    page = render_fixture("TADD")
    self.assertIn("selector-encoded-block-operation", page)
    self.assertIn("This operation has no standalone opcode.", page)
    self.assertIn("BSTART.VEC TADD, DataType", page)
```

- [ ] **Step 2: Run focused rendering tests and confirm failure**

Run: `python3 -m unittest tests.scripts.test_instruction_docs -v`

Expected: FAIL because the current renderer exposes raw constraints and placeholder roles.

- [ ] **Step 3: Replace generic rendering with resolved structured sections**

The renderer MUST use resolved contract objects and MUST render explicit `none` for non-applicable state, memory, ordering, or result subjects. It MUST preserve byte-derived `DOC-BEGIN` regions and supplementary prose boundaries.

- [ ] **Step 4: Add stale-page and missing-section negative fixtures**

Fixture assertions MUST show that removing one reserved row, replacing a role with the placeholder phrase, or deleting “no standalone opcode” makes `instruction_docs.py --check` fail.

- [ ] **Step 5: Generate and verify pages**

Run: `python3 scripts/instruction_docs.py generate && python3 scripts/instruction_docs.py --check`

Run: `python3 -m unittest tests.scripts.test_instruction_docs tests.scripts.test_instruction_contracts -v`

Expected: PASS.

- [ ] **Step 6: Commit the renderer**

```bash
git add scripts/instruction_docs.py scripts/instruction_contracts.py \
  tests/scripts/test_instruction_docs.py tests/scripts/test_instruction_contracts.py \
  docs/arch docs/block docs/scalar docs/tile docs/mkdocs
git commit -m "docs: generate complete instruction contracts"
```

### Task 4: Close every Block field and composition contract

**Files:**
- Create: `asl/arch/overview/block-field-contracts.asl`
- Modify: all 68 mnemonic files under `asl/block/attributes/`, `asl/block/encoding/`, `asl/block/execution/`, `asl/block/lifecycle/`, and `asl/block/operands/`
- Modify: relevant schema owners under `asl/block/model/schema/`, `asl/block/model/operands/`, `asl/block/model/dispatch/`, and `asl/block/model/commit/`
- Create: `tests/scripts/test_block_instruction_contracts.py`
- Create: independent points below `tests/asl/block/` for each newly explicit reserved/default rule

**Interfaces:**
- Consumes: shared contract schema and renderer.
- Produces: complete Block field domains, defaults, aliases, deleted-name dispositions, and operation-specific Tile block compositions.

- [ ] **Step 1: Add a failing all-Block closure test**

```python
def test_every_block_instruction_contract_is_complete(self) -> None:
    errors = check_instruction_contracts(ROOT, surface="block")
    self.assertEqual(errors, [])

def test_deleted_names_are_not_instruction_records(self) -> None:
    self.assertEqual(name_disposition("B.IOD"), "deleted")
    self.assertEqual(name_disposition("BSTART.PAR"), "deleted")
    self.assertEqual(name_disposition("C.B.IOS"), "deleted")
```

- [ ] **Step 2: Run the Block closure test and record every missing field/domain/topic**

Run: `python3 -m unittest tests.scripts.test_block_instruction_contracts -v`

Expected: FAIL with the complete deterministic list of incomplete Block records.

- [ ] **Step 3: Define shared Block raw-field domains**

The new arch unit MUST own raw meanings for DataType, Mode, Function, Layout, CMode, RMode, TSize, PE_MASK, SharedID, Local Tile selectors, GPR selectors, BrType, hint fields, fixed-zero regions, and every remaining Block field. Assigned/reserved partitions MUST cover each full width.

- [ ] **Step 4: Complete all Block instruction metadata**

For each Block mnemonic, add exact `encoding_class`, canonical rendering, resolved field references, operand/results, omission versus encoded-zero behavior, state/memory/order/exception subjects, and examples. Engine aliases MUST be `encoding-alias`; typed starts MUST name their selector owner; lifecycle and command forms MUST be `standalone-encoded`.

- [ ] **Step 5: Complete selector-operation block compositions**

For each Tile operation referenced by a Block start, encode required commands, optional commands, defaults, operand binding sources, surplus-field rejection, commit point, and no-effect fault boundary. Preserve B.IOR omission/encoded-zero semantics and PE_MASK zero strict no-op.

- [ ] **Step 6: Add generated reserved/default canaries and run them**

Run: `python3 -m unittest tests.scripts.test_block_instruction_contracts -v`

Generate an exact temporary matrix from the canonical test registry, retaining only IDs whose source path starts with `tests/asl/block/`, then run that matrix with host parallelism:

```bash
python3 scripts/print-asl-test-matrix --page-size 100000 --page 0 \
  | python3 -c 'import json,sys; m=json.load(sys.stdin); m["include"]=[r for r in m["include"] if r["path"].startswith("tests/asl/block/")]; json.dump(m,sys.stdout)' \
  > /tmp/pto-block-asl-matrix.json
./scripts/run-asl-page --matrix /tmp/pto-block-asl-matrix.json \
  -j "${PTO_ASL_TEST_JOBS:-$(getconf _NPROCESSORS_ONLN)}"
```

Expected: PASS for every Block point named in the exact matrix.

- [ ] **Step 7: Regenerate and commit Block closure**

Run: `python3 scripts/project_asl_catalogs.py --root . --write && python3 scripts/instruction_docs.py generate && python3 scripts/generate-mnemonic-avs.py --write && make pr-check && make repo-check`

```bash
git add asl/arch/overview/block-field-contracts.asl asl/block tests/asl/block \
  tests/scripts/test_block_instruction_contracts.py spec/catalog docs/block docs/mkdocs
git commit -m "spec: close block instruction explanations"
```

### Task 5: Close Scalar instruction contracts by family

**Files:**
- Create: `asl/arch/overview/scalar-field-contracts.asl`
- Modify: all mnemonic files under `asl/scalar/agu/`, `asl/scalar/alu/`, `asl/scalar/amo/`, `asl/scalar/bru/`, `asl/scalar/fsu/`, and `asl/scalar/sys/`
- Modify: semantic owners under `asl/scalar/model/`
- Create: `tests/scripts/test_scalar_instruction_contracts.py`
- Create or extend independent points below `tests/asl/scalar/`

**Interfaces:**
- Consumes: scalar catalog fields, semantic-handler bindings, Reg5 contracts, memory/fault/order model clauses.
- Produces: complete contracts for all 474 scalar forms without changing their binary closure.

- [ ] **Step 1: Add one failing family-count closure test**

```python
EXPECTED = {"agu": 183, "alu": 107, "amo": 53, "bru": 66, "fsu": 30, "sys": 35}

def test_every_scalar_family_is_complete(self) -> None:
    for family, count in EXPECTED.items():
        records = scalar_records(family)
        self.assertEqual(len(records), count)
        self.assertEqual(validate_records(records), [], family)
```

- [ ] **Step 2: Run the scalar closure test and verify deterministic family failures**

Run: `python3 -m unittest tests.scripts.test_scalar_instruction_contracts -v`

Expected: FAIL until each family is completed.

- [ ] **Step 3: Define the complete scalar raw-field contract set**

Cover all 45 catalog field kinds, including Reg5 sources/destinations, immediates, address modifiers, widths, type selectors, ordering bits, request classes, system-register addresses, fixed/ignored fields, and reserved ranges. Immediate fields assign their full bit domains; selector fields partition assigned/reserved values.

- [ ] **Step 4: Complete AGU and AMO contracts and tests**

Each mnemonic MUST state exact access width/sign, address formation/scaling, pre/post writeback, source/destination roles, preflight and restart, memory events, atomicity, reservation effects, and fault preservation. Run:

`python3 -m unittest tests.scripts.test_scalar_instruction_contracts.ScalarInstructionContractTest.test_agu tests.scripts.test_scalar_instruction_contracts.ScalarInstructionContractTest.test_amo -v`

- [ ] **Step 5: Complete ALU and BRU contracts and tests**

Each mnemonic MUST state fixed-width arithmetic, extension, shift/bitfield bounds, source snapshot, result write order, target calculation, taken/not-taken behavior, and odd-target fault behavior. Run the ALU and BRU methods from the same test class.

- [ ] **Step 6: Complete FSU and SYS contracts and tests**

Each FSU mnemonic MUST state raw type legality, carrier width, rounding source/override, flags, result class, and profile boundary. Each SYS mnemonic MUST state privilege, address/operand legality, system state effect, fence/order behavior, request/trap behavior, and no-effect rejection. Run the FSU and SYS methods.

- [ ] **Step 7: Remove all generic scalar summaries and run the global scalar gate**

Run: `rg -n 'this mnemonic|encoded operand or control|Execute the .* instruction contract' asl/scalar docs/scalar`

Expected: no matches in active generated instruction content.

Run: `python3 -m unittest tests.scripts.test_scalar_instruction_contracts -v && make pr-check && make repo-check`

- [ ] **Step 8: Regenerate and commit scalar closure**

```bash
git add asl/arch/overview/scalar-field-contracts.asl asl/scalar tests/asl/scalar \
  tests/scripts/test_scalar_instruction_contracts.py spec/catalog/scalar-forms.json \
  docs/scalar docs/mkdocs
git commit -m "spec: close scalar instruction explanations"
```

### Task 6: Close selector-encoded Tile operation contracts

**Files:**
- Create: `asl/arch/overview/tile-selector-contracts.asl`
- Modify: all 109 mnemonic files below the seven active instruction-class directories under `asl/tile/`
- Modify: semantic owners below `asl/tile/model/dispatch/`, `asl/tile/model/execution/`, `asl/tile/model/legality/`, `asl/tile/model/memory/`, and `asl/tile/model/numeric/`
- Create: `tests/scripts/test_tile_instruction_contracts.py`
- Create or extend independent points below `tests/asl/tile/`

**Interfaces:**
- Consumes: Mode/Function selectors, VEC/SFU/TLSU/CUBE engine classification, Block composition contracts, Tile legality/effect handlers.
- Produces: 109 complete selector-encoded operation records and explicit reserved selector coverage.

- [ ] **Step 1: Add failing counts and encoding-class tests**

```python
def test_all_109_tile_operations_are_selector_encoded(self) -> None:
    records = tile_records()
    self.assertEqual(len(records), 109)
    self.assertEqual({record.contract.encoding_class for record in records},
                     {"selector-encoded-block-operation"})
    self.assertTrue(all(not record.contract.standalone_opcode for record in records))
```

- [ ] **Step 2: Run the Tile closure test and verify failure**

Run: `python3 -m unittest tests.scripts.test_tile_instruction_contracts -v`

Expected: FAIL because the current metadata has block strings but no resolved encoding class/default/effect contract.

- [ ] **Step 3: Define TEPL-carrier, TLSU, and CUBE selector domains**

The arch unit MUST distinguish encoding carrier from engine. It MUST enumerate assigned selectors and reserved complements, retain TFMA at selector `0x01C`, retain 35 VEC/52 SFU/10 TLSU/12 CUBE engine counts, and preserve every PTO-owned extension reservation.

- [ ] **Step 4: Complete VEC and SFU operation explanations**

For elementwise, scalar/immediate, reduction/expansion, layout/rearrangement, and irregular/complex operations, state exact operands/results, shapes, valid-region rules, aliases, numeric controls, preserved regions, faults, and operation ASL. VEC MUST remain elementwise-only; complex hardware operations MUST remain SFU.

- [ ] **Step 5: Complete TLSU operation explanations**

State GM base and logical row stride, packed-nibble addressing, per-PE private GPR resolution, preflight, atomic/CAS behavior, memory events, ordering, restart, Shared quarter behavior, and mask-zero no-op. TLOAD/TSTORE stride encoding MUST remain unchanged.

- [ ] **Step 6: Complete CUBE operation explanations**

State all Local/Shared operands, explicit Local accumulator inputs, matrix shapes, DataType/scale relationships, selected Shared-quarter behavior, alias legality, preflight, destination atomicity, and numeric profile boundary.

- [ ] **Step 7: Generate exhaustive reserved selector and composition canaries**

Every reserved TEPL/TLSU/CUBE selector MUST reject before effects. Every accepted operation MUST have one direct selector witness and one complete-block composition witness with exact required/optional/default command resolution.

- [ ] **Step 8: Run Tile gates and commit**

Run: `python3 -m unittest tests.scripts.test_tile_instruction_contracts -v`

Run: `python3 scripts/project_asl_catalogs.py --root . --write && python3 scripts/instruction_docs.py generate && python3 scripts/generate-mnemonic-avs.py --write && make pr-check && make repo-check`

```bash
git add asl/arch/overview/tile-selector-contracts.asl asl/tile tests/asl/tile \
  tests/scripts/test_tile_instruction_contracts.py spec/catalog/tile-operations.json \
  spec/catalog/extension-encoding-reservations.json docs/tile docs/mkdocs
git commit -m "spec: close tile operation explanations"
```

### Task 7: Turn global completeness on and close traceability

**Files:**
- Modify: `scripts/instruction_contracts.py`
- Modify: `scripts/check-repository`
- Modify: `scripts/generate-release-traceability-readiness`
- Modify: `scripts/generate-release-gate-readiness`
- Modify: `scripts/generate-release-manifest`
- Create: `scripts/generate-instruction-contract-closure`
- Modify: `spec/requirements.json`
- Modify: `spec/release-inputs.json`
- Create: `spec/evidence/instruction-contract-closure.json`
- Modify: generated evidence under `spec/evidence/`
- Test: `tests/scripts/test_instruction_contracts.py`
- Test: `tests/scripts/test_release_closure.py`

**Interfaces:**
- Consumes: complete Block, Scalar, Tile, and Arch contracts.
- Produces: global zero-gap counts, a canonical instruction-contract projection, and release evidence that hashes the new checker and structured projection.

- [ ] **Step 1: Add a regression that requires global completeness without allowlists**

```python
def test_global_contract_has_no_exempt_instruction_family(self) -> None:
    self.assertNotIn("INCOMPLETE_FAMILY_ALLOWLIST", source_text())
    self.assertEqual(check_instruction_contracts(ROOT), [])
```

- [ ] **Step 2: Run the regression and confirm it fails while the allowlist exists**

Run: `python3 -m unittest tests.scripts.test_instruction_contracts -v`

Expected: FAIL on the explicit temporary allowlist.

- [ ] **Step 3: Remove staged exemptions and add exact closure summaries**

The checker output MUST report the exact active-mnemonic and encoded-form counts projected from the reviewed ASL tree, 109 selector-encoded Tile operations, zero unresolved field domains, zero placeholder roles, zero missing explanation subjects, and zero active legacy routes. Deleted or extension-reserved forms MUST NOT remain in the accepted count.

- [ ] **Step 4: Add the canonical structured contract projection**

`scripts/generate-instruction-contract-closure` MUST serialize every resolved active mnemonic contract in stable mnemonic/form order, include its ASL owner and NDF clause links, and emit `spec/evidence/instruction-contract-closure.json`. It MUST expose `--check` and fail if generated bytes differ. Add this artifact to `spec/release-inputs.json` as a canonical input owned by the generator; the release manifest MUST hash it. No consumer may read raw Markdown or reconstruct instruction semantics independently.

- [ ] **Step 5: Add requirement and evidence ownership**

Add stable requirement IDs for field-domain totality, mnemonic explanation completeness, block-composition closure, and projection equality. Release traceability MUST link each instruction and field contract to its ASL owner, page, test points, and bounded status.

- [ ] **Step 6: Regenerate release evidence and verify exact set equality**

Run: `./scripts/generate-instruction-contract-closure && ./scripts/generate-release-traceability-readiness && ./scripts/generate-release-gate-readiness && ./scripts/generate-release-manifest`

Run: `make release-evidence-check && make pr-check && make repo-check`

Expected: PASS and clean generated evidence.

- [ ] **Step 7: Commit global closure**

```bash
git add scripts spec tests/scripts docs/mkdocs
git commit -m "spec: enforce mnemonic and field contract closure"
```

### Task 8: Perform final PTO review and freeze an exact candidate

**Files:**
- Review: every file changed since `1c2cb0dcafdbc151357c83e89e7d9460b5d9f401`
- Modify only if review finds a concrete defect.

**Interfaces:**
- Consumes: Tasks 1–7.
- Produces: one clean exact candidate commit and recorded reviewed tree.

- [ ] **Step 1: Audit binary identity and intended semantic delta**

Run: `git diff 1c2cb0dcafdbc151357c83e89e7d9460b5d9f401...HEAD -- spec/catalog/`

Expected: only structured explanation/reserved-disposition additions; no unintended mask, match, selector, operand-piece, or accepted-form change.

- [ ] **Step 2: Audit all explanation counts and forbidden text**

Run: `python3 scripts/instruction_contracts.py --check --summary`

Run: `rg -n 'encoded operand or control|this mnemonic|Execute the .* instruction contract' asl docs/arch docs/block docs/scalar docs/tile`

Expected: zero incomplete active contracts and no forbidden placeholder text.

- [ ] **Step 3: Run fresh lightweight gates**

Run: `make pr-check && make repo-check && git diff --check`

Expected: PASS.

- [ ] **Step 4: Commit any review correction, then prove a clean exact head**

```bash
test -z "$(git status --porcelain=v1 --untracked-files=all)"
git rev-parse HEAD
git rev-parse HEAD^{tree}
```

Record both values in the release handoff; do not amend after validation starts.

### Task 9: Run and publish the PTO exact-head release

**Files:**
- Generated release evidence under `spec/evidence/` and `spec/release-manifest.json` only if the release preparation requires a reviewed commit.
- GitHub release/tag metadata after every gate succeeds.

**Interfaces:**
- Consumes: clean exact candidate from Task 8.
- Produces: successful local release validation, successful hosted `Release / validate`, release tag/artifact, and exact PTO commit/tree/manifest identities.

- [ ] **Step 1: Run the full local exact-head release gate**

```bash
candidate=$(git rev-parse HEAD)
test -z "$(git status --porcelain=v1 --untracked-files=all)"
make release-check RELEASE_COMMIT="$candidate"
```

Expected: strict ASLRef type-check and every independent test point PASS. Do not treat a timeout, missing tool, or partial result as success.

- [ ] **Step 2: Push the exact candidate branch**

```bash
git push --set-upstream origin codex/mnemonic-field-encoding-closure-design
```

- [ ] **Step 3: Dispatch hosted exact-head release verification**

```bash
gh workflow run release.yml --repo PTO-ISA/pto-spec \
  --ref codex/mnemonic-field-encoding-closure-design \
  -f commit="$(git rev-parse HEAD)"
```

Observe the created run once, record its ID and exact SHA, and return control while it is pending. Do not wait synchronously for the multi-hour hosted suite.

- [ ] **Step 4: On a later heartbeat, require every hosted job to be successful**

Run:

```bash
candidate=$(git rev-parse HEAD)
run_id=$(gh run list --repo PTO-ISA/pto-spec --workflow release.yml \
  --branch codex/mnemonic-field-encoding-closure-design \
  --json databaseId,headSha,createdAt \
  --jq --arg sha "$candidate" '[.[] | select(.headSha == $sha)] | sort_by(.createdAt) | last | .databaseId')
test -n "$run_id"
gh run view "$run_id" --repo PTO-ISA/pto-spec \
  --json headSha,status,conclusion,jobs,url
```

Expected: `headSha` equals the candidate and every required job, including `Release / validate`, has `conclusion=success`.

- [ ] **Step 5: Merge with exact-head protection and prove the squash tree**

Set `candidate=$(git rev-parse HEAD)` and `candidate_tree=$(git rev-parse HEAD^{tree})`, then merge with `gh pr merge "$pr_number" --squash --match-head-commit "$candidate"`; add `--admin` only if GitHub reports that administrator merge privilege is required. Never use it to treat failed or pending checks as successful. Fetch `origin/main`, require `git rev-parse origin/main^{tree}` to equal `$candidate_tree`, and fast-forward the clean local main only after equality.

- [ ] **Step 6: Create or replace the formal release only after tree proof**

Inspect `refs/tags/v0.58.0` and the existing GitHub release first. If the tag is absent, create it at the proven main commit. If it exists at the prior official commit, replace it only with an exact compare-and-swap push (`git push --force-with-lease=refs/tags/v0.58.0:$old_tag_commit origin refs/tags/v0.58.0`) as authorized by the requested 0.58 re-release; abort if the observed target changes. Publish or update the `v0.58.0` GitHub release and record commit, tree, binary fingerprint, release encoding hash, release manifest hash, instruction-contract hash, hosted run URL, and tag.

- [ ] **Step 7: Record exact PTO release identities**

Run:

```bash
git rev-parse origin/main
git rev-parse origin/main^{tree}
sha256sum spec/release-manifest.json
```

Record these outputs with the PTO release evidence. They identify the exact
formal source published by this repository.
