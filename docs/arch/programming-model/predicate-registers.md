<!-- GENERATED FROM: asl/arch/programming-model/predicate-registers.asl -->
# Predicate Registers

**Normative ASL source:** `asl/arch/programming-model/predicate-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/predicate-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS","surface":"arch","classification":["programming-model","predicate-registers"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
readonly func ReadPredicateRegister(index: PredicateIndex) => PredicateWord
begin
    return if index == 0 then Ones{PTO_PREDICATE_WIDTH}
           else _PredicateRegisters[[index]];
end;

func WritePredicateRegister(index: PredicateIndex, value: PredicateWord)
begin
    if index != 0 then
        _PredicateRegisters[[index]] = value;
    end;
end;

pure func PredicateRegisterHasInstructionConsumer(index: PredicateIndex)
        => boolean
begin
    // PTO has no instruction encoding that consumes P0..P7.
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
