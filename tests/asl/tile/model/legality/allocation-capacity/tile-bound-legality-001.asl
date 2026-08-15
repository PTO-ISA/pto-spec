// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-TILE-TESTTILECAPACITYLEGALITY-BOUNDARY-001","source":"asl/tile/model/legality/allocation-capacity.asl","requirements":[],"kind":"boundary","summary":"Covers Tile Capacity Legality.","pass_condition":"TestTileCapacityLegality completes without assertion failure","related_sources":[]}
func TestTileCapacityLegality()
begin
    ResetProfileState();
    _SystemRegisters.tile_capacity = Zeros{PTO_XLEN} + 768;
    assert IsNonzeroPowerOfTwo(1);
    assert IsNonzeroPowerOfTwo(2);
    assert IsNonzeroPowerOfTwo(4);
    assert IsNonzeroPowerOfTwo(8);
    assert IsNonzeroPowerOfTwo(16);
    assert !IsNonzeroPowerOfTwo(0);
    assert !IsNonzeroPowerOfTwo(3);
    assert !IsNonzeroPowerOfTwo(6);
    assert !IsNonzeroPowerOfTwo(12);

    assert DerivedTileRows(128, 1, TileDataType_U64) == 16;
    assert DerivedTileRows(128, 2, TileDataType_U64) == 8;
    assert DerivedTileRows(128, 4, TileDataType_U64) == 4;
    assert DerivedTileRows(128, 8, TileDataType_U64) == 2;
    assert DerivedTileRows(128, 16, TileDataType_U64) == 1;
    assert DerivedTileRows(128, 32, TileDataType_U64) == 0;
    assert DerivedTileRows(128, 1, TileDataType_U4X2) == 256;
    assert DerivedTileRows(256, 1, TileDataType_U64) == 32;
    assert DerivedTileRows(512, 1, TileDataType_U64) == 64;
    assert DerivedTileRows(1024, 1, TileDataType_U64) == 128;
    assert DerivedTileRows(2048, 1, TileDataType_U64) == 256;
    assert DerivedTileRows(4096, 1, TileDataType_U64) == 512;
    assert DerivedTileRows(8192, 1, TileDataType_U64) == 1024;
    assert DerivedTileRows(8192, 1, TileDataType_U4X2) == 16384;
    assert TileShapeMatchesCapacity(128, 16, 1, TileDataType_U64);
    assert TileShapeMatchesCapacity(8192, 16384, 1,
                                    TileDataType_U4X2);
    assert !TileShapeMatchesCapacity(128, 15, 1, TileDataType_U64);
    assert !TileShapeMatchesCapacity(128, 16, 3, TileDataType_U64);

    assert TileSizeCodeBytes(1) == 128;
    assert TileSizeCodeBytes(2) == 256;
    assert TileSizeCodeBytes(3) == 512;
    assert TileSizeCodeBytes(4) == 1024;
    assert TileSizeCodeBytes(5) == 2048;
    assert TileSizeCodeBytes(6) == 4096;
    assert TileSizeCodeBytes(7) == 8192;
    assert !TileCapacityIsLegal(0);
    assert !TileCapacityIsLegal(255);
    assert TileCapacityIsLegal(256);
    assert !TileStorageFitsCapacity(33, 1, TileDataType_U64, 256);
    assert TileStorageFitsCapacity(32, 1, TileDataType_U64, 256);
    // Capacity covers the complete allocated shape. A smaller valid region
    // limits observable elements but cannot make a larger shape fit.
    assert !TileStorageFitsCapacity(64, 1, TileDataType_U64, 256);
    assert TileStorageFitsCapacity(64, 1, TileDataType_U64, 512);
    ConfigureTile(19, 512, 64, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    assert _Tiles[[19]].capacity_bytes == 512;
    assert _Tiles[[19]].rows == 64 && _Tiles[[19]].valid_rows == 1;
    ReleaseTile(19);

    ConfigureTile(20, 256, 32, 1, 32, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(21, 256, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(20, 512, 1, 1, 1, 1, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    assert TileCapacityInUseExcept(63) == 768;
    // SYSREG-EFFECT-WITNESS tile-capacity-profile-limit/limits-per-tile-and-aggregate-allocation
    assert TileCapacityInUseExcept(22) + 256 > TileCapacityLimitBytes();
    assert !_Tiles[[22]].allocated;
    assert _Tiles[[20]].capacity_bytes == 512;
    assert _Tiles[[21]].capacity_bytes == 256;

    ReleaseTile(20);
    assert TileCapacityInUseExcept(63) == 256;
    ResetProfileState();
end;
func main() => integer
begin
    ResetProfileState();
    TestTileCapacityLegality();
    return 0;
end;
