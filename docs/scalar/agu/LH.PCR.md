<!-- GENERATED FROM: asl/scalar/agu/LH.PCR.asl -->
# LH.PCR

**Normative ASL source:** `asl/scalar/agu/LH.PCR.asl`

LH.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-LH-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lh-pcr-purpose role=purpose -->
## What `LH.PCR` does

`LH.PCR` loads one signed `2`-byte halfword from an address relative to the instruction itself, with no base register and no index register.

The canonical assembly is `lh.pcr [symbol], ->{t, u, Rd}`.

Design point: the reference point is the instruction's own address, so a halfword table placed next to the code is reachable without spending a register on its base.

<!-- PTO-READER-BLOCK: scalar-lh-pcr-mechanism role=mechanism -->
## How the address and the transfer are formed

The base is `TPC` with bits `1:0` cleared. The sign-extended `simm17` is multiplied by `4` and added to that base modulo `2^PTO_XLEN`.

Preflight tests `2`-byte alignment, then translation, then permission and bounded memory. On success `2` bytes are read little-endian and one relaxed load event is recorded.

The halfword is sign-extended to `PTO_XLEN` and published through `RegDst`. Nothing else changes except `TPC`.

Design point: both the cleared base and the displacement are multiples of `4`, so the sum is a multiple of `4` and therefore a multiple of `2`. The `2`-byte alignment rule cannot fail for `LH.PCR`.

<!-- PTO-READER-BLOCK: scalar-lh-pcr-inputs role=inputs-outputs -->
## Encoded fields and roles

- `TPC` is the implicit base and holds the address of the instruction being executed; bits `1:0` are cleared before the addition.
- `simm17` is signed and covers `-65536`..`65535` units of `4` bytes, so the byte displacement covers `-262144`..`262140`.
- `RegDst` is the only selector in the encoding. Codes `1`..`23` write GPRs, `30` pushes the `U` queue, `31` pushes the `T` queue, and `0` plus `24`..`29` publish nothing; code `0` is the architectural zero GPR, whose writes are discarded.
- Design point: `LH.PCR` and `LHU.PCR` differ only in the extension applied to the loaded halfword; their addressing fields are identical.

<!-- PTO-READER-BLOCK: scalar-lh-pcr-effects role=effects -->
## Effects, ordering, and completion

`TPC` is read as the base before the memory operation, so the displacement is measured from this instruction and not from the next one.

Success records one relaxed load event, changes no memory byte, preserves the reservation, publishes the sign-extended halfword, and advances `TPC` by `4` bytes.

Design point: the loaded halfword is sign-extended, so `0x8000` from memory publishes as `0xFFFFFFFFFFFF8000`.

<!-- PTO-READER-BLOCK: scalar-lh-pcr-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch raises `Fault_IllegalInstruction` at the instruction address before any memory or destination effect.
- The address must be a multiple of `2` before translation is consulted; a later permission or bounded-memory failure raises `Fault_DataPage` at the original effective address.
- A fault records no event, publishes nothing, and leaves `TPC` on the faulting instruction so the attempt can be reissued unchanged.
- Design point: `Fault_DataAlignment` is unreachable here because the effective address is always a multiple of `4`; only `Fault_DataPage` can follow the legality stage.

<!-- PTO-READER-BLOCK: scalar-lh-pcr-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- With `TPC` = `0x2000` and `simm17` = `-1`, the byte displacement is `-4` and the address is `0x1FFC`.
- Bytes `00 80` at `0x1FFC` are the halfword `0x8000`, published as `0xFFFFFFFFFFFF8000`.
- Because the sum is a multiple of `4`, no `simm17` value can make this instruction raise `Fault_DataAlignment`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lh.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lh_pcr_32_aabf46d21e49 | L32 | 32 | 0x00001039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lh_pcr_32_aabf46d21e49 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lh_pcr_32_aabf46d21e49 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lh_pcr_32_aabf46d21e49 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| lh_pcr_32_aabf46d21e49 | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LH.PCR.asl -->
```asl
readonly func InstructionContractOperation_LH_PCR() => ScalarOperation
begin
    return ScalarOperation_LH_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LH.PCR.asl -->
```asl
readonly func InstructionContractHandler_LH_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_LH_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_LH_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_LH_PCR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_LH_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_LH_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_LH_PCR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_LH_PCR()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.

## Legality

- Every Reg5 destination is assigned: codes 1..23 write GPRs, code 30 pushes U, code 31 pushes T, and codes 0 and 24..29 discard only that result.
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 2-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- lh.pcr [symbol], ->{t, u, Rd}
