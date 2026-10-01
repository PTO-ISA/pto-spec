<!-- GENERATED FROM: asl/scalar/amo/DMA.asl -->
# DMA

**Normative ASL source:** `asl/scalar/amo/DMA.asl`

DMA performs an exact 64-byte copy, validates both ranges before effects, snapshots the source so overlap has memmove semantics, and guarantees that any fault leaves memory unchanged for precise full reissue.

## Normative identity {#PTO-INST-SCALAR-DMA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-dma-purpose role=purpose -->
## What DMA does

`DMA` copies exactly `64` bytes from the byte address in `SrcL` to the byte address in `SrcR`. The form has no destination register, so no GPR and no queue entry receives a result: the only architectural result is the destination range in memory.

A successful execution commits the whole copy and advances `TPC` by `4` bytes; a fault commits nothing and leaves `TPC` on the instruction.

Design point: the copy length belongs to the mnemonic, not to the encoding. `InstructionContractCopySizeBytes_DMA` returns `64` and both probes request `64` bytes, so no field value selects another length.

<!-- PTO-READER-BLOCK: scalar-dma-mechanism role=mechanism -->
## How the copy is ordered

Dispatch routes the form to `ExecuteScalarDMACopy64` in `asl/scalar/model/amo/semantics.asl`. Both `ReadDecodedScalarRegister` arguments are evaluated before that call, so the two addresses are snapshotted before the first probe.

The steps then run in a fixed order:

- probe the complete `64`-byte source range for read access with one-byte alignment;
- probe the complete `64`-byte destination range for write access with one-byte alignment;
- read all `64` source bytes into one snapshot and record `8` relaxed load events;
- write that snapshot to the destination range and record `8` relaxed store events.

Design point: the snapshot is read before the first destination byte is written, so overlapping ranges behave like `memmove`: with the destination `8` bytes above the source, the bytes at `source+8 .. source+71` are the original `source+0 .. source+63`.

Design point: the source probe precedes the destination probe, so when both ranges are unusable the reported fault is the source one and the destination range is not probed at all in that case.

<!-- PTO-READER-BLOCK: scalar-dma-inputs-outputs role=inputs-outputs -->
## Inputs and result

`SrcL` is a `5`-bit field at instruction bits `15..19` and supplies the source byte address; `SrcR` is a `5`-bit field at bits `20..24` and supplies the destination byte address. Both are Reg5 sources: `0..23` read absolute GPRs, `24..27` read `T#1..T#4`, and `28..31` read `U#1..U#4`.

Reading a queue entry does not consume it, so `dma [t#1], u#1` reads `T#1` and `U#1` and leaves both queues at their previous depth.

Bits `31:25` are fixed zero by the instruction match, so this form has no ordering field, no route hint and no size modifier: no `far` bit and no `.aq`, `.rl` or size suffix to encode. Alignment requires one byte, so every byte address passes the alignment test inside `ProbeDataAccess`; the range must still pass the permission and bounds check.

Design point: with a one-byte alignment requirement the alignment branch of `ProbeDataAccess` never fires here, so the only data-access fault this form raises is `Fault_DataPage`.

<!-- PTO-READER-BLOCK: scalar-dma-effects role=effects -->
## Effects and ordering

A successful execution records `8` load events of `8` bytes at the translated source address plus offsets `0, 8, ... 56`, then writes all `64` snapshot bytes to the destination, then records `8` store events of `8` bytes at the translated destination address plus the same offsets. Every event uses relaxed ordering, and events are captured only while memory-event capture is enabled.

The destination store clears the local reservation when a reservation is valid and the `64`-byte destination range overlaps the reserved `64`-byte granule; a reservation that does not overlap is preserved. GPRs and queue entries are unchanged.

Design point: every recorded store value comes from the snapshot rather than a second read of the source, so the trace describes the source bytes as they were before the instruction started.

<!-- PTO-READER-BLOCK: scalar-dma-constraints role=constraints -->
## Legality and precise faults

Both complete ranges must pass preflight before any byte is read or written, and the first failing probe wins. The fault carries the original architectural address; in the reference model translation returns that address unchanged.

A fault at either probe produces no destination byte, no memory event, no reservation change and no `TPC` advance. A decode failure or an unavailable selected T/U source raises `Fault_IllegalInstruction` earlier.

Design point: because both probes cover the complete ranges before the copy starts, a fault leaves memory exactly as it was; a reissue therefore performs the whole copy rather than resuming a partly finished one.

<!-- PTO-READER-BLOCK: scalar-dma-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

With `a0` holding the source address and `a1` holding an address `8` bytes above it, `dma [a0], a1` leaves the `64` bytes that were at `[a0 .. a0+63]` at `[a0+8 .. a0+71]`, and the captured trace holds `8` load events followed by `8` store events.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
dma [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dma_32_a168aeca5fa5 | L32 | 32 | 0x0000700b / 0xfe007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dma_32_a168aeca5fa5 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| dma_32_a168aeca5fa5 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| dma_32_a168aeca5fa5 | SrcL | 5 | 0–31 | none | none | Reg5 source byte-address source | Encoded zero reads the architectural zero register as source byte address zero. |
| dma_32_a168aeca5fa5 | SrcR | 5 | 0–31 | none | none | Reg5 destination byte-address source | Encoded zero reads the architectural zero register as destination byte address zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source byte-address source |
| SrcR | Reg5 destination byte-address source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/DMA.asl -->
```asl
readonly func InstructionContractOperation_DMA()
    => ScalarOperation
begin
    return ScalarOperation_DMA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/DMA.asl -->
```asl
readonly func InstructionContractHandler_DMA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDMACopy64;
end;

pure func InstructionContractCopySizeBytes_DMA()
    => integer {1..262144}
begin
    return 64;
end;

pure func InstructionContractEventChunkSizeBytes_DMA()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractEventChunkCount_DMA()
    => integer {1..16}
begin
    return 8;
end;

pure func InstructionContractSourceProbePrecedesDestination_DMA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSnapshotsSourceBeforeCommit_DMA()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required Reg5 source fields. Encoded source zero reads the architectural zero register as byte address zero; no field value denotes omission.
- DMA has no ordering, route, destination, or size modifier. The copy size is always 64 bytes, its alignment requirement is one byte, and every successful memory event is relaxed.

## Legality

- All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- Both complete 64-byte ranges must pass access preflight. The source range is probed before the destination range and the first failing probe wins.
- Every byte address is naturally aligned because DMA requires one-byte alignment. Exact overlap, forward overlap, backward overlap, and disjoint ranges are all legal.

## State effects

- Snapshot both Reg5 address operands before access preflight so repeated GPR selectors and T/U queue sources observe pre-instruction values. DMA has no scalar destination and consumes no queue entry.
- Successful execution advances TPC by four bytes after the complete memory and event commit. Fault entry saves the original TPC, redirects the live TPC, and recovery restores the saved TPC for full reissue.
- GPRs, T/U queues, unrelated memory, and unrelated architectural state are unchanged. Reservation state changes only for a successful destination range overlapping the reserved 64-byte granule.

## Memory effects and ordering

### Memory effects

- Probe the complete 64-byte source range for read access, then the complete 64-byte destination range for write access, before reading or writing architectural memory.
- All 64 source bytes are snapshotted before the first destination write, giving exact, forward, and backward overlap memmove semantics.
- A successful captured execution emits eight ordered 8-byte relaxed load events followed by eight ordered 8-byte relaxed store events. Each store event value is derived from the corresponding chunk of the single source snapshot.
- The destination store invalidates an overlapping local reservation and preserves a nonoverlapping reservation. Either fault preserves the prior reservation.

### Ordering

- The eight load events precede all eight store events in instruction program order. Every event uses relaxed ordering.
- DMA is one restartable instruction: a fault exposes no event prefix or partial destination update; recovery performs a full reissue and one successful commit.

## Exceptions

- Bits 31:25 are fixed zero by the instruction match. Any other fixed-bit pattern is not DMA and raises Fault_IllegalInstruction before effects when it has no other legal owner.
- The source range is probed before the destination range. The first failing alignment, translation, permission, or bounded-memory check reports the original architectural address.
- A source or destination fault occurs before any source byte read, memory event, destination write, reservation update, or TPC advance. Trap entry saves the original TPC and recovery restores it for full reissue.

## Examples

- dma [a0], a1
- dma [t#1], u#1
- dma [zero], sp
