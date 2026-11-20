import {createHash} from 'node:crypto';
import {expect, test} from '@playwright/test';

test.use({javaScriptEnabled: false});

test('classification page shows ASL definitions and links to the complete source', async ({page}) => {
  await page.goto('/units/PTO-ARCH-OVERVIEW-INSTRUCTION-CLASSIFICATION/');
  const source = page.getByRole('region', {name: 'ASL pseudocode'});
  await expect(source.getByText('TileEngineHasCanonicalBundleStartAlias', {exact: true})).toBeVisible();
  await expect(source.getByText(/PTO-TILEOP-MACRO:/)).toHaveCount(0);
  const link = source.getByRole('link', {name: 'Open complete ASL and TileOp macro records'});
  await expect(link).toHaveAttribute('href', /^\/evidence\/asl-fragments\/[0-9a-f]{64}\.asl$/);
  const href = (await link.getAttribute('href'))!;
  const response = await page.request.get(href);
  expect(response.ok()).toBe(true);
  const text = await response.body();
  expect(text.toString('utf8')).toContain('// PTO-TILEOP-MACRO: ');
  expect(href).toContain(createHash('sha256').update(text).digest('hex'));
});
