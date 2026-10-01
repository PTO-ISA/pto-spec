<!-- GENERATED FROM: asl/scalar/agu/HL.SHI.asl -->
# HL.SHI

**Normative ASL source:** `asl/scalar/agu/HL.SHI.asl`

HL.SHI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SHI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-shi-purpose role=purpose -->
## What `HL.SHI` stores

`HL.SHI` is a standalone `48`-bit scalar AGU instruction that stores one `2`-byte little-endian unit from `SrcD` at a scaled `simm22` displacement from the `SrcR` base.

The canonical assembly is `hl.shi SrcD, [SrcR, simm]`.

Design point: `22` bits scaled by `2` reach every even byte offset from `-4194304` through `4194302`, so a large `2`-byte array can be addressed with one instruction and no index register.

<!-- PTO-READER-BLOCK: scalar-hl-shi-mechanism role=mechanism -->
## How the address is formed

The displacement is the sign-extended `simm22` value multiplied by `2`, and it is added to the `SrcR` snapshot modulo `2^PTO_XLEN`, which gives the computed address.

The scale is `1`, so the displacement counts `2`-byte units and every reachable displacement is even.

The update mode is none, so the store uses the computed address and no register receives a result: this form has no `RegDst` field.

The address is probed before the store, and `SrcD` is read before that probe; on success one `2`-byte little-endian store and one relaxed store event are performed.

Design point: the larger field is spent on range rather than on byte granularity, so an odd offset is not representable and must be formed as a base adjustment instead.

<!-- PTO-READER-BLOCK: scalar-hl-shi-inputs role=inputs-outputs -->
## Operands

- `SrcD` and `SrcR` are `5`-bit Reg5 source selectors: codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed, and code `0` reads the architectural zero GPR.

- `simm22` is a `22`-bit signed field that assigns every value from `-2097152` through `2097151`; the encoded byte displacement is that value multiplied by `2`, and encoded zero is a zero displacement rather than omission.

- This form has no `RegDst` field, so no register receives a result and no updated base is published.

Design point: there is no `RegDst`, so the base register is read-only for this form and the only architectural change is the `2` bytes in memory.

<!-- PTO-READER-BLOCK: scalar-hl-shi-effects role=effects -->
## Effects and ordering

`SrcR` and `SrcD` are read before the store, so the address and the stored data are pre-instruction values.

A successful execution records one relaxed store event and changes only the `2` bytes of the unit.

A valid reservation is invalidated when the stored range overlaps the reservation's `64`-byte granule; a reservation whose granule the store leaves untouched stays valid.

`TPC` advances by `6` bytes after the store completes. A rejected or faulting attempt does not retire.

Design point: the store writes the low `2` bytes of `SrcD` and leaves the other `48` bits in the register, so a `64`-bit source is truncated silently by design of the `2`-byte unit.

<!-- PTO-READER-BLOCK: scalar-hl-shi-constraints role=constraints -->
## Alignment, faults, and restart

- The effective address must be a multiple of `2`. A misaligned address raises `Fault_DataAlignment` before translation or permission; a later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

- A fixed-bit mismatch, or a source selector naming an unavailable `T` or `U` entry, raises `Fault_IllegalInstruction` at `PC` before any instruction effect.

- A fault records no store event: memory and every register keep their pre-instruction values, `TPC` is not advanced, and recovery recomputes the address, the probe, and the store.

Design point: the displacement is scaled by `2`, so it can never make an aligned base unaligned; only an odd base can fail the alignment probe, and it is reported as `Fault_DataAlignment` before translation.

<!-- PTO-READER-BLOCK: scalar-hl-shi-example role=example -->
## Worked example

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- `hl.shi 20, [2, 3]` with GPR2 = `0x1000` and GPR20 = `0xbeef`.

- The displacement `3` multiplied by `2` is `6`, so the effective address is `0x1006`.

- The store writes `0xef`, `0xbe` at `0x1006` through `0x1007` in increasing address order.

- No register changes: `SrcD` and `SrcR` keep their pre-instruction values, and `TPC` advances by `6` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.shi SrcD, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_shi_48_38ea3f0a4f08 | HL48 | 48 | 0x00001059000e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_shi_48_38ea3f0a4f08 | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_shi_48_38ea3f0a4f08 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_shi_48_38ea3f0a4f08 | simm22 | 22 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":10}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_shi_48_38ea3f0a4f08 | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_shi_48_38ea3f0a4f08 | SrcR | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_shi_48_38ea3f0a4f08 | simm22 | 22 | 0–4194303 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcR | Reg5 address-base source |
| simm22 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SHI.asl -->
```asl
readonly func InstructionContractOperation_HL_SHI() => ScalarOperation
begin
    return ScalarOperation_HL_SHI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SHI.asl -->
```asl
readonly func InstructionContractHandler_HL_SHI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SHI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SHI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SHI()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SHI()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_HL_SHI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SHI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SHI()
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
- simm22 assigns every signed 22-bit value -2097152..2097151; the encoded byte displacement is that value multiplied by 2.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm22, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcR base.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

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

- hl.shi SrcD, [SrcR, simm]
