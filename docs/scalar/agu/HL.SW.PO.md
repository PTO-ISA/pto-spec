<!-- GENERATED FROM: asl/scalar/agu/HL.SW.PO.asl -->
# HL.SW.PO

**Normative ASL source:** `asl/scalar/agu/HL.SW.PO.asl`

HL.SW.PO snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SW-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.sw.po SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sw_po_48_84cf0cd97fde | HL48 | 48 | 0x00002049003e / 0x00007fff07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sw_po_48_84cf0cd97fde | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sw_po_48_84cf0cd97fde | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sw_po_48_84cf0cd97fde | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sw_po_48_84cf0cd97fde | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sw_po_48_84cf0cd97fde | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sw_po_48_84cf0cd97fde | SrcRType | 2 | 0–3 | none | none | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SW.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_SW_PO() => ScalarOperation
begin
    return ScalarOperation_HL_SW_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SW.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_SW_PO()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SW_PO()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SW_PO()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SW_PO()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_SW_PO()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SW_PO()
    => AddressUpdateMode
begin
    return AddressUpdate_PostIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SW_PO()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SW_PO()
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
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 2) and add it modulo 2^PTO_XLEN to the SrcL base.
- Post-index mode accesses the original base and publishes base plus offset only after successful memory completion.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

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

- hl.sw.po SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2], ->{t, u, Rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
