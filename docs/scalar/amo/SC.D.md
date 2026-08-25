<!-- GENERATED FROM: asl/scalar/amo/SC.D.asl -->
# SC.D

**Normative ASL source:** `asl/scalar/amo/SC.D.asl`

SC.D conditionally stores one doubleword when the local 64-byte-line reservation matches.

## Normative identity {#PTO-INST-SCALAR-SC-D}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sc-d-purpose role=purpose -->
## What SC.D does

`SC.D` conditionally stores one doubleword when the local 64-byte-line reservation matches and publishes status zero for success or one for a miss.

<!-- PTO-READER-BLOCK: scalar-sc-d-mechanism role=mechanism -->
## Atomic mechanism

The ASL DOC contract selects `ScalarHandler_StoreConditional` with an access width of `8` bytes.

Every attempt clears the reservation. A reservation miss is probe-free, while a matching attempt performs write preflight before memory or destination effects.

<!-- PTO-READER-BLOCK: scalar-sc-d-inputs-outputs role=inputs-outputs -->
## Inputs and result

`SrcL` carries the Reg5 doubleword store-value source; `SrcR` carries the Reg5 store-address source; `RegDst` carries the Reg5 success-status destination; `aq` carries the acquire ordering bit; `rl` carries the release ordering bit; `far` carries the flat-address routing hint.

`aq` and `rl` select relaxed, acquire, release, or acquire-release ordering; `far` is a profile routing hint and does not change the architectural result in the reference profile.

<!-- PTO-READER-BLOCK: scalar-sc-d-effects role=effects -->
## Effects and ordering

A matching nonfaulting attempt stores the low-width source and emits one ordered store event; a miss leaves memory untouched and emits no event.

Success, miss, and line-matched fault all clear the reservation; success or miss advances `TPC` by `4` bytes.

<!-- PTO-READER-BLOCK: scalar-sc-d-constraints role=constraints -->
## Legality and precise faults

The effective address must be aligned to `8` bytes. Alignment, translation, and permission checks precede architectural effects.

A reservation miss is probe-free. A line-matched fault clears the reservation but publishes no status, event, memory update, or `TPC` advance; recovery reissue misses without a new LR.

<!-- PTO-READER-BLOCK: scalar-sc-d-example role=example -->
## Non-normative example

This example only shows one accepted spelling; the generated contract below remains authoritative.

For a first reading, use `sc.d SrcL, [SrcR], ->Rd` and then vary only the ordering or route modifiers described above.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sc.d SrcL, [SrcR], ->Rd
sc.d.aq SrcL, [SrcR], ->Rd
sc.d.rl SrcL, [SrcR], ->Rd
sc.d.f SrcL, [SrcR], ->Rd
sc.d.aqrl SrcL, [SrcR], ->Rd
sc.d.aqf SrcL, [SrcR], ->Rd
sc.d.rlf SrcL, [SrcR], ->Rd
sc.d.aqrlf SrcL, [SrcR], ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sc_d_32_2e714149031c | L32 | 32 | 0x3000100b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sc_d_32_2e714149031c | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sc_d_32_2e714149031c | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sc_d_32_2e714149031c | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sc_d_32_2e714149031c | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| sc_d_32_2e714149031c | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sc_d_32_2e714149031c | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sc_d_32_2e714149031c | RegDst | 5 | 0–31 | none | none | Reg5 success-status destination | Encoded zero discards the success status. |
| sc_d_32_2e714149031c | SrcL | 5 | 0–31 | none | none | Reg5 doubleword store-value source | Encoded zero supplies numeric zero as the store value. |
| sc_d_32_2e714149031c | SrcR | 5 | 0–31 | none | none | Reg5 store-address source | Encoded zero reads the architectural zero register as the store address. |
| sc_d_32_2e714149031c | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| sc_d_32_2e714149031c | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| sc_d_32_2e714149031c | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 doubleword store-value source |
| SrcR | Reg5 store-address source |
| RegDst | Reg5 success-status destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SC.D.asl -->
```asl
readonly func InstructionContractOperation_SC_D() => ScalarOperation
begin
    return ScalarOperation_SC_D;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SC.D.asl -->
```asl
readonly func InstructionContractHandler_SC_D() => ScalarSemanticHandler
begin
    return ScalarHandler_StoreConditional;
end;

pure func InstructionContractStoreSizeBytes_SC_D()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractReservationGranuleBytes_SC_D()
    => integer {1..262144}
begin
    return PTO_RESERVATION_GRANULE_BYTES;
end;

pure func InstructionContractSuccessStatus_SC_D() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractMissStatus_SC_D() => Word
begin
    return Zeros{PTO_XLEN} + 1;
end;

pure func InstructionContractMissIsProbeFree_SC_D()
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
- A line-matched effective address must be aligned to 8 bytes.

## State effects

- Snapshot SrcL and SrcR before reservation, memory, or destination effects, including repeated GPR and same-queue aliases.
- Publish status zero after a nonfaulting matching store and status one after a reservation miss. A line-matched fault publishes no status.
- Clear the local reservation for success, miss, and line-matched fault before any possible trap.
- Successful or miss completion advances TPC by four bytes. A line-matched fault saves the original TPC; recovery restores it, and reissue without a new LR completes as a miss.

## Memory effects and ordering

### Memory effects

- A matching reservation is cleared before access preflight. After successful preflight, store SrcL all 64 bits as one 8-byte little-endian doubleword, emit one ordered store event, and publish status zero.
- A missing or different-line reservation is cleared and publishes status one without alignment, translation, permission, bounded-memory probe, memory event, or memory access.
- The reservation is cleared by every attempt. A line-matched access fault leaves memory and destination unchanged; after recovery, reissue without a new LR is a probe-free miss.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release on a successful store.
- A reservation miss emits no memory event. far changes only the route hint in the reference profile.

## Exceptions

- A line-matched effective address must be aligned to 8 bytes. On a line-matched attempt, alignment, translation, and write permission are checked after reservation clear and before memory or destination effects.
- A line-matched access fault reports the original address, emits no event, preserves memory and destination, and enters the ordinary trap envelope. Recovery restores the original TPC.
- A reservation miss is probe-free even for a misaligned or inaccessible address and therefore does not raise a data-access fault.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- sc.d a0, [a1], ->a2
- sc.d.aqrl t#1, [u#1], ->u
- sc.d.f zero, [sp], ->t
