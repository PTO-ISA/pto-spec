<!-- GENERATED FROM: asl/scalar/fsu/FCVTZ.asl -->
# FCVTZ

**Normative ASL source:** `asl/scalar/fsu/FCVTZ.asl`

FCVTZ converts a selected FP64 or FP32 carrier to integer carrier code 0 through 14 with fixed round-toward-zero mode.

## Normative identity {#PTO-INST-SCALAR-FCVTZ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fcvtz.{srcT2dstT} SrcL, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fcvtz_32_bee01d31217c | L32 | 32 | 0x0000506b / 0x01f0707f | [{"field":"SrcType","operator":"one-of","values":[0,1]},{"field":"DstType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fcvtz_32_bee01d31217c | DstType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fcvtz_32_bee01d31217c | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fcvtz_32_bee01d31217c | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fcvtz_32_bee01d31217c | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fcvtz_32_bee01d31217c | DstType | 5 | 0–14 | none | 15–31 | destination carrier selector | Encoded zero selects the 64-bit destination carrier; it is not omission. |
| fcvtz_32_bee01d31217c | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| fcvtz_32_bee01d31217c | SrcL | 5 | 0–31 | none | none | left or sole Reg5 source | Encoded zero reads the architectural zero GPR. |
| fcvtz_32_bee01d31217c | SrcType | 2 | 0–1 | none | 2–3 | source carrier selector | Encoded zero selects the 64-bit source carrier; it is not omission. |

- `fcvtz_32_bee01d31217c.DstType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `fcvtz_32_bee01d31217c.SrcType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstType | destination carrier selector |
| RegDst | Reg5 destination or discard |
| SrcL | left or sole Reg5 source |
| SrcType | source carrier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FCVTZ.asl -->
```asl
readonly func InstructionContractOperation_FCVTZ()
    => ScalarOperation
begin
    return ScalarOperation_FCVTZ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FCVTZ.asl -->
```asl
readonly func InstructionContractHandler_FCVTZ()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;

pure func InstructionContractSourceTypeLegal_FCVTZ(encoded: bits(2))
    => boolean
begin
    return encoded == '00' || encoded == '01';
end;

pure func InstructionContractSourceCarrier_FCVTZ(encoded: bits(2))
    => bits(5)
begin
    assert InstructionContractSourceTypeLegal_FCVTZ(encoded);
    return ScalarFPSourceTypeCode(encoded);
end;

pure func InstructionContractDestinationTypeLegal_FCVTZ(encoded: bits(5))
    => boolean
begin
    return UInt(encoded) <= 14;
end;

pure func InstructionContractSourceArity_FCVTZ()
    => integer {1..3}
begin
    return 1;
end;

pure func InstructionContractUsesProfileFlags_FCVTZ()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesActiveRounding_FCVTZ()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractFixedRounding_FCVTZ()
    => NumericRoundingMode
begin
    return NumericRound_RTZ;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand field is encoded explicitly; encoded zero is a value and never denotes omission.
- SrcType=0 selects an FP64 carrier and SrcType=1 selects the zero-extended low-word FP32 carrier. SrcType=2 and SrcType=3 are reserved.
- DstType codes 0..14 are assigned carrier widths and codes 15..31 are reserved.

## Legality

- Every Reg5 source uses codes 0..23 for absolute GPRs, 24..27 for T#1..T#4, and 28..31 for U#1..U#4 without consumption.
- Every Reg5 destination is assigned: codes 1..23 write GPRs, 30 pushes U, 31 pushes T, and 0 plus 24..29 discard only the result.
- SrcType codes 0 and 1 are assigned; codes 2 and 3 are reserved.
- DstType codes 0 through 14 are assigned; codes 15 through 31 are reserved.

## State effects

- FCVTZ converts a selected FP64 or FP32 carrier to integer carrier code 0 through 14 with fixed round-toward-zero mode.
- The selected numeric profile returns an exact NV, DZ, OF, UF, NX vector which is ORed into existing sticky CORE_STATE flags.
- For pto-v0, preserve the normalized source bits, retain the selected integer carrier width, and return zero flags. This executable reference behavior is not target floating-point conformance.
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

- fcvtz.fd2sd a0, ->a1
- fcvtz.fs2sw t#1, ->u

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
