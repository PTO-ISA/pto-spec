import {createHash} from 'node:crypto';
import {expect, test} from '@playwright/test';

const representatives = [
  {section: 'scalar', mnemonic: 'ADD', helper: 'ComputeADDResult'},
  {section: 'float', mnemonic: 'FMADD', helper: 'DecodeFMADDSourceCarrier'},
  {section: 'block', mnemonic: 'B.IOT', helper: 'BIOTZeroMaskNoEffect'},
  {section: 'cube', mnemonic: 'TMATMUL', helper: 'TMATMULOperandsLegal'},
  {section: 'vector', mnemonic: 'TADD', helper: 'ExecuteTADD'},
  {section: 'vector', mnemonic: 'TEXP', helper: 'ExecuteTEXP'},
  {section: 'tma', mnemonic: 'TLOAD', helper: 'ResolveTLOADGlobalAddress'},
] as const;

test.describe('static manual', () => {
  test.use({javaScriptEnabled: false});

  test('all seven instruction categories can be read with JavaScript disabled', async ({page}) => {
    test.setTimeout(120_000);
    for (const {section, mnemonic, helper} of representatives) {
      await page.goto(`/instructions/${section}/`);
      const entry = page.locator('main table').getByRole('link', {name: mnemonic, exact: true});
      await expect(entry).toHaveCount(1);
      await entry.click();
      await expect(page.locator('[data-layout-contract="arm-style-v1"]')).toHaveCount(1);
      await expect(page.getByRole('heading', {name: mnemonic, exact: true, level: 1})).toBeVisible();
      await expect(page.locator('#encoding table').first()).toBeVisible();
      const exactDefinition = page.locator(`pre[aria-label^="${helper},"]`);
      await expect(exactDefinition.first()).toBeVisible();
      await expect(exactDefinition.first()).toContainText(`func ${helper}(`);
      const href = await page.getByRole('link', {name: new RegExp(`^${helper} ↗$`)}).first().getAttribute('href');
      expect(href).toMatch(/^(?:\/evidence\/asl-fragments\/[0-9a-f]{64}\.asl|https:\/\/github\.com\/PTO-ISA\/pto-spec\/blob\/[0-9a-f]{40}\/asl\/.+#L\d+-L\d+)$/);
      if (href?.startsWith('/evidence/')) {
        const response = await page.request.get(href);
        expect(response.ok()).toBe(true);
        const source = await response.text();
        expect(source).toContain(`func ${helper}(`);
        expect(href).toContain(createHash('sha256').update(source).digest('hex'));
      }
    }
  });

  test('encoding index lists scoped physical forms and real Tile selectors', async ({page}) => {
    await page.goto('/instructions/encoding/');
    await expect(page.locator('#scoped64').getByRole('row', {name: /ld\.private/i}).first()).toBeVisible();
    const vector = page.locator('#tile-vec');
    await expect(vector.getByRole('row', {name: /Mode=0.*Function=0.*TADD/})).toBeVisible();
    await expect(page.locator('#tile-sfu').getByRole('link', {name: 'TEXP', exact: true})).toHaveCount(1);
    await expect(page.locator('#reserved').getByRole('row', {name: /reserved-in-pto/}).first()).toBeVisible();
  });

  test('additional instruction forms use the same reference template', async ({page}) => {
    await page.goto('/instructions/scalar/amo/CASW/');
    await expect(page.locator('[data-layout-contract="arm-style-v1"]')).toHaveCount(1);
    await expect(page.getByRole('heading', {name: 'CASW', level: 1})).toBeVisible();
    await expect(page.locator('#encoding').getByRole('heading', {name: /casw\.private/i})).toBeVisible();
    await expect(page.locator('#encoding').getByRole('heading', {name: /casw.*\.inter/i})).toBeVisible();
    await expect(page.getByRole('heading', {name: 'Decode', level: 2})).toBeVisible();
    await expect(page.getByRole('heading', {name: 'Operation', level: 2})).toBeVisible();

    await page.goto('/instructions/block/execution/BSTART.VEC/');
    const aliasEncoding = page.locator('#encoding');
    await expect(aliasEncoding.getByText(/reuses/)).toBeVisible();
    await expect(aliasEncoding.getByRole('link', {name: 'BSTART.TEPL'}))
      .toHaveAttribute('href', '/instructions/block/execution/BSTART.TEPL/');

    await page.goto('/instructions/tile/reduce-and-expand/row-reduction/TROWSUM/');
    await expect(page.getByRole('heading', {name: 'TROWSUM', level: 1})).toBeVisible();
    await expect(page.getByRole('heading', {name: 'TileOp assembly', level: 2})).toBeVisible();
    const physicalBundle = page.getByRole('heading', {name: 'Physical bundle'}).locator('..');
    await expect(physicalBundle).toBeVisible();
    await expect(physicalBundle.getByRole('link', {name: /BSTART\.SFU definition/})).toBeVisible();
  });

  test('Chinese manual stays on localized canonical routes', async ({page}) => {
    await page.goto('/zh-CN/');
    const navigation = page.getByRole('navigation', {name: '指令手册分类'});
    await navigation.getByRole('link', {name: 'Cube', exact: true}).click();
    await expect(page).toHaveURL('/zh-CN/instructions/cube/');
    await page.locator('main table').getByRole('link', {name: 'TMATMUL', exact: true}).click();
    await expect(page).toHaveURL('/zh-CN/instructions/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL/');
    await expect(page.getByRole('heading', {name: '指令编码', exact: true})).toBeVisible();
  });
});

test('manual indexes hydrate and link to the same canonical instructions', async ({page}) => {
  test.setTimeout(120_000);
  await page.goto('/');
  const manual = page.getByRole('navigation', {name: 'Instruction manual categories'});
  for (const {section, mnemonic} of representatives) {
    await manual.locator(`a[href="/instructions/${section}/"]`).click();
    await expect(page).toHaveURL(`/instructions/${section}/`);
    await expect(page.locator('main table').getByRole('link', {name: mnemonic, exact: true})).toBeVisible();
  }
  await manual.getByRole('link', {name: 'Encoding Table', exact: true}).click();
  await expect(page.getByRole('navigation', {name: 'Encoding groups'}).getByRole('link', {name: 'SCOPED64'})).toBeVisible();
  await manual.getByRole('link', {name: 'Scalar', exact: true}).click();
  await page.locator('main table').getByRole('link', {name: 'ADD', exact: true}).click();
  const call = page.locator('#operation-computeaddresult pre').getByRole('link', {name: 'PrepareADDRightOperand', exact: true});
  await expect(call).toHaveAttribute('href', '#operation-prepareaddrightoperand');
  await call.click();
  await expect(page).toHaveURL(/#operation-prepareaddrightoperand$/);
});
