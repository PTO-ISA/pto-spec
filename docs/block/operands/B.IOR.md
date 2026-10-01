<!-- GENERATED FROM: asl/block/operands/B.IOR.asl -->
# B.IOR

**Normative ASL source:** `asl/block/operands/B.IOR.asl`

Bind up to three absolute GPR inputs and one absolute GPR output per record; ExecMaskPresent marks final-record GPR ExecutionMask words.

## Normative identity {#PTO-INST-BLOCK-B-IOR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-ior-purpose role=purpose -->
## What B.IOR contributes

`B.IOR` is a 32-bit block header command that binds general-purpose registers (GPRs) to the operation of the current block. One record names up to three GPR inputs and one GPR output. The operation uses them for scalar operands such as a global-memory base address, a row stride, a scalar parameter, or a scalar result.

`B.IOR` reads no GPR when it executes. It records the selectors, and the selected operation reads the registers at commit. See [Scalar bindings](../model/operands/scalar-bindings.md).

<!-- PTO-READER-BLOCK: block-b-ior-mechanism role=mechanism -->
## Placement and mechanism

`B.IOR` must appear in the header of an active block, after the block start and before the first body instruction. An ordinary block accepts one record. Three kinds of operation accept a second, immediately contiguous record: TGPR2T, TIMG2COL, and eligible Local CUBE forms that take an ExecutionMask from GPRs.

The complete operation schema decides how many selectors are consumed and what each one means. The record itself always stores four selectors. Inputs pack densely into `RegSrc0`, `RegSrc1`, and `RegSrc2` in the order the operation defines, and a GPR ExecutionMask word follows every operation-owned input.

Design point: omission and encoded zero are different. When `B.IOR` is omitted, each consumed slot takes the operation's own default. When `B.IOR` is present, selector code 0 names the architectural zero GPR, which reads 0. For `TLOAD` and `TSTORE`, omission supplies base address zero and a dense row stride computed from the column count and `DataType`, while an explicit `RegSrc1 = zero` supplies stride 0.

<!-- PTO-READER-BLOCK: block-b-ior-inputs role=inputs-outputs -->
## Fields and encoded values

- `RegSrc0` (bits 19:15), `RegSrc1` (bits 24:20), and `RegSrc2` (bits 31:27) are input selectors.
- `RegDst` (bits 11:7) is the output selector.
- Each selector is spelled as an absolute GPR code 0 to 23: `zero`, `sp`, `a0` to `a7`, `ra`, `s0` to `s8`, and `x0` to `x3`. Codes 24 to 31 are reserved for `B.IOR`; a relative T or U queue selector is never a valid `B.IOR` field, and the schema checks named above are what reject the reserved codes.
- `ExecMaskPresent` (bit 26) marks the record that carries the GPR ExecutionMask word or words. Bit 25 is fixed at zero.

Design point: `ExecMaskPresent` distinguishes a mask selector of `zero` from an unused zero selector. It is set only on the final `B.IOR` record, and only when the schema binds a GPR ExecutionMask. `PredInv` and the zero-versus-merge choice are `B.DATR` controls, not `B.IOR` fields.

<!-- PTO-READER-BLOCK: block-b-ior-effects role=effects -->
## Pending state

An accepted `B.IOR` writes one scalar-binding entry: the four selectors, a source capacity, and the `ExecMaskPresent` flag. It modifies no GPR and accesses no memory.

The operation reads the bound inputs before it publishes any destination. A destination selector receives the operation's scalar result when the operation defines one. Sources may repeat, and a source may name the same GPR as the destination when the schema permits a destination.

<!-- PTO-READER-BLOCK: block-b-ior-constraints role=constraints -->
## Legality and fault boundary

- Selector codes 24 to 31 are reserved. The record still stores them; a fault appears only where an operation-specific check requires an absolute GPR or a mask source, for example CUBE `TCI` and `TGPR2T`, which reject at preflight with `Fault_TileLegality`.
- `B.IOR` outside an active header, a second record where the operation allows only one, a third record, or a record that breaks the TGPR2T or TIMG2COL stream rules raises `Fault_BundleControl`.
- A nonzero selector in a slot the schema does not consume, a nonfinal or inapplicable `ExecMaskPresent`, or another schema mismatch raises the operation's legality fault before operation effects.
- Indexed TLSU operations require an explicit `B.IOR` with `RegSrc0` as the base address and `RegSrc1`, `RegSrc2`, and `RegDst` all zero.

Design point: a surplus selector must be zero. Because the schema rejects a nonzero unused field, a stray register name in a slot the operation ignores is reported instead of silently dropped.

<!-- PTO-READER-BLOCK: block-b-ior-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.IOR a0, a1, zero, ->zero
```

In a `TLOAD` block this record supplies the base address from `a0` and the row stride in bytes from `a1`. `RegSrc2` and `RegDst` are `zero`, the selectors for unused slots. The fields are `RegSrc0 = 2`, `RegSrc1 = 3`, `RegSrc2 = 0`, `RegDst = 0`, and `ExecMaskPresent = 0`, which encode as `0x00310013`. If the block omitted `B.IOR` instead, the load would use base address zero and a dense row stride.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.IOR [<gpr>[, <gpr>[, <gpr>]]][, -><gpr>][, ExecMaskPresent]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_ior_32_c3ea71404eb3 | L32 | 32 | 0x00000013 / 0x0200707f | [{"field":"RegDst","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"ExecMaskPresent","operator":"one-of","values":[0,1]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_ior_32_c3ea71404eb3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| b_ior_32_c3ea71404eb3 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_ior_32_c3ea71404eb3 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| b_ior_32_c3ea71404eb3 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| b_ior_32_c3ea71404eb3 | ExecMaskPresent | 1 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Field value dispositions

### RegDst (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### RegSrc0 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### RegSrc1 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

### RegSrc2 (`PTO-FIELD-BLOCK-GPR-SELECTOR`)

Selects one absolute architectural GPR for B.IOR input or output binding.

**Encoded zero:** Code zero names the architectural zero GPR; it never means an omitted B.IOR field.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | zero |
| 1 | assigned | sp |
| 2 | assigned | a0 |
| 3 | assigned | a1 |
| 4 | assigned | a2 |
| 5 | assigned | a3 |
| 6 | assigned | a4 |
| 7 | assigned | a5 |
| 8 | assigned | a6 |
| 9 | assigned | a7 |
| 10 | assigned | ra |
| 11 | assigned | s0 |
| 12 | assigned | s1 |
| 13 | assigned | s2 |
| 14 | assigned | s3 |
| 15 | assigned | s4 |
| 16 | assigned | s5 |
| 17 | assigned | s6 |
| 18 | assigned | s7 |
| 19 | assigned | s8 |
| 20 | assigned | x0 |
| 21 | assigned | x1 |
| 22 | assigned | x2 |
| 23 | assigned | x3 |
| 24 | reserved | future extension |
| 25 | reserved | future extension |
| 26 | reserved | future extension |
| 27 | reserved | future extension |
| 28 | reserved | future extension |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Selectors 24 through 31 are reserved and raise Fault_IllegalInstruction before binding state changes.

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_ior_32_c3ea71404eb3 | RegDst | 5 | 0–23 | none | 24–31 | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| b_ior_32_c3ea71404eb3 | RegSrc0 | 5 | 0–23 | none | 24–31 | first absolute GPR source | Encoded zero names the architectural zero GPR. |
| b_ior_32_c3ea71404eb3 | RegSrc1 | 5 | 0–23 | none | 24–31 | second absolute GPR source | Encoded zero names the architectural zero GPR. |
| b_ior_32_c3ea71404eb3 | RegSrc2 | 5 | 0–23 | none | 24–31 | third absolute GPR source | Encoded zero names the architectural zero GPR. |
| b_ior_32_c3ea71404eb3 | ExecMaskPresent | 1 | 0–1 | none | none | marks that the final B.IOR record supplies the GPR ExecutionMask word(s) declared by the selected complete schema | No GPR ExecutionMask carrier is bound by this record. |

- `b_ior_32_c3ea71404eb3.RegDst` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_ior_32_c3ea71404eb3.RegSrc0` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_ior_32_c3ea71404eb3.RegSrc1` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_ior_32_c3ea71404eb3.RegSrc2` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| RegSrc0 | first absolute GPR source |
| RegSrc1 | second absolute GPR source |
| RegSrc2 | third absolute GPR source |
| ExecMaskPresent | marks that the final B.IOR record supplies the GPR ExecutionMask word(s) declared by the selected complete schema |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/operands/B.IOR.asl -->
```asl
readonly func InstructionContractMatches_B_IOR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_ior_32_c3ea71404eb3);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
One B.IOR may appear after BSTART and before the block body when the complete schema declares GPR operands. Eligible Local CUBE ExecutionMask forms may use one or two immediately contiguous records; TGPR2T and TIMG2COL retain their separately owned two-record forms.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.IOR.asl -->
```asl
// B.IOR's complete selected schema is authoritative for record count, source
// and destination role, omitted fields, and surplus rejection. TGPR2T uses
// exactly two contiguous source-only records with source arity 3+1. Eligible
// Local CUBE ExecutionMask GPR forms append one or two source words after all
// operation-owned GPR inputs and may use at most two contiguous records; the
// second is source-only, and the two words (when required) are one carrier.
// A third record, a misplaced record, a non-final presence flag, or any
// nonzero unconsumed selector is illegal. ExecMaskPresent is B.IOR[26];
// B.IOR[25] remains fixed zero. PredInv and Zero belong to B.DATR and are
// not encoded by B.IOR.
// All four selectors name complete 64-bit architectural GPRs in GPR0..GPR23.
// Canonical <gpr> spellings are zero, sp, a0..a7, ra, s0..s8, and x0..x3.
// Relative T/U queue selectors are not legal in any B.IOR field.
// Each B.IOR record binds up to three dense input slots, RegSrc0..RegSrc2.
// For eligible Local CUBE ExecutionMask forms, complete schemas concatenate
// up to two records in operation-owned order followed by mask word(s).
// Omission is distinct from an encoded zero selector. Consumers own raw-value
// validation before constrained assignment; a second B.IOR is accepted only
// by TGPR2T, TIMG2COL, or an eligible ExecutionMask GPR schema.
// Matrix complete-bundle consumers append optional scalar QuantParam then
// scalar LReLUParam in the same dense RegSrc order. Their omission/default,
// surplus-zero, and raw-carrier policy is owned by the dynamic schema at
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and
// spec/evidence/bundle-command-totality.json.
pure func InstructionContractMatrixPostProcessGPRQuantSlot_B_IOR() => integer
begin
    return 0;
end;

pure func InstructionContractMatrixPostProcessGPRLReLUSlot_B_IOR() => integer
begin
    return 1;
end;

pure func InstructionContractMatrixPostProcessGPRCapacity_B_IOR() => integer
begin
    return 3;
end;

pure func InstructionContractAbsoluteGPRSelectorLegal_B_IOR(
    selector: Reg5Selector) => boolean
begin
    return selector < PTO_ABSOLUTE_GPR_COUNT;
end;

// In TLOAD/TSTORE schemas source zero supplies the GM base and source one
// supplies row stride in bytes.  Omission is distinct from an
// encoded selector whose current value is zero.
// Indexed TLSU schemas require an explicit B.IOR: source zero supplies the GM
// base and source one, source two, and the destination supply zero.
pure func InstructionContractTLSUBaseSource_B_IOR() => integer
begin
    return 0;
end;

pure func InstructionContractTLSURowStrideSource_B_IOR() => integer
begin
    return 1;
end;

readonly func InstructionContractHandler_B_IOR() => CommandSemanticHandler
begin
    return CommandHandler_BindBundleScalarIO;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The complete BSTART operation schema determines whether B.IOR is consumed and the number and roles of its GPR inputs and output.
- When B.IOR is omitted, every consumed input or output uses its operation-defined default. An explicitly encoded selector zero names the architectural zero GPR and is not omission.
- For TLOAD and TSTORE, omission supplies GM base zero and a dense byte row stride derived from the resolved column count and DataType; explicit RegSrc1=zero supplies a zero stride.
- All indexed TLSU forms require explicit B.IOR with RegSrc0 as the GM base address; RegSrc1, RegSrc2, and RegDst encode zero.
- Matrix postprocess B.IOR slots follow the complete B.FPATR schema: scalar QuantParam then scalar LReLUParam, with omitted consumed slots reading the zero GPR.

## Legality

- B.IOR is legal only after BSTART and before the block body when the complete selected schema declares GPR operands; an explicitly encoded zero selector names GPR0 and is not omission.
- RegDst and RegSrc0..RegSrc2 accept only absolute GPR selectors 0..23; selectors 24..31 are reserved and reject before effects.
- Sources may repeat and may alias RegDst where the selected complete schema permits a destination. Any nonzero unconsumed field rejects before block effects.
- Indexed TLSU consumes RegSrc0 as BaseGPR. RegSrc1, RegSrc2, and RegDst must be zero before memory or destination effects.
- Every ordinary block accepts at most one B.IOR. TGPR2T and TIMG2COL retain their exact two-record exceptions. An eligible Local CUBE ExecutionMask GPR form appends one or two words after all operation-owned GPR inputs and may use one or two contiguous records, in dense source order, for up to six GPR inputs. Any GPR destination is allowed only in the first record; the second record is source-only.
- ExecMaskPresent is one only on the final contiguous B.IOR record when a GPR ExecutionMask is bound. Earlier records, unpredicated forms, and Predicate-Tile forms require it to be zero. Selector GPR0 is legal and is distinguished from an unused zero selector by the final-record flag and exact schema arity.

## State effects

- Record the schema-permitted B.IOR selector state: one record for ordinary consumers or up to two immediately contiguous records for TGPR2T, TIMG2COL, or eligible Local CUBE ExecutionMask forms. Effective arity, roles, and ExecMaskPresent applicability derive from the complete operation schema.
- Inputs are read according to the selected operation before destination publication; executing B.IOR itself modifies no GPR.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- A nonzero unused field or other operation-schema mismatch raises a block/tile legality fault before operation effects.
- An out-of-range selector raises Fault_IllegalInstruction before binding state changes. Standalone or body-phase B.IOR raises Illegal Block Exception before binding state changes. Duplicate, noncontiguous, third, misplaced, or schema-inapplicable records and a non-final or inapplicable ExecMaskPresent flag raise Fault_BundleControl or Fault_TileLegality before effects.

## Examples

- B.IOR a0, a1, zero, ->zero
- B.IOR zero, ExecMaskPresent
