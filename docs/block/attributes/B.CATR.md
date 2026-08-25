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
## What B.CATR contributes

`B.CATR` is a 32-bit block header command that records optional block control, ordering, remote-execution, and reduction attributes. It changes pending block metadata rather than executing a tile body operation immediately.

<!-- PTO-READER-BLOCK: block-b-catr-mechanism role=mechanism -->
## Placement and mechanism

The command belongs to the active block header before the first body instruction. Duplicate or misplaced use is rejected before pending header state changes.

The accepted command latches one typed attribute record in pending block state. The selected operation consumes those fields only after the complete header, bindings, dimensions, and body satisfy its schema.

<!-- PTO-READER-BLOCK: block-b-catr-inputs role=inputs-outputs -->
## Operands and header roles

- `DR` selects multidimensional or operation-defined reduction mode; its exact assigned domain remains in the generated contract below.
- `trap` requests a synchronous post-commit trap; its exact assigned domain remains in the generated contract below.
- `far` requests routing-selected remote execution; its exact assigned domain remains in the generated contract below.
- `atom` selects whole-block transactional visibility; its exact assigned domain remains in the generated contract below.
- `aq` selects acquire ordering; its exact assigned domain remains in the generated contract below.
- `rl` selects release ordering; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-b-catr-effects role=effects -->
## Pending state and completion

An accepted header command changes only its pending record or carrier. Architectural tile, Shared, GPR, memory, and completion effects remain deferred to the completed block unless this owner's contract explicitly identifies an immediate header-state update.

<!-- PTO-READER-BLOCK: block-b-catr-constraints role=constraints -->
## Legality and fault boundary

Reserved encodings are rejected before reads or pending-state changes. Placement, duplicate, role, or completed-schema mismatches fail before body effects.

<!-- PTO-READER-BLOCK: block-b-catr-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}
```

Assume an active compatible header with no earlier conflicting `B.CATR` command. Placing `B.CATR {trap, atomic, <aq, rl, aqrl>, far, dr}` at the next header slot records this command's pending fields; it does not by itself execute the eventual body operation.
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
