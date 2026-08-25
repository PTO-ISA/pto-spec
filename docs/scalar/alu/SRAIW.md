<!-- GENERATED FROM: asl/scalar/alu/SRAIW.asl -->
# SRAIW

**Normative ASL source:** `asl/scalar/alu/SRAIW.asl`

SRAIW performs a word arithmetic right shift and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-SRAIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sraiw-purpose role=purpose -->
## What SRAIW does

`SRAIW` is a 32-bit scalar ALU instruction. It arithmetically shifts the source right under the low 32-bit word, followed by sign-extension to XLEN shift rules; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-sraiw-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then arithmetically shifts the source right under the low 32-bit word, followed by sign-extension to XLEN shift rules, and only afterward performs the destination effects.

- The operation-specific width, signedness, and immediate rules are fixed by the mnemonic and the encoded fields shown below.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-sraiw-inputs role=inputs-outputs -->
## Inputs and destinations

- The 5-bit `RegDst` field selects the Reg5 result target or discards the result.
- The 5-bit `SrcL` field selects a Reg5 scalar input whose low 32 bits are used.
- The 5-bit `shamt` field encodes the five-bit shift amount.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-sraiw-effects role=effects -->
## Effects and ordering

Every scalar source is snapshotted before the destination effect. The completed value is then routed through `RegDst` using the current scalar destination map.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 4 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-sraiw-constraints role=constraints -->
## Legality and fault boundary

All 5 encoded shift bits are assigned, giving amounts `0..31`; fixed-width shifting is total and raises no arithmetic exception.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-sraiw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `SRAIW` example, source `-8` shifted arithmetically right by `2` produces `-2`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sraiw SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sraiw_32_db04a6299504 | L32 | 32 | 0x00006035 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sraiw_32_db04a6299504 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sraiw_32_db04a6299504 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sraiw_32_db04a6299504 | shamt | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sraiw_32_db04a6299504 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sraiw_32_db04a6299504 | SrcL | 5 | 0–31 | none | none | Reg5 source; low 32 bits used | Encoded zero reads the architectural zero GPR. |
| sraiw_32_db04a6299504 | shamt | 5 | 0–31 | none | none | five-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source; low 32 bits used |
| shamt | five-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRAIW.asl -->
```asl
readonly func InstructionContractOperation_SRAIW()
    => ScalarOperation
begin
    return ScalarOperation_SRAIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRAIW.asl -->
```asl
readonly func InstructionContractHandler_SRAIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftWidth_SRAIW()
    => integer {1..64}
begin
    return 5;
end;

pure func InstructionContractIsWordOperation_SRAIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 5-bit shift amount from 0 through 31. Encoded zero performs an identity word shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 5-bit shift amount from 0 through 31 is legal; source bits above bit 31 do not participate.

## State effects

- Compute the 32-bit arithmetic right shift ASR(SrcL[31:0], shamt), then publish the 32-bit result sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the sign-extended word result, then advance TPC by four bytes.

## Exceptions

- SRAIW raises no arithmetic exception; copies of SrcL[31] enter from the left and the final word is sign-extended to XLEN.
- Bits 31:25 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- sraiw a0, 1, ->a0
- sraiw u#1, 31, ->t
- sraiw zero, 0, ->zero
