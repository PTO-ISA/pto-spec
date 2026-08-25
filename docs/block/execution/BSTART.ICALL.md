<!-- GENERATED FROM: asl/block/execution/BSTART.ICALL.asl -->
# BSTART.ICALL

**Normative ASL source:** `asl/block/execution/BSTART.ICALL.asl`

Atomically retires the old block, snapshots its BARG.BPCN into a new indirect-call BARG, and writes the independent return target to ra.

## Normative identity {#PTO-INST-BLOCK-BSTART-ICALL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-icall-purpose role=purpose -->
## What BSTART.ICALL contributes

`BSTART.ICALL` is a 32-bit block-start command for the ICALL form. It establishes the pending block identity and selectors; the completed block, not the start command alone, owns body execution and result commitment.

<!-- PTO-READER-BLOCK: block-bstart-icall-mechanism role=mechanism -->
## Placement and mechanism

Header commands execute sequentially after the start, while `BSTOP` or the next `BSTART` is the boundary that validates and retires the completed block. The current owner gives this exact composition checklist:

```text
BSTART.ICALL retires one active Standard or Floating block whose BARG.BPCN supplies the call target, then atomically opens a new Standard indirect-call block and writes ra.
```

After any active predecessor is retired successfully, the command initializes the new pending `BARG` or operation descriptor and continues header execution at the sequential PC. No block destination or memory result becomes visible merely because the start decoded. The return-address result is published only when start applicability, target checks, and predecessor retirement all succeed.

<!-- PTO-READER-BLOCK: block-bstart-icall-inputs role=inputs-outputs -->
## Operands and header roles

- `uimm5` supplies the encoded offset or addend; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-bstart-icall-effects role=effects -->
## Pending state and completion

The start transition is all-or-nothing with predecessor retirement for applicability and target checks. After the start succeeds, the later completion boundary validates the full composition before any body result can commit.

<!-- PTO-READER-BLOCK: block-bstart-icall-constraints role=constraints -->
## Legality and fault boundary

Reserved selectors, invalid targets, malformed completed composition, or failed predecessor retirement are rejected before new-block or body effects.

<!-- PTO-READER-BLOCK: block-bstart-icall-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.ICALL <rt_label>, ->ra
```

Assume predecessor retirement and target checks succeed. `BSTART.ICALL <rt_label>, ->ra` opens the pending `BSTART.ICALL` form; subsequent header/body commands remain provisional until `BSTOP` or the next `BSTART` validates the complete composition.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.ICALL <rt_label>, ->ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_icall_32_50166001 | L32 | 32 | 0x50166001 / 0xf83fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_icall_32_50166001 | uimm5 | 5 | unsigned | [{"instruction_lsb":22,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_icall_32_50166001 | uimm5 | 5 | 0–31 | none | none | unsigned return-address displacement from the embedded high halfword | Encoded zero selects P+2 as the return target. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| uimm5 | unsigned return-address displacement from the embedded high halfword |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.ICALL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_ICALL(operation: CommandOperation) => boolean
begin
    return operation == CommandOperation_bstart_icall_32_50166001;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.ICALL retires one active Standard or Floating block whose BARG.BPCN supplies the call target, then atomically opens a new Standard indirect-call block and writes ra.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.ICALL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_ICALL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractTransfer_BSTART_ICALL()
    => BundleTransfer
begin
    return BundleTransfer_IndirectCall;
end;

pure func InstructionContractWritesReturnAddress_BSTART_ICALL()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Encoded uimm5 zero is a real zero displacement from the embedded C.SETRET halfword.

## Legality

- This fused form is the only accepted indirect-call spelling; bare BSTART.* ICALL forms are deleted.
- The retiring block must be Standard or Floating because System BARG has no selecting BPCN.

## State effects

- Installs BARG.BPC=P, BlockType=STD, BPCN=the retiring BARG.BPCN snapshot, TYPE=ICALL, TAKEN=1, and writes return_target to ra.
- The indirect target is selected only when the new block later commits.

## Memory effects and ordering

### Memory effects

- Any memory effects of the retiring block complete before the indirect-call BARG and ra are published; BSTART.ICALL itself performs no memory access.

### Ordering

- Snapshot and validate retiring BARG.BPCN, successfully commit the retiring block, then atomically install the new STD BARG and write ra.

## Exceptions

- No active retiring Standard or Floating block raises Fault_BundleControl before target or return-address effects.
- An odd retiring BARG.BPCN raises Fault_InstructionPC before retiring-block effects.
- Decode, applicability, target, or retiring-commit failure preserves ra and the retiring BARG and installs no candidate BARG.

## Examples

- BSTART.ICALL <rt_label>, ->ra
