// PTO-TEST: {"id":"PTO-AVS-ARCH-TILE-SIZECODE-MAP-002","source":"asl/arch/features/tile-allocation.asl","requirements":["PTO-TILE-CAPACITY-PER-PE"],"kind":"boundary","summary":"B.IOT and B.IOS share the complete SizeCode byte map.","pass_condition":"Codes 1 through 12 double from 128 B through 256 KiB, Local charges scale by PE population, and Shared charges remain one Core-wide object.","related_sources":["asl/block/operands/B.IOT.asl","asl/block/operands/B.IOS.asl","asl/tile/model/state/descriptors.asl"]}
func main() => integer
begin
    ResetProfileState();
    var expected_bytes: integer = 128;
    for code = 1 to 12 looplimit 12 do
        let size_code = code as integer {1..12};
        assert TileSizeCodeBytes(size_code) == expected_bytes;
        assert InstructionContractPerPECapacity_B_IOT(size_code) ==
            expected_bytes;
        assert InstructionContractSharedCapacity_B_IOS(size_code) ==
            expected_bytes;
        assert InstructionContractCoreCapacity_B_IOT(
            size_code, '1111') == expected_bytes * 4;
        assert InstructionContractCoreCapacity_B_IOS(
            size_code, '1111') == expected_bytes;
        assert InstructionContractCoreCapacity_B_IOS(
            size_code, '1000') == expected_bytes;
        expected_bytes = expected_bytes * 2;
    end;
    assert expected_bytes == 524288;
    return 0;
end;
