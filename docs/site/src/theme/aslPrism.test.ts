const aslAssert = require('node:assert/strict');
const aslTest = require('node:test');
const {Prism: AslPrism} = require('prism-react-renderer');
const {registerAslPrism} = require('./aslPrism.ts');

function tokenText(token: unknown): string {
  if (typeof token === 'string') return token;
  if (Array.isArray(token)) return token.map(tokenText).join('');
  return tokenText((token as {content: unknown}).content);
}

function tokenTypes(source: string): string[] {
  function types(token: unknown): string[] {
    if (typeof token === 'string') return [];
    if (Array.isArray(token)) return token.flatMap(types);
    const prismToken = token as {type: string; content: unknown};
    return [prismToken.type, ...types(prismToken.content)];
  }
  return AslPrism.tokenize(source, AslPrism.languages.asl).flatMap(types);
}

aslTest('ASL grammar highlights structure without changing source text', () => {
  registerAslPrism();
  const source = [
    '// decoded operation',
    'readonly func DecodeADD(encoded: bits(2)) => boolean',
    'begin',
    "    let legal = encoded != '11';",
    '    return legal && TRUE;',
    'end;',
  ].join('\n');
  const tokens = AslPrism.tokenize(source, AslPrism.languages.asl);
  const flattened = tokens.map(tokenText).join('');
  const types = tokenTypes(source);

  aslAssert.equal(flattened, source);
  aslAssert.ok(types.includes('comment'));
  aslAssert.ok(types.includes('keyword'));
  aslAssert.ok(types.includes('function'));
  aslAssert.ok(types.includes('boolean'));
  aslAssert.ok(types.includes('operator'));
});
