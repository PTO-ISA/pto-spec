<!-- GENERATED FROM: asl/scalar/sys/C.EBREAK.asl -->
# C.EBREAK

**Normative ASL source:** `asl/scalar/sys/C.EBREAK.asl`

C.EBREAK raises software-breakpoint trap 50 with its 5-bit immediate as cause.

## Normative identity {#PTO-INST-SCALAR-C-EBREAK}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-ebreak-purpose role=purpose -->
## What C.EBREAK does

`C.EBREAK` raises the software-breakpoint trap. The trap number is `50`, and the encoded immediate becomes the trap cause.

It is the compressed software-breakpoint form: the cause travels inside the instruction itself rather than in a register.

<!-- PTO-READER-BLOCK: scalar-c-ebreak-mechanism role=mechanism -->
## How the instruction is placed and executed

This instruction is one scalar operation of an active SYS block. The scalar dispatcher first checks that a bundle is active and that its body is active with block kind System; a SYS form outside such a block is rejected with `Fault_BundleControl`, before any encoded-field check and before any architectural effect.

Encoded legality and source availability are then checked, and only then does the handler run.

The handler takes the 5-bit immediate field, zero-extends it into the 24-bit trap-cause field, and raises `Fault_SoftwareBreakpoint` at the request site. The trap context is saved before the vector transfer, so the pre-instruction state, the trap number, the zero-extended cause and the faulting-address argument are all recorded together.

Design point: the cause is zero-extended rather than sign-extended, and no breakpoint-tag register is written. That keeps the immediate a plain unsigned cause value that a trap handler can compare without knowing the encoding width, and it keeps the breakpoint identity entirely inside the trap record.

<!-- PTO-READER-BLOCK: scalar-c-ebreak-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

- `imm5` is the only encoded operand: a 5-bit immediate value.
- Every 5-bit value is an assigned encoding, so encoded zero is a real zero cause, not an omitted operand.
- There is no destination field, so the instruction never writes a GPR and never pushes `T` or `U`, and there is no source field, so no register or queue entry is read.

<!-- PTO-READER-BLOCK: scalar-c-ebreak-effects role=effects -->
## Architectural effects

The instruction raises `Fault_SoftwareBreakpoint` and publishes trap number `50`. The trap-cause field receives the zero-extended immediate, so `imm5=0` produces cause `0` and `imm5=31` produces cause `31`.

`TPC` does not advance by the ordinary `2`-byte step of this compressed form: the trap records the request site as the fault address and control transfers through the trap vector. No scalar register, queue entry, or memory location is changed by the instruction itself.

<!-- PTO-READER-BLOCK: scalar-c-ebreak-constraints role=constraints -->
## Placement and rejection

Invalid block placement is rejected first, with `Fault_BundleControl`, before the encoded field is even considered.

No `imm5` value is reserved, so the cause field can never be the reason for a rejection. There is no source selector to validate and no destination to validate.

Because the immediate is zero-extended into a `5`-bit breakpoint tag, the largest cause a software breakpoint can produce is `31`.

<!-- PTO-READER-BLOCK: scalar-c-ebreak-example role=example -->
## Non-normative example

`c.break imm` with `imm5=7` raises the software-breakpoint trap with number `50` and cause `7`. With `imm5=0` the same trap is raised with cause `0`; the zero cause is a real encoded request and is never treated as a missing operand.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.break imm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_ebreak_16_7f9c245fa13c | C16 | 16 | 0xc02c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_ebreak_16_7f9c245fa13c | imm5 | 5 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_ebreak_16_7f9c245fa13c | imm5 | 5 | 0–31 | none | none | 5-bit immediate value | Encoded zero supplies numeric zero for the 5-bit immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm5 | 5-bit immediate value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/C.EBREAK.asl -->
```asl
readonly func InstructionContractOperation_C_EBREAK()
    => ScalarOperation
begin
    return ScalarOperation_C_EBREAK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
C.EBREAK executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/C.EBREAK.asl -->
```asl
readonly func InstructionContractHandler_C_EBREAK()
    => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;

pure func InstructionContractRequiresSystemBlock_C_EBREAK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBreakpointImmediateWidth_C_EBREAK()
    => integer {4,5}
begin
    return 5;
end;

pure func InstructionContractBreakpointPublishesTrapCause_C_EBREAK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every 5-bit immediate value is assigned; encoded zero is a real zero cause.

## State effects

- Raise Fault_SoftwareBreakpoint and publish trap number 50.
- Zero-extend the encoded immediate into the 24-bit trap-cause field; no parallel breakpoint-tag state exists.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- After placement and decode, atomically save the pre-instruction context, trap number, zero-extended immediate cause, and faulting-PC argument before vector transfer.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- c.break imm
