<!-- GENERATED FROM: asl/scalar/agu/HL.LHUP.asl -->
# HL.LHUP

**Normative ASL source:** `asl/scalar/agu/HL.LHUP.asl`

HL.LHUP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 2-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LHUP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.lhup [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lhup_48_ea24f978b27a | HL48 | 48 | 0x00005009001e / 0x0000707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lhup_48_ea24f978b27a | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lhup_48_ea24f978b27a | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lhup_48_ea24f978b27a | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lhup_48_ea24f978b27a | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lhup_48_ea24f978b27a | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lhup_48_ea24f978b27a | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lhup_48_ea24f978b27a | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhup_48_ea24f978b27a | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhup_48_ea24f978b27a | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lhup_48_ea24f978b27a | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lhup_48_ea24f978b27a | SrcRType | 2 | 0–3 | none | none | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lhup_48_ea24f978b27a | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHUP.asl -->
```asl
readonly func InstructionContractOperation_HL_LHUP() => ScalarOperation
begin
    return ScalarOperation_HL_LHUP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHUP.asl -->
```asl
readonly func InstructionContractHandler_HL_LHUP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LHUP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LHUP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LHUP()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_LHUP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LHUP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LHUP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LHUP()
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
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 2; the instruction performs no base writeback.
- After both 2-byte probes succeed, zero-extend each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 2-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 2-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lhup [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->Dst0, Dst1

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
