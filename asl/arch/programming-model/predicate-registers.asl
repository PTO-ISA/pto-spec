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
