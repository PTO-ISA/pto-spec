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
## What B.DIM contributes

`B.DIM` is a 32-bit block header command that writes one block-local dimension register during header construction. It changes pending block metadata rather than executing a tile body operation immediately.

<!-- PTO-READER-BLOCK: block-b-dim-mechanism role=mechanism -->
## Placement and mechanism

The command belongs to an active header before the first body instruction. Its effective order and arity are checked against the completed operation schema rather than inferred from this command in isolation.

The command adds the unsigned immediate to the selected absolute GPR, keeps the low 16 bits, zero-extends that value, and writes the selected `LB0`, `LB1`, or `LB2` slot once.

<!-- PTO-READER-BLOCK: block-b-dim-inputs role=inputs-outputs -->
## Operands and header roles

- `RegSrc` identifies an input source or source-role selector; its exact assigned domain remains in the generated contract below.
- `uimm17` supplies the encoded offset or addend; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-b-dim-effects role=effects -->
## Pending state and completion

An accepted header command changes only its pending record or carrier. Architectural tile, Shared, GPR, memory, and completion effects remain deferred to the completed block unless this owner's contract explicitly identifies an immediate header-state update.

<!-- PTO-READER-BLOCK: block-b-dim-constraints role=constraints -->
## Legality and fault boundary

Reserved encodings are rejected before reads or pending-state changes. Placement, duplicate, role, or completed-schema mismatches fail before body effects.

<!-- PTO-READER-BLOCK: block-b-dim-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.DIM RegSrc, uimm, ->LB2
```

Assume an active compatible header with no earlier conflicting `B.DIM` command. Placing `B.DIM RegSrc, uimm, ->LB2` at the next header slot records this command's pending fields; it does not by itself execute the eventual body operation.
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
