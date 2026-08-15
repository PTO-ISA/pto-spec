<!-- GENERATED FROM: asl/scalar/alu/SRLW.asl -->
# SRLW

**Normative ASL source:** `asl/scalar/alu/SRLW.asl`

SRLW performs a logical right shift of the low 32-bit source by the low five bits of the snapshotted SrcR; the 32-bit result is sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-SRLW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
srlw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srlw_32_2c6458b2aadb | L32 | 32 | 0x00005025 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srlw_32_2c6458b2aadb | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srlw_32_2c6458b2aadb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srlw_32_2c6458b2aadb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srlw_32_2c6458b2aadb | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srlw_32_2c6458b2aadb | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| srlw_32_2c6458b2aadb | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLW.asl -->
```asl
readonly func InstructionContractOperation_SRLW()
    => ScalarOperation
begin
    return ScalarOperation_SRLW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLW.asl -->
```asl
readonly func InstructionContractHandler_SRLW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftAmount_SRLW(right: Word)
    => integer {0..31}
begin
    return UInt(right[4:0]);
end;

pure func InstructionContractResult_SRLW(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SRLW(right);
    let shifted = LSR(left[31:0], amount);
    return SignExtend{PTO_XLEN}(shifted);
end;

pure func InstructionContractIsWordOperation_SRLW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- The low five bits of the snapshotted SrcR select the shift amount 0 through 31; every higher SrcR bit is ignored for the amount.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All SrcR values are legal; only its low five bits contribute to the shift amount.

## State effects

- Compute the logical right shift using the low five bits of the snapshotted SrcR. The low 32-bit result is sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRLW raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- srlw a0, a1, ->a2
- srlw t#1, u#1, ->u
- srlw zero, zero, ->zero

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
