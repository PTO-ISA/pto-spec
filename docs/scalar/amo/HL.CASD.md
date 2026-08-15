<!-- GENERATED FROM: asl/scalar/amo/HL.CASD.asl -->
# HL.CASD

**Normative ASL source:** `asl/scalar/amo/HL.CASD.asl`

HL.CASD atomically compares and conditionally replaces one doubleword, then publishes the prior value.

## Normative identity {#PTO-INST-SCALAR-HL-CASD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.casd [SrcL], SrcR, SrcD, ->Rd
hl.casd.aq [SrcL], SrcR, SrcD, ->Rd
hl.casd.rl [SrcL], SrcR, SrcD, ->Rd
hl.casd.f [SrcL], SrcR, SrcD, ->Rd
hl.casd.aqrl [SrcL], SrcR, SrcD, ->Rd
hl.casd.aqf [SrcL], SrcR, SrcD, ->Rd
hl.casd.rlf [SrcL], SrcR, SrcD, ->Rd
hl.casd.aqrlf [SrcL], SrcR, SrcD, ->Rd
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_casd_48_fbb5c4256d30 | HL48 | 48 | 0x3000600b000e / 0xf000707ff83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_casd_48_fbb5c4256d30 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | SrcD | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_casd_48_fbb5c4256d30 | aq | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_casd_48_fbb5c4256d30 | far | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_casd_48_fbb5c4256d30 | rl | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_casd_48_fbb5c4256d30 | RegDst | 5 | 0–31 | none | none | Reg5 old-value destination | Encoded zero discards the prior value. |
| hl_casd_48_fbb5c4256d30 | SrcD | 5 | 0–31 | none | none | Reg5 desired doubleword source | Encoded zero supplies numeric zero as the desired value. |
| hl_casd_48_fbb5c4256d30 | SrcL | 5 | 0–31 | none | none | Reg5 atomic address source | Encoded zero reads the architectural zero register as the address. |
| hl_casd_48_fbb5c4256d30 | SrcR | 5 | 0–31 | none | none | Reg5 expected doubleword source | Encoded zero supplies numeric zero as the expected value. |
| hl_casd_48_fbb5c4256d30 | aq | 1 | 0–1 | none | none | acquire ordering bit | Encoded zero disables acquire ordering. |
| hl_casd_48_fbb5c4256d30 | far | 1 | 0–1 | none | none | flat-address routing hint | Encoded zero selects the default flat-address route. |
| hl_casd_48_fbb5c4256d30 | rl | 1 | 0–1 | none | none | release ordering bit | Encoded zero disables release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 atomic address source |
| SrcR | Reg5 expected doubleword source |
| SrcD | Reg5 desired doubleword source |
| RegDst | Reg5 old-value destination |
| aq | acquire ordering bit |
| rl | release ordering bit |
| far | flat-address routing hint |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/amo/HL.CASD.asl -->
```asl
readonly func InstructionContractOperation_HL_CASD() => ScalarOperation
begin
    return ScalarOperation_HL_CASD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/amo/HL.CASD.asl -->
```asl
readonly func InstructionContractHandler_HL_CASD() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;

pure func InstructionContractCompareSizeBytes_HL_CASD()
    => integer {1,2,4,8}
begin
    return 8;
end;

pure func InstructionContractHasFarField_HL_CASD()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractZeroExtendsOldValue_HL_CASD()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractSignExtendsOldValue_HL_CASD()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcD, and RegDst are required Reg5 fields. Encoded source zero reads the architectural zero register; encoded destination zero discards the old value.
- aq=0 and rl=0 select relaxed ordering. aq=1 selects acquire, rl=1 selects release, and aq=1 with rl=1 selects acquire-release.
- far=0 selects the default flat-address route. far=1 is a profile routing hint; the reference profile preserves the same address and atomic result.

## Legality

- All 32 SrcL, SrcR, and SrcD Reg5 encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned. Code 0 and codes 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write the named absolute GPR.
- All aq, rl, and far combinations are assigned.
- The effective address must be aligned to 8 bytes.

## State effects

- Snapshot SrcL, SrcR, and SrcD before any memory or destination effect.
- Publish the prior value after every nonfaulting match or mismatch; publish no value on fault.
- The 64-bit old value is published unchanged.
- Successful execution advances TPC by 6 bytes. A fault saves and later restores the original TPC for full reissue.

## Memory effects and ordering

### Memory effects

- After aligned read and write preflight identify the same translated location, atomically read one 8-byte doubleword and compare it with SrcR truncated to 8 bytes.
- On equality, store SrcD truncated to 8 bytes and set write_performed in the atomic event. On mismatch, preserve memory and emit an ordered atomic event with write_performed false.
- Only a successful overlapping write invalidates the local 64-byte-line reservation; mismatch and nonoverlap preserve it.
- The 64-bit old value is published unchanged.

### Ordering

- aq=0,rl=0 records relaxed ordering; aq=1,rl=0 acquire; aq=0,rl=1 release; aq=1,rl=1 acquire-release for both match and mismatch.
- far changes only the route hint in the reference profile.

## Exceptions

- The effective address must be aligned to 8 bytes. Alignment, read translation/permission, write translation/permission, and translated-address equality are checked before effects.
- On a fault, no destination, memory write, event, reservation update, or TPC advance occurs. Trap entry saves the original TPC and recovery restores it for full reissue.
- An undecodable fixed-bit pattern raises Fault_IllegalInstruction before effects. All explicit field values are assigned.

## Examples

- hl.casd [a0], a1, a2, ->a3
- hl.casd.aqrlf [t#1], u#1, a0, ->u

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
