<!-- GENERATED FROM: asl/scalar/agu/C.SDI.asl -->
# C.SDI

**Normative ASL source:** `asl/scalar/agu/C.SDI.asl`

C.SDI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-C-SDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.sdi t#1, [srcL, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_sdi_16_bbec69bcfd5d | C16 | 16 | 0x003a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_sdi_16_bbec69bcfd5d | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_sdi_16_bbec69bcfd5d | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_sdi_16_bbec69bcfd5d | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| c_sdi_16_bbec69bcfd5d | simm5 | 5 | 0–31 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| simm5 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.SDI.asl -->
```asl
readonly func InstructionContractOperation_C_SDI() => ScalarOperation
begin
    return ScalarOperation_C_SDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.SDI.asl -->
```asl
readonly func InstructionContractHandler_C_SDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_C_SDI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_C_SDI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_SDI()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_C_SDI()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_C_SDI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_SDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_SDI()
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
- The implicit store-data source is T#1 and must be available before execution; reading it does not consume it.
- simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm5, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot implicit T#1 before memory effects and preserve the queue entry after the store.
- Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 8-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 8-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- c.sdi t#1, [srcL, simm]

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
