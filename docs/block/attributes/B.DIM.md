<!-- GENERATED FROM: asl/block/attributes/B.DIM.asl -->
# B.DIM

**Normative ASL source:** `asl/block/attributes/B.DIM.asl`

Writes one selected bundle-local LB register from an absolute GPR plus immediate, truncated to 16 bits.

## Normative identity {#PTO-INST-BLOCK-B-DIM}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-dim-purpose role=purpose -->
## What B.DIM does

`B.DIM` is a 32-bit header command that writes one bundle-local dimension register: `LB0`, `LB1`, or `LB2`. The value is the low 16 bits of an absolute GPR plus an unsigned 17-bit immediate, zero-extended.

`B.DIM` gives the register no meaning of its own. The completed operation schema decides whether an `LB` register is a valid column count, a row count, a physical column count, or an M, N, or K extent. For example, `TADD` reads `LB0` as `ValidCol`, `LB1` as `ValidRow`, and `LB2` as `Col`.

<!-- PTO-READER-BLOCK: block-b-dim-mechanism role=mechanism -->
## Placement and mechanism

The command dispatcher accepts `B.DIM` only while a block is active and still in its header. Otherwise it raises `Fault_BundleControl`. It then computes `GPR[RegSrc] + uimm17`, keeps bits 15 to 0, and calls `SetBundleDimension`.

`SetBundleDimension` checks the target's presence bit. If the bit is already set, it raises `Fault_BundleControl` and keeps the first value. Otherwise it sets the presence bit and stores the value. See the [dimension schema model](../model/schema/dimensions.md).

Design point: each `LB` register is write-once per block, and `B.DIM` shares one presence bit per register with the compressed `C.B.DIMI`. A second write by either form is rejected rather than silently overriding the first, so the value an operation reads is always the single value written in the header.

<!-- PTO-READER-BLOCK: block-b-dim-inputs role=inputs-outputs -->
## Encoded fields

- The target register is fixed by the form, through bits 12 to 14: `0x00000043` writes `LB0`, `0x00001043` writes `LB1`, and `0x00002043` writes `LB2`.
- `RegSrc`, bits 15 to 19: an absolute GPR selector 0 to 23. Selector 0 reads the architectural zero register. Codes 24 to 31 are not absolute GPRs; in other commands they name block-relative queue entries. No executable check in the command path constrains `RegSrc` to 0 to 23 for `B.DIM`, unlike the range modifiers `B.SUBVIEW` and `B.ASSEMBLE`, which reject those codes before any GPR read.
- `uimm17`, bits 20 to 31 (value bits 0 to 11) and bits 7 to 11 (value bits 12 to 16): an unsigned addend. Encoded zero adds zero.

Both fields are always encoded; no part of `B.DIM` is optional.

<!-- PTO-READER-BLOCK: block-b-dim-effects role=effects -->
## Defaults and the value written

The written value is `ZeroExtend((GPR[RegSrc] + uimm17)[15:0])`. The sum is truncated to 16 bits, so values of 65536 or more wrap.

Design point: an `LB` register that is never written has effective value 1, and an explicit write, including a write of 0, replaces that default. A program that writes 0 gets 0, not 1, and the operation schema then decides whether 0 is legal. For example, `TADD` rejects an explicitly present zero dimension.

Some operation schemas also read the presence bit. For `TADD`, an omitted `LB2` selects `Col = ValidCol` rather than 1, and `LB0` is required. The page of each operation gives its exact defaults.

Dimension values and presence bits are cleared when the block commits, so they never carry into the next block. `B.DIM` has no memory effect and changes no Tile state.

<!-- PTO-READER-BLOCK: block-b-dim-constraints role=constraints -->
## Legality and faults

- The form metadata reserves `RegSrc` codes 24 to 31, but the current handler performs no such check: it reads whatever selector it decoded (`asl/block/model/dispatch/commands.asl:123-138`). A reserved-selector fault is therefore not an executable outcome on this page's owning unit.
- A `B.DIM` outside an active block header raises `Fault_BundleControl`.
- A second write to the same `LB` register, through `B.DIM` or `C.B.DIMI`, raises `Fault_BundleControl` and keeps the first value.
- Range limits on the value, such as nonzero or power-of-two requirements, belong to the operation schema and are checked at block preflight.

<!-- PTO-READER-BLOCK: block-b-dim-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.DIM a0, 16, ->LB0
B.DIM zero, 0, ->LB2
```

With `a0 = 0x10010`, the first line computes `0x10020`, keeps the low 16 bits, and writes `0x0020`, which is 32, to `LB0`. The second line writes 0 to `LB2` and sets its presence bit, so `LB2` no longer has the default value 1. `LB1` stays at its default of 1. A later `C.B.DIMI 8, ->LB0` in the same header reaches the same presence bit and raises `Fault_BundleControl` for the duplicate write.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.DIM RegSrc, uimm17, ->LB0
B.DIM RegSrc, uimm17, ->LB1
B.DIM RegSrc, uimm17, ->LB2
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_dim_32_1caa1aa2944a | L32 | 32 | 0x00002043 / 0x0000707f | [{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |
| b_dim_32_27602ab68929 | L32 | 32 | 0x00000043 / 0x0000707f | [{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |
| b_dim_32_4191099a5f4d | L32 | 32 | 0x00001043 / 0x0000707f | [{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_dim_32_1caa1aa2944a | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_dim_32_1caa1aa2944a | uimm17 | 17 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |
| b_dim_32_27602ab68929 | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_dim_32_27602ab68929 | uimm17 | 17 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |
| b_dim_32_4191099a5f4d | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_dim_32_4191099a5f4d | uimm17 | 17 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_dim_32_1caa1aa2944a | RegSrc | 5 | 0–23 | none | 24–31 | absolute GPR source 0 through 23 | Encoded zero names the architectural zero GPR. |
| b_dim_32_1caa1aa2944a | uimm17 | 17 | 0–131071 | none | none | unsigned addend before low-16-bit truncation | Encoded zero supplies a zero displacement or zero immediate value. |
| b_dim_32_27602ab68929 | RegSrc | 5 | 0–23 | none | 24–31 | absolute GPR source 0 through 23 | Encoded zero names the architectural zero GPR. |
| b_dim_32_27602ab68929 | uimm17 | 17 | 0–131071 | none | none | unsigned addend before low-16-bit truncation | Encoded zero supplies a zero displacement or zero immediate value. |
| b_dim_32_4191099a5f4d | RegSrc | 5 | 0–23 | none | 24–31 | absolute GPR source 0 through 23 | Encoded zero names the architectural zero GPR. |
| b_dim_32_4191099a5f4d | uimm17 | 17 | 0–131071 | none | none | unsigned addend before low-16-bit truncation | Encoded zero supplies a zero displacement or zero immediate value. |

- `b_dim_32_1caa1aa2944a.RegSrc` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_dim_32_27602ab68929.RegSrc` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_dim_32_4191099a5f4d.RegSrc` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc | absolute GPR source 0 through 23 |
| uimm17 | unsigned addend before low-16-bit truncation |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.DIM.asl -->
```asl
readonly func InstructionContractMatches_B_DIM(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_dim_32_1caa1aa2944a) ||
           (operation == CommandOperation_b_dim_32_27602ab68929) ||
           (operation == CommandOperation_b_dim_32_4191099a5f4d);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Header command after BSTART and before the first body instruction. B.DIM and compressed dimension forms share one write-once presence bit for each of LB0, LB1, and LB2.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.DIM.asl -->
```asl
type BundleDimensionRegister of enumeration {
    BundleDimension_LB0,
    BundleDimension_LB1,
    BundleDimension_LB2
};

pure func BundleDimensionIndexOfRegister(reg: BundleDimensionRegister)
    => BundleDimensionIndex
begin
    case reg of
        when BundleDimension_LB0 => return 0;
        when BundleDimension_LB1 => return 1;
        when BundleDimension_LB2 => return 2;
    end;
end;

readonly func InstructionContractHandler_B_DIM() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDimension;
end;

pure func InstructionContractHeaderOnly_B_DIM()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDuplicateRejects_B_DIM()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected form fixes LB0, LB1, or LB2; RegSrc and uimm17 are both encoded and zero remains an explicit value.

## Legality

- b_dim_32_1caa1aa2944a.RegSrc accepts only absolute GPR codes 0..23; 24..31 are reserved.
- b_dim_32_27602ab68929.RegSrc accepts only absolute GPR codes 0..23; 24..31 are reserved.
- b_dim_32_4191099a5f4d.RegSrc accepts only absolute GPR codes 0..23; 24..31 are reserved.

## State effects

- Computes zero-extend((GPR[RegSrc] + zero-extend(uimm17))[15:0]) and writes the selected LB0, LB1, or LB2 register.
- LB meanings are selected by the completed operation schema; B.DIM itself assigns no universal row, column, M, N, or K role.
- Each LB may be written at most once per block across B.DIM and compressed dimension forms.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- RegSrc codes 24 through 31 raise Fault_IllegalInstruction before reading a queue or changing bundle state.
- A write outside an active block header or a second write to the same LB raises Fault_BundleControl before changing the first value.

## Examples

- B.DIM a0, 16, ->LB0
- B.DIM zero, 0, ->LB2
