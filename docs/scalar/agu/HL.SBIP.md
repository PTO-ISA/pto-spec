<!-- GENERATED FROM: asl/scalar/agu/HL.SBIP.asl -->
# HL.SBIP

**Normative ASL source:** `asl/scalar/agu/HL.SBIP.asl`

HL.SBIP snapshots its scalar sources, forms its encoded address, and stores two adjacent aligned little-endian 1-byte values.

## Normative identity {#PTO-INST-SCALAR-HL-SBIP}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-sbip-purpose role=purpose -->
## What `HL.SBIP` does

`HL.SBIP` is a standalone `48`-bit scalar AGU instruction that stores two adjacent `1`-byte little-endian units from `SrcD` and `SrcD1`.

The canonical assembly is `hl.sbip SrcD, SrcD1, [SrcR, simm]`.

The displacement is in the instruction and counts bytes, so a pair of adjacent bytes can be written at a constant offset from a base register without any index register at all.

<!-- PTO-READER-BLOCK: scalar-hl-sbip-mechanism role=mechanism -->
## How the address and the transfer are formed

The displacement is the sign-extended `simm17` value with a shift of `0`, added to the `SrcR` snapshot modulo `2^PTO_XLEN`.

That sum is the first address, and the second address is that sum plus `1`. The update mode is none, so no base write-back is published.

Both addresses are probed and both store-data sources are read before the first store. On a fault, neither unit is written.

Design point: a `1`-byte pair is exactly `16` bits of destination payload, so this is the form that writes two independent bytes of one logical record without a read-modify-write of the surrounding bytes.

Design point: both sources are read only after both probes succeed, so a rejected or faulting attempt leaves every source register and `T` or `U` queue entry unchanged.

<!-- PTO-READER-BLOCK: scalar-hl-sbip-inputs role=inputs-outputs -->
## Encoded fields and what they select

- `SrcD` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcD1` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `SrcR` is a `5`-bit Reg5 selector. Codes `0`..`23` select absolute GPRs, `24`..`27` select `T#1`..`T#4`, and `28`..`31` select `U#1`..`U#4`; a queue entry is read without being consumed.
- `simm17` is a signed `17`-bit displacement carried in the encoding as three pieces at bits `41`..`47`, bits `23`..`27`, and bits `11`..`15`, covering `-65536`..`65535` bytes.
- This form has no `RegDst` field, so no register receives a result and no updated base is published.

Design point: `SrcD` and `SrcD1` may name the same register, in which case both bytes receive the same value from one pre-instruction read. Neither source is modified by the store.

<!-- PTO-READER-BLOCK: scalar-hl-sbip-effects role=effects -->
## Effects, snapshots, and completion

Every scalar source is snapshotted before any memory or destination effect, so a source that a destination also names still contributes the pre-instruction value.

A successful execution records two relaxed store events in increasing address order.

In memory, a successful execution changes only the bytes inside the stored range. A valid reservation is invalidated when the stored range overlaps the reservation's `64`-byte granule; a reservation whose granule the store leaves untouched stays valid.

Design point: only the low `8` bits of each source are written, so wider sources are truncated silently. The rest of each register is untouched.

<!-- PTO-READER-BLOCK: scalar-hl-sbip-constraints role=constraints -->
## Legality, faults, and restart

- A fixed-bit mismatch, or a source code selecting an unavailable `T` or `U` slot, raises `Fault_IllegalInstruction` before any instruction effect.
- Every address is a whole number of `1`-byte units, so preflight cannot raise `Fault_DataAlignment` for this form. A permission or bounded-memory failure raises `Fault_DataPage` at the failing unit's own address: when only the second unit fails the bound or permission check, that second address is reported.
- A fault records no store event, leaves memory and destination registers unchanged, and keeps `TPC` on the faulting instruction. Recovery recomputes the snapshot, the address, the probe, and the store from the beginning.

Design point: the form carries no `SrcRType` and no `shamt` field, so no field of this form is reserved; the encoding-level rejections are a fixed-bit mismatch and an unavailable `T` or `U` source slot.

<!-- PTO-READER-BLOCK: scalar-hl-sbip-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.sbip 5, 6, [7, 2]` with GPR7 = `0x9000`, GPR5 = `0xAA11`, and GPR6 = `0xBB22`.
- The displacement of `2` bytes gives the two addresses `0x9002` and `0x9003`.
- Byte `0x11` is stored at `0x9002` and byte `0x22` at `0x9003`.
- No register changes, and `TPC` becomes the instruction address plus `6`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.sbip SrcD, SrcD1, [SrcR, simm]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sbip_48_48a212ee655e | HL48 | 48 | 0x00000059001e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sbip_48_48a212ee655e | SrcD | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sbip_48_48a212ee655e | SrcD1 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |
| hl_sbip_48_48a212ee655e | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sbip_48_48a212ee655e | simm17 | 17 | signed | [{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_sbip_48_48a212ee655e | SrcD | 5 | 0–31 | none | none | Reg5 first store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sbip_48_48a212ee655e | SrcD1 | 5 | 0–31 | none | none | Reg5 second store-data source | Encoded zero reads the architectural zero GPR. |
| hl_sbip_48_48a212ee655e | SrcR | 5 | 0–31 | none | none | Reg5 register-offset source | Encoded zero reads the architectural zero GPR. |
| hl_sbip_48_48a212ee655e | simm17 | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcD | Reg5 first store-data source |
| SrcD1 | Reg5 second store-data source |
| SrcR | Reg5 register-offset source |
| simm17 | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SBIP.asl -->
```asl
readonly func InstructionContractOperation_HL_SBIP() => ScalarOperation
begin
    return ScalarOperation_HL_SBIP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SBIP.asl -->
```asl
readonly func InstructionContractHandler_HL_SBIP()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;

pure func InstructionContractAGUAction_HL_SBIP()
    => ScalarAGUAction
begin
    return ScalarAGU_StorePair;
end;

pure func InstructionContractAGUAddressKind_HL_SBIP()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_Immediate;
end;

pure func InstructionContractAGUSizeBytes_HL_SBIP()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_SBIP()
    => integer {0..3}
begin
    return 0;
end;

pure func InstructionContractAGUUpdateMode_HL_SBIP()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_SBIP()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_SBIP()
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
- simm17 assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 1.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Sign-extend simm17, multiply it by 1, and add it modulo 2^PTO_XLEN to the SrcR base.
- The pair addresses are address and address plus 1; the instruction performs no base writeback.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- Preflight both adjacent 1-byte addresses before either store; on success record two relaxed store events in address order.
- Successful overlapping stores invalidate an overlapping reservation only after complete pair preflight.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Preflight both addresses, commit the two relaxed 1-byte operations in address order, publish ordered results if any, then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.sbip SrcD, SrcD1, [SrcR, simm]
