<!-- GENERATED FROM: asl/scalar/bru/JR.asl -->
# JR

**Normative ASL source:** `asl/scalar/bru/JR.asl`

JR - Jump to the scalar-register target.

## Normative identity {#PTO-INST-SCALAR-JR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-jr-purpose role=purpose -->
## What JR does

`JR` transfers control to an address formed from a scalar register plus a signed halfword displacement. The register value is the base, so the target is absolute and does not depend on the current `PC`.

Design point: `jr Ra, 0` is an indirect jump through `Ra`, because the displacement is added to the register value rather than to the `PC`. Unlike `J`, the target is not anchored to the instruction address.

<!-- PTO-READER-BLOCK: scalar-jr-mechanism role=mechanism -->
## Target computation and the even-target rule

`SrcL` is read through the ordinary `Reg5` source rules, and `simm12` is sign-extended to `PTO_XLEN` and shifted left by `1`. The two are added in `64` bits, wrapping at `2^64`, and the sum is the candidate target.

The candidate is installed as the new `PC` only when its lowest bit is `0`. When the lowest bit is `1`, `JumpRegister` raises `Fault_InstructionPC` with the candidate as the fault argument and does not write `PC`.

Design point: the shifted displacement is always even, so only the register value can make the sum odd. Testing the sum therefore covers both inputs with one check, and a fault installs no target at all rather than an aligned substitute.

<!-- PTO-READER-BLOCK: scalar-jr-inputs-outputs role=inputs-outputs -->
## Operands, alias field, and result

- `SrcL` supplies the base address through the `Reg5` source rules: codes `0` to `23` read absolute GPRs, codes `24` to `27` read the T queue, and codes `28` to `31` read the U queue. A queue code whose entry is not valid rejects the instruction before any read.

- `simm12` supplies the signed halfword displacement, encoded in two pieces of `7` bits and `5` bits.

- `SrcZero` is decoded but never read: no path in the operation uses it, so the value of those `5` bits cannot change the target or the fault decision.

Design point: `SrcZero` is an ignored alias field rather than an operand. The canonical assembly `jr SrcL, label` has no place for it, and all `32` values of the field decode to the same operation.

<!-- PTO-READER-BLOCK: scalar-jr-effects role=effects -->
## Effects, faults, and ordering

`WritePC` installs the even target. `JumpRegister` is a handler that writes `TPC`, so the dispatch boundary does not add the `4`-byte length of this `32`-bit form.

On the fault path no `PC` value is installed and `TPC` does not advance, and `Fault_InstructionPC` reports the candidate target. Neither path writes a register, a queue entry, a memory location, or a `BARG` field.

<!-- PTO-READER-BLOCK: scalar-jr-constraints role=constraints -->
## Legality and fault order

The fixed bits of the form must match and the selected `SrcL` source must be usable, otherwise `Fault_IllegalInstruction` is raised before any target is computed. No field value is reserved, including `SrcZero`.

Design point: the source is read and the target computed only after the decode and operand checks, so a rejected `JR` leaves `PC` and the source register untouched and the instruction can be re-executed after recovery.

<!-- PTO-READER-BLOCK: scalar-jr-example role=example -->
## Non-normative example

This example illustrates the current owner and does not create a second semantic definition.

With `a0` holding `0x8000` and `PC` equal to `0x4000`, `jr a0, 4` installs `0x8008`. `jr a0, 0` installs `0x8000`, and if `a0` instead held `0x8001` the same encoding would raise `Fault_InstructionPC` with the argument `0x8001`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
jr SrcL, label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| jr_32_c4128e843b05 | L32 | 32 | 0x00006027 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| jr_32_c4128e843b05 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| jr_32_c4128e843b05 | SrcZero | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| jr_32_c4128e843b05 | simm12 | 12 | signed | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| jr_32_c4128e843b05 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| jr_32_c4128e843b05 | SrcZero | 5 | 0–31 | none | none | explicit zero-valued source selector | Encoded zero selects value zero of the explicit zero-valued source selector. |
| jr_32_c4128e843b05 | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcZero | explicit zero-valued source selector |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/JR.asl -->
```asl
readonly func InstructionContractOperation_JR() => ScalarOperation
begin
    return ScalarOperation_JR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/JR.asl -->
```asl
readonly func InstructionContractHandler_JR() => ScalarSemanticHandler
begin
    return ScalarHandler_JumpRegister;
end;

pure func InstructionContractRequiresEvenTarget_JR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTarget_JR(
    register_value: Word,
    halfword_offset: Word)
    => Word
begin
    return register_value + LSL(halfword_offset, 1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- JR - Jump to the scalar-register target.
- After decode and legality checks, execute the normative JumpRegister ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- jr SrcL, label
