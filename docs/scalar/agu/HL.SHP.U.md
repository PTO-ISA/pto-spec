<!-- GENERATED FROM: asl/scalar/agu/HL.SHP.U.asl -->
# HL.SHP.U

**Normative ASL source:** `asl/scalar/agu/HL.SHP.U.asl`

HL.SHP.U snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 2-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SHP-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-shp-u-purpose role=purpose -->
## What HL.SHP.U does

`HL.SHP.U` is a standalone `48`-bit AGU instruction that forms a register-offset address and stores two adjacent aligned little-endian `2`-byte values.

<!-- PTO-READER-BLOCK: scalar-hl-shp-u-mechanism role=mechanism -->
## Address and memory mechanism

`HL.SHP.U` transforms `SrcR` according to `SrcRType` and adds the unscaled result modulo `2^PTO_XLEN` to the snapshotted `SrcL` base.

The instruction preflights two adjacent `2`-byte addresses, then stores the two snapshotted data values in increasing-address order.

This form performs no base-register writeback; its effective address is used only by the selected memory operation.

<!-- PTO-READER-BLOCK: scalar-hl-shp-u-inputs role=inputs-outputs -->
## Inputs and outputs

- `SrcL` supplies the base; `SrcR` supplies the offset; `SrcRType` supplies the offset transformation. Every encoded Reg5 source among `SrcD`, `SrcD1`, `SrcL`, `SrcR` uses codes `0..23` for GPRs, `24..27` for `T#1..T#4`, and `28..31` for `U#1..U#4` without consumption.
- `SrcD` supplies first store value; `SrcD1` supplies second store value.
- All `SrcRType` values `0..3` are assigned; the selected transformation is applied before the form's fixed scaling.

<!-- PTO-READER-BLOCK: scalar-hl-shp-u-effects role=effects -->
## Effects and ordering

All explicit and implicit scalar sources are snapshotted before memory or destination effects, so aliases observe pre-instruction values.

After both addresses pass preflight, success records two relaxed store events in address order, updates overlapping reservation state only after complete preflight, and advances `TPC` by `6` bytes.

<!-- PTO-READER-BLOCK: scalar-hl-shp-u-constraints role=constraints -->
## Alignment, faults, and restart

Each effective address must satisfy `2`-byte alignment. Misalignment raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no successful memory event, performs no partial memory, destination, or writeback effect, preserves pending writeback, and leaves the faulting `TPC` available for full reissue.

A fixed-bit mismatch, reserved field value, or unavailable selected `T`/`U` source raises `Fault_IllegalInstruction` before instruction effects.

<!-- PTO-READER-BLOCK: scalar-hl-shp-u-example role=example -->
## Non-normative address example

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

With base `0x100`, unchanged offset source `2`, and the fixed shift `0`, the offset is `2` and base plus offset is `0x102`. The memory access uses `0x102`. The second `2`-byte store uses `0x104` after both addresses pass preflight.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.shp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_shp_u_48_232b2200b7b9 | HL48 | 48 | 0x00005049001e / 0x00007ffff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_shp_u_48_232b2200b7b9 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_shp_u_48_232b2200b7b9 | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_shp_u_48_232b2200b7b9 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_shp_u_48_232b2200b7b9 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_shp_u_48_232b2200b7b9 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_shp_u_48_232b2200b7b9 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_shp_u_48_232b2200b7b9 | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_shp_u_48_232b2200b7b9 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_shp_u_48_232b2200b7b9 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_shp_u_48_232b2200b7b9 | SrcRType | 2 | 0–3 | none | none | register-offset transformation selector | Encoded zero sign-extends SrcR[31:0] to PTO_XLEN; it does not mean an omitted modifier. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHP.U.asl -->
```asl
readonly func InstructionContractOperation_HL_SHP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SHP_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHP.U.asl -->
```asl
readonly func InstructionContractHandler_HL_SHP_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SHP_U()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SHP_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_SHP_U()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SHP_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SHP_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SHP_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SHP_U()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 sign-extends SrcR[31:0], SrcRType=1 zero-extends SrcR[31:0], SrcRType=2 negates the full PTO_XLEN value, and SrcRType=3 leaves the complete PTO_XLEN value unchanged. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- All four SrcRType values and all shamt values 0..31 are assigned; apply the modifier before the shift.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), 0) and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 2; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 2-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 2-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.shp.u SrcD, SrcD1, [SrcL, SrcR<{.sw,.uw,.neg}>]
