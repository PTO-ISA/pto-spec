<!-- GENERATED FROM: asl/scalar/agu/SBI.asl -->
# SBI

**Normative ASL source:** `asl/scalar/agu/SBI.asl`

SBI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-SBI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sbi SrcL, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sbi_32_f3c6b796f0d9 | L32 | 32 | 0x00000059 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sbi_32_f3c6b796f0d9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sbi_32_f3c6b796f0d9 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sbi_32_f3c6b796f0d9 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sbi_32_f3c6b796f0d9 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sbi_32_f3c6b796f0d9 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sbi_32_f3c6b796f0d9 | simm12 | 12 | 0–4095 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| SrcR | Reg5 address-base source |
| simm12 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SBI.asl -->
```asl
readonly func InstructionContractOperation_SBI() => ScalarOperation
begin
    return ScalarOperation_SBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SBI.asl -->
```asl
readonly func InstructionContractHandler_SBI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SBI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SBI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_SBI()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_SBI()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SBI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SBI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SBI()
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
- simm12 assigns every signed 12-bit value -2048..2047; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm12, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- sbi SrcL, [SrcR, simm]

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
