<!-- GENERATED FROM: asl/scalar/amo/SC.B.asl -->
# SC.B

**Normative ASL source:** `asl/scalar/amo/SC.B.asl`

SC.B conditionally stores one byte when the local 64-byte-line reservation matches.

## Normative identity {#PTO-INST-SCALAR-SC-B}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sc-b-purpose role=purpose -->
## What SC.B does
`SC.B` conditionally stores one byte to memory. The store happens only when the local reservation still covers the containing 64-byte line of the store address; otherwise `SC.B` reports a miss and memory is left alone. The summary recorded for this form is: SC.B conditionally stores one byte when the local 64-byte-line reservation matches.
Only an earlier `LR` load creates a reservation, and every attempt clears it, so `SC.B` reports a result instead of updating memory unconditionally. That result is written to the Reg5 destination named by `RegDst`.

<!-- PTO-READER-BLOCK: scalar-sc-b-mechanism role=mechanism -->
## Atomic mechanism
The instruction contract selects `ScalarHandler_StoreConditional` at store width `1` bytes and a `64`-byte reservation granule, and records that a miss is probe-free.
Scalar dispatch calls `StoreConditional`, which first reads `SrcL` and `SrcR`, then clears `_ReservationValid` before looking at the access at all. A store whose granule address differs from `_ReservationAddress` is a miss: the helper returns `Zeros + 1` and never calls `ProbeDataAccess`, so no probe and no fault can occur.
A match builds a write probe for `1` bytes at the store address. A failing probe raises the data-access fault and publishes nothing; a passing one stores the low 8 bits, records one ordered store event, and returns `Zeros`.
Design point: the reservation is cleared before the probe, not after the store, so every attempt consumes it and a trap on the access cannot be followed by a retry that succeeds without a new `LR` load. The reservation behaves as a one-shot token rather than a latch.

<!-- PTO-READER-BLOCK: scalar-sc-b-inputs-outputs role=inputs-outputs -->
## Inputs and result
`SrcL` supplies the value to store and `SrcR` supplies the store address. `RegDst` receives the status: `0` after a matching store that completed without fault, `1` after a reservation miss.
`aq` and `rl` select the ordering recorded for a successful store. `far` is a route hint only: `AtomicAddress` returns its `address` argument unchanged, and the reservation comparison uses that same address.
All 32 source codes are assigned: `0`..`23` name a GPR, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. All 32 destination codes are legal as well: `0` and `24`..`29` discard the status, `30` pushes the `U` queue, `31` pushes the `T` queue, and `1`..`23` write the named GPR.

<!-- PTO-READER-BLOCK: scalar-sc-b-effects role=effects -->
## Effects, status, and ordering
A successful store writes one byte of memory at the translated address, records one store event with the selected ordering, and publishes status `Zeros`. A miss publishes status `Zeros + 1` and records no memory event because no memory access took place.
The reservation is cleared in all three outcomes: success, miss, and a line-matched access fault. A line-matched fault publishes no status, and the trap saves the original `TPC`; recovery restores it, so a reissue without a new `LR` is itself a probe-free miss.
Successful completion and a miss both advance `TPC` by `4` bytes. `SC.B` records no numeric status.
Design point: the miss path deliberately skips alignment and translation although a successful store requires both, so a stale reservation reports the miss rather than a fault about the address the program was about to write.

<!-- PTO-READER-BLOCK: scalar-sc-b-constraints role=constraints -->
## Legality and precise faults
This store is one byte wide, so every byte address is naturally aligned and the alignment test always passes. On a line-matched attempt the order is fixed: the reservation is cleared, then alignment, translation, and write permission are checked, and only then is the store performed. A line-matched fault reports the original architectural address, emits no event, and leaves memory and the destination unchanged.
A mismatch is not a fault: the miss path raises no data-access fault even for a misaligned or out-of-range address, because it never probes, so the reservation comparison is the only gate before a memory access.
`Fault_IllegalInstruction` is raised before any effect when no form decodes the 32-bit pattern (this one matches `0x0000100b` under mask `0xf000707f`), and also when a named source selects an invalid temporary queue entry. Encoded zero in `SrcL` supplies numeric zero as the stored value, and encoded zero in `SrcR` reads the architectural zero register as the store address.
Design point: that comparison uses the whole 64-byte granule: neither the `LR` byte address nor its width narrows the match.

<!-- PTO-READER-BLOCK: scalar-sc-b-example role=example -->
## Non-normative example
This example illustrates the current ASL owner and does not replace the normative operation.
The eight accepted spellings combine the optional `.aq`, `.rl`, and `.f` suffixes; the status destination may also be written `->t` or `->u`.
```text
sc.b SrcL, [SrcR], ->Rd
sc.b.aq SrcL, [SrcR], ->Rd
sc.b.rl SrcL, [SrcR], ->Rd
sc.b.f SrcL, [SrcR], ->Rd
sc.b.aqrl SrcL, [SrcR], ->Rd
sc.b.aqf SrcL, [SrcR], ->Rd
sc.b.rlf SrcL, [SrcR], ->Rd
sc.b.aqrlf SrcL, [SrcR], ->Rd
```
A pair of instructions makes the two outcomes visible. The `LR.W` below loads the word at address `a1` into `a3` and so establishes a reservation; this conditional store then targets the same line from `a1` and publishes its status to `a2`.
```text
lr.w [a1], ->a3
sc.b a0, [a1], ->a2
```
If nothing else wrote the line in between, `SC.B` stores and `a2` holds `0`; if the reservation was lost, `a2` holds `1` and memory is unchanged.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sc.b SrcL, [SrcR], ->Rd
sc.b.aq SrcL, [SrcR], ->Rd
sc.b.rl SrcL, [SrcR], ->Rd
sc.b.f SrcL, [SrcR], ->Rd
sc.b.aqrl SrcL, [SrcR], ->Rd
sc.b.aqf SrcL, [SrcR], ->Rd
sc.b.rlf SrcL, [SrcR], ->Rd
sc.b.aqrlf SrcL, [SrcR], ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sc_b_32_baf609e1d5c3 | L32 | 32 | 0x0000100b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sc_b_32_baf609e1d5c3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sc_b_32_baf609e1d5c3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sc_b_32_baf609e1d5c3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sc_b_32_baf609e1d5c3 | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| sc_b_32_baf609e1d5c3 | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sc_b_32_baf609e1d5c3 | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sc_b_32_baf609e1d5c3 | RegDst | 5 | 0–31 | none | none | Reg5 success-status destination | Encoded zero discards the success status. |
| sc_b_32_baf609e1d5c3 | SrcL | 5 | 0–31 | none | none | Reg5 byte store-value source | Encoded zero supplies numeric zero as the store value. |
| sc_b_32_baf609e1d5c3 | SrcR | 5 | 0–31 | none | none | Reg5 store-address source | Encoded zero reads the architectural zero register as the store address. |
| sc_b_32_baf609e1d5c3 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| sc_b_32_baf609e1d5c3 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| sc_b_32_baf609e1d5c3 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 byte store-value source |
| SrcR | Reg5 store-address source |
| RegDst | Reg5 success-status destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SC.B.asl -->
```asl
readonly func InstructionContractOperation_SC_B() => ScalarOperation
begin
    return ScalarOperation_SC_B;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SC.B.asl -->
```asl
readonly func InstructionContractHandler_SC_B() => ScalarSemanticHandler
begin
    return ScalarHandler_StoreConditional;
end;

pure func InstructionContractStoreSizeBytes_SC_B()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractReservationGranuleBytes_SC_B()
    => integer {1..262144}
begin
    return PTO_RESERVATION_GRANULE_BYTES;
end;

pure func InstructionContractSuccessStatus_SC_B() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractMissStatus_SC_B() => Word
begin
    return Zeros{PTO_XLEN} + 1;
end;

pure func InstructionContractMissIsProbeFree_SC_B()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the status.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same address and reservation comparison.

## Legality

- All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq, rl, and far combinations are assigned. Reservation match is based only on the containing 64-byte line; LR byte address and width do not narrow it.
- Every byte address is naturally aligned.

## State effects

- Snapshot SrcL and SrcR before reservation, memory, or destination effects, including repeated GPR and same-queue aliases.
- Publish status zero after a nonfaulting matching store and status one after a reservation miss. A line-matched fault publishes no status.
- Clear the local reservation for success, miss, and line-matched fault before any possible trap.
- Successful or miss completion advances TPC by four bytes. A line-matched fault saves the original TPC; recovery restores it, and reissue without a new LR completes as a miss.

## Memory effects and ordering

### Memory effects

- A matching reservation is cleared before access preflight. After successful preflight, store SrcL bits 7:0 as one 1-byte little-endian byte, emit one ordered store event, and publish status zero.
- A missing or different-line reservation is cleared and publishes status one without alignment, translation, permission, bounded-memory probe, memory event, or memory access.
- The reservation is cleared by every attempt. A line-matched access fault leaves memory and destination unchanged; after recovery, reissue without a new LR is a probe-free miss.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release on a successful store.
- A reservation miss emits no memory event. far changes only the route hint in the reference profile.

## Exceptions

- Every byte address is naturally aligned. On a line-matched attempt, alignment, translation, and write permission are checked after reservation clear and before memory or destination effects.
- A line-matched access fault reports the original address, emits no event, preserves memory and destination, and enters the ordinary trap envelope. Recovery restores the original TPC.
- A reservation miss is probe-free even for a misaligned or inaccessible address and therefore does not raise a data-access fault.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- sc.b a0, [a1], ->a2
- sc.b.aqrl t#1, [u#1], ->u
- sc.b.f zero, [sp], ->t
