// PTO-TEST: {"id":"PTO-AVS-ARCH-TILE-SIZECODE-MAP-002","source":"asl/arch/features/tile-allocation.asl","requirements":["PTO-TILE-CAPACITY-PER-PE"],"kind":"boundary","summary":"Local and Shared bindings use one byte map with different legal SizeCode subsets.","pass_condition":"Codes 1 through 12 double from 128 B through 256 KiB; B.IOT accepts 1 through 10 and scales Local charges by PE population, while B.IOS accepts 1 through 12 and charges one Core-wide Shared object.","related_sources":["asl/block/operands/B.IOT.asl","asl/block/operands/B.IOS.asl","asl/tile/model/state/descriptors.asl"]}
func main() => integer
begin
    ResetProfileState();
    var expected_bytes: integer = 128;
    for code = 1 to 12 looplimit 12 do
        let size_code = code as integer {1..12};
        assert TileSizeCodeBytes(size_code) == expected_bytes;
        assert InstructionContractSharedCapacity_B_IOS(size_code) ==
            expected_bytes;
        assert InstructionContractCoreCapacity_B_IOS(
            size_code, '1111') == expected_bytes;
        assert InstructionContractCoreCapacity_B_IOS(
            size_code, '1000') == expected_bytes;
        if code <= 10 then
            let local_size_code = code as integer {1..10};
            assert LocalTileSizeCodeIsLegal(code);
            assert InstructionContractPerPECapacity_B_IOT(local_size_code) ==
                expected_bytes;
            assert InstructionContractCoreCapacity_B_IOT(
                local_size_code, '1111') == expected_bytes * 4;
        else
            assert !LocalTileSizeCodeIsLegal(code);
        end;
        expected_bytes = expected_bytes * 2;
    end;
    assert expected_bytes == 524288;
    return 0;
end;
