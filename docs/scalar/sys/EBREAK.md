<!-- GENERATED FROM: asl/scalar/sys/EBREAK.asl -->
# EBREAK

**Normative ASL source:** `asl/scalar/sys/EBREAK.asl`

EBREAK raises software-breakpoint trap 50 with its 4-bit immediate as cause.

## Normative identity {#PTO-INST-SCALAR-EBREAK}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ebreak imm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ebreak_32_4f122d1e6be3 | L32 | 32 | 0x0010102b / 0xf0ffffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ebreak_32_4f122d1e6be3 | imm4 | 4 | encoding-defined | [{"instruction_lsb":24,"value_lsb":0,"width":4}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ebreak_32_4f122d1e6be3 | imm4 | 4 | 0–15 | none | none | 4-bit immediate value | Encoded zero supplies numeric zero for the 4-bit immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| imm4 | 4-bit immediate value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/EBREAK.asl -->
```asl
readonly func InstructionContractOperation_EBREAK()
    => ScalarOperation
begin
    return ScalarOperation_EBREAK;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
EBREAK executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/EBREAK.asl -->
```asl
readonly func InstructionContractHandler_EBREAK()
    => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;

pure func InstructionContractRequiresSystemBlock_EBREAK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractBreakpointImmediateWidth_EBREAK()
    => integer {4,5}
begin
    return 4;
end;

pure func InstructionContractBreakpointPublishesTrapCause_EBREAK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every 4-bit immediate value is assigned; encoded zero is a real zero cause.

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

- ebreak imm

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
