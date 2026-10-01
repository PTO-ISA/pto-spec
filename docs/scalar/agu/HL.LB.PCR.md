<!-- GENERATED FROM: asl/scalar/agu/HL.LB.PCR.asl -->
# HL.LB.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LB.PCR.asl`

HL.LB.PCR snapshots its scalar sources, forms its encoded address, and loads one aligned little-endian 1-byte value.

## Normative identity {#PTO-INST-SCALAR-HL-LB-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-purpose role=purpose -->
## What `HL.LB.PCR` does

`HL.LB.PCR` is a `48`-bit PC-relative load of one byte. It computes its address from the current program counter rather than from a register, reads one byte, sign-extends it to `PTO_XLEN`, and publishes the result through the single `RegDst` field.

The canonical assembly is `hl.lb.pcr [<symbol>], ->{t, u, Rd}`. The assembly names a symbol, while the encoding carries a signed `29`-bit displacement that the instruction scales by `4`.

Design point: the form has no source-register field at all. Nothing in the instruction depends on a GPR, `T`, or `U` value, so there is no source snapshot to take and no queue-availability check to run before the access. The only architectural state read is the program counter.

<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-mechanism role=mechanism -->
## How the address and the transfer are formed

The base is the current `TPC` with bits `1`:`0` cleared, and the offset is the sign-extended `29`-bit displacement shifted left by `2` bits. The two are added modulo `2^PTO_XLEN`.

The access uses that address directly; there is no base writeback, because the form has no second destination and no update mode.

After the encoding checks and the address preflight pass, the handler performs one `1`-byte little-endian load, sign-extends bit `7` of the byte, and publishes the extended value to `RegDst`.

Design point: clearing `TPC[1:0]` makes the base `4`-byte aligned, and the displacement is scaled by `4`, so every address this form can reach is `4`-byte aligned. A `1`-byte access requires no alignment, so no reachable address is refused by the alignment rule; the rule is nevertheless evaluated, because the preflight always runs before translation.

<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-inputs role=inputs-outputs -->
## Encoded fields and where the byte goes

- `RegDst` is a `5`-bit selector. Codes `1`..`23` write absolute GPRs, code `30` pushes the `U` queue, code `31` pushes the `T` queue, and codes `0` and `24`..`29` discard the loaded value without suppressing the rest of the instruction.
- The signed `29`-bit displacement is a word displacement: its assembled byte value runs from `-1073741824` to `1073741820` in steps of `4`.
- The base is implicit: it is the current `TPC`, aligned down to a `4`-byte boundary.

Design point: an encoded `RegDst` of `0` is an explicit discard, not omission. The load, its preflight, and its event all still happen; only the publication step is dropped. A program can therefore use this form as a checked memory probe whose result it does not need.

<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-effects role=effects -->
## Effects, ordering, and completion

Successful execution performs one relaxed `1`-byte load and records one load event. Memory bytes and any reservation state are unchanged.

Publication writes the destination only after the memory operation reported no fault, so a faulting load leaves the destination selector unmodified.

After publication, `HL.LB.PCR` advances `TPC` by `6` bytes. The address was formed from the pre-instruction `TPC`, so the advance does not move the location that was read.

Design point: the destination selector is not a source, but if it names the same queue that a later instruction reads, the push happens once and unconditionally on success; the value is sign-extended before the push, so the queue never holds the raw `8` bits.

<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-constraints role=constraints -->
## Legality, faults, and restart

A fixed-bit mismatch in the `48`-bit encoding raises `Fault_IllegalInstruction` before any effect. There is no base-register selector to check and therefore no unavailable-`T`/`U` rejection path for a source.

The preflight applies the alignment requirement of the access itself. For a `1`-byte transfer every address satisfies it, so this form never raises `Fault_DataAlignment`. The address is then translated and tested for permission, and a permission or bounded-memory failure raises `Fault_DataPage` at the original address.

A fault records no load event, writes no destination, and leaves `TPC` on the faulting instruction. Recovery recomputes the aligned base, the scaled displacement, the preflight, and the load from the beginning.

<!-- PTO-READER-BLOCK: scalar-hl-lb-pcr-example role=example -->
## Reading one encoding end to end

This walkthrough explains how to use the page and does not add instruction behavior.

- Take `hl.lb.pcr [<symbol>], ->5` executing at `TPC` = `0x1002`, with the encoded displacement equal to `7`. Clearing the low `2` bits gives the base `0x1000`, and the displacement assembles to `28`.
- The effective address is `0x1000` plus `28`, which is `0x101C`.
- The instruction reads the single byte at `0x101C` and sign-extends bit `7` into GPR5.
- `TPC` becomes `0x1002` plus `6`, which is `0x1008`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lb.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lb_pcr_48_c0ba9a54c8e0 | HL48 | 48 | 0x00000039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lb_pcr_48_c0ba9a54c8e0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lb_pcr_48_c0ba9a54c8e0 | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lb_pcr_48_c0ba9a54c8e0 | RegDst | 5 | 0–31 | none | none | Reg5 loaded-value destination or discard | Encoded zero discards this result without suppressing the instruction's other effects. |
| hl_lb_pcr_48_c0ba9a54c8e0 | simm | 29 | 0–536870911 | none | none | signed address displacement | Encoded zero supplies a zero displacement; it does not denote omission. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 loaded-value destination or discard |
| simm | signed address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LB.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LB_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LB.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LB_PCR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;

pure func InstructionContractAGUAction_HL_LB_PCR()
    => ScalarAGUAction
begin
    return ScalarAGU_Load;
end;

pure func InstructionContractAGUAddressKind_HL_LB_PCR()
    => ScalarAGUAddressKind
begin
    return ScalarAGU_PCRelative;
end;

pure func InstructionContractAGUSizeBytes_HL_LB_PCR()
    => integer {1,2,4,8}
begin
    return 1;
end;

pure func InstructionContractAGUOffsetScale_HL_LB_PCR()
    => integer {0..3}
begin
    return 2;
end;

pure func InstructionContractAGUUpdateMode_HL_LB_PCR()
    => AddressUpdateMode
begin
    return AddressUpdate_None;
end;

pure func InstructionContractAGUSignedLoad_HL_LB_PCR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAGUPrefetchReturnsAddress_HL_LB_PCR()
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
- simm assigns every signed 29-bit value -268435456..268435455; the encoded byte displacement is that value multiplied by 4.
- Each memory address must be aligned to the 1-byte access size; a 1-byte access is the complete transfer unit.

## State effects

- Clear TPC bits 1:0, sign-extend the encoded displacement, multiply it by four, and add it modulo 2^PTO_XLEN.
- After a successful 1-byte load, sign-extend the loaded value to PTO_XLEN and publish it through the destination.
- Successful execution advances TPC by 6 bytes; a rejected or faulting attempt does not retire.

## Memory effects and ordering

### Memory effects

- After complete preflight, perform one little-endian 1-byte load and record one relaxed load event.
- The load preserves memory and reservation state.

### Ordering

- Snapshot all explicit and implicit scalar sources before destination or memory effects; duplicate and source/destination aliases observe pre-instruction values.
- Complete the relaxed 1-byte memory operation, publish any result or writeback, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved field value, or unavailable selected T/U source raises Fault_IllegalInstruction before instruction effects.
- A misaligned 1-byte address raises Fault_DataAlignment before translation or permission. A later permission or bounded-memory failure raises Fault_DataPage at the original address.
- A fault emits no successful memory event, performs no partial memory or destination effect, preserves pending writeback, and leaves TPC at the faulting instruction.
- Recovery performs a full reissue: every address, source snapshot, preflight, memory operation, and destination is recomputed with no retained progress.

## Examples

- hl.lb.pcr [<symbol>], ->{t, u, Rd}
