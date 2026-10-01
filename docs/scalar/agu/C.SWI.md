<!-- GENERATED FROM: asl/scalar/agu/C.SWI.asl -->
# C.SWI

**Normative ASL source:** `asl/scalar/agu/C.SWI.asl`

C.SWI snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-C-SWI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-swi-purpose role=purpose -->
## What `C.SWI` does

`C.SWI` is a `16`-bit compressed store of one `4`-byte little-endian word. The base is the `SrcL` selector, the byte displacement is the sign-extended `simm5` field multiplied by `4`, and the data written to memory is the low `32` bits of the newest temporary-queue value `t#1`.

The form has no destination field and no writeback.

Design point: only the low `4` bytes of the `64`-bit queue entry reach memory. The store writes exactly the access size, taking byte `k` of the value from bits `8k` to `8k+7`, so `C.SWI` truncates while `C.SDI` writes the whole entry. A `T#1` of `0x00000000FFFFFFFF` stored by `C.SWI` writes `FF FF FF FF`, and the upper half is lost.

<!-- PTO-READER-BLOCK: scalar-c-swi-mechanism role=mechanism -->
## How the address and the store are formed

The address path snapshots `SrcL`, sign-extends `simm5`, shifts it left by `2` bits, and adds the two modulo `2^PTO_XLEN`.

No updated-base value is computed for publication, so `SrcL` is read-only for this instruction on both the success and the fault path.

Once the encoding checks and the address preflight pass, the handler reads `T#1`, performs one aligned `4`-byte little-endian store, and records the store event.

Design point: the scale factor matches the `4`-byte access. The reachable byte displacement is `-64` to `60` in steps of `4`, and because both the displacement and the required alignment are multiples of `4`, an aligned base keeps every reachable address aligned. The narrower scale is what makes the reachable window smaller than the one `C.SDI` offers.

<!-- PTO-READER-BLOCK: scalar-c-swi-inputs role=inputs-outputs -->
## Encoded fields and data source

- `SrcL` is a `5`-bit Reg5 selector covering absolute GPRs, `T#1`..`T#4`, and `U#1`..`U#4`.
- `simm5` is a signed `5`-bit displacement scaled by `4`; all `32` encodings are values.
- The data source is implicit `T#1`, read through the queue without being popped.
- There is no destination field, so no result register is named and none is written.

Design point: the availability of `T#1` is part of legality, checked before the memory operation. A clear validity flag therefore rejects the instruction with `Fault_IllegalInstruction` and no byte is written, which keeps a store from publishing a stale or undefined queue entry.

<!-- PTO-READER-BLOCK: scalar-c-swi-effects role=effects -->
## Effects, ordering, and completion

The `SrcL` snapshot and the `T#1` read precede the memory effect, so any alias between them uses the pre-instruction value.

On success one relaxed store event is recorded. A store whose byte range overlaps the reservation granule that contains the reserved address clears the reservation; a store outside that granule leaves it valid.

`TPC` advances by `2` bytes after the store completes. A rejected or faulting attempt does not retire.

Design point: the event is recorded after the bytes are written, so a later observer that sees the event also sees the stored value. A faulting store produces neither.

<!-- PTO-READER-BLOCK: scalar-c-swi-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch in the `16`-bit encoding raises `Fault_IllegalInstruction` before any effect, as does an unavailable `SrcL` `T` or `U` slot and an unavailable `T#1`.

The preflight tests the low `2` bits of the effective address. A nonzero value raises `Fault_DataAlignment` before translation and before the permission check; a later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves the reservation and `TPC` unchanged. Recovery reissues `SrcL` snapshot, address formation, preflight, `T#1` read, and store with no retained progress.

<!-- PTO-READER-BLOCK: scalar-c-swi-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `c.swi t#1, [9, -1]` with GPR9 holding `0x5000`. The signed `simm5` is `-1`, scaled by `4` gives `-4`, so the effective address is `0x5000` minus `4`, which is `0x4FFC`.
- The instruction writes the low `4` bytes of `T#1` to `0x4FFC` through `0x4FFF`, least significant byte first.
- If `T#1` holds `0x1122334455667788`, the bytes written are `88 77 66 55`.
- GPR9 still holds `0x5000` and `TPC` becomes the instruction address plus `2`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.swi t#1, [srcL, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_swi_16_ca6c111163e5 | C16 | 16 | 0x002a / 0x003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_swi_16_ca6c111163e5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| c_swi_16_ca6c111163e5 | simm5 | 5 | signed | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_swi_16_ca6c111163e5 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| c_swi_16_ca6c111163e5 | simm5 | 5 | 0–31 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 address-base source |
| simm5 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/C.SWI.asl -->
```asl
readonly func InstructionContractOperation_C_SWI() => ScalarOperation
begin
    return ScalarOperation_C_SWI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/C.SWI.asl -->
```asl
readonly func InstructionContractHandler_C_SWI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_C_SWI()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_C_SWI()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Compressed;
end;

pure func InstructionContractAGUSizeBytes_C_SWI()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_C_SWI()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_C_SWI()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_C_SWI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_C_SWI()
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
- The implicit store-data source is T#1 and must be available before execution; reading it does not consume it.
- simm5 assigns every signed 5-bit value -16..15; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Sign-extend simm5, multiply it by 4, and add it modulo 2^PTO_XLEN to the SrcL base.
- Snapshot implicit T#1 before memory effects and preserve the queue entry after the store.
- Successful execution advances TPC by 2 bytes; a rejected or faulting attempt does not retire.

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

- c.swi t#1, [srcL, simm]
