<!-- GENERATED FROM: asl/scalar/agu/LHUI.asl -->
# LHUI

**Normative ASL source:** `asl/scalar/agu/LHUI.asl`

LHUI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LHUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
lhui [SrcL, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lhui_32_6da39bba900b | L32 | 32 | 0x00005019 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lhui_32_6da39bba900b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lhui_32_6da39bba900b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| lhui_32_6da39bba900b | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lhui_32_6da39bba900b | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lhui_32_6da39bba900b | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| lhui_32_6da39bba900b | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LHUI.asl -->
```asl
readonly func InstructionContractOperation_LHUI() => ScalarOperation
begin
    return ScalarOperation_LHUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LHUI.asl -->
```asl
readonly func InstructionContractHandler_LHUI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LHUI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LHUI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_LHUI()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LHUI()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_LHUI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LHUI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LHUI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 2.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 2-byte load, zero-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lhui [SrcL, simm], ->{t, u, Rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
