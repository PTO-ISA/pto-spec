<!-- GENERATED FROM: asl/block/model/operands/tile-bindings.asl -->
# Tile Bindings

**Normative ASL source:** `asl/block/model/operands/tile-bindings.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/tile-bindings.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","surface":"block","classification":["model","operands","tile-bindings"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS"]}
func SetBundleTileBinding(index: BundleTileBindingIndex,
                         destination_valid: boolean,
                         destination: TileIndex,
                         destination_size: integer {0..15},
                         pe_mask: bits(4),
                         source0_valid: boolean,
                         source1_valid: boolean,
                         source0: TileIndex,
                         source1: TileIndex,
                         last: boolean)
begin
    if destination_valid &&
       (destination > 3 || !TileSizeCodeIsLegal(destination_size)) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    _BundleTileBindings[[index]].valid = TRUE;
    _BundleTileBindings[[index]].destination_valid = destination_valid;
    _BundleTileBindings[[index]].destination = destination;
    _BundleTileBindings[[index]].destination_hand =
        Zeros{2} + (destination MOD 4);
    _BundleTileBindings[[index]].destination_allocated_by_bundle = FALSE;
    _BundleTileBindings[[index]].destination_size = destination_size;
    _BundleTileBindings[[index]].pe_mask = pe_mask;
    _BundleTileBindings[[index]].source0_valid = source0_valid;
    _BundleTileBindings[[index]].source1_valid = source1_valid;
    _BundleTileBindings[[index]].source0 = source0;
    _BundleTileBindings[[index]].source1 = source1;
    _BundleTileBindings[[index]].last = last;
end;

func AddBundleTileBinding(destination_valid: boolean,
                          destination: TileIndex,
                          destination_size: integer {0..15},
                          pe_mask: bits(4),
                          source0_valid: boolean,
                          source1_valid: boolean,
                          source0: TileIndex,
                          source1: TileIndex,
                          last: boolean)
begin
    var added = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !added && !_BundleTileBindings[[binding]].valid then
            SetBundleTileBinding(binding as BundleTileBindingIndex,
                destination_valid, destination, destination_size, pe_mask,
                source0_valid, source1_valid, source0, source1, last);
            added = TRUE;
        end;
    end;
    if !added then SetFault(Fault_TileLegality, ReadTPC()); end;
end;

readonly func BundleTileDestinationSizeLegal(
    binding: BundleTileBindingIndex) => boolean
begin
    if !_BundleTileBindings[[binding]].destination_valid then return TRUE; end;
    return TileSizeCodeIsLegal(
        _BundleTileBindings[[binding]].destination_size);
end;

readonly func BundleTileDestinationSizeBytes(
    binding: BundleTileBindingIndex)
    => integer {0,128,256,512,1024,2048,4096,8192}
begin
    if !_BundleTileBindings[[binding]].destination_valid then return 0; end;
    assert BundleTileDestinationSizeLegal(binding);
    return TileSizeCodeBytes(
        _BundleTileBindings[[binding]].destination_size as integer {1..7});
end;

readonly func BundleTileIsDestination(tile: TileIndex) => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           _BundleTileBindings[[binding]].destination == tile then
            return TRUE;
        end;
    end;
    return FALSE;
end;

readonly func BundleTileIsAccumulatorSource(tile: TileIndex) => boolean
begin
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMatrix ||
       !_BundleOperation.selector_valid then return FALSE; end;
    let operation = DecodeTileOperation(TileDecode_CUBE,
        BundleOperationDecodeCode(_BundleOperation));
    // ACC forms consume C as a read-only accumulator.  The decoded Stage C
    // contract requires the old C value to remain observable after a fresh D
    // is committed, so do not release the first ordered Local source.
    if operation != 99 && operation != 102 && operation != 105 &&
       operation != 108 then return FALSE; end;
    var first_source_valid = FALSE;
    var first_source: TileIndex = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 16 do
        if _BundleTileBindings[[binding]].valid then
            if !first_source_valid &&
               _BundleTileBindings[[binding]].source0_valid then
                first_source = _BundleTileBindings[[binding]].source0;
                first_source_valid = TRUE;
            elsif !first_source_valid &&
                  _BundleTileBindings[[binding]].source1_valid then
                first_source = _BundleTileBindings[[binding]].source1;
                first_source_valid = TRUE;
            end;
        end;
    end;
    return first_source_valid && first_source == tile;
end;

func CommitBundleTileSourceLifetime(binding: BundleTileBindingIndex)
begin
    if _BundleTileBindings[[binding]].source0_valid &&
       !BundleTileIsAccumulatorSource(_BundleTileBindings[[binding]].source0) &&
       !BundleTileIsDestination(_BundleTileBindings[[binding]].source0) then
        ReleaseTile(_BundleTileBindings[[binding]].source0);
    end;
    if _BundleTileBindings[[binding]].source1_valid &&
       !BundleTileIsDestination(_BundleTileBindings[[binding]].source1) &&
       (!_BundleTileBindings[[binding]].source0_valid ||
        _BundleTileBindings[[binding]].source1 !=
            _BundleTileBindings[[binding]].source0) then
        ReleaseTile(_BundleTileBindings[[binding]].source1);
    end;
end;

func FinalizeBundleTileAttempt(status: TileExecutionStatus)
begin
    if status == TileExecution_Executed then
        for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
            if _BundleTileBindings[[binding]].valid then
                CommitBundleTileSourceLifetime(
                    binding as BundleTileBindingIndex);
            end;
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
