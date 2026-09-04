<!-- GENERATED FROM: asl/block/operands/B.IOR.asl -->
# B.IOR

**Normative ASL source:** `asl/block/operands/B.IOR.asl`

Bind up to three absolute GPR inputs and one absolute GPR output; regular TLSU uses source one as row stride and indexed TLSU uses it as GM row stride in elements.

## Normative identity {#PTO-INST-BLOCK-B-IOR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-ior-purpose role=purpose -->
## What B.IOR contributes

`B.IOR` is a 32-bit block header command that records scalar GPR inputs and an optional scalar destination. It changes pending block metadata rather than executing a tile body operation immediately.

<!-- PTO-READER-BLOCK: block-b-ior-mechanism role=mechanism -->
## Placement and mechanism

The command belongs to an active header before the first body instruction. Its effective order and arity are checked against the completed operation schema rather than inferred from this command in isolation.

The command records one pending scalar-binding record. Sources are read later according to the selected operation, and executing `B.IOR` alone does not write a GPR destination.

<!-- PTO-READER-BLOCK: block-b-ior-inputs role=inputs-outputs -->
## Operands and header roles

- `RegDst` identifies a destination or publication selector; its exact assigned domain remains in the generated contract below.
- `RegSrc0` identifies an input source or source-role selector; its exact assigned domain remains in the generated contract below.
- `RegSrc1` identifies an input source or source-role selector; its exact assigned domain remains in the generated contract below.
- `RegSrc2` identifies an input source or source-role selector; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-b-ior-effects role=effects -->
## Pending state and completion

An accepted header command changes only its pending record or carrier. Architectural tile, Shared, GPR, memory, and completion effects remain deferred to the completed block unless this owner's contract explicitly identifies an immediate header-state update.

<!-- PTO-READER-BLOCK: block-b-ior-constraints role=constraints -->
## Legality and fault boundary

Reserved encodings are rejected before reads or pending-state changes. Placement, duplicate, role, or completed-schema mismatches fail before body effects.

<!-- PTO-READER-BLOCK: block-b-ior-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
B.IOR [<gpr>[, <gpr>[, <gpr>]]][, -><gpr>]
```

Assume an active compatible header with no earlier conflicting `B.IOR` command. Placing `B.IOR [<gpr>[, <gpr>[, <gpr>]]][, -><gpr>]` at the next header slot records this command's pending fields; it does not by itself execute the eventual body operation.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.IOR [<gpr>[, <gpr>[, <gpr>]]][, -><gpr>]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_ior_32_c3ea71404eb3 | L32 | 32 | 0x00000013 / 0x0600707f | [{"field":"RegDst","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_ior_32_c3ea71404eb3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| b_ior_32_c3ea71404eb3 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_ior_32_c3ea71404eb3 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| b_ior_32_c3ea71404eb3 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

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
One B.IOR may appear after BSTART and before the block body when the complete schema declares GPR operands. TGPR2T instead requires exactly two immediately contiguous source-only records before its destination B.IOT.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/operands/B.IOR.asl -->
```asl
// B.IOR's complete selected schema is authoritative for record count, source
// and destination role, omitted fields, and surplus rejection. TGPR2T is the
// explicit multi-record form: exactly two contiguous source-only records with
// source arity 3+1; a third record, a destination, or another split is illegal.
// All four selectors name complete 64-bit architectural GPRs in GPR0..GPR23.
// Canonical <gpr> spellings are zero, sp, a0..a7, ra, s0..s8, and x0..x3.
// Relative T/U queue selectors are not legal in any B.IOR field.
// B.IOR binds at most three dense input slots, RegSrc0..RegSrc2, in the
// operation-independent logical order address, scalar0, diagonal,
// flag0. Omission is distinct from an encoded zero selector. Consumers own
// raw-value validation before constrained assignment; a second non-TGPR2T
// B.IOR faults with Fault_BundleControl and preserves the first binding.
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
// base and source one supplies a nonzero GM row stride in elements.
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
- MGATHER, MSCATTER, MGATHER.MASK, MSCATTER.MASK, and MGATHER.CAS require explicit B.IOR: RegSrc0 is the GM base address and RegSrc1 is a nonzero GM row stride in elements no smaller than ValidCol.
- Matrix postprocess B.IOR slots follow the complete B.FPATR schema: scalar QuantParam then scalar LReLUParam, with omitted consumed slots reading the zero GPR.

## Legality

- B.IOR is legal only after BSTART and before the block body when the complete selected schema declares GPR operands; an explicitly encoded zero selector names GPR0 and is not omission.
- Every non-TGPR2T block accepts at most one B.IOR. TGPR2T accepts exactly two immediately contiguous source-only records with arity 3+1; destination-bearing, missing, reordered, intervening-command, wrong-split, or surplus records reject before effects.
- RegDst and RegSrc0..RegSrc2 accept only absolute GPR selectors 0..23; selectors 24..31 are reserved and reject before effects.
- Sources may repeat and may alias RegDst where the selected complete schema permits a destination. Any nonzero unconsumed field rejects before block effects.
- Indexed TLSU consumes RegSrc0 and RegSrc1. RegSrc2 and RegDst must be zero, and the consuming operation rejects a RegSrc1 value smaller than ValidCol before memory or destination effects.

## State effects

- Record the schema-permitted B.IOR selector state: one record for ordinary consumers or two contiguous source-only records for TGPR2T. Effective arity and roles derive from the complete operation schema.
- Inputs are read according to the selected operation before destination publication; executing B.IOR itself modifies no GPR.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- An out-of-range selector raises Fault_IllegalInstruction before binding state changes.
- Standalone or body-phase B.IOR raises Illegal Block Exception before binding state changes. A duplicate non-TGPR2T record, a TGPR2T third record, or any command between TGPR2T's first and second B.IOR raises Fault_BundleControl and preserves accepted prior state.
- A nonzero unused field or other operation-schema mismatch raises a block/tile legality fault before operation effects.

## Examples

- B.IOR a0, a1, zero, ->zero
