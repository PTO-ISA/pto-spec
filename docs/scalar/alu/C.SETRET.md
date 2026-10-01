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

`C.SETRET` computes a return address from the current `TPC` plus a scaled unsigned immediate and captures it in both the architectural `ra` register (GPR `10`) and the block's saved return-address state.

Design point: the destination is fixed by the opcode. The 16-bit form uses its five payload bits for the displacement, so `ra` is implied; there is no destination field to select, and the instruction never forms a call by itself.

<!-- PTO-READER-BLOCK: scalar-c-setret-mechanism role=mechanism -->
## How the result is formed

- `uimm5` is zero-extended and shifted left by `1`, giving an even byte offset from `0` through `62`.
- `TPC` is read before the sequential advance, so the target is `TPC + (uimm5 * 2)`.

The same target is written to `ra` and to the captured return-address state in one step, and then the ordinary `2`-byte `TPC` advance happens.

Design point: the displacement is scaled by `2`, so the recorded target is always an even offset from the instruction's own address. An odd target cannot be encoded, which is why this instruction needs no alignment check.

Design point: encoded `uimm5` zero is a real zero displacement, so `c.setret 0, ->ra` records the address of the `C.SETRET` itself, not the following instruction.

Design point: `ra` and the captured return-address state are written together but are not the same storage. The block return path reads the captured state, so a later ordinary write to `ra` changes the register without changing where a return goes.

<!-- PTO-READER-BLOCK: scalar-c-setret-inputs role=inputs-outputs -->
## Inputs and destinations

- `uimm5` is the only encoded operand, an unsigned halfword displacement from `0` through `31`.
- The destination is fixed: architectural `ra`, which is GPR `10`, together with the captured return-address state.

Design point: the source of the value is `TPC`, not a register, so `C.SETRET` reads no operand storage. That is why it has no source-availability fault and no discard form; the `->ra` in the assembly text names a destination that cannot be changed.

<!-- PTO-READER-BLOCK: scalar-c-setret-effects role=effects -->
## Effects and ordering

`TPC` is snapshotted first, then `ra` and the captured return-address state are published together, and then `TPC` advances by `2` bytes.

No other state changes: no queue moves, no memory access, and no reservation, descriptor, numeric-status, bundle, privilege, predicate or control-flow state is affected.

<!-- PTO-READER-BLOCK: scalar-c-setret-constraints role=constraints -->
## Legality and fault boundary

Every `uimm5` value from `0` through `31` is assigned, so `C.SETRET` has no reserved displacement.

An undecodable 16-bit form raises `Fault_IllegalInstruction` at `PC`, and an instruction that is not applicable to the active block raises `Fault_BundleControl` at `TPC`. Beyond those checks `C.SETRET` has no fault of its own: it dereferences nothing, so no alignment, memory or permission fault can come from it.

Design point: the instruction validates neither the target nor the surrounding frame. It only records an address, so the correctness of the chosen displacement is the caller's responsibility and not something the architecture can reject.

<!-- PTO-READER-BLOCK: scalar-c-setret-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

At `TPC=4096`, `c.setret 2, ->ra` records `4096 + 4 = 4100` in `ra` and in the captured return-address state, then advances `TPC` to `4098`. With `uimm5=0` the recorded value is `4096`; with `uimm5=31` it is `4158`.
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
Standalone scalar return-address materialization. Each BSTART variant's DIRECT form can fuse with C.SETRET into a distinct per-variant call instruction; the accepted BSTART.FP CALL and BSTART.STD CALL forms define call formation separately.
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
