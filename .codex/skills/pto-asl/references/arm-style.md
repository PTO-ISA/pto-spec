# Arm-style PTO ASL authoring

Use this guide for specification structure and readability. Arm material is a
style reference only; PTO ASL and accepted PTO decisions remain the sole
authority for PTO behavior.

## Official style basis

This guide is calibrated against Arm's public ASL material:

- [Architecture Specification Language guide](https://documentation-service.arm.com/static/6901ca9402789941c1920b3a)
  describes ASL1 as imperative, strongly and statically typed, first-order,
  and able to update ambient architectural state.
- [ASL Reference](https://documentation-service.arm.com/static/673c50ed27eda361ad4db00c)
  states that ASL is intended to be readable, precise, and unambiguous for
  programmers, hardware engineers, and verification engineers.
- Arm instruction pseudocode separates encoding-specific decode from the
  common operation, and terminating special behavior prevents later
  pseudocode effects.

Apply those structural properties, not Arm instruction semantics or names.
PTO remains responsible for its own decode domains, effects, ordering,
faults, and extension policy.

## Instruction-page structure

Follow the same separation visible in Arm A-profile instruction pages:

1. **Encoding and variants** identify fixed bits, fields, and the condition
   under which each variant applies.
2. **Decode** converts raw fields into small typed locals and rejects illegal
   combinations before effects.
3. **Assembler symbols** explain every visible field and assigned/reserved
   value.
4. **Operation** reads sources, computes the architectural result, and commits
   state in an explicit order.
5. **Operational information** states ordering, fault, alias, or profile rules
   that are not obvious from the value expression.

Decode and operation are distinct scopes. Decode MUST finish field binding,
alias selection, and reserved-value rejection before an operation procedure
can publish architectural effects. A fault or rejection path MUST terminate
the current operation explicitly; code appearing later in the procedure MUST
not be relied upon to remain ineffective by convention.

PTO projects those sections from one mnemonic ASL owner into the exact mirrored
Markdown page. Never maintain a second handwritten semantic definition.

## Naming

- Shared architectural actions use descriptive PascalCase verb phrases:
  `ReadScalarRegisterOperand`, `ProbeDataAccess`, `RecordAtomicEvent`.
- Predicates and queries name the fact they return: `...Legal`, `...Enabled`,
  `...Overlaps`, `...PublishesOldValue`.
- Conversion helpers name source/target intent: `NormalizeAtomicSigned`,
  `TileDataTypeToEncoding`.
- Enumeration values retain the type prefix so call sites are unambiguous.
- Locals use concise lower-case architectural nouns: `address`, `operand`,
  `old_value`, `new_value`, `read_probe`, `write_probe`.
- Avoid opaque abbreviations outside encoded field names. Preserve an encoded
  field spelling only where the encoding contract requires it.

## Operation shape

Prefer this sequence when applicable:

```asl
func ExecuteDecodedExample(instruction: bits(48),
                           form: ScalarFormIndex)
begin
    let address = ReadDecodedAddress(instruction, form);
    let operand = ReadDecodedOperand(instruction, form);

    let read_probe = ProbeDataAccess(address, 4, 4, FALSE);
    if RaiseDataAccessFault(read_probe, address) then
        return;
    end;

    let old_value = LoadTranslatedUnsigned(
        read_probe.translated_address, 4);
    let new_value = ExampleValue(old_value, operand);

    CommitExample(address, read_probe.translated_address,
        old_value, new_value);
end;
```

The source snapshot and all faultable preflight must precede destructive
effects. Keep the successful commit visually distinct from preflight.

Arm instruction references present encoding, arguments, pseudocode, and
restrictions as views of one instruction definition. Apply the same discipline
to PTO: field names and operation locals should expose operand roles directly,
and the Markdown page should project the exact ASL decode and operation rather
than maintaining parallel prose semantics.

## Line layout

- Put `begin` and `end;` on their own lines.
- Keep one semantic phase per paragraph of code: snapshot, derive, validate,
  preflight, compute, commit.
- Wrap function signatures after the function name when they do not scan as
  one short declaration.
- Align continuation arguments under the first argument or use one stable
  four-space continuation level.
- Break compound boolean expressions at operators, one architectural reason
  per line.
- Break long record literals into one field assignment per line.
- Use comments for architectural intent and non-obvious precedence, not to
  restate the next assignment.

## Extension points

- Use a named `impdef func` only where PTO deliberately permits profile
  refinement. State the portable default and invariants a profile cannot
  change.
- Do not use an implementation-defined hook to avoid deciding required PTO
  semantics.
- Keep target names and microarchitectural mechanisms out of portable helpers.
- Reserved encodings reject before effects; they are not permissive extension
  hooks.

## Review checklist

Before marking a mnemonic `FORMAL-COMPLETE`, verify that its ASL and generated
page expose assembly, encoding, defaults, operation, state, memory, ordering,
faults, and reserved behavior; its operation is readable without consulting a
downstream implementation; and independent tests execute success, relevant
forms/boundaries, and fault/no-effect behavior.
