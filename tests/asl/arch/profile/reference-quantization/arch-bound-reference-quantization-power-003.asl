// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-QUANTIZATION-POWER-003","source":"asl/arch/profile/reference-quantization.asl","requirements":[],"kind":"boundary","summary":"the logarithmic reference power-of-two helper matches an independent linear oracle across representative values and both domain endpoints","pass_condition":"zero, representative signed exponents, and both complete-domain endpoints equal independently constructed exact powers of two","related_sources":["asl/arch/profile/reference-profile.asl","asl/arch/profile/reference-conversion.asl"]}
pure func LinearReferencePowerOfTwo(
    exponent: integer {-1074..1023}) => real
begin
    var result: real = 1.0;
    var step: integer {-1074..1023} = 0;
    while step < exponent looplimit 1023 do
        result = result * 2.0;
        step = (step + 1) as integer {-1074..1023};
    end;
    while step > exponent looplimit 1074 do
        result = result / 2.0;
        step = (step - 1) as integer {-1074..1023};
    end;
    return result;
end;

func AssertReferencePowerOfTwo(
    exponent: integer {-1074..1023})
begin
    assert ReferencePowerOfTwo(exponent) ==
        LinearReferencePowerOfTwo(exponent);
end;

func main() => integer
begin
    AssertReferencePowerOfTwo(0);
    AssertReferencePowerOfTwo(10);
    AssertReferencePowerOfTwo(-10);
    AssertReferencePowerOfTwo(1023);
    AssertReferencePowerOfTwo(-1074);
    return 0;
end;
