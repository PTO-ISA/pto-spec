<!-- GENERATED FROM: asl/scalar/agu/HL.LHIP.asl -->
# HL.LHIP

**Normative ASL source:** `asl/scalar/agu/HL.LHIP.asl`

HL.LHIP snapshots its scalar sources, forms its encoded address, and loads two adjacent aligned little-endian 2-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-LHIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: hl-lhip-purpose role=purpose -->
## What `HL.LHIP` does

`HL.LHIP` is a standalone 48-bit load that adds an immediate displacement to the `SrcL` base. It loads two adjacent 2-byte values into two destinations.

<!-- PTO-READER-BLOCK: hl-lhip-mechanism role=mechanism -->
## Address and load mechanism

The decoded `simm17` is sign-extended and shifted left by `1`, so each encoded unit is worth `2` bytes of address.

The scaled displacement is added to the snapshotted `SrcL` value modulo `2^PTO_XLEN`.

Both addresses are preflighted before either load: the second address is the first address plus `2` bytes. Only after both probes pass does the instruction read the two little-endian values and record two relaxed load events in address order.

There is no base writeback: `Dst0` and `Dst1` are both loaded values, and `Dst1` is not an address.

The byte at the accessed address becomes bits `7:0` of the result and later bytes fill higher bits, so the value is little-endian, and the instruction will sign-extend the loaded value to `PTO_XLEN`, keeping the low `16` bits and copying bit `15` into every higher bit.

**Design point:** storing the displacement divided by `2` lets a 17-bit `simm17` reach far more addresses than an unscaled field of the same width, at the cost of a displacement that is always a multiple of `2`. The shift happens before the modulo `2^PTO_XLEN` addition, so a negative `simm17` still subtracts.

<!-- PTO-READER-BLOCK: hl-lhip-inputs role=inputs-outputs -->
## Inputs and destinations

- `SrcL` is the address base and uses the complete Reg5 source domain, where codes `0..23` name absolute GPRs, codes `24..27` name `T#1..T#4`, and codes `28..31` name `U#1..U#4`.
- Reading a `T` or `U` selector does not consume or shift the queue it names; the queue index `1..4` is used as a source value only.
- `simm17` covers every signed 17-bit value from `-65536` through `65535`, and the encoded byte displacement is that value multiplied by `2`.
- `Dst0` receives the value loaded from the first address and `Dst1` the value loaded from the second; both are loaded-value destinations, and neither is a base writeback.
- Both destination fields use the complete Reg5 destination domain: codes `1..23` write absolute GPRs, code `30` pushes U, code `31` pushes T, and codes `0` and `24..29` discard only that result without suppressing the rest of the instruction.
- Every displayed operand field is encoded explicitly, so encoded zero is a value and never denotes omission.

<!-- PTO-READER-BLOCK: hl-lhip-effects role=effects -->
## Effects and ordering

The base register is read before the memory operation and before any destination write.

A successful attempt records two relaxed load events in address order, leaves memory and reservation state unchanged, publishes both loaded values, and advances `TPC` by `6` bytes.

**Design point:** both values rest on the one base snapshot, so even when a destination names `SrcL` the second address is still the first plus the access size. The pair always reads two adjacent locations.

<!-- PTO-READER-BLOCK: hl-lhip-constraints role=constraints -->
## Alignment, faults, and restart

The effective address must be aligned to the `2`-byte transfer size. Misalignment raises `Fault_DataAlignment` before translation; a translation or bounded-memory failure after that raises `Fault_DataPage` at the original address.

A fixed-bit mismatch, a reserved field value, or an unavailable selected `T` or `U` source raises `Fault_IllegalInstruction` before any instruction effect.

A fault emits no load event and writes no destination, and the address it records is the address that failed. Recovery reissues the whole instruction: the address, the source snapshot, every probe, the load, and every destination are recomputed with no retained progress.

**Design point:** both probes complete before either load is committed, so the pair cannot publish one destination and leave the other holding a pre-instruction value; a fault on the second probe therefore costs the first result as well.

<!-- PTO-READER-BLOCK: hl-lhip-example role=example -->
## Non-normative address example

This example illustrates the current address and publication rule and does not replace the normative load contract.

A decoded `simm17` of `1` becomes a byte displacement of `2`, so with `SrcL=0x1000` the two accesses are at `0x1002` and `0x1004`.

If both addresses are aligned and permitted, `Dst0` receives the first value, `Dst1` receives the second, and `TPC` advances by `6` bytes.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lhip [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lhip_48_2c664751c537 | HL48 | 48 | 0x00001019001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lhip_48_2c664751c537 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lhip_48_2c664751c537 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lhip_48_2c664751c537 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lhip_48_2c664751c537 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lhip_48_2c664751c537 | RegDst0 | 5 | 0–31 | none | none | Reg5 first loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhip_48_2c664751c537 | RegDst1 | 5 | 0–31 | none | none | Reg5 second loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lhip_48_2c664751c537 | SrcL | 5 | 0–31 | none | none | Reg5 address-base source | Encoded zero reads the architectural zero GPR. |
| hl_lhip_48_2c664751c537 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | Reg5 first loaded-value destination or discard |
| RegDst1 | Reg5 second loaded-value destination or discard |
| SrcL | Reg5 address-base source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHIP.asl -->
```asl
readonly func InstructionContractOperation_HL_LHIP() => ScalarOperation
begin
    return ScalarOperation_HL_LHIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHIP.asl -->
```asl
readonly func InstructionContractHandler_HL_LHIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoadPair;
end;

pure func InstructionContractAGUAction_HL_LHIP()
    => ScalarAGUAction
begin
    return ScalarAGU_LoadPair;
end;

pure func InstructionContractAGUAddressKind_HL_LHIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_LHIP()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_LHIP()
    => integer {0..3}
begin
    return 1;
end;

pure func InstructionContractAGUUpdateMode_HL_LHIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LHIP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LHIP()
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
- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 2.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 2, and add it modulo 2^PTO_XLEN to the SrcL base.
- The pair addresses are address and address plus 2; the instruction performs no base writeback.
- After both 2-byte probes succeed, sign-extend each result at PTO_XLEN and publish first then second.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 2-byte addresses before either load; on success record two relaxed load events in address order.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 2-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lhip [SrcL, simm], ->Dst0, Dst1
