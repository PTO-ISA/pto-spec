<!-- GENERATED FROM: asl/scalar/alu/SRLI.asl -->
# SRLI

**Normative ASL source:** `asl/scalar/alu/SRLI.asl`

SRLI performs an XLEN logical right shift by a six-bit immediate.

## Normative identity {#PTO-INST-SCALAR-SRLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-srli-purpose role=purpose -->
## What SRLI does

`SRLI` is a 32-bit scalar ALU instruction. It logically shifts the source right under the complete XLEN value shift rules; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-srli-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then logically shifts the source right under the complete XLEN value shift rules, and only afterward performs the destination effects.

- The operation-specific width, signedness, and immediate rules are fixed by the mnemonic and the encoded fields shown below.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-srli-inputs role=inputs-outputs -->
## Inputs and destinations

- The 5-bit `RegDst` field selects the Reg5 result target or discards the result.
- The 5-bit `SrcL` field selects a scalar input through Reg5.
- The 6-bit `shamt` field encodes the six-bit shift amount.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-srli-effects role=effects -->
## Effects and ordering

Every scalar source is snapshotted before the destination effect. The completed value is then routed through `RegDst` using the current scalar destination map.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 4 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-srli-constraints role=constraints -->
## Legality and fault boundary

All 6 encoded shift bits are assigned, giving amounts `0..63`; fixed-width shifting is total and raises no arithmetic exception.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-srli-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `SRLI` example, source `16` shifted logically right by `2` produces `4`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
srli SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srli_32_dd29ca058cfe | L32 | 32 | 0x00005015 / 0xfc00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srli_32_dd29ca058cfe | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srli_32_dd29ca058cfe | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srli_32_dd29ca058cfe | shamt | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srli_32_dd29ca058cfe | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srli_32_dd29ca058cfe | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| srli_32_dd29ca058cfe | shamt | 6 | 0–63 | none | none | six-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| shamt | six-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLI.asl -->
```asl
readonly func InstructionContractOperation_SRLI()
    => ScalarOperation
begin
    return ScalarOperation_SRLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLI.asl -->
```asl
readonly func InstructionContractHandler_SRLI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftWidth_SRLI()
    => integer {1..64}
begin
    return 6;
end;

pure func InstructionContractIsWordOperation_SRLI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 6-bit shift amount from 0 through 63. Encoded zero performs an identity shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 6-bit shift amount from 0 through 63 is legal.

## State effects

- Compute the XLEN logical right shift LSR(SrcL, shamt); discard low shifted-out bits and insert zero bits at the left.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRLI raises no arithmetic exception; shifted-out bits are discarded and zero bits enter from the left.
- Bits 31:26 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- srli a0, 1, ->a0
- srli t#1, 63, ->u
- srli zero, 0, ->zero
