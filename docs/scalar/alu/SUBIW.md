<!-- GENERATED FROM: asl/scalar/alu/SUBIW.asl -->
# SUBIW

**Normative ASL source:** `asl/scalar/alu/SUBIW.asl`

SUBIW performs unsigned-immediate word subtraction and sign-extends the result to XLEN.

## Normative identity {#PTO-INST-SCALAR-SUBIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
subiw SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| subiw_32_51019ff77d0a | L32 | 32 | 0x00001035 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| subiw_32_51019ff77d0a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| subiw_32_51019ff77d0a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| subiw_32_51019ff77d0a | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| subiw_32_51019ff77d0a | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| subiw_32_51019ff77d0a | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads the architectural zero GPR. |
| subiw_32_51019ff77d0a | uimm12 | 12 | 0–4095 | none | none | unsigned 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| uimm12 | unsigned 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUBIW.asl -->
```asl
readonly func InstructionContractOperation_SUBIW()
    => ScalarOperation
begin
    return ScalarOperation_SUBIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUBIW.asl -->
```asl
readonly func InstructionContractHandler_SUBIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_SUBIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_SUBIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_SUBIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm12, and RegDst are required encoded fields; no field can be omitted.
- uimm12 is an unsigned 12-bit immediate from 0 through 4095. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every unsigned 12-bit immediate from 0 through 4095 is legal; source bits above bit 31 do not affect the result.

## State effects

- Subtract zero-extended uimm12 from SrcL[31:0] modulo 2^32, then sign-extend the 32-bit result to XLEN and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the sign-extended word result and then advances TPC by four bytes.

## Exceptions

- SUBIW raises no arithmetic exception: word subtraction wraps modulo 2^32 and is sign-extended to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- subiw a0, 1, ->a0
- subiw u#1, 4095, ->t
- subiw zero, 0, ->zero

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
