<!-- GENERATED FROM: asl/scalar/alu/BCNT.asl -->
# BCNT

**Normative ASL source:** `asl/scalar/alu/BCNT.asl`

BCNT counts set bits in an independently selected wrapping scalar field and publishes the XLEN population count.

## Normative identity {#PTO-INST-SCALAR-BCNT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bcnt-purpose role=purpose -->
## What BCNT does

`BCNT` is a 32-bit scalar ALU instruction. It counts one-bits in the independently selected wrapping bit field; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-bcnt-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then counts one-bits in the independently selected wrapping bit field, and only afterward performs the destination effects.

- `imml` and `imms` independently select field width and starting bit; wrapping is part of the selected-field mechanism.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-bcnt-inputs role=inputs-outputs -->
## Inputs and destinations

- The 5-bit `RegDst` field selects the Reg5 result target or discards the result.
- The 5-bit `SrcL` field selects a scalar input through Reg5.
- The 6-bit `imml` field encodes the selected field width as `N-1`.
- The 6-bit `imms` field encodes selected-field starting bit `M`.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-bcnt-effects role=effects -->
## Effects and ordering

Every scalar source is snapshotted before the destination effect. The completed value is then routed through `RegDst` using the current scalar destination map.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 4 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-bcnt-constraints role=constraints -->
## Legality and fault boundary

Field selection may wrap from bit 63 to bit 0; the generated defaults and legality tables below give the exact width and starting-position encodings.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-bcnt-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `BCNT` example, the four-bit selected field `1011` contains three set bits, so the result is `3`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bcnt srcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bcnt_32_e0b06e436a5b | L32 | 32 | 0x00006067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bcnt_32_e0b06e436a5b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bcnt_32_e0b06e436a5b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bcnt_32_e0b06e436a5b | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bcnt_32_e0b06e436a5b | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bcnt_32_e0b06e436a5b | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| bcnt_32_e0b06e436a5b | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| bcnt_32_e0b06e436a5b | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| bcnt_32_e0b06e436a5b | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BCNT.asl -->
```asl
readonly func InstructionContractOperation_BCNT()
    => ScalarOperation
begin
    return ScalarOperation_BCNT;
end;

pure func InstructionContractWidth_BCNT(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BCNT(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BCNT.asl -->
```asl
readonly func InstructionContractHandler_BCNT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;

pure func InstructionContractResult_BCNT(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return CountBitfield(
        value,
        width,
        offset,
        FALSE,
        TRUE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, imml, imms, and RegDst are required encoded fields; no field can be omitted.
- imml encodes N minus one, so raw values 0 through 63 select widths 1 through 64; encoded zero selects N=1.
- imms directly encodes M from 0 through 63; encoded zero selects source bit zero.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every imml and imms value is assigned. The selected N-bit field begins at bit M and wraps through bit 63 to bit 0.

## State effects

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0, then count every set bit in the selected field. An all-zero selected field returns zero and an all-one selected field returns N.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before any destination effect so a GPR alias or a T/U destination push observes the pre-instruction source value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.
- BCNT raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- bcnt a0, 0, 64, ->a1
- bcnt t#1, 60, 8, ->u
- bcnt zero, 0, 1, ->zero
