import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import test from 'node:test';

const repositoryRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  '../../../..',
);

function json(relative: string): Record<string, unknown> {
  return JSON.parse(readFileSync(path.join(repositoryRoot, relative), 'utf8')) as Record<string, unknown>;
}

test('manual catalogs retain complete scoped and TileOp inventories', () => {
  const scalar = json('spec/catalog/scalar-forms.json');
  assert.ok(Array.isArray(scalar.scoped_forms));
  assert.equal(scalar.scoped_forms.length, scalar.scoped_form_count);
  assert.ok(scalar.scoped_forms.length > 0);

  const tileOperations = json('spec/catalog/tile-operations.json').operations as Array<{name: string}>;
  const tileMacros = json('spec/catalog/tile-macro-assembly.json').operations as Array<{mnemonic: string}>;
  assert.ok(Array.isArray(tileOperations));
  assert.ok(Array.isArray(tileMacros));
  assert.deepEqual(
    new Set(tileMacros.map((operation) => operation.mnemonic)),
    new Set(tileOperations.map((operation) => operation.name)),
  );
});
