export interface EncodingSegment {
  bits: string;
  fieldName?: string;
  fixed: boolean;
  kind: 'field' | 'constant' | 'unspecified';
  name: string;
  pieceId?: string;
  value?: string;
  width: number;
}

export interface EncodingWordModel {
  fields: EncodingSegment[];
  index: number;
  mask: bigint;
  match: bigint;
  offset: number;
  width: number;
}

interface FieldBit {
  fieldName: string;
  pieceId: string;
}

function object(value: unknown, path: string): Record<string, unknown> {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new TypeError(`${path} must be an object`);
  }
  return value as Record<string, unknown>;
}

function array(value: unknown, path: string): unknown[] {
  if (!Array.isArray(value)) throw new TypeError(`${path} must be an array`);
  return value;
}

function integer(value: unknown, path: string, {positive = false} = {}): number {
  if (typeof value !== 'number' || !Number.isSafeInteger(value) || value < (positive ? 1 : 0)) {
    throw new TypeError(`${path} must be ${positive ? 'a positive' : 'a non-negative'} safe integer`);
  }
  return value;
}

function nonEmptyString(value: unknown, path: string): string {
  if (typeof value !== 'string' || value.length === 0 || value.trim() !== value) {
    throw new TypeError(`${path} must be a non-empty exact string`);
  }
  return value;
}

function hex(value: unknown, path: string): bigint {
  if (typeof value !== 'string' || !/^0x[0-9a-fA-F]+$/.test(value)) {
    throw new TypeError(`${path} must be an exact 0x-prefixed hexadecimal string`);
  }
  return BigInt(value);
}

function bitRange(msb: number, lsb: number): string {
  return msb === lsb ? String(lsb) : `${msb}:${lsb}`;
}

export function formatFixedValue(match: bigint, localLsb: number, width: number): string {
  const value = (match >> BigInt(localLsb)) & ((1n << BigInt(width)) - 1n);
  if (width === 1) return String(value);
  if (width <= 4) return `0b${value.toString(2).padStart(width, '0')}`;
  return `0x${value.toString(16).padStart(Math.ceil(width / 4), '0')}`;
}

export function formatFixedBits(match: bigint, localLsb: number, width: number): string {
  const value = (match >> BigInt(localLsb)) & ((1n << BigInt(width)) - 1n);
  return value.toString(2).padStart(width, '0');
}

export function formatConstantToken(match: bigint, localLsb: number, width: number): string {
  const bits = formatFixedBits(match, localLsb, width);
  return width === 1 ? bits : `${width}'b${bits}`;
}

export function parseEncodingForm(formValue: unknown): EncodingWordModel[] {
  const form = object(formValue, 'form');
  const totalWidth = integer(form.length_bits, 'form.length_bits', {positive: true});
  const encodings = array(form.encoding, 'form.encoding');
  if (encodings.length === 0) throw new TypeError('form.encoding must not be empty');

  let offset = 0;
  const words = encodings.map((encodingValue, position) => {
    const encoding = object(encodingValue, `form.encoding[${position}]`);
    const index = integer(encoding.index, `form.encoding[${position}].index`);
    if (index !== position) {
      throw new RangeError(`form.encoding indices must be sorted and contiguous; expected ${position}, got ${index}`);
    }
    const width = integer(
      encoding.width_bits,
      `form.encoding[${position}].width_bits`,
      {positive: true},
    );
    const mask = hex(encoding.mask, `form.encoding[${position}].mask`);
    const match = hex(encoding.match, `form.encoding[${position}].match`);
    const wordLimit = 1n << BigInt(width);
    if (mask >= wordLimit || match >= wordLimit) {
      throw new RangeError(`form.encoding[${position}] mask and match must fit ${width} bits`);
    }
    if ((match & ~mask) !== 0n) {
      throw new RangeError(`form.encoding[${position}].match sets bits outside its mask`);
    }
    const word = {index, mask, match, offset, width};
    offset += width;
    if (offset > totalWidth) {
      throw new RangeError('form encoding word widths exceed form.length_bits');
    }
    return word;
  });
  if (offset !== totalWidth) {
    throw new RangeError(`form encoding word widths total ${offset}, expected ${totalWidth}`);
  }

  const instructionBits = new Map<number, FieldBit>();
  const fieldNames = new Set<string>();
  array(form.fields, 'form.fields').forEach((fieldValue, fieldIndex) => {
    const field = object(fieldValue, `form.fields[${fieldIndex}]`);
    const fieldName = nonEmptyString(field.name, `form.fields[${fieldIndex}].name`);
    if (fieldNames.has(fieldName)) throw new RangeError(`duplicate field name ${fieldName}`);
    fieldNames.add(fieldName);
    const fieldWidth = integer(field.width, `form.fields[${fieldIndex}].width`, {positive: true});
    const valueBits = new Set<number>();
    const pieces = array(field.pieces, `form.fields[${fieldIndex}].pieces`);
    if (pieces.length === 0) throw new TypeError(`form.fields[${fieldIndex}].pieces must not be empty`);
    pieces.forEach((pieceValue, pieceIndex) => {
      const piece = object(pieceValue, `form.fields[${fieldIndex}].pieces[${pieceIndex}]`);
      const instructionLsb = integer(
        piece.instruction_lsb,
        `form.fields[${fieldIndex}].pieces[${pieceIndex}].instruction_lsb`,
      );
      const valueLsb = integer(
        piece.value_lsb,
        `form.fields[${fieldIndex}].pieces[${pieceIndex}].value_lsb`,
      );
      const pieceWidth = integer(
        piece.width,
        `form.fields[${fieldIndex}].pieces[${pieceIndex}].width`,
        {positive: true},
      );
      if (instructionLsb + pieceWidth > totalWidth) {
        throw new RangeError(`field ${fieldName} piece ${pieceIndex} exceeds instruction width`);
      }
      if (valueLsb + pieceWidth > fieldWidth) {
        throw new RangeError(`field ${fieldName} piece ${pieceIndex} exceeds field width`);
      }
      const pieceId = `${fieldIndex}:${pieceIndex}`;
      for (let delta = 0; delta < pieceWidth; delta += 1) {
        const instructionBit = instructionLsb + delta;
        if (instructionBits.has(instructionBit)) {
          throw new RangeError(`field pieces overlap at instruction bit ${instructionBit}`);
        }
        instructionBits.set(instructionBit, {fieldName, pieceId});
        const valueBit = valueLsb + delta;
        if (valueBits.has(valueBit)) {
          throw new RangeError(`field ${fieldName} pieces overlap at value bit ${valueBit}`);
        }
        valueBits.add(valueBit);
      }
    });
    // A declared value may contain source-defined implicit bits that have no
    // instruction piece (for example, scaled immediates with implicit zeros).
    // Present value bits must be unique and in range; exhaustive value-bit
    // coverage is intentionally not required.
  });

  return words.map((word) => {
    const identities = Array.from({length: word.width}, (_, localBit) => {
      const field = instructionBits.get(word.offset + localBit);
      const fixed = (word.mask & (1n << BigInt(localBit))) !== 0n;
      return {
        fieldName: field?.fieldName,
        fixed,
        name: field?.fieldName ?? (fixed ? 'Fixed selector' : 'Unspecified bits'),
        pieceId: field?.pieceId,
      };
    });
    const fields: EncodingSegment[] = [];
    let localMsb = word.width - 1;
    while (localMsb >= 0) {
      const identity = identities[localMsb];
      let localLsb = localMsb;
      while (
        localLsb > 0 &&
        identities[localLsb - 1].name === identity.name &&
        identities[localLsb - 1].pieceId === identity.pieceId &&
        identities[localLsb - 1].fixed === identity.fixed
      ) {
        localLsb -= 1;
      }
      const width = localMsb - localLsb + 1;
      const unnamedFixedBits = identity.fixed && !identity.fieldName
        ? formatConstantToken(word.match, localLsb, width)
        : null;
      fields.push({
        bits: bitRange(word.offset + localMsb, word.offset + localLsb),
        ...(identity.fieldName ? {fieldName: identity.fieldName} : {}),
        fixed: identity.fixed,
        kind: identity.fieldName ? 'field' : identity.fixed ? 'constant' : 'unspecified',
        name: unnamedFixedBits ?? identity.name,
        ...(identity.pieceId ? {pieceId: identity.pieceId} : {}),
        ...(identity.fixed ? {value: formatFixedValue(word.match, localLsb, width)} : {}),
        width,
      });
      localMsb = localLsb - 1;
    }
    return {...word, fields};
  });
}
