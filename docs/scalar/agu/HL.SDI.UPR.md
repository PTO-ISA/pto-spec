<!-- GENERATED FROM: asl/scalar/agu/HL.SDI.UPR.asl -->
# HL.SDI.UPR

**Normative ASL source:** `asl/scalar/agu/HL.SDI.UPR.asl`

HL.SDI.UPR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 8-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SDI-UPR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.sdi.upr SrcD, [SrcR, simm], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sdi_upr_48_f8aba43b65d5 | HL48 | 48 | 0x00007059002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sdi_upr_48_f8aba43b65d5 | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sdi_upr_48_f8aba43b65d5 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sdi_upr_48_f8aba43b65d5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sdi_upr_48_f8aba43b65d5 | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sdi_upr_48_f8aba43b65d5 | RegDst | 5 | 0–31 | none | none | Reg5 updated-base destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_sdi_upr_48_f8aba43b65d5 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_upr_48_f8aba43b65d5 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_sdi_upr_48_f8aba43b65d5 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 updated-base destination or discard |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SDI.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_SDI_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SDI_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SDI.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_SDI_UPR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SDI_UPR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SDI_UPR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SDI_UPR()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SDI_UPR()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SDI_UPR()
    => AddressUpdateMode
begin
    return AddressUpdate_PreIndex;
end;

pure func InstructionContractAGUSignedLoad_HL_SDI_UPR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SDI_UPR()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcL base.
- Pre-index mode accesses the updated base and publishes that same updated base only after successful memory completion.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

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

- hl.sdi.upr SrcD, [SrcR, simm], ->{t, u, Rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
