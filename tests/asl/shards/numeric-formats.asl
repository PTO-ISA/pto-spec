func main() => integer
begin
    ResetProfileState();
    TestNumericFormatCommon();
    TestFP64NumericFormat();
    TestFP32NumericFormat();
    TestTF32NumericFormat();
    TestHF32NumericFormat();
    TestFP16NumericFormat();
    TestBF16NumericFormat();
    TestE4M3NumericFormat();
    TestE5M2NumericFormat();
    TestE3M2NumericFormat();
    TestE2M3NumericFormat();
    TestHiF8NumericFormat();
    TestE2M1X2NumericFormat();
    TestE1M2X2NumericFormat();
    TestHiF4X2NumericFormat();
    TestE8M0NumericFormat();
    return 0;
end;
