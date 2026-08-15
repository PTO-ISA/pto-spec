<!-- GENERATED FROM: asl/scalar/agu/HL.SDIP.asl -->
# HL.SDIP

**Normative ASL source:** `asl/scalar/agu/HL.SDIP.asl`

HL.SDIP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 8-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SDIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.sdip SrcD, SrcD1, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sdip_48_6d622cf167ca | HL48 | 48 | 0x00003059001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sdip_48_6d622cf167ca | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sdip_48_6d622cf167ca | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_sdip_48_6d622cf167ca | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sdip_48_6d622cf167ca | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sdip_48_6d622cf167ca | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sdip_48_6d622cf167ca | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sdip_48_6d622cf167ca | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sdip_48_6d622cf167ca | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcR | Reg5 register-offset source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SDIP.asl -->
```asl
readonly func InstructionContractOperation_HL_SDIP() => ScalarOperation
begin
    return ScalarOperation_HL_SDIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SDIP.asl -->
```asl
readonly func InstructionContractHandler_HL_SDIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SDIP()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SDIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SDIP()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractAGUOffsetScale_HL_SDIP()
    => integer {0..3}
begin
    return 3;
end;

pure func InstructionContractAGUUpdateMode_HL_SDIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SDIP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SDIP()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 8.
- Each memory address must be aligned to the 8-byte access size; a 8-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 8, and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 8; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 8-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 8-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 8-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sdip SrcD, SrcD1, [SrcR, simm]

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
