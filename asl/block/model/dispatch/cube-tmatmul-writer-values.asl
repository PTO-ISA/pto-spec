// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL-WRITER-VALUES","surface":"block","classification":["model","dispatch","cube-tmatmul-writer-values"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE-WRITER-EFFECTS","PTO-TILE-MODEL-EXECUTION-CUBE","PTO-TILE-MODEL-EXECUTION-CUBE-VALUE","PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR","PTO-TILE-MODEL-STATE-TYPES","PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS"]}

func ExecuteBundleTMATMULWriterValues(
    input_writer_effects: BundleLocalGenerationCubeWriterEffects,
    function: integer {0..31}, partial_output: boolean,
    accumulator: TileIndex, left: TileInfo, left_scale: TileInfo,
    left_scale_present: boolean, right: TileInfo, right_scale: TileInfo,
    right_scale_present: boolean, bias: TileIndex, c_scale: TileIndex,
    c_scale_present: boolean, cctrl_first: boolean)
    => (BundleLocalGenerationCubeWriterEffects, TileInfo, TileInfo, TileInfo,
        boolean, boolean, boolean)
begin
    var writer_effects = input_writer_effects;
    let destination = BundleMatrixDestinationAt(0);
    let row_destination = BundleMatrixDestinationAt(1);
    let group_destination = if _BundleFixedPointAttributes.row_max_en then
        BundleMatrixDestinationAt(2) else BundleMatrixDestinationAt(1);
    let (primary_writer_found, primary_writer_value) =
        BundleLocalGenerationCubeWriterValueForDestination(
            writer_effects, destination, _Tiles[[destination]]);
    let (row_writer_found, row_writer_value) =
        if _BundleFixedPointAttributes.row_max_en then
            BundleLocalGenerationCubeWriterValueForDestination(
                writer_effects, row_destination, _Tiles[[row_destination]])
        else (FALSE, _Tiles[[row_destination]]);
    let (group_writer_found, group_writer_value) =
        if _BundleFixedPointAttributes.group_max_en then
            BundleLocalGenerationCubeWriterValueForDestination(
                writer_effects, group_destination,
                _Tiles[[group_destination]])
        else (FALSE, _Tiles[[group_destination]]);
    let primary_target = TileOutputValueTarget {
        destination = destination,
        value = primary_writer_value
    };
    let row_target = TileOutputValueTarget {
        destination = row_destination,
        value = row_writer_value
    };
    let group_target = TileOutputValueTarget {
        destination = group_destination,
        value = group_writer_value
    };
    var primary_result = primary_target.value;
    var row_result = row_target.value;
    var group_result = group_target.value;
    if writer_effects.count != 0 then
        if TileMatrixFunctionUsesMX(function) then
            (primary_result, row_result, group_result) =
                TMATMULMXSharedWithOptionalScalesToValues(
                    destination, primary_target, row_target, group_target,
                    accumulator, left, left_scale, left_scale_present,
                    right, right_scale, right_scale_present, bias,
                    TileMatrixFunctionUsesBias(function),
                    TileMatrixFunctionUsesAccumulator(function),
                    c_scale, c_scale_present, partial_output);
        else
            (primary_result, row_result, group_result) =
                TMATMULSharedToValues(
                    destination, primary_target, row_target, group_target,
                    accumulator, left, right, bias,
                    TileMatrixFunctionUsesBias(function),
                    TileMatrixFunctionUsesAccumulator(function),
                    c_scale, c_scale_present, partial_output);
        end;
        if primary_writer_found then
            writer_effects = BundleLocalGenerationCubeWriterEffectWithOutput(
                writer_effects, destination, primary_result);
        end;
        if _BundleFixedPointAttributes.row_max_en && row_writer_found then
            writer_effects = BundleLocalGenerationCubeWriterEffectWithOutput(
                writer_effects, row_destination, row_result);
        end;
        if _BundleFixedPointAttributes.group_max_en && group_writer_found then
            writer_effects = BundleLocalGenerationCubeWriterEffectWithOutput(
                writer_effects, group_destination, group_result);
        end;
    else
        if TileMatrixFunctionUsesMX(function) then
            TMATMULMXSharedWithOptionalScales(
                destination, _Tiles[[destination]], accumulator,
                left, left_scale, left_scale_present,
                right, right_scale, right_scale_present,
                bias, TileMatrixFunctionUsesBias(function),
                TileMatrixFunctionUsesAccumulator(function),
                c_scale, c_scale_present, cctrl_first);
        else
            TMATMULShared(destination, _Tiles[[destination]], accumulator,
                left, right, bias, TileMatrixFunctionUsesBias(function),
                TileMatrixFunctionUsesAccumulator(function),
                c_scale, c_scale_present, cctrl_first);
        end;
    end;
    return (writer_effects, primary_result, row_result, group_result,
        primary_writer_found, row_writer_found, group_writer_found);
end;
