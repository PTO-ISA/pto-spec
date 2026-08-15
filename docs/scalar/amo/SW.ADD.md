<!-- GENERATED FROM: asl/scalar/amo/SW.ADD.asl -->
# SW.ADD

**Normative ASL source:** `asl/scalar/amo/SW.ADD.asl`

SW.ADD atomically replaces the aligned 32-bit memory value with its modular sum with SrcR; it does not publish the old value.

## Normative identity {#PTO-INST-SCALAR-SW-ADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sw.add [SrcL], SrcR
sw.add.rl [SrcL], SrcR
sw.add.f [SrcL], SrcR
sw.add.rlf [SrcL], SrcR
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_add_32_3dca755552cb | L32 | 32 | 0x0000300b / 0xf4007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_add_32_3dca755552cb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_add_32_3dca755552cb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| sw_add_32_3dca755552cb | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| sw_add_32_3dca755552cb | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_add_32_3dca755552cb | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the atomic address. |
| sw_add_32_3dca755552cb | SrcR | 5 | 0–31 | none | none | Reg5 atomic operand source | Encoded zero supplies numeric zero as the atomic operand. |
| sw_add_32_3dca755552cb | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| sw_add_32_3dca755552cb | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero selects relaxed ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 atomic operand source |
| far | flat-address routing hint |
| rl | release ordering bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SW.ADD.asl -->
```asl
readonly func InstructionContractOperation_SW_ADD() => ScalarOperation
begin
    return ScalarOperation_SW_ADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SW.ADD.asl -->
```asl
readonly func InstructionContractHandler_SW_ADD()
    => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SW_ADD()
    => AtomicOperation
begin
    return Atomic_ADD;
end;

pure func InstructionContractAtomicSizeBytes_SW_ADD()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractPublishesOldValue_SW_ADD()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL and SrcR are required Reg5 sources. Encoded zero reads the architectural zero register.
- rl=0 selects relaxed ordering; rl=1 selects release ordering.
- far=0 selects the default flat-address route. far=1 is a routing hint and does not change the architectural address or atomic operation in the reference profile.

## Legality

- All 32 Reg5 source encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- The effective address must be aligned to 4 bytes. SrcL, SrcR, far, and rl have no reserved encodings in this form.
- The instruction has no destination field and cannot publish the old memory value to a GPR or temporary queue.

## State effects

- Snapshot SrcL and SrcR before any memory or architectural effect.
- SW.ADD adds the operand modulo the access width at 32-bit width and stores that value; it does not publish the old value.
- Successful execution advances TPC by four bytes. On a fault, the instruction does not retire; trap entry saves the original TPC, redirects the live TPC to the trap vector, and recovery restores that TPC for full reissue. GPRs, T/U queues, memory events, reservation state, and memory remain unchanged by the failed instruction.

## Memory effects and ordering

### Memory effects

- Atomically read one aligned 4-byte little-endian value, compute the modular sum, and write one 4-byte result to the same location.
- Complete both read and write access probes before the memory load or store, and require both probes to resolve to the same translated address.
- On success, record one atomic memory event, invalidate an overlapping local reservation, and preserve a nonoverlapping reservation.

### Ordering

- rl=0 records the atomic event with relaxed ordering; rl=1 records it with release ordering. This encoding has no acquire bit.
- far changes only the route hint in the reference profile and does not change ordering, address arithmetic, or the read-modify-write result.

## Exceptions

- Misalignment, translation, and permission checks occur before effects in that precedence order and report the original address.
- If either read or write preflight fails, the instruction performs no load, store, event, reservation update, result publication, or TPC advance.
- An undecodable or operand-illegal form raises Fault_IllegalInstruction before effects.

## Examples

- sw.add [a0], a1
- sw.add.rl [t#1], u#1
- sw.add.f [sp], a0

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
