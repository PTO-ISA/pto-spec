<!-- GENERATED FROM: asl/scalar/alu/BXU.asl -->
# BXU

**Normative ASL source:** `asl/scalar/alu/BXU.asl`

BXU extracts an independently selected wrapping scalar field, zero-extends it to XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-BXU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bxu-purpose role=purpose -->
## What BXU does

`BXU` is a 32-bit scalar ALU instruction. It extracts the independently selected wrapping field and zero-extends it to XLEN; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-bxu-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then extracts the independently selected wrapping field and zero-extends it to XLEN, and only afterward performs the destination effects.

- `imml` and `imms` independently select field width and starting bit; wrapping is part of the selected-field mechanism.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-bxu-inputs role=inputs-outputs -->
## Inputs and destinations

- The 5-bit `RegDst` field selects the Reg5 result target or discards the result.
- The 5-bit `SrcL` field selects a scalar input through Reg5.
- The 6-bit `imml` field encodes the selected field width as `N-1`.
- The 6-bit `imms` field encodes selected-field starting bit `M`.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-bxu-effects role=effects -->
## Effects and ordering

Every scalar source is snapshotted before the destination effect. The completed value is then routed through `RegDst` using the current scalar destination map.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 4 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-bxu-constraints role=constraints -->
## Legality and fault boundary

Field selection may wrap from bit 63 to bit 0; the generated defaults and legality tables below give the exact width and starting-position encodings.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-bxu-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `BXU` example, extracting four-bit field `1110` zero-extends to XLEN value `14`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bxu SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bxu_32_e9ea9715ba62 | L32 | 32 | 0x00001067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bxu_32_e9ea9715ba62 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bxu_32_e9ea9715ba62 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bxu_32_e9ea9715ba62 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bxu_32_e9ea9715ba62 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bxu_32_e9ea9715ba62 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| bxu_32_e9ea9715ba62 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| bxu_32_e9ea9715ba62 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| bxu_32_e9ea9715ba62 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BXU.asl -->
```asl
readonly func InstructionContractOperation_BXU()
    => ScalarOperation
begin
    return ScalarOperation_BXU;
end;

pure func InstructionContractWidth_BXU(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_BXU(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BXU.asl -->
```asl
readonly func InstructionContractHandler_BXU()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExtractBitfield;
end;

pure func InstructionContractResult_BXU(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ExtractBitfield(
        value,
        width,
        offset,
        FALSE);
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

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. Zero-fill every result bit above selected field bit N-1.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before any destination effect so a GPR alias or T/U destination push observes the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.
- BXU raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- bxu a0, 60, 8, ->a1
- bxu t#1, 0, 64, ->u
