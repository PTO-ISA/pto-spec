// PTO-UNIT: {"id":"PTO-ARCH-STATE-PROGRAM-COUNTER","surface":"arch","classification":["state","program-counter"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}
readonly func ReadPC() => Word
begin
    return _PC;
end;

readonly func ReadTPC() => Word
begin
    return _PC;
end;

readonly func ReadBPC() => Word
begin
    return _BPC;
end;

func WritePC(value: Word)
begin
    _PC = value;
end;

func WriteTPC(value: Word)
begin
    _PC = value;
end;

func WriteBPC(value: Word)
begin
    _BPC = value;
end;

