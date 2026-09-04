const assert = require('node:assert/strict');
const {readFileSync} = require('node:fs');
const {resolve} = require('node:path');
const test = require('node:test');
const {
  formatFixedValue,
  formatConstantToken,
  parseEncodingForm,
} = require('./encodingModel.ts');

function catalogForms(): Record<string, unknown>[] {
  return ['command-forms.json', 'scalar-forms.json'].flatMap((name) => {
    const path = resolve(process.cwd(), '../../spec/catalog', name);
    const catalog = JSON.parse(readFileSync(path, 'utf8')) as {forms: Record<string, unknown>[]};
    return catalog.forms;
  });
}

function range(bits: string): {lsb: number; msb: number} {
  const [first, second] = bits.split(':').map(Number);
  return {msb: first, lsb: second ?? first};
}

test('all released catalog encodings have exact exhaustive WaveDrom segments', () => {
  const forms = catalogForms();
  assert.equal(forms.length, 561);
  const lengthCounts = new Map<number, number>();
  let encodingWordCount = 0;
  let multiwordCount = 0;

  for (const form of forms) {
    const words = parseEncodingForm(form);
    const totalWidth = form.length_bits as number;
    lengthCounts.set(totalWidth, (lengthCounts.get(totalWidth) ?? 0) + 1);
    encodingWordCount += words.length;
    if (words.length > 1) multiwordCount += 1;
    assert.equal(words.reduce((sum: number, word: {width: number}) => sum + word.width, 0), totalWidth);

    let expectedOffset = 0;
    for (const [wordPosition, word] of words.entries()) {
      assert.equal(word.index, wordPosition);
      assert.equal(word.offset, expectedOffset);
      expectedOffset += word.width;
      assert.equal(word.fields.reduce((sum: number, segment: {width: number}) => sum + segment.width, 0), word.width);
      const covered = new Set<number>();
      for (const segment of word.fields) {
        const {lsb, msb} = range(segment.bits);
        assert.equal(msb - lsb + 1, segment.width);
        const localLsb = lsb - word.offset;
        assert.ok(localLsb >= 0 && msb < word.offset + word.width);
        for (let bit = lsb; bit <= msb; bit += 1) {
          assert.equal(covered.has(bit), false, `duplicate segment coverage at bit ${bit}`);
          covered.add(bit);
          const fixed = (word.mask & (1n << BigInt(bit - word.offset))) !== 0n;
          assert.equal(segment.fixed, fixed, `${String(form.form_id)} bit ${bit} fixed status`);
        }
        if (segment.fixed) {
          assert.equal(segment.value, formatFixedValue(word.match, localLsb, segment.width));
        } else {
          assert.equal(segment.value, undefined);
        }
      }
      assert.equal(covered.size, word.width);
    }

    const segments = words.flatMap((word: {fields: unknown[]}) => word.fields);
    for (const field of form.fields as Array<Record<string, unknown>>) {
      for (const piece of field.pieces as Array<Record<string, number>>) {
        for (let bit = piece.instruction_lsb; bit < piece.instruction_lsb + piece.width; bit += 1) {
          const owner = segments.find((segment: {bits: string; fieldName?: string}) => {
            const {lsb, msb} = range(segment.bits);
            return bit >= lsb && bit <= msb && segment.fieldName === field.name;
          });
          assert.ok(owner, `${String(form.form_id)} ${String(field.name)} must own instruction bit ${bit}`);
        }
      }
    }
  }

  assert.equal(encodingWordCount, 562);
  assert.equal(multiwordCount, 1);
  assert.deepEqual(Object.fromEntries(lengthCounts), {16: 34, 32: 336, 48: 190, 64: 1});
});

test('B.FPATR retains names for mask-fixed operand pieces', () => {
  const form = catalogForms().find((candidate) => candidate.mnemonic === 'B.FPATR');
  assert.ok(form);
  const segments = parseEncodingForm(form).flatMap((word: {fields: unknown[]}) => word.fields);
  for (const expected of [
    {fieldName: 'Func', bits: '14:12', value: '0b010'},
    {fieldName: 'Opc1', bits: '6:4', value: '0b010'},
    {fieldName: 'Opcode', bits: '3:1', value: '0b001'},
    {fieldName: 'W', bits: '0', value: '1'},
  ]) {
    assert.ok(
      segments.some((segment: Record<string, unknown>) =>
        segment.fieldName === expected.fieldName &&
        segment.name === expected.fieldName &&
        segment.bits === expected.bits &&
        segment.fixed === true &&
        segment.value === expected.value),
      `${expected.fieldName} must remain named and expose ${expected.value}`,
    );
  }
});

test('unnamed fixed selectors render their concrete bit pattern', () => {
  const form = catalogForms().find((candidate) => candidate.mnemonic === 'ADD');
  assert.ok(form);
  const segments = parseEncodingForm(form).flatMap((word: {fields: unknown[]}) => word.fields);
  const fixedSelectors = segments.filter(
    (segment: {fixed: boolean; fieldName?: string}) => segment.fixed && !segment.fieldName,
  );
  assert.ok(fixedSelectors.length > 0);
  for (const segment of fixedSelectors as Array<{name: string; width: number; bits: string}>) {
    const {lsb} = range(segment.bits);
    assert.equal(segment.name, formatConstantToken(BigInt(form.encoding[0].match), lsb, segment.width));
    assert.match(segment.name, segment.width === 1 ? /^[01]$/ : /^\d+'b[01]+$/);
  }
});

test('scaled immediates may leave source-defined value bits implicit', () => {
  const forms = catalogForms();
  for (const mnemonic of ['FENTRY', 'FEXIT', 'FRET.RA', 'FRET.STK']) {
    const form = forms.find((candidate) => candidate.mnemonic === mnemonic);
    assert.ok(form, `${mnemonic} form`);
    const uimmSegments = parseEncodingForm(form)
      .flatMap((word: {fields: unknown[]}) => word.fields)
      .filter((segment: {fieldName?: string}) => segment.fieldName === 'uimm');
    assert.deepEqual(
      uimmSegments.map((segment: {bits: string}) => segment.bits).sort(),
      ['11:7', '31:25'],
      `${mnemonic} must retain both encoded uimm pieces while value bits 2:0 remain implicit`,
    );
  }
});

test('malformed catalog numeric and structural values fail closed', () => {
  const source = catalogForms().find((candidate) => candidate.mnemonic === 'B.FPATR');
  assert.ok(source);
  const malformed: Array<[string, (form: Record<string, any>) => void]> = [
    ['string index', (form) => { form.encoding[0].index = '0'; }],
    ['non-contiguous index', (form) => { form.encoding[0].index = 1; }],
    ['string width', (form) => { form.encoding[0].width_bits = '32'; }],
    ['zero width', (form) => { form.encoding[0].width_bits = 0; }],
    ['numeric mask', (form) => { form.encoding[0].mask = 0x7c7f; }],
    ['invalid match', (form) => { form.encoding[0].match = '0x20_23'; }],
    ['mask outside width', (form) => { form.encoding[0].mask = '0x100000000'; }],
    ['match outside mask', (form) => { form.encoding[0].match = '0x00008023'; }],
    ['zero total width', (form) => { form.length_bits = 0; }],
    ['total width mismatch', (form) => { form.length_bits = 31; }],
    ['string piece offset', (form) => { form.fields[0].pieces[0].instruction_lsb = '26'; }],
    ['string field width', (form) => { form.fields[0].width = '6'; }],
    ['piece outside instruction', (form) => { form.fields[0].pieces[0].instruction_lsb = 31; }],
    ['zero piece width', (form) => { form.fields[0].pieces[0].width = 0; }],
    ['overlapping pieces', (form) => { form.fields[1].pieces[0].instruction_lsb = 26; }],
    ['piece outside field', (form) => { form.fields[0].pieces[0].value_lsb = 1; }],
  ];
  for (const [label, mutate] of malformed) {
    const form = structuredClone(source) as Record<string, any>;
    mutate(form);
    assert.throws(() => parseEncodingForm(form), undefined, label);
  }
});
