<!-- GENERATED FROM: asl/scalar/agu/C.LDI.asl -->
# C.LDI

**Normative ASL source:** `asl/scalar/agu/C.LDI.asl`

C.LDI snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-C-LDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.ldi [srcL, simm], ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_ldi_16_973f42d37f29 | C16 | 16 | 0x001a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_ldi_16_973f42d37f29 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_ldi_16_973f42d37f29 | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_ldi_16_973f42d37f29 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| c_ldi_16_973f42d37f29 | simm5 | 5 | 0–31 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| simm5 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.LDI.asl -->
```asl
readonly func InstructionContractOperation_C_LDI() => ScalarOperation
begin
    return ScalarOperation_C_LDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.LDI.asl -->
```asl
readonly func InstructionContractHandler_C_LDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_C_LDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_C_LDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_LDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_C_LDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_C_LDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_LDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_LDI()
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
- simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm5, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- After a successful 8-byte load, preserve the complete 64-bit loaded bit pattern and publish it through the destination.
- Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- c.ldi [srcL, simm], ->t

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
