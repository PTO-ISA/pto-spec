<!-- GENERATED FROM: asl/scalar/sys/C.EBREAK.asl -->
# C.EBREAK

**Normative ASL source:** `asl/scalar/sys/C.EBREAK.asl`

C.EBREAK raises software-breakpoint trap 50 with its 5-bit immediate as cause.

## Normative identity {#PTO-INST-SCALAR-C-EBREAK}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
