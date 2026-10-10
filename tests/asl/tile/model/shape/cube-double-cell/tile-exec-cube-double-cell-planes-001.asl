// PTO-TEST: {"id":"PTO-AVS-TILE-CUBE-DOUBLE-CELL-PLANES-001","source":"asl/tile/model/shape/cube-double-cell.asl","requirements":["PTO-CUBE-M32-B64-DOUBLE-CELL-001"],"kind":"execution","summary":"M32 b64 raw planes map bijectively to paired CELL and row-word positions.","pass_condition":"Low and high words occupy CELL 2c and 2c+1 at word r, inverse mapping recovers c/r/plane, byte offsets are exact, and split words reconstruct the original 64-bit carrier.","related_sources":["asl/tile/model/shape/cube-cell.asl"]}
func main() => integer
begin
    assert TileCubeM32DoubleCellIndex(3, FALSE) == 6;
    assert TileCubeM32DoubleCellIndex(3, TRUE) == 7;
    assert TileCubeM32DoubleCellWord(31) == 31;
    let (column, row, high) = TileCubeM32DoubleCellLogical(7, 31);
    assert column == 3 && row == 31 && high;
    assert TileCubeM32B64PlaneByteOffset(0, 0, FALSE) == 0;
    assert TileCubeM32B64PlaneByteOffset(0, 0, TRUE) == 128;
    assert TileCubeM32B64PlaneByteOffset(31, 1, TRUE) == 508;

    let original = Zeros{PTO_XLEN} + 0x1122334455667788;
    let low = TileCubeM32B64RawPlaneWord(original, FALSE);
    let upper = TileCubeM32B64RawPlaneWord(original, TRUE);
    assert low == '01010101011001100111011110001000';
    assert upper == '00010001001000100011001101000100';
    var rebuilt = Zeros{PTO_XLEN};
    rebuilt = TileCubeM32B64WithRawPlaneWord(rebuilt, low, FALSE);
    rebuilt = TileCubeM32B64WithRawPlaneWord(rebuilt, upper, TRUE);
    assert rebuilt == original;
    return 0;
end;
