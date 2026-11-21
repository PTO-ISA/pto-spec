import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import test from 'node:test';
import path from 'node:path';
import {projectManualAsl} from './manualAsl.ts';

const repositoryRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  '../../../..',
);
const traceability = JSON.parse(readFileSync(
  path.join(repositoryRoot, 'spec/evidence/release-traceability-readiness.json'),
  'utf8',
)) as {units: Array<{id: string; mnemonic: string | null; source: string}>};

test('every mnemonic page projects exact owner-backed ASL functions', () => {
  const commit = '0123456789abcdef0123456789abcdef01234567';
  const mnemonicUnits = traceability.units.filter((unit) => unit.mnemonic !== null);
  assert.ok(mnemonicUnits.length > 600);

  for (const unit of mnemonicUnits) {
    const projection = projectManualAsl(
      repositoryRoot,
      {commit},
      unit.id,
      unit.source,
    );
    assert.equal(projection.owner, unit.id);
    assert.equal(projection.status, 'complete', `${unit.id} must have complete DOC regions`);
    assert.deepEqual(projection.missingSymbols, []);
    assert.ok(projection.functions.some((region) => region.phase === 'decode'));
    assert.ok(projection.functions.some((region) => region.phase === 'operation'));
    for (const region of projection.functions) {
      assert.match(region.text, new RegExp(`func ${region.symbol}\\b`));
      assert.equal(region.text.trimEnd().split('\n').at(-1)?.trim(), 'end;');
      if (region.role === 'owner') assert.equal(region.sourcePath, unit.source);
      assert.match(region.sourceUrl, new RegExp(
        `^https://github\\.com/PTO-ISA/pto-spec/blob/${commit}/asl/.+#L\\d+-L\\d+$`,
      ));
      assert.equal(region.sourceSha256.length, 64);
      assert.equal(region.fragmentSha256.length, 64);
      assert.equal(
        region.sourceAssetUrl,
        `/evidence/asl-fragments/${region.fragmentSha256}.asl`,
      );
      assert.ok(region.endLine >= region.startLine);
    }
    for (const reference of projection.references) {
      assert.equal(reference.fragmentSha256.length, 64);
      assert.equal(
        reference.sourceAssetUrl,
        `/evidence/asl-fragments/${reference.fragmentSha256}.asl`,
      );
      assert.ok(reference.text?.includes(`func ${reference.symbol}`));
      assert.equal(reference.text?.trimEnd().split('\n').at(-1)?.trim(), 'end;');
    }
  }
});

test('floating fused pages include the exact dispatcher-selected execution', () => {
  const commit = '0123456789abcdef0123456789abcdef01234567';
  for (const mnemonic of ['FMADD', 'FMSUB', 'FNMADD', 'FNMSUB']) {
    const unit = traceability.units.find((candidate) => candidate.mnemonic === mnemonic);
    assert.ok(unit, `${mnemonic} unit must exist`);
    const projection = projectManualAsl(repositoryRoot, {commit}, unit.id, unit.source);
    const shared = projection.functions.filter((definition) => definition.role === 'shared');
    assert.equal(shared.length, 1, `${mnemonic} must project one exact shared execution`);
    assert.equal(shared[0].symbol, 'ExecuteFPMulAdd');
    assert.match(shared[0].text, /FPMulAdd/);
    assert.ok(projection.references.some((reference) =>
      reference.symbol === 'FPMulAdd',
    ));
  }
});
