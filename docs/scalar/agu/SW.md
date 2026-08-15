<!-- GENERATED FROM: asl/scalar/agu/SW.asl -->
# SW

**Normative ASL source:** `asl/scalar/agu/SW.asl`

SW snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-SW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sw SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_32_28ad317b1b41 | L32 | 32 | 0x00002049 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_32_28ad317b1b41 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sw_32_28ad317b1b41 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_32_28ad317b1b41 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_32_28ad317b1b41 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_32_28ad317b1b41 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| sw_32_28ad317b1b41 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sw_32_28ad317b1b41 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| sw_32_28ad317b1b41 | SrcRType | 2 | 0–3 | none | none | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SW.asl -->
```asl
readonly func InstructionContractOperation_SW() => ScalarOperation
begin
    return ScalarOperation_SW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SW.asl -->
```asl
readonly func InstructionContractHandler_SW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SW()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SW()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SW()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_SW()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SW()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SW()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SW()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 negates the full PTO_XLEN value. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 2) and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- sw SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2]

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
