<!-- GENERATED FROM: asl/scalar/amo/SWAPB.asl -->
# SWAPB

**Normative ASL source:** `asl/scalar/amo/SWAPB.asl`

SWAPB atomically replaces one byte and publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-SWAPB}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
swapb [SrcL], SrcR, ->Rd
swapb.aq [SrcL], SrcR, ->Rd
swapb.rl [SrcL], SrcR, ->Rd
swapb.f [SrcL], SrcR, ->Rd
swapb.aqrl [SrcL], SrcR, ->Rd
swapb.aqf [SrcL], SrcR, ->Rd
swapb.rlf [SrcL], SrcR, ->Rd
swapb.aqrlf [SrcL], SrcR, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| swapb_32_80733f03b77f | L32 | 32 | 0x0000600b / 0xf000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| swapb_32_80733f03b77f | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| swapb_32_80733f03b77f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| swapb_32_80733f03b77f | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| swapb_32_80733f03b77f | aq | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |
| swapb_32_80733f03b77f | far | 1 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":1}] |
| swapb_32_80733f03b77f | rl | 1 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| swapb_32_80733f03b77f | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| swapb_32_80733f03b77f | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| swapb_32_80733f03b77f | SrcR | 5 | 0–31 | none | none | Reg5 byte replacement source | Encoded zero supplies numeric zero as the replacement. |
| swapb_32_80733f03b77f | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| swapb_32_80733f03b77f | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| swapb_32_80733f03b77f | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 byte replacement source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/SWAPB.asl -->
```asl
readonly func InstructionContractOperation_SWAPB() => ScalarOperation
begin
    return ScalarOperation_SWAPB;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/SWAPB.asl -->
```asl
readonly func InstructionContractHandler_SWAPB() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;

pure func InstructionContractAtomicOperation_SWAPB()
    => AtomicOperation
begin
    return Atomic_SWAP;
end;

pure func InstructionContractAtomicSizeBytes_SWAPB()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractZeroExtendsOldValue_SWAPB()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSignExtendsOldValue_SWAPB()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same architectural address and atomic result.

## Legality

- All 32 SrcL and SrcR Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq, rl, and far combinations are assigned.
- Every byte address is naturally aligned.

## State effects

- Snapshot SrcL and SrcR before any memory or destination effect.
- Publish the prior value only after successful atomic commit.
- The 8-bit old value is zero-extended to XLEN.
- Successful execution advances TPC by four bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 1-byte byte, store SrcR truncated to 1 bytes, and emit one ordered atomic event.
- A successful overlapping write invalidates the local 64-byte-line reservation; a nonoverlapping write preserves it.
- The 8-bit old value is zero-extended to XLEN.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release.
- far changes only the route hint in the reference profile.

## Exceptions

- Every byte address is naturally aligned. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- swapb [a0], a1, ->a2
- swapb.aqrl [t#1], u#1, ->u
- swapb.f [sp], zero, ->t

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
