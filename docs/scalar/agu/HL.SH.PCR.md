<!-- GENERATED FROM: asl/scalar/agu/HL.SH.PCR.asl -->
# HL.SH.PCR

**Normative ASL source:** `asl/scalar/agu/HL.SH.PCR.asl`

HL.SH.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 2-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-SH-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-purpose role=purpose -->
## What `HL.SH.PCR` stores

`HL.SH.PCR` is a standalone `48`-bit scalar AGU instruction that stores one `2`-byte little-endian unit from `SrcL` at a position-relative address.

The canonical assembly is `hl.sh.pcr SrcL, [<symbol>]`.

Design point: the address is built from `TPC` and the displacement alone, so a position-relative store needs no base register and cannot be disturbed by a register that another instruction changes.

<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-mechanism role=mechanism -->
## How the address is formed

The base is `TPC` with bits `1:0` cleared. The encoded `simm` is sign-extended, left-shifted by `2`, and added modulo `2^PTO_XLEN`, which gives the effective address.

The scale is `2`, so the encoded displacement counts `4`-byte words, and clearing bits `1:0` of `TPC` before the addition keeps the whole address a multiple of `4`.

The update mode is none, so the store uses the computed address and no register receives a result: this form has no `RegDst` field.

The address is probed before the store, and `SrcL` is read before that probe; on success one `2`-byte little-endian store and one relaxed store event are performed.

Design point: the displacement is a signed `29`-bit word count, so the reachable byte displacement runs from `-1073741824` through `1073741820` around the aligned instruction address.

<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-inputs role=inputs-outputs -->
## Operands

- `SrcL` is a `5`-bit Reg5 source selector: codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed, and code `0` reads the architectural zero GPR.

- `simm` is a `29`-bit signed field that assigns every value from `-268435456` through `268435455`; the encoded byte displacement is that value multiplied by `4`, and encoded zero is a zero displacement rather than omission.

- This form has no `RegDst` field, so no register receives a result and no updated base is published.

Design point: `simm` assigns the whole `-268435456..268435455` domain and encoded zero is a zero displacement, so there is no separate no-displacement encoding to reserve.

<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-effects role=effects -->
## Effects and ordering

`SrcL` is read before the store and `TPC` supplies the base, so the stored unit is a pre-instruction value.

A successful execution records one relaxed store event and changes only the `2` bytes of the unit.

A valid reservation is invalidated when the stored range overlaps the reservation's `64`-byte granule; a reservation whose granule the store leaves untouched stays valid.

`TPC` advances by `6` bytes after the store completes. A rejected or faulting attempt does not retire.

Design point: only the low `2` bytes of `SrcL` reach memory, and `SrcL` itself is unchanged, so the store is a pure memory effect.

<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-constraints role=constraints -->
## Alignment, faults, and restart

- The effective address must be a multiple of `2`, and it always is: the base has bits `1:0` cleared and the scaled displacement is a multiple of `4`. The alignment probe still runs, but it cannot raise `Fault_DataAlignment` for this form.

- A fixed-bit mismatch, or a source selector naming an unavailable `T` or `U` entry, raises `Fault_IllegalInstruction` at `PC` before any instruction effect.

- A fault records no store event: memory and every register keep their pre-instruction values, `TPC` is not advanced, and recovery recomputes the address, the probe, and the store.

Design point: the base has bits `1:0` cleared and the displacement is scaled by `4`, so the effective address is always a multiple of `4` and the alignment probe cannot raise `Fault_DataAlignment` for this form.

<!-- PTO-READER-BLOCK: scalar-hl-sh-pcr-example role=example -->
## Worked example

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- `hl.sh.pcr 20, [3]` executed at `TPC` = `0x1006` with GPR20 = `0xbeef`.

- Bits `1:0` of `TPC` are cleared, so the base is `0x1004`; the displacement `3` scaled by `4` is `12`, and the effective address is `0x1010`.

- The store writes `0xef`, `0xbe` at `0x1010` through `0x1011` in increasing address order.

- `SrcL` keeps `0xbeef`, and the store completes before `TPC` advances by `6` bytes to `0x100c`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sh.pcr SrcL, [<symbol>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sh_pcr_48_705ea4062d0b | HL48 | 48 | 0x00001069000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sh_pcr_48_705ea4062d0b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sh_pcr_48_705ea4062d0b | simm | 29 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":23,"value_lsb":12,"width":5},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sh_pcr_48_705ea4062d0b | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sh_pcr_48_705ea4062d0b | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SH.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_SH_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_SH_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SH.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_SH_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_HL_SH_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_HL_SH_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_SH_PCR()
    => integer {1,2,4,8}
begin
    return 2;
end;

pure func InstructionContractAGUOffsetScale_HL_SH_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_SH_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SH_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SH_PCR()
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
- simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 2-byte access size; a 2-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 2-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 2-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 2-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sh.pcr SrcL, [<symbol>]
