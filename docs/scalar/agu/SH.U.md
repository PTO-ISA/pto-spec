<!-- GENERATED FROM: asl/scalar/agu/SH.U.asl -->
# SH.U

**Normative ASL source:** `asl/scalar/agu/SH.U.asl`

SH.U snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-SH-U}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sh-u-purpose role=purpose -->
## What SH.U does

`SH.U` is a standalone `32`-bit AGU instruction that forms a register-offset address and stores one aligned little-endian `2`-byte value.

<!-- PTO-READER-BLOCK: scalar-sh-u-mechanism role=mechanism -->
## Address and memory mechanism

`SH.U` transforms `SrcR` according to `SrcRType` and adds the unscaled result modulo `2^PTO_XLEN` to the snapshotted `SrcL` base.

After complete preflight, the instruction performs one little-endian `2`-byte store from its snapshotted store-data source.

This form performs no base-register writeback; its effective address is used only by the selected memory operation.

<!-- PTO-READER-BLOCK: scalar-sh-u-inputs role=inputs-outputs -->
## Inputs and outputs

- `SrcL` supplies the base; `SrcR` supplies the offset; `SrcRType` supplies the offset transformation. Every encoded Reg5 source among `SrcD`, `SrcL`, `SrcR` uses codes `0..23` for GPRs, `24..27` for `T#1..T#4`, and `28..31` for `U#1..U#4` without consumption.
- `SrcD` supplies store data.
- All `SrcRType` values `0..3` are assigned; the selected transformation is applied before the form's fixed scaling.

<!-- PTO-READER-BLOCK: scalar-sh-u-effects role=effects -->
## Effects and ordering

All explicit and implicit scalar sources are snapshotted before memory or destination effects, so aliases observe pre-instruction values.

A successful attempt records one relaxed store event, invalidates an overlapping reservation but preserves a nonoverlapping one, and advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-sh-u-constraints role=constraints -->
## Alignment, faults, and restart

Each effective address must satisfy `2`-byte alignment. Misalignment raises `Fault_DataAlignment` before translation; a later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no successful memory event, performs no partial memory, destination, or writeback effect, preserves pending writeback, and leaves the faulting `TPC` available for full reissue.

A fixed-bit mismatch, reserved field value, or unavailable selected `T`/`U` source raises `Fault_IllegalInstruction` before instruction effects.

<!-- PTO-READER-BLOCK: scalar-sh-u-example role=example -->
## Non-normative address example

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

With base `0x100`, unchanged offset source `2`, and the fixed shift `0`, the offset is `2` and base plus offset is `0x102`. The memory access uses `0x102`. If aligned and permitted, the instruction stores `2` bytes at that address.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sh.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sh_u_32_fa87afbf8f24 | L32 | 32 | 0x00005049 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sh_u_32_fa87afbf8f24 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| sh_u_32_fa87afbf8f24 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sh_u_32_fa87afbf8f24 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sh_u_32_fa87afbf8f24 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sh_u_32_fa87afbf8f24 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| sh_u_32_fa87afbf8f24 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| sh_u_32_fa87afbf8f24 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| sh_u_32_fa87afbf8f24 | SrcRType | 2 | 0–3 | none | none | register-offset transformation selector | Encoded zero sign-extends SrcR[31:0] to PTO_XLEN; it does not mean an omitted modifier. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcL | Reg5 address-base source |
| SrcR | Reg5 register-offset source |
| SrcRType | register-offset transformation selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SH.U.asl -->
```asl
readonly func InstructionContractOperation_SH_U() => ScalarOperation
begin
    return ScalarOperation_SH_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SH.U.asl -->
```asl
readonly func InstructionContractHandler_SH_U()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SH_U()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SH_U()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_SH_U()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_SH_U()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_SH_U()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SH_U()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SH_U()
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
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- sh.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]
