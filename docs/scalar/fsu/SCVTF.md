<!-- GENERATED FROM: asl/scalar/fsu/SCVTF.asl -->
# SCVTF

**Normative ASL source:** `asl/scalar/fsu/SCVTF.asl`

SCVTF converts a signed 64-bit or sign-extended signed 32-bit source to floating carrier code 0 through 14 through the active numeric profile.

## Normative identity {#PTO-INST-SCALAR-SCVTF}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
scvtf.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| scvtf_32_01861bbd5ef2 | L32 | 32 | 0x0000606b / 0x01f0707f | [{"field":"SrcType","operator":"one-of","values":[0,1]},{"field":"DstType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| scvtf_32_01861bbd5ef2 | DstType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| scvtf_32_01861bbd5ef2 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| scvtf_32_01861bbd5ef2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| scvtf_32_01861bbd5ef2 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| scvtf_32_01861bbd5ef2 | DstType | 5 | 0–14 | none | 15–31 | destination carrier selector | Encoded zero selects the 64-bit destination carrier; it is not omission. |
| scvtf_32_01861bbd5ef2 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| scvtf_32_01861bbd5ef2 | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| scvtf_32_01861bbd5ef2 | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `scvtf_32_01861bbd5ef2.DstType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `scvtf_32_01861bbd5ef2.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstType | destination carrier selector |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/SCVTF.asl -->
```asl
readonly func InstructionContractOperation_SCVTF()
    => ScalarOperation
begin
    return ScalarOperation_SCVTF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/SCVTF.asl -->
```asl
readonly func InstructionContractHandler_SCVTF()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_SCVTF(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_SCVTF(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_SCVTF(encoded);
    return ScalarSignedIntegerSourceTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_SCVTF(encoded: bits(5))
    => boolean
begin
    return UInt(encoded) <= 14;
end;

pure func InstructionContractSourceArity_SCVTF()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_SCVTF()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_SCVTF()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcType=0 selects signed 64-bit and SrcType=1 selects signed 32-bit with sign extension. SrcType=2 and SrcType=3 are reserved.
- DstType codes 0..14 are assigned carrier widths and codes 15..31 are reserved.

## Legality

- Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
- SrcType codes 0 and 1 are assigned; codes 2 and 3 are reserved.
- DstType codes 0 through 14 are assigned; codes 15 through 31 are reserved.

## State effects

- SCVTF converts a signed 64-bit or sign-extended signed 32-bit source to floating carrier code 0 through 14 through the active numeric profile.
- The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.
- For pto-v0, sign-normalize the source, retain the selected floating carrier width, and return zero flags. This executable reference behavior is not target floating-point conformance.
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

- scvtf.sd2fd a0, ->a1
- scvtf.sw2fs t#1, ->u

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
