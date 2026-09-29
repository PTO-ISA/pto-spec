<!-- GENERATED FROM: asl/scalar/model/dispatch/decode.asl -->
# Decode

**Normative ASL source:** `asl/scalar/model/dispatch/decode.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-DECODE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-purpose role=purpose-scope -->
## Purpose and scope

This unit turns raw instruction bits into typed operand values for scalar dispatch. After a scalar form has been recognized, every family dispatcher uses these helpers to read a register selector, an immediate, a memory-order pair, or a right-operand modifier.

It also defines `ScalarExecutionStatus` (`ScalarExecution_Executed` or `ScalarExecution_Rejected`) and `ScalarHandlerWritesTPC`, which names the three handlers that install their own TPC: `ScalarHandler_JumpRelative`, `ScalarHandler_JumpRegister`, and `ScalarHandler_ArchitectureEnterRequest`.

The unit depends on `generated:decoders`, which is built from the instruction catalog. That generated layer provides `DecodeScalarForm`, `DecodeScalarOperandRaw`, and the per-form legality functions.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-concepts role=concepts-state -->
## Concepts and visible state

A form is one catalog encoding of a mnemonic, with a fixed length (16, 32, or 48 bits), a mask, and a match value. An instruction word belongs to a form when `word AND mask == match`.

A field is a named operand inside a form, such as `RegDst`, `SrcL`, `simm12`, or `SrcRType`. `DecodeScalarOperandRaw` gathers the field's bit pieces into the low bits of a 48-bit value. A field may be split into several pieces.

The helpers interpret that raw value:

- `ScalarDecodedSelector` keeps 5 bits as a `Reg5Selector`.
- `ScalarDecodedWord` sign-extends a field whose catalog signedness is `Signed` and zero-extends every other field.
- `ScalarDecodedUInt6`, `ScalarDecodedUInt7`, and the `ScalarDecodedBits*` helpers keep fixed low slices.
- `ScalarDecodedBitfieldWidth` adds 1 to the 6-bit `imml`, so widths are 1 through 64.
- `ScalarDecodedMemoryOrder` maps the `aq` and `rl` bits to relaxed, acquire, release, or acquire-release.

These helpers are pure or read-only. `ReadDecodedScalarRegister` reads a GPR or a T/U queue entry through `ReadScalarRegisterOperand`, and `ScalarDecodedAtomicAddress` reads its address register through `ReadDecodedScalarRegister`; the other helpers read no state.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-rules role=rules-interactions -->
## Rules and interactions

The 2-bit `SrcRType` field is decoded differently for each family:

| Raw | Binary ALU | Comparison | Select | Address |
| --- | --- | --- | --- | --- |
| `00` | `.sw` | none | none | none |
| `01` | `.uw` | `.sw` | none | `.sw` |
| `10` | `.neg` or `.not` | `.uw` | none | `.uw` |
| `11` | none | NOT or none | `.neg` | unreachable |

Design point: the binary ALU table puts "no modifier" at `11`. The ADD contract states that an omitted assembly suffix encodes `11`, so an encoded zero in this field selects `.sw`, not "no change".

The NDF clause PTO-REQ-AGU-SRCRTYPE-001 makes raw `11` reserved for register-offset AGU forms. It must be rejected before any source read. The decoder meets this through catalog constraints: each such form lists `SrcRType` as one of 0, 1, or 2, and `ScalarFormOperandsLegal` rejects the word before the AGU handler runs. That is why `DecodeScalarAddressRightModifier` can mark `11` as `unreachable`.

Design point: reserved values that the catalog constrains are rejected by legality checks, not by the value helpers. The value helpers can therefore mark those values `unreachable`, and such a word is rejected before any family handler reads a source or writes a result.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decide which form an instruction word is, and it does not check legality. Those steps run in [scalar top-level dispatch](top-level.md) through the generated `DecodeScalarForm`, `ScalarFormOperandsLegal`, and `ScalarRegisterOperandsLegal`.

`ScalarDecodedAtomicAddress` calls `AtomicAddress` from [AMO semantics](../amo/semantics.md) with the decoded `far` bit; the address is unchanged in this model.

`ScalarDecodedWord` accepts signed widths 5, 12, 17, 22, 24, 29, and 32. Any other signed width is `unreachable`.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-example role=example-usage -->
## Non-normative reading example

Take the 32-bit word 0x0F818F85. The `ADD` form has mask 0x707F and match 0x0005. The word ANDed with the mask is 0x0005, so it is `ADD`.

| Field | Bits | Raw | Meaning |
| --- | --- | --- | --- |
| `RegDst` | 11:7 | 31 | push the result to T |
| `SrcL` | 19:15 | 3 | GPR 3 |
| `SrcR` | 24:20 | 24 | T#1, the newest T entry |
| `SrcRType` | 26:25 | `11` | no modifier |
| `shamt` | 31:27 | 1 | shift right operand left by 1 |

The instruction adds GPR 3 and T#1 shifted left by 1, and pushes the sum to T. Reading T#1 does not consume it.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-decode-related role=related-owners-navigation -->
## Related owners

- [Scalar top-level dispatch](top-level.md) runs form decode and legality before these helpers are used.
- [Scalar operands](../types/operands.md) owns Reg5 source and destination meaning.
- [ALU semantics](../alu/semantics.md) applies the decoded modifiers.
- [Bundle encoding schema](../../../block/model/schema/bundle-encoding.md) is the other declared dependency of this unit.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/decode.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-DECODE","surface":"scalar","classification":["model","dispatch","decode"],"depends_on":["generated:decoders","PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING"]}
// PTO-REQ-SCALAR-DISPATCH-001, PTO-REQ-SCALAR-CONSTRAINT-001: decoded scalar
// execution with catalog-generated form and family legality.
//
// Every accepted scalar family has a form-to-effect binding. Unknown or
// operand-illegal encodings are rejected; there is no silent unsupported path.

// NDF-BEGIN: PTO-REQ-AGU-SRCRTYPE-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// Every register-offset AGU form MUST decode SrcRType as 00=unchanged,
// 01=.sw, and 10=.uw before the encoded or fixed left shift. Raw 11 is
// reserved and MUST reject before source reads or architectural effects.
// NDF-END: PTO-REQ-AGU-SRCRTYPE-001

type ScalarExecutionStatus of enumeration {
    ScalarExecution_Executed,
    ScalarExecution_Rejected
};

pure func ScalarHandlerWritesTPC(handler: ScalarSemanticHandler) => boolean
begin
    return handler == ScalarHandler_JumpRelative ||
           handler == ScalarHandler_JumpRegister ||
           handler == ScalarHandler_ArchitectureEnterRequest;
end;

pure func ScalarDecodedSelector(instruction: bits(48),
                                form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                field: ScalarOperandField) => Reg5Selector
begin
    let raw = DecodeScalarOperandRaw(instruction, form, field);
    return UInt(raw[4:0]) as Reg5Selector;
end;

pure func ScalarDecodedWord(instruction: bits(48),
                            form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                            field: ScalarOperandField) => Word
begin
    let raw = DecodeScalarOperandRaw(instruction, form, field);
    if ScalarOperandSignedness(form, field) == ScalarField_Signed then
        case ScalarOperandWidth(form, field) of
            when 5  => return SignExtend{PTO_XLEN}(raw[4:0]);
            when 12 => return SignExtend{PTO_XLEN}(raw[11:0]);
            when 17 => return SignExtend{PTO_XLEN}(raw[16:0]);
            when 22 => return SignExtend{PTO_XLEN}(raw[21:0]);
            when 24 => return SignExtend{PTO_XLEN}(raw[23:0]);
            when 29 => return SignExtend{PTO_XLEN}(raw[28:0]);
            when 32 => return SignExtend{PTO_XLEN}(raw[31:0]);
            otherwise => unreachable;
        end;
    end;
    return ZeroExtend{PTO_XLEN}(raw);
end;

pure func ScalarDecodedBits19(instruction: bits(48),
                              form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                              field: ScalarOperandField) => bits(19)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[18:0];
end;

pure func ScalarDecodedBits20(instruction: bits(48),
                              form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                              field: ScalarOperandField) => bits(20)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[19:0];
end;

pure func ScalarDecodedBits4(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => bits(4)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[3:0];
end;

pure func ScalarDecodedBits5(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => bits(5)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[4:0];
end;

pure func ScalarDecodedSystemRegisterAddress(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    field: ScalarOperandField) => SystemRegisterAddress
begin
    return DecodeScalarOperandRaw(instruction, form, field)[23:0];
end;

pure func ScalarDecodedBoolean(instruction: bits(48),
                               form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                               field: ScalarOperandField) => boolean
begin
    return DecodeScalarOperandRaw(instruction, form, field)[0] == '1';
end;

pure func ScalarDecodedMemoryOrder(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1})
    => MemoryOrder
begin
    let acquire = ScalarDecodedBoolean(instruction, form, ScalarField_aq);
    let release = ScalarDecodedBoolean(instruction, form, ScalarField_rl);
    if acquire && release then return MemoryOrder_AcquireRelease;
    elsif acquire then return MemoryOrder_Acquire;
    elsif release then return MemoryOrder_Release;
    else return MemoryOrder_Relaxed;
    end;
end;

readonly func ScalarDecodedAtomicAddress(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    field: ScalarOperandField) => Word
begin
    let address = ReadDecodedScalarRegister(instruction, form, field);
    let far = ScalarDecodedBoolean(instruction, form, ScalarField_far);
    return AtomicAddress(address, far);
end;

pure func ScalarDecodedBits32(instruction: bits(48),
                              form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                              field: ScalarOperandField) => bits(32)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[31:0];
end;

pure func ScalarDecodedUInt6(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => integer {0..63}
begin
    return UInt(DecodeScalarOperandRaw(instruction, form, field)[5:0]);
end;

pure func ScalarDecodedUInt7(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => integer {0..127}
begin
    return UInt(DecodeScalarOperandRaw(instruction, form, field)[6:0]);
end;

pure func ScalarDecodedBitfieldWidth(instruction: bits(48),
                                     form: integer {0..PTO_SCALAR_FORM_COUNT-1})
                                     => integer {1..64}
begin
    return UInt(DecodeScalarOperandRaw(instruction, form, ScalarField_imml)[5:0]) + 1;
end;

pure func DecodeScalarBinaryRightModifier(raw: bits(2))
                                           => ScalarRightModifier
begin
    case raw of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func DecodeScalarComparisonRightModifier(raw: bits(2))
                                               => ScalarRightModifier
begin
    case raw of
        when '00' => return ScalarRight_None;
        when '01' => return ScalarRight_SignedWord;
        when '10' => return ScalarRight_UnsignedWord;
        when '11' => return ScalarRight_NegateOrNot;
    end;
end;

pure func DecodeScalarSelectRightModifier(raw: bits(2))
                                          => ScalarRightModifier
begin
    if raw == '11' then
        return ScalarRight_NegateOrNot;
    else
        return ScalarRight_None;
    end;
end;

pure func DecodeScalarAddressRightModifier(raw: bits(2))
                                           => ScalarRightModifier
begin
    case raw of
        when '00' => return ScalarRight_None;
        when '01' => return ScalarRight_SignedWord;
        when '10' => return ScalarRight_UnsignedWord;
        when '11' => unreachable;
    end;
end;

pure func ScalarDecodedBinaryRightModifier(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1})
    => ScalarRightModifier
begin
    let raw = DecodeScalarOperandRaw(
        instruction,
        form,
        ScalarField_SrcRType)[1:0];
    return DecodeScalarBinaryRightModifier(raw);
end;

pure func ScalarDecodedComparisonRightModifier(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1})
    => ScalarRightModifier
begin
    let raw = DecodeScalarOperandRaw(
        instruction,
        form,
        ScalarField_SrcRType)[1:0];
    return DecodeScalarComparisonRightModifier(raw);
end;

pure func ScalarDecodedSelectRightModifier(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1})
    => ScalarRightModifier
begin
    let raw = DecodeScalarOperandRaw(
        instruction,
        form,
        ScalarField_SrcRType)[1:0];
    return DecodeScalarSelectRightModifier(raw);
end;

pure func ScalarDecodedAddressRightModifier(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1})
    => ScalarRightModifier
begin
    let raw = DecodeScalarOperandRaw(
        instruction,
        form,
        ScalarField_SrcRType)[1:0];
    return DecodeScalarAddressRightModifier(raw);
end;

readonly func ReadDecodedScalarRegister(instruction: bits(48),
                                        form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                        field: ScalarOperandField) => Word
begin
    return ReadScalarRegisterOperand(ScalarDecodedSelector(instruction, form, field));
end;
```
<!-- GENERATED-ASL-END: unit -->
