<!-- GENERATED FROM: asl/scalar/agu/SW.PCR.asl -->
# SW.PCR

**Normative ASL source:** `asl/scalar/agu/SW.PCR.asl`

SW.PCR snapshots its scalar sources, forms its encoded address, and stores one aligned little-endian 4-byte value.

## Normative identity {#PTO-INST-SCALAR-SW-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sw-pcr-purpose role=purpose -->
## What `SW.PCR` does

`SW.PCR` writes the low `4` bytes of `SrcL` to a PC-relative address. It has no base-register field: the address is the current `TPC` plus a signed `17`-bit word displacement. Its canonical assembly is `sw.pcr SrcL, [symbol]`.

Design point: the scale of `4` matches the `4`-byte access exactly. A `4`-byte-aligned base plus a multiple-of-`4` displacement therefore always yields an accepted address, and this form has no alignment fault to report.

<!-- PTO-READER-BLOCK: scalar-sw-pcr-mechanism role=mechanism -->
## How `SW.PCR` forms the address and completes the store

The base is the pre-instruction `TPC` with bits `1`:`0` cleared, and the offset is the sign-extended `simm` field shifted left by `2`. The two values are added modulo `2^PTO_XLEN`.

The value written to that address is the low `4` bytes of `SrcL`, least-significant byte at the lowest address, read before the store. The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: the `4` bytes written are the low `32` bits of `SrcL`, least-significant byte at the lowest address. The upper `32` bits of the register never reach memory through this form.

<!-- PTO-READER-BLOCK: scalar-sw-pcr-inputs role=inputs-outputs -->
## Encoded fields and what the store consumes

- `SrcL` is a `5`-bit Reg5 store-data source. Codes `0`..`23` name absolute GPRs, `24`..`27` name `T#1`..`T#4`, and `28`..`31` name `U#1`..`U#4`. Reading a `T` or `U` slot neither consumes nor reorders it, and code `0` supplies the constant zero GPR.
- `simm` is a signed `17`-bit word displacement, so all `131072` encodings are values. The byte displacement is a multiple of `4` in the range `-262144` through `262140`.
- The form has no destination field: nothing in the encoding selects a register or queue slot to write, so a store never publishes a result and never updates a base.

Design point: `SrcL` is the only register field, and it is both the data source and, through the assembly symbol, the unstated base of the addressing scheme. There is no register that participates in the address.

<!-- PTO-READER-BLOCK: scalar-sw-pcr-effects role=effects -->
## Effects, ordering, and completion

`SrcL` is read before the memory effect, and the `TPC` advance is the last step, so the address never depends on the instruction's own retirement.

Successful execution performs one relaxed `4`-byte store and records one store event. A store whose byte range overlaps the `64`-byte reservation granule that contains a valid reservation invalidates that reservation; a store outside the granule leaves it valid. `TPC` then advances by `4` bytes.

Design point: `SW.PCR` is a positional store: its target moves with the code. Inserting an instruction before it changes the address, so it suits fixed data slots whose distance from the store is stable.

<!-- PTO-READER-BLOCK: scalar-sw-pcr-constraints role=constraints -->
## Legality, faults, and restart

Dispatch rejects the instruction with `Fault_IllegalInstruction` before any effect when the fixed bits do not match, or when a selected `T`/`U` data source is unavailable because nothing has been pushed into it.

A `4`-byte access needs an address that is a multiple of `4`, and every address this form produces is a multiple of `4`, so `Fault_DataAlignment` is unreachable. The preflight still runs the alignment test and then the permission and bounded-memory test, whose failure raises `Fault_DataPage` at the original address.

A fault writes no memory byte, records no store event, and leaves `TPC` on the faulting instruction. Recovery reissues the whole operation: every source read, the address arithmetic, the preflight, and the store.

Design point: the alignment outcome is decided entirely by the encoding, so no operand choice can provoke an alignment fault. The largest PC-relative store of this family, `SD.PCR`, has the same scale but a wider access, which is what makes its alignment fault reachable.

<!-- PTO-READER-BLOCK: scalar-sw-pcr-example role=example -->
## Reading one encoding end to end

This example demonstrates the address calculation only; exact behavior remains in the current ASL and instruction contract.

- Take `sw.pcr 5, [symbol]` executing at `TPC` = `0x4004`, with `simm` equal to `2` and GPR5 = `0x00000000DEADBEEF`.
- The base is `0x4004` and the displacement is `2` times `4`, which is `8`, so the effective address is `0x400C`.
- `0x400C` is a multiple of `4`, so the preflight passes and the `4` bytes `EF BE AD DE` are written there, low byte first.
- GPR5 is unchanged, and `TPC` becomes `0x4008`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sw.pcr SrcL, [symbol]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sw_pcr_32_436677679523 | L32 | 32 | 0x00002069 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sw_pcr_32_436677679523 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sw_pcr_32_436677679523 | simm | 17 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sw_pcr_32_436677679523 | SrcL | 5 | 0–31 | none | none | Reg5 store-data source | Encoded zero reads the architectural zero GPR. |
| sw_pcr_32_436677679523 | simm | 17 | 0–131071 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 store-data source |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SW.PCR.asl -->
```asl
readonly func InstructionContractOperation_SW_PCR() => ScalarOperation
begin
    return ScalarOperation_SW_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SW.PCR.asl -->
```asl
readonly func InstructionContractHandler_SW_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;

pure func InstructionContractAGUAction_SW_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Store;
end;

pure func InstructionContractAGUAddressKind_SW_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_SW_PCR()
    => integer {1,2,4,8}
begin
    return 4;
end;

pure func InstructionContractAGUOffsetScale_SW_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_SW_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_SW_PCR()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_SW_PCR()
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
- simm assigns every signed 17-bit value -65536..65535; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 4-byte access size; a 4-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- Snapshot every store-data source before any memory effect or destination publication.
- Successful execution advances TPC by 4 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 4-byte store and record one relaxed store event.
- A successful overlapping store invalidates the overlapping reservation; a nonoverlapping reservation remains valid.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 4-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 4-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- sw.pcr SrcL, [symbol]
