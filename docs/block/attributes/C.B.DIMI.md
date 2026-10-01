<!-- GENERATED FROM: asl/block/attributes/C.B.DIMI.asl -->
# C.B.DIMI

**Normative ASL source:** `asl/block/attributes/C.B.DIMI.asl`

Writes one selected bundle-local LB from a zero-extended eight-bit immediate exactly once.

## Normative identity {#PTO-INST-BLOCK-C-B-DIMI}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-b-dimi-purpose role=purpose -->
## What C.B.DIMI does

`C.B.DIMI` is the 16-bit compressed form of `B.DIM`. It writes one bundle-local dimension register, `LB0`, `LB1`, or `LB2`, from an unsigned 8-bit immediate. It reads no register.

Like `B.DIM`, it gives the register no meaning. The completed operation schema decides whether the value is a valid column count, a row count, or a matrix extent.

<!-- PTO-READER-BLOCK: block-c-b-dimi-mechanism role=mechanism -->
## Placement and mechanism

The command dispatcher accepts `C.B.DIMI` only while a block is active and still in its header, after `BSTART` and before the first body instruction. Otherwise it raises `Fault_BundleControl`.

The command writes `ZeroExtend(imm8)` through `SetBundleDimension`, the same writer that `B.DIM` uses (see the [dimension schema model](../model/schema/dimensions.md)).

`C.B.DIMI` and `B.DIM` share one write-once presence bit for each of `LB0`, `LB1`, and `LB2`.

Design point: because the presence bit is shared, the compressed and full forms are interchangeable for a register but cannot both write it. Mixing them, for example `C.B.DIMI` for `LB0` and `B.DIM` for `LB2`, is legal; writing `LB0` with both is rejected.

<!-- PTO-READER-BLOCK: block-c-b-dimi-inputs role=inputs-outputs -->
## Encoded fields

- `imm8`, bits 6 to 13: an unsigned value 0 to 255, zero-extended to the dimension word.
- `LoopNest`, bits 14 and 15: codes 0, 1, and 2 select `LB0`, `LB1`, and `LB2`. Code 3 is reserved and raises `Fault_IllegalInstruction` before any state change.
- Bits 0 to 5 are fixed at `0x3c`.

<!-- PTO-READER-BLOCK: block-c-b-dimi-effects role=effects -->
## State effects and ordering

Placement and duplicate-write checks precede the dimension update.

Success publishes the selected raw LB value and its shared presence bit atomically, then advances `TPC` by `2` bytes.

Design point: `imm8` is always encoded, so an encoded zero writes numeric zero. It is not omission: an `LB` register that is never written has effective value 1, while `C.B.DIMI 0, ->LB0` makes it 0. The operation schema then decides whether 0 is legal.

<!-- PTO-READER-BLOCK: block-c-b-dimi-constraints role=constraints -->
## Legality, faults, and atomicity

- `LoopNest` code 3 raises `Fault_IllegalInstruction` before any change to `TPC` or block state.
- A `C.B.DIMI` outside an active block header raises `Fault_BundleControl`.

The current owner reports invalid schema, state, address, or continuation conditions through `Fault_BundleControl`, `Fault_IllegalInstruction`; no prose on this page creates an additional fault rule.

A second write through either `C.B.DIMI` or `B.DIM` rejects before changing the first value or presence bit.

<!-- PTO-READER-BLOCK: block-c-b-dimi-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
C.B.DIMI 0, ->LB0
```

After an active `BSTART`, this header command writes numeric zero to `LB0` and sets its presence bit. A value above 255, such as 256, does not fit in `imm8` and needs `B.DIM` with a register or its 17-bit immediate, for example `B.DIM zero, 256, ->LB2`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.B.DIMI imm8, ->LB0
C.B.DIMI imm8, ->LB1
C.B.DIMI imm8, ->LB2
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_b_dimi_16_3f1b113c76ce | C16 | 16 | 0x003c / 0x003f | [{"field":"LoopNest","operator":"not-equal","value":3}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_b_dimi_16_3f1b113c76ce | LoopNest | 2 | encoding-defined | [{"instruction_lsb":14,"value_lsb":0,"width":2}] |
| c_b_dimi_16_3f1b113c76ce | imm8 | 8 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":8}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_b_dimi_16_3f1b113c76ce | LoopNest | 2 | 0–2 | none | 3 | encoded LB0, LB1, or LB2 selector | Code zero selects LB0. |
| c_b_dimi_16_3f1b113c76ce | imm8 | 8 | 0–255 | none | none | unsigned eight-bit bundle-local dimension value | Encoded zero writes numeric zero to the selected LB. |

- `c_b_dimi_16_3f1b113c76ce.LoopNest` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| LoopNest | encoded LB0, LB1, or LB2 selector |
| imm8 | unsigned eight-bit bundle-local dimension value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/C.B.DIMI.asl -->
```asl
readonly func InstructionContractMatches_C_B_DIMI(
    operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_c_b_dimi_16_3f1b113c76ce;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Header command after BSTART and before the first body instruction. C.B.DIMI and B.DIM share one write-once presence bit for each of LB0, LB1, and LB2.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/C.B.DIMI.asl -->
```asl
pure func InstructionContractDimension_C_B_DIMI(
    loop_nest: bits(2))
    => BundleDimensionIndex
begin
    assert loop_nest != '11';
    return UInt(loop_nest) as BundleDimensionIndex;
end;

pure func InstructionContractValue_C_B_DIMI(
    immediate: bits(8))
    => Word
begin
    return ZeroExtend{PTO_XLEN}(immediate);
end;

readonly func InstructionContractHandler_C_B_DIMI()
    => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDimension;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LoopNest 0, 1, and 2 select LB0, LB1, and LB2. imm8 is always present; encoded zero writes numeric zero and is not omission.

## Legality

- LoopNest codes 0..2 are assigned to LB0..LB2; code 3 is reserved.
- imm8 accepts every unsigned value 0..255 and is zero-extended to the bundle dimension word.
- Each selected LB is write-once for one block across full and compressed dimension commands.

## State effects

- Write ZeroExtend(imm8) to the selected raw LB and set its presence bit.
- LB meaning is selected by the completed operation schema; C.B.DIMI assigns no universal row, column, M, N, or K role.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Placement and duplicate checks precede the LB update. A successful update sets the presence bit and value together, then command dispatch advances TPC by two bytes.

## Exceptions

- LoopNest code 3 raises Fault_IllegalInstruction before changing TPC or bundle state.
- Execution outside an active block header or a second write to the same LB across C.B.DIMI and B.DIM raises Fault_BundleControl before changing the first value.

## Examples

- C.B.DIMI 0, ->LB0
- C.B.DIMI 255, ->LB2
