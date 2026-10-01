<!-- GENERATED FROM: asl/block/attributes/B.CATR.asl -->
# B.CATR

**Normative ASL source:** `asl/block/attributes/B.CATR.asl`

Defines one optional block control record for post-commit trap, transactional visibility, acquire/release ordering, remote execution, and dimension-reduction mode.

## Normative identity {#PTO-INST-BLOCK-B-CATR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-catr-purpose role=purpose -->
## What B.CATR does

`B.CATR` (block control attributes) is an optional 32-bit header command. It records six one-bit block controls: `trap`, `atom`, `aq`, `rl`, `far`, and `DR`. It performs no computation and no memory access. The block's operation and its commit read the recorded flags later.

The flags are stored in one record with a `present` bit, written by `SetBundleControlAttributeState`. See the [attribute schema model](../model/schema/attributes.md) for the writer.

<!-- PTO-READER-BLOCK: block-b-catr-mechanism role=mechanism -->
## Placement and mechanism

A block header is the part of a block after its `BSTART` and before its first body instruction. `B.CATR` belongs there. The command dispatcher raises `Fault_BundleControl` when no block is active, when the block body has already begun, or when the record's `present` bit is already set.

Design point: a second `B.CATR` is detected from the `present` bit, not from the field values. A `B.CATR` with every flag clear still counts as written, so a later `B.CATR` in the same header is rejected instead of silently replacing it.

After a successful commit, the record is cleared with the rest of the header state. The flags never carry into the next block.

<!-- PTO-READER-BLOCK: block-b-catr-inputs role=inputs-outputs -->
## Encoded fields

The fixed bits are the low 15 bits equal to `0x0023` and bits 20 to 25 and 27 to 31 equal to zero (mask `0xfbf07fff`, match `0x00000023`). The six flags are:

- `rl`, bit 15: release ordering.
- `aq`, bit 16: acquire ordering.
- `atom`, bit 17: whole-block transaction request.
- `far`, bit 18: remote execution request.
- `trap`, bit 19: synchronous post-commit trap request.
- `DR`, bit 26: dimension-reduction mode.

All six bits are independent. `aq` and `rl` do not require `atom`.

Design point: omitting `B.CATR` is equivalent to encoding every flag as zero. Unlike `B.DATR`, this command has no field whose omission and encoded zero differ, because the reset value of each flag is zero.

<!-- PTO-READER-BLOCK: block-b-catr-effects role=effects -->
## What each flag changes

`aq` and `rl` select the block memory order through `CurrentBundleMemoryOrder`: both set gives acquire-release, one set gives acquire or release, neither gives relaxed. Tile memory operations, for example the gather, scatter, and atomic paths, pass this order to their memory events.

`trap` acts only after a successful commit. `StopBundleAt` first clears the block and selects the next PC, then raises `Fault_BundlePostCommit` at that PC. Recovering the trap resumes at the continuation, not at the retired block. A block that fails to commit raises no post-commit trap.

`far` changes the path of a tile operation. The formal model executes the operation against the initiating core's inputs and publishes results only through the normal local commit. No intermediate remote result is observable.

`atom` and `DR` are recorded and readable in bits 8 and 12 of the packed control word that `LSRGET` identifier 2 returns (see [BARG](../model/state/barg.md)). The contract states that `atom=1` makes the block one all-or-nothing transaction. In the current executable ASL, no operation reads `CurrentBundleAtomic` or `CurrentBundleDimensionReduction`; the only executable check on `DR` is the commit rule below.

<!-- PTO-READER-BLOCK: block-b-catr-constraints role=constraints -->
## Legality and faults

- Misplaced or duplicate `B.CATR` raises `Fault_BundleControl` before the record changes.
- `DR=1` is checked at commit. If the block kind recorded in `BARG` is neither `TileElement` nor `TileMemory`, [commit validation](../model/commit/validation.md) raises `Fault_BundleControl` before any block effect. A block of any other kind, for example a CUBE matrix block or a floating-point block, therefore cannot carry `DR=1`.

Design point: `DR` is checked at commit, not when `B.CATR` executes. The ASL comment states that the raw bit may be collected before the complete header selects its operation, so the check waits until the block kind is final.

<!-- PTO-READER-BLOCK: block-b-catr-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}
```

A `B.CATR` that sets only `aq` and `rl` encodes bits 15 and 16 on top of the fixed `0x23`, giving the word `0x00018023`. A tile memory operation in that block then runs with acquire-release order. Setting only `trap` instead gives `0x00080023`: the block commits normally, and then `Fault_BundlePostCommit` is raised at the selected continuation.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_catr_32_e90bd52fa480 | L32 | 32 | 0x00000023 / 0xfbf07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_catr_32_e90bd52fa480 | DR | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | trap | 1 | encoding-defined | [{"instruction_lsb":19,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | far | 1 | encoding-defined | [{"instruction_lsb":18,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | atom | 1 | encoding-defined | [{"instruction_lsb":17,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | aq | 1 | encoding-defined | [{"instruction_lsb":16,"value_lsb":0,"width":1}] |
| b_catr_32_e90bd52fa480 | rl | 1 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_catr_32_e90bd52fa480 | DR | 1 | 0–1 | none | none | dimension-reduction selector: zero multidimensional; one group-executed reduction mode | Encoded zero selects the default multidimensional operation mode. |
| b_catr_32_e90bd52fa480 | trap | 1 | 0–1 | none | none | synchronous post-commit trap request | Encoded zero disables the synchronous post-commit trap request. |
| b_catr_32_e90bd52fa480 | far | 1 | 0–1 | none | none | remote execution request using existing routing state | Encoded zero executes the block on the initiating core. |
| b_catr_32_e90bd52fa480 | atom | 1 | 0–1 | none | none | whole-block transaction selector | Encoded zero selects normal operation-specific commit visibility. |
| b_catr_32_e90bd52fa480 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| b_catr_32_e90bd52fa480 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| DR | dimension-reduction selector: zero multidimensional; one group-executed reduction mode |
| trap | synchronous post-commit trap request |
| far | remote execution request using existing routing state |
| atom | whole-block transaction selector |
| aq | acquire ordering bit |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.CATR.asl -->
```asl
readonly func InstructionContractMatches_B_CATR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_catr_32_e90bd52fa480);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Optional header command after BSTART and before the first body instruction. At most one B.CATR may appear in a block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.CATR.asl -->
```asl
readonly func InstructionContractHandler_B_CATR() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleControlAttributes;
end;

pure func InstructionContractHeaderOnly_B_CATR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDuplicateRejects_B_CATR()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitting B.CATR is equivalent to trap=0, atom=0, aq=0, rl=0, far=0, and DR=0. Every encoded bit is explicit; zero never means an omitted instruction.

## Legality

- All six one-bit fields are independently assigned; aq and rl do not require atom=1.
- B.CATR is header-only and unique per block.
- DR=1 is assigned only for VEC, SFU, and TLSU blocks and rejects for CUBE and non-tile blocks before effects.

## State effects

- Defines one optional block control record for post-commit trap, transactional visibility, acquire/release ordering, remote execution, and dimension-reduction mode.
- trap=1 first commits and clears the block, then saves the selected continuation in a clean trap context; trap return resumes that continuation.
- far=1 captures the block inputs for the routing-selected remote target, waits for returned results, and commits those results only on the initiating core.
- DR=1 selects operation-defined dimension-reduction behavior for VEC, SFU, or TLSU; it never means dynamic rounding or direct-register addressing.

## Memory effects and ordering

### Memory effects

- aq prevents later-block memory effects from preceding this block; rl prevents earlier-block memory effects from following it; aq+rl applies both constraints.
- atom=1 makes the complete block one non-interleavable all-or-nothing architectural transaction: memory and register-output effects become visible together or remain ineffective.
- far=1 may transport inputs and returned results through a remote target selected by routing state, but only the initiating core's final commit is architecturally visible.

### Ordering

- aq prevents later-block memory effects from preceding this block.
- rl prevents earlier-block memory effects from following this block.
- When both bits are one, both acquire and release constraints apply independently.

## Exceptions

- A B.CATR outside an active header or a second B.CATR raises Illegal Block Exception before changing pending or architectural state.
- DR=1 in CUBE or a non-tile block raises Illegal Block Exception before block effects; VEC, SFU, and TLSU blocks may consume dimension-reduction mode.
- A failed or rejected block commit produces no post-commit trap and exposes no partial atomic-block result.

## Examples

- B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}
