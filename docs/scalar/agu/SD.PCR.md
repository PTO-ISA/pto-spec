<!-- GENERATED FROM: asl/scalar/agu/SD.PCR.asl -->
# SD.PCR

**Normative ASL source:** `asl/scalar/agu/SD.PCR.asl`

SD.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-SD-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sd.pcr SrcL, [symbol]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_pcr_32_2340e0085413 | L32 | 32 | 0x00003069 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_pcr_32_2340e0085413 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_pcr_32_2340e0085413 | simm | 17 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sd_pcr_32_2340e0085413 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sd_pcr_32_2340e0085413 | simm | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SD.PCR.asl -->
```asl
readonly func InstructionContractOperation_SD_PCR() => ScalarOperation
begin
    return ScalarOperation_SD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SD.PCR.asl -->
```asl
readonly func InstructionContractHandler_SD_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SD_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SD_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_SD_PCR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_SD_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SD_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SD_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SD_PCR()
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
- simm assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

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

- sd.pcr SrcL, [symbol]

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
