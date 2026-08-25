<!-- GENERATED FROM: asl/scalar/alu/C.SETRET.asl -->
# C.SETRET

**Normative ASL source:** `asl/scalar/alu/C.SETRET.asl`

Materialize an unsigned halfword-scaled TPC-relative return address in ra and captured return state.

## Normative identity {#PTO-INST-SCALAR-C-SETRET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-setret-purpose role=purpose -->
## What C.SETRET does

`C.SETRET` is a 16-bit scalar ALU instruction. It forms the halfword-scaled TPC-relative return address and records it in both the return register and captured return state; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-c-setret-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then forms the halfword-scaled TPC-relative return address and records it in both the return register and captured return state, and only afterward performs the destination effects.

- The immediate width and extension rule come from the encoded field shown below; encoded zero supplies numeric zero unless the generated contract states another zero meaning.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-c-setret-inputs role=inputs-outputs -->
## Inputs and destinations

- The unsigned 5-bit `uimm5` field carries the unsigned five-bit halfword displacement from the pre-increment `TPC`.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-c-setret-effects role=effects -->
## Effects and ordering

The return address is computed before the return register and captured return state are updated.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 2 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-c-setret-constraints role=constraints -->
## Legality and fault boundary

Every encoded immediate is assigned; the instruction does not dereference the target and does not form a call by itself.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-c-setret-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `C.SETRET` example, pre-increment `TPC=0x100` and `uimm5=1` produce return address `0x102` in both `ra` and captured return state.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.setret uimm, ->ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_setret_16_335651ef6c27 | C16 | 16 | 0x5016 / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_setret_16_335651ef6c27 | uimm5 | 5 | unsigned | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_setret_16_335651ef6c27 | uimm5 | 5 | 0–31 | none | none | unsigned five-bit halfword displacement from the pre-increment TPC | Encoded zero supplies numeric zero for the 5-bit unsigned immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| uimm5 | unsigned five-bit halfword displacement from the pre-increment TPC |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/C.SETRET.asl -->
```asl
readonly func InstructionContractOperation_C_SETRET() => ScalarOperation
begin
    return ScalarOperation_C_SETRET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Standalone scalar return-address materialization. Fused BSTART.CALL and BSTART.ICALL define call formation separately.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/C.SETRET.asl -->
```asl
readonly func InstructionContractHandler_C_SETRET() => ScalarSemanticHandler
begin
    return ScalarHandler_SetReturnAddress;
end;

pure func InstructionContractTarget_C_SETRET(
    tpc: Word,
    uimm5: bits(5))
    => Word
begin
    let halfword_offset = ZeroExtend{PTO_XLEN}(uimm5);
    return tpc + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- C.SETRET has no omitted field. Encoded uimm5 zero is the real zero displacement and materializes the address of C.SETRET itself.

## Legality

- Every uimm5 value 0..31 is assigned. The fixed destination is architectural ra (GPR10).
- C.SETRET is legal as a standalone scalar operation and does not by itself form a call.

## State effects

- Compute target = pre-increment TPC + (ZeroExtend(uimm5) << 1) with XLEN wrapping.
- Atomically write the same target to GPR10 ra and the captured return-address state; successful dispatch then advances TPC by two bytes.
- A later ordinary write to ra does not retroactively change the captured return-address state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot the pre-increment TPC, compute the target, publish ra and captured return state together, then perform the ordinary two-byte sequential TPC advance.

## Exceptions

- All uimm5 values are legal. C.SETRET performs no target dereference and raises no alignment, memory, arithmetic, or block-control exception.

## Examples

- c.setret 0, ->ra
- c.setret 31, ->ra
