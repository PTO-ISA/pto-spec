// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","surface":"tile","classification":["model","memory","gm-atom-red"],"depends_on":["PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION","PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS","PTO-ARCH-FEATURES-MX-FORMATS","PTO-SCALAR-MODEL-AGU-MEMORY","PTO-TILE-MODEL-MEMORY-LOAD-STORE","PTO-TILE-MODEL-MEMORY-ATOMICS","PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA"]}
// NDF-BEGIN: PTO-MGATHER-CAS-ATOMIC-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// The legacy MGATHER_CAS spelling aliases mgather.cas and MUST accept only
// U16, U32, and U64 transfer DataTypes. Each valid request MUST perform one
// atomic compare-and-swap at its signed or unsigned byte displacement and
// place the value observed by that request in the corresponding destination
// element. Duplicate-address requests MUST serialize in an implementation-
// defined order and MUST NOT expose a fixed row-major ordering requirement.
// NDF-END: PTO-MGATHER-CAS-ATOMIC-001
// NDF-BEGIN: PTO-MGATHER-CAS-PUBLICATION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// The legacy MGATHER_CAS spelling MUST preflight every valid-region read and
// write address before its first atomic effect. On success it MUST publish
// one fully defined destination whose non-valid physical elements contain the
// selected pad value.
// NDF-END: PTO-MGATHER-CAS-PUBLICATION-001
// NDF-BEGIN: PTO-ATOM-RED-ENCODING-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TLSU Functions 8 through 27 select the GM atom/red family with the fixed
// low carrier 0x11181 and mask 0x07ffffff; 28 through 31 remain reserved.
// NDF-END: PTO-ATOM-RED-ENCODING-001
// NDF-BEGIN: PTO-ATOM-RED-BODY-SCHEMA-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Atom forms bind a destination-bearing Local B.IOT; red forms bind only
// source tiles. mscatter.popc has indices only and no ValueTile.
// NDF-END: PTO-ATOM-RED-BODY-SCHEMA-001
// NDF-BEGIN: PTO-ATOM-RED-TYPE-LEGALITY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// The indexed GM atom/red operation/type matrix is explicit and excludes
// Shared sources, vectors, packed f16x2/bf16x2, and U128. These exclusions
// apply to indexed atom/red bodies; strided Atomic TSTORE has its separate
// Function 1 source-domain and dtype contract.
// NDF-END: PTO-ATOM-RED-TYPE-LEGALITY-001
// NDF-BEGIN: PTO-ATOM-RED-INC-DEC-SEMANTICS-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// INC and DEC are U32 limit operations: inc returns zero at or above the
// limit, while dec returns the limit for zero or above-limit old values.
// NDF-END: PTO-ATOM-RED-INC-DEC-SEMANTICS-001
// NDF-BEGIN: PTO-ATOM-RED-POPC-SEMANTICS-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// mscatter.popc contributes one U32 increment per valid effective GM address and
// has no ValueTile or destination.
// NDF-END: PTO-ATOM-RED-POPC-SEMANTICS-001
// NDF-BEGIN: PTO-ATOM-RED-ORDERING-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Every valid request is one intrinsic atomic event; duplicate effective
// addresses serialize in implementation-defined order and all are effective.
// All address probes complete before the first event or local publication.
// NDF-END: PTO-ATOM-RED-ORDERING-001
// NDF-BEGIN: PTO-ATOM-RED-FAULTS-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Reserved encodings fault IllegalInstruction, unsupported tuples fault
// TileLegality, malformed bundles fault BundleControl, and alignment/page
// failures are preflighted before any architectural effect.
// NDF-END: PTO-ATOM-RED-FAULTS-001

// NDF-BEGIN: PTO-GM-FLOATING-ADD-NUMERIC-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// GM FP16/BF16/FP32/FP64 ADD MUST preserve subnormal inputs and round once per
// RMW to its own dtype using RN-even with gradual-underflow results. This
// accepted issue #397 N1 amendment supersedes issue #208's FP32 GM FTZ rule.
// NaN operands or opposite infinities MUST yield the format canonical NaN;
// other infinity sums MUST retain infinity. Overflow MUST yield signed
// infinity. Minus zero plus minus zero MUST yield minus zero; other exact
// cancellation MUST yield plus zero. Narrow carriers MUST ignore high bits.
// Indexed atom.add/red.add and strided atomic TSTORE MUST share the readonly
// helper and MUST NOT introduce numeric-status writes or scalar results.
// NDF-END: PTO-GM-FLOATING-ADD-NUMERIC-001

type GMAtomicOperation of enumeration {
    GMAtomic_CAS,
    GMAtomic_EXCH,
    GMAtomic_MAX,
    GMAtomic_MIN,
    GMAtomic_ADD,
    GMAtomic_INC,
    GMAtomic_DEC,
    GMAtomic_AND,
    GMAtomic_OR,
    GMAtomic_XOR
};

type GMReductionOperation of enumeration {
    GMReduction_MAX,
    GMReduction_MIN,
    GMReduction_ADD,
    GMReduction_INC,
    GMReduction_DEC,
    GMReduction_AND,
    GMReduction_OR,
    GMReduction_XOR,
    GMReduction_POPC
};

pure func GMReductionOperationForTStoreMode(mode: bits(3))
    => GMReductionOperation
begin
    case UInt(mode) of
        when 0 => return GMReduction_ADD;
        when 1 => return GMReduction_MIN;
        when 2 => return GMReduction_MAX;
        when 3 => return GMReduction_AND;
        when 4 => return GMReduction_OR;
        when 5 => return GMReduction_XOR;
        when 6 => return GMReduction_INC;
        otherwise => return GMReduction_DEC;
    end;
end;

// One authoritative no-return reduction primitive is shared by indexed
// MSCATTER red forms and strided Atomic TSTORE. The address generators differ;
// dtype legality and per-RMW arithmetic do not.
readonly func GMReductionResult(operation: GMReductionOperation,
    data_type: TileDataType, old: Word, input: Word) => Word
begin
    // Tile payloads use XLEN carriers for every memory element.  Integer GM
    // reductions operate on the selected architectural element, so discard
    // carrier bits before interpreting either operand and keep the result in
    // that element's representation.  Signed MIN/MAX need sign-extended
    // operands; all other integer operations can use the same normalized
    // low-width bit patterns.
    let element_bytes = TileMemoryElementBytes(data_type);
    let signed = TileDataTypeIsSigned(data_type);
    let normalized_old = if signed then
        NormalizeLoadedValue(old, element_bytes, TRUE)
        else NormalizeMemoryAccessValue(old, element_bytes);
    let normalized_input = if signed then
        NormalizeLoadedValue(input, element_bytes, TRUE)
        else NormalizeMemoryAccessValue(input, element_bytes);
    case operation of
        when GMReduction_ADD =>
            if TileDataTypeIsFloating(data_type) then
                return GMFloatingAddPTX(data_type, old, input);
            end;
            return NormalizeMemoryAccessValue(
                normalized_old + normalized_input, element_bytes);
        when GMReduction_INC =>
            return NormalizeMemoryAccessValue(
                GMIncValue(normalized_old, normalized_input), element_bytes);
        when GMReduction_DEC =>
            return NormalizeMemoryAccessValue(
                GMDecValue(normalized_old, normalized_input), element_bytes);
        when GMReduction_AND =>
            return NormalizeMemoryAccessValue(
                normalized_old AND normalized_input, element_bytes);
        when GMReduction_OR =>
            return NormalizeMemoryAccessValue(
                normalized_old OR normalized_input, element_bytes);
        when GMReduction_XOR =>
            return NormalizeMemoryAccessValue(
                normalized_old XOR normalized_input, element_bytes);
        when GMReduction_MAX =>
            if signed then
                if SInt(normalized_old) > SInt(normalized_input) then
                    return NormalizeMemoryAccessValue(
                        normalized_old, element_bytes);
                else
                    return NormalizeMemoryAccessValue(
                        normalized_input, element_bytes);
                end;
            end;
            if UInt(normalized_old) > UInt(normalized_input) then
                return NormalizeMemoryAccessValue(normalized_old, element_bytes);
            else
                return NormalizeMemoryAccessValue(normalized_input, element_bytes);
            end;
        when GMReduction_MIN =>
            if signed then
                if SInt(normalized_old) < SInt(normalized_input) then
                    return NormalizeMemoryAccessValue(
                        normalized_old, element_bytes);
                else
                    return NormalizeMemoryAccessValue(
                        normalized_input, element_bytes);
                end;
            end;
            if UInt(normalized_old) < UInt(normalized_input) then
                return NormalizeMemoryAccessValue(normalized_old, element_bytes);
            else
                return NormalizeMemoryAccessValue(normalized_input, element_bytes);
            end;
        otherwise => return old;
    end;
end;

pure func GMAtomicOperationDataTypeLegal(
    operation: GMAtomicOperation, data_type: TileDataType) => boolean
begin
    case operation of
        when GMAtomic_CAS =>
            return data_type == TileDataType_U16 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_EXCH =>
            return data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_ADD =>
            return data_type == TileDataType_FP16 ||
                   data_type == TileDataType_BF16 ||
                   data_type == TileDataType_FP32 ||
                   data_type == TileDataType_FP64 ||
                   data_type == TileDataType_S32 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_INC, GMAtomic_DEC => return data_type == TileDataType_U32;
        when GMAtomic_MAX, GMAtomic_MIN =>
            return data_type == TileDataType_S32 ||
                   data_type == TileDataType_S64 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMAtomic_AND, GMAtomic_OR, GMAtomic_XOR =>
            return data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
    end;
end;

pure func GMReductionOperationDataTypeLegal(
    operation: GMReductionOperation, data_type: TileDataType) => boolean
begin
    case operation of
        when GMReduction_POPC => return data_type == TileDataType_U32;
        when GMReduction_INC, GMReduction_DEC => return data_type == TileDataType_U32;
        when GMReduction_ADD =>
            return data_type == TileDataType_FP16 ||
                   data_type == TileDataType_BF16 ||
                   data_type == TileDataType_FP32 ||
                   data_type == TileDataType_FP64 ||
                   data_type == TileDataType_S32 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMReduction_MAX, GMReduction_MIN =>
            return data_type == TileDataType_S32 ||
                   data_type == TileDataType_S64 ||
                   data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
        when GMReduction_AND, GMReduction_OR, GMReduction_XOR =>
            return data_type == TileDataType_U32 ||
                   data_type == TileDataType_U64;
    end;
end;

pure func GMIncValue(old: Word, limit: Word) => Word
begin
    if UInt(old) >= UInt(limit) then return Zeros{PTO_XLEN}; end;
    return old + Zeros{PTO_XLEN} + 1;
end;

pure func GMDecValue(old: Word, limit: Word) => Word
begin
    if UInt(old) == 0 || UInt(old) > UInt(limit) then return limit; end;
    return old - (Zeros{PTO_XLEN} + 1);
end;

// Build exact powers for FP64 exponent alignment without host floating point.
pure func GMFloatingAddPowerOfTwo(exponent: integer {0..2100}) => integer
begin
    var result: integer = 1;
    var remaining = exponent;
    var factor: integer = 2;
    while remaining > 0 looplimit 12 do
        if remaining MOD 2 == 1 then result = result * factor; end;
        factor = factor * factor;
        remaining = (remaining DIVRM 2) as integer {0..2100};
    end;
    return result;
end;

readonly func GMFloatingAddPTX(data_type: TileDataType, old: Word,
                             value: Word) => Word
begin
    assert data_type == TileDataType_FP64 || data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 || data_type == TileDataType_BF16;
    let descriptor = TileNumericFormatDescriptor(data_type);
    let fraction_bits = descriptor.fraction_bits_min;
    let bias = descriptor.exponent_bias;
    let minimum_exponent = 1 - bias;
    let maximum_exponent = bias;
    let hidden = GMFloatingAddPowerOfTwo(fraction_bits as integer {0..2100});
    let infinity = hidden * (2 * bias + 1);
    let sign_bit = GMFloatingAddPowerOfTwo(descriptor.sign_bit as integer {0..2100});
    let left = TileRawElementValue(old, data_type);
    let right = TileRawElementValue(value, data_type);
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    if NumericValueClassIsNaN(left_class) || NumericValueClassIsNaN(right_class) then
        let (available, nan) = TileNumericCanonicalNaN(data_type);
        assert available;
        return nan;
    end;
    let left_negative = left[descriptor.sign_bit] == '1';
    let right_negative = right[descriptor.sign_bit] == '1';
    let left_infinite = NumericValueClassIsInfinity(left_class);
    let right_infinite = NumericValueClassIsInfinity(right_class);
    if left_infinite && right_infinite && left_negative != right_negative then
        let (available, nan) = TileNumericCanonicalNaN(data_type);
        assert available;
        return nan;
    elsif left_infinite then return left;
    elsif right_infinite then return right;
    end;
    let (left_valid, -, left_significand, left_exponent) =
        TileNumericFiniteDecomposition(data_type, left);
    let (right_valid, -, right_significand, right_exponent) =
        TileNumericFiniteDecomposition(data_type, right);
    assert left_valid && right_valid;
    let common_exponent = if left_exponent < right_exponent then
        left_exponent else right_exponent;
    let left_integer = UInt(left_significand) * GMFloatingAddPowerOfTwo(
        (left_exponent - common_exponent) as integer {0..2100});
    let right_integer = UInt(right_significand) * GMFloatingAddPowerOfTwo(
        (right_exponent - common_exponent) as integer {0..2100});
    let exact = (if left_negative then -left_integer else left_integer) +
                (if right_negative then -right_integer else right_integer);
    if exact == 0 then
        if left_integer == 0 && right_integer == 0 && left_negative && right_negative then
            return Zeros{PTO_XLEN} + sign_bit;
        end;
        return Zeros{PTO_XLEN};
    end;
    let negative = exact < 0;
    let magnitude = if negative then -exact else exact;
    let sign = if negative then sign_bit else 0;
    var scaled = magnitude;
    var bit_count: integer {0..2101} = 0;
    while scaled > 0 looplimit 2101 do
        scaled = scaled DIVRM 2;
        bit_count = (bit_count + 1) as integer {0..2101};
    end;
    let exact_exponent = (common_exponent + bit_count) - 1;
    let quantum = if exact_exponent < minimum_exponent then
        minimum_exponent - fraction_bits else exact_exponent - fraction_bits;
    let shift = quantum - common_exponent;
    var rounded: integer = magnitude;
    if shift > 0 then
        let divisor = GMFloatingAddPowerOfTwo(shift as integer {0..2100});
        rounded = magnitude DIVRM divisor;
        let remainder = magnitude MOD divisor;
        if 2 * remainder > divisor ||
           (2 * remainder == divisor && rounded MOD 2 == 1) then
            rounded = rounded + 1;
        end;
    elsif shift < 0 then
        rounded = magnitude * GMFloatingAddPowerOfTwo((-shift) as integer {0..2100});
    end;
    if rounded < hidden then return Zeros{PTO_XLEN} + sign + rounded; end;
    var result_exponent: integer = quantum + fraction_bits;
    if rounded >= 2 * hidden then
        rounded = rounded DIVRM 2;
        result_exponent = result_exponent + 1;
    end;
    if result_exponent > maximum_exponent then
        return Zeros{PTO_XLEN} + sign + infinity;
    end;
    return Zeros{PTO_XLEN} + sign +
        (result_exponent + bias) * hidden + (rounded - hidden);
end;

func GMAtomicResult(operation: GMAtomicOperation,
                         data_type: TileDataType, old: Word,
                         value: Word, expected: Word,
                         replacement: Word) => (Word, boolean)
begin
    case operation of
        when GMAtomic_CAS =>
            let matched = GMRawElementValue(old, data_type) ==
                GMRawElementValue(expected, data_type);
            if matched then return (GMRawElementValue(replacement, data_type), TRUE); end;
            return (old, FALSE);
        when GMAtomic_EXCH => return (GMRawElementValue(value, data_type), TRUE);
        when GMAtomic_ADD =>
            if TileDataTypeIsFloating(data_type) then
                return (GMFloatingAddPTX(data_type, old, value), TRUE);
            end;
            return (GMRawElementValue(old, data_type) +
                    GMRawElementValue(value, data_type), TRUE);
        when GMAtomic_INC => return (GMIncValue(old, value), TRUE);
        when GMAtomic_DEC => return (GMDecValue(old, value), TRUE);
        when GMAtomic_AND => return (old AND value, TRUE);
        when GMAtomic_OR => return (old OR value, TRUE);
        when GMAtomic_XOR => return (old XOR value, TRUE);
        when GMAtomic_MAX =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) > SInt(value) then return (old, TRUE); else return (value, TRUE); end;
            end;
            if UInt(old) > UInt(value) then return (old, TRUE); else return (value, TRUE); end;
        when GMAtomic_MIN =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) < SInt(value) then return (old, TRUE); else return (value, TRUE); end;
            end;
            if UInt(old) < UInt(value) then return (old, TRUE); else return (value, TRUE); end;
    end;
end;

pure func GMRawElementValue(value: Word, data_type: TileDataType) => Word
begin
    return TileRawElementValue(value, data_type);
end;

readonly func TileOperandsLegal_GM_ATOM_CAS(
    operation: GMAtomicOperation, destination: TileIndex, base_address: Word, indices: TileIndex,
    expected: TileIndex, replacement: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    let data_type = _Tiles[[destination]].data_type;
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(expected) &&
           IndexedTLSUExecutionMaskContentsDefined(replacement) &&
           GMAtomicOperationDataTypeLegal(operation, data_type) &&
           _Tiles[[expected]].data_type == data_type &&
           _Tiles[[replacement]].data_type == data_type &&
           _Tiles[[destination]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[indices]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[expected]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[expected]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[replacement]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[replacement]].valid_columns &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[expected]].layout &&
           _Tiles[[destination]].layout == _Tiles[[replacement]].layout;
end;

readonly func TileOperandsLegal_GM_ATOM_VALUE(
    operation: GMAtomicOperation, destination: TileIndex, base_address: Word, indices: TileIndex,
    value: TileIndex, pad_value: TilePadValue) => boolean
begin
    let data_type = _Tiles[[destination]].data_type;
    return IndexedTLSUNumericDescriptorLegal(destination) &&
           IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(value) &&
           GMAtomicOperationDataTypeLegal(operation, data_type) &&
           _Tiles[[value]].data_type == data_type &&
           _Tiles[[destination]].valid_rows == _Tiles[[indices]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[indices]].valid_columns &&
           _Tiles[[destination]].valid_rows == _Tiles[[value]].valid_rows &&
           _Tiles[[destination]].valid_columns == _Tiles[[value]].valid_columns &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           _Tiles[[destination]].layout == _Tiles[[indices]].layout &&
           _Tiles[[destination]].layout == _Tiles[[value]].layout;
end;

readonly func TileOperandsLegal_GM_RED_VALUE(
    operation: GMReductionOperation, base_address: Word, indices: TileIndex, value: TileIndex,
    pad_value: TilePadValue) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUExecutionMaskContentsDefined(value) &&
           GMReductionOperationDataTypeLegal(
               operation, _Tiles[[value]].data_type) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type) &&
           _Tiles[[indices]].valid_rows == _Tiles[[value]].valid_rows &&
           _Tiles[[indices]].valid_columns == _Tiles[[value]].valid_columns &&
           _Tiles[[indices]].layout == _Tiles[[value]].layout;
end;

readonly func TileOperandsLegal_GM_RED_POPC(
    operation: GMReductionOperation, base_address: Word, indices: TileIndex) => boolean
begin
    return IndexedTLSUExecutionMaskContentsDefined(indices) &&
           IndexedTLSUMemoryIndexDataTypeLegal(
               _Tiles[[indices]].data_type);
end;
