<!-- GENERATED FROM: asl/scalar/agu/HL.LWUP.asl -->
# HL.LWUP

**Normative ASL source:** `asl/scalar/agu/HL.LWUP.asl`

HL.LWUP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 4-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LWUP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lwup-purpose role=purpose -->
## What `HL.LWUP` does

`HL.LWUP` is a standalone `48`-bit scalar AGU instruction that loads two adjacent 4-byte little-endian values through a register offset and zero-extends each one to `PTO_XLEN`.

The canonical assembly is `hl.lwup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1`.

Design point: the offset comes from `SrcR` and the base from `SrcL`, so one traversal can keep a stream pointer and a moving index in separate registers. The base is an address; the offset register is a distance and can be reused as a count.

Design point: the second address is not encoded. The handler computes it as the first address plus the transfer size, so the pair is always two adjacent 4-byte units. Two values 8 bytes apart need two separate loads.

<!-- PTO-READER-BLOCK: scalar-hl-lwup-mechanism role=mechanism -->
## How the address and the transfer are formed

`SrcRType` transforms the `SrcR` snapshot first, then `shamt` shifts the result, and the shifted value is added to the `SrcL` snapshot modulo `2^PTO_XLEN`.

That sum is the first address, and the sum plus `4` is the second. The update mode is none, so this form writes no base register back.

Both addresses are probed before either memory read starts. Only when both probes report no fault does the handler read the two aligned 4-byte units and publish the two results.

Design point: probing the whole pair before the first read makes the form all-or-nothing. An access fault on the second unit is raised before the first unit is read, so half a pair can never be observed as loaded.

<!-- PTO-READER-BLOCK: scalar-hl-lwup-inputs role=inputs-outputs -->
## Encoded fields and results

- `SrcL` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcR` uses the same `5`-bit Reg5 domain, so an offset may also come from a queue slot or from the zero GPR.
- `SrcRType` is `2` bits: `00` leaves the whole `SrcR` value unchanged, `01` and `10` replace it with the signed and unsigned readings of its low `32` bits, and `11` is reserved.
- `shamt` is a `5`-bit unsigned shift amount applied after the transformation; encoded zero performs no shift.
- `RegDst0` and `RegDst1` are `5`-bit selectors. Codes `1`..`23` write absolute GPRs, code `30` pushes `U`, code `31` pushes `T`, and codes `0` and `24`..`29` discard that one result.

Design point: `RegDst0` receives the lower-address unit and `RegDst1` the higher one, and the two fields are independent, so a discarded load still runs and still raises its own faults.

<!-- PTO-READER-BLOCK: scalar-hl-lwup-effects role=effects -->
## Effects, ordering, and completion

Every scalar source is snapshotted before any memory or destination effect, so a destination that names `SrcL` or `SrcR` still contributes the pre-instruction value to the address.

A successful execution records two relaxed load events, lower address first. Memory bytes and reservation state are unchanged, because a load neither writes memory nor disturbs a reservation.

`TPC` advances by `6` bytes after both results are published. A rejected or faulting attempt does not retire.

Design point: both results are written only in the last step, so one destination cannot feed the second address of the same instruction. The pair acts on one pre-instruction register state, which is what makes `->5, 5` a defined encoding.

<!-- PTO-READER-BLOCK: scalar-hl-lwup-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch, a reserved encoded value, or a source code selecting an unavailable `T` or `U` slot raises `Fault_IllegalInstruction` before any instruction effect.

A misaligned 4-byte address raises `Fault_DataAlignment` before translation or permission. A later permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction. Recovery recomputes the snapshots, both addresses, both probes, and both loads from the beginning.

Design point: `SrcRType` raw `11` rejects in the reserved-value check before the sources are read, so a reserved selector cannot expose a partly formed offset.

<!-- PTO-READER-BLOCK: scalar-hl-lwup-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lwup [3, 9<<2], ->5, 6` with GPR3 = `0x1000` and GPR9 = `0x400`.
- `SrcRType` is `00`, so the offset is `0x400`; `shamt` is `2`, so it becomes `0x1000`.
- The sum is `0x2000`, so the pair covers `0x2000` and `0x2004`.
- GPR5 receives the unit at `0x2000` and GPR6 the unit at `0x2004`. GPR3 and GPR9 keep their values, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lwup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lwup_48_30f20380c354 | HL48 | 48 | 0x00006009001e / 0x0000707f07ff | [{"field":"SrcRType","operator":"one-of","values":[0,1,2]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lwup_48_30f20380c354 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lwup_48_30f20380c354 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lwup_48_30f20380c354 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lwup_48_30f20380c354 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_lwup_48_30f20380c354 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |
| hl_lwup_48_30f20380c354 | shamt | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lwup_48_30f20380c354 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwup_48_30f20380c354 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lwup_48_30f20380c354 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lwup_48_30f20380c354 | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_lwup_48_30f20380c354 | SrcRType | 2 | 0–2 | none | 3 | register-offset transformation selector | Encoded zero leaves the complete PTO_XLEN register-offset value unchanged. |
| hl_lwup_48_30f20380c354 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

- `hl_lwup_48_30f20380c354.SrcRType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

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

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWUP.asl -->
```asl
readonly func InstructionContractOperation_HL_LWUP() => ScalarOperation
begin
    return ScalarOperation_HL_LWUP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWUP.asl -->
```asl
readonly func InstructionContractHandler_HL_LWUP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LWUP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LWUP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Register;
end;

pure func InstructionContractAGUSizeBytes_HL_LWUP()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_HL_LWUP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_LWUP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LWUP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LWUP()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcRType=0 leaves SrcR unchanged, SrcRType=1 sign-extends SrcR[31:0], SrcRType=2 zero-extends SrcR[31:0], and SrcRType=3 is reserved. Encoded shamt zero performs no shift.

## Legality

- Every encoded Reg5 source uses the complete domain: codes 0..23 select absolute GPRs, codes 24..27 select T#1..T#4, and codes 28..31 select U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- SrcRType values 0, 1, and 2 and all shamt values 0..31 are assigned; SrcRType=3 is reserved; apply the modifier before the shift.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Form offset = LSL(Modify(SrcR, SrcRType), the encoded shamt) and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 4; the instruction performs no base writeback.
- After both 4-byte probes succeed, zero-extend each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 4-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 4-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lwup [SrcL, SrcR<{.sw,.uw}><<<shamt>], ->Dst0, Dst1
