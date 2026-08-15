<!-- GENERATED FROM: asl/scalar/fsu/FGE.asl -->
# FGE

**Normative ASL source:** `asl/scalar/fsu/FGE.asl`

FGE performs ordered quiet greater-than-or-equal comparison and returns canonical XLEN zero or one.

## Normative identity {#PTO-INST-SCALAR-FGE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fge.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fge_32_b3244b2ffa89 | L32 | 32 | 0x0000305b / 0xf800707f | [{"field":"SrcType","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fge_32_b3244b2ffa89 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fge_32_b3244b2ffa89 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fge_32_b3244b2ffa89 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fge_32_b3244b2ffa89 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fge_32_b3244b2ffa89 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fge_32_b3244b2ffa89 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fge_32_b3244b2ffa89 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| fge_32_b3244b2ffa89 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fge_32_b3244b2ffa89.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcR | right Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FGE.asl -->
```asl
readonly func InstructionContractOperation_FGE()
    => ScalarOperation
begin
    return ScalarOperation_FGE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FGE.asl -->
```asl
readonly func InstructionContractHandler_FGE()
    => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;

pure func InstructionContractSourceTypeLegal_FGE(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FGE(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FGE(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractSourceArity_FGE()
    => integer {1..3}
begin
    return 2;
end;

pure func InstructionContractUsesProfileFlags_FGE()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesActiveRounding_FGE()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCompareOperation_FGE()
    => FloatingCompareOperation
begin
    return FloatingCompare_GE;
end;

pure func InstructionContractSignalingCompare_FGE()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcType=0 selects an FP64 carrier and SrcType=1 selects the zero-extended low-word FP32 carrier. SrcType=2 and SrcType=3 are reserved.

## Legality

- Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
- SrcType codes 0 and 1 are assigned; codes 2 and 3 are reserved.

## State effects

- FGE performs ordered quiet greater-than-or-equal comparison and returns canonical XLEN zero or one.
- Any NaN returns false. This quiet form records sticky NV only for a signaling NaN.
- Destination codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard the result.
- Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Validate every encoded type before the first architectural source read or profile call.
- Snapshot every explicit source before flag or destination effects; duplicate sources, destination aliases, and same-queue read-then-push observe pre-instruction values.
- Accumulate produced flags, publish or discard the destination, and then advance TPC.

## Exceptions

- A fixed-bit mismatch, reserved SrcType, reserved DstType where present, or unavailable selected T/U source raises Fault_IllegalInstruction before source, profile, destination, flag, queue, or TPC effects.
- Numeric profile flags update sticky status and do not themselves raise a synchronous PTO trap.

## Examples

- fge.fd a0, a1, ->a2
- fge.fs t#1, u#1, ->u

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
