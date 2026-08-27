import {expect, test} from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';
import {readFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {isCommonMarkFenceClose} from '../plugins/pto-content/index';

const tloadRoute =
  '/instructions/tile/memory-and-data-movement/regular/TLOAD/';
const traceability = JSON.parse(readFileSync(
  resolve(process.cwd(), '../../spec/evidence/release-traceability-readiness.json'),
  'utf8',
)) as {units: Array<{mnemonic: string | null; surface: 'arch' | 'scalar' | 'block' | 'tile'}>};
const instructionUnits = traceability.units.filter((unit) => unit.mnemonic !== null);
const instructionSurfaceTotals = Object.fromEntries(
  ['scalar', 'block', 'tile'].map((surface) => [
    surface,
    instructionUnits.filter((unit) => unit.surface === surface).length,
  ]),
) as {scalar: number; block: number; tile: number};

test('reader-guide code fences use CommonMark closing rules', () => {
  expect(isCommonMarkFenceClose('```', '```')).toBe(true);
  expect(isCommonMarkFenceClose('   ````   ', '```')).toBe(true);
  expect(isCommonMarkFenceClose('```not-a-commonmark-close', '```')).toBe(false);
  expect(isCommonMarkFenceClose('``', '```')).toBe(false);
  expect(isCommonMarkFenceClose('~~~', '```')).toBe(false);
});

test('latest release landing page teaches the architecture before implementation tools', async ({
  page,
}) => {
  await page.goto('/');
  await expect(page.getByRole('heading', {level: 1})).toContainText('Architecture');
  await expect(page.getByText(/^v\d+\.\d+\.\d+\.\d+$/, {exact: true})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Scalar', level: 3})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Block', level: 3})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Tile', level: 3})).toBeVisible();
  await expect(page.getByRole('heading', {name: /ADR explains why/})).toBeVisible();
  const scalarCard = page.getByRole('heading', {name: 'Scalar', level: 3}).locator('xpath=ancestor::article[1]');
  await scalarCard.getByRole('link', {name: /Browse Scalar units/}).click();
  await expect(page).toHaveURL(/\/instructions\/\?surface=scalar/);
  await expect(page.getByRole('status')).toContainText(`${instructionSurfaceTotals.scalar} instructions`);
  await page.goto('/');
  await page.getByRole('searchbox').fill('TLOAD');
  await page.getByRole('button', {name: 'Search specification'}).click();
  await expect(page).toHaveURL(/\/search\/\?q=TLOAD/);
  await expect(page.getByText('PTO-TILE-TLOAD', {exact: true})).toBeVisible();
  await page.getByRole('link', {name: 'TLOAD', exact: true}).click();
  await expect(page).toHaveURL(tloadRoute);
});

test('instruction coverage matrix closes the released bilingual inventory', async ({page}) => {
  await page.goto('/');
  const matrices = await page.evaluate(async () => Promise.all([
    fetch('/pto-instruction-coverage.json').then((response) => response.json()),
    fetch('/zh-CN/pto-instruction-coverage.json').then((response) => response.json()),
  ]));
  for (const matrix of matrices) {
    expect(matrix.schema).toBe('pto.site-instruction-coverage.v1');
    expect(matrix.instruction_count).toBe(instructionUnits.length);
    expect(matrix.surface_totals).toEqual(instructionSurfaceTotals);
    expect(matrix.unexplained_omissions).toBe(0);
    expect(matrix.entries).toHaveLength(instructionUnits.length);
    expect(matrix.entries.filter((entry: {surface: string; bundle_source: string}) =>
      entry.surface === 'tile' && entry.bundle_source === 'owner-metadata')).toHaveLength(
        instructionSurfaceTotals.tile,
      );
  }
  expect(matrices[0].entries.every((entry: {route: string}) => !entry.route.startsWith('/zh-CN/'))).toBe(true);
  expect(matrices[1].entries.every((entry: {route: string}) => entry.route.startsWith('/zh-CN/'))).toBe(true);
});

test('instruction and NDF indexes route every identity to one canonical page', async ({page}) => {
  await page.goto('/instructions/');
  await expect(page.getByRole('heading', {name: 'Instruction index', level: 1})).toBeVisible();
  await expect(page.getByRole('status')).toContainText(`${instructionUnits.length} instructions`);
  await page.getByRole('button', {name: 'Tile', exact: true}).click();
  await expect(page.getByRole('status')).toContainText(`${instructionSurfaceTotals.tile} instructions`);
  await page.getByRole('searchbox', {name: 'Search instructions'}).fill('TLOAD');
  await page.getByRole('link', {name: 'TLOAD', exact: true}).click();
  await expect(page).toHaveURL(tloadRoute);

  await page.goto('/ndf/');
  await expect(page.getByRole('heading', {name: 'NDF index', level: 1})).toBeVisible();
  await page.getByRole('searchbox', {name: 'Search NDF'}).fill('PTO-TLOAD-MEMORY-001');
  const ndfCard = page.locator('#index-pto-tload-memory-001');
  await expect(ndfCard).toBeVisible();
  await ndfCard.getByRole('link', {name: 'contract', exact: true}).click();
  await expect(page).toHaveURL('/ndf/PTO-TLOAD-MEMORY-001/');
  await expect(page.getByText(/byte row stride/).first()).toBeVisible();
  const ownerPages = page.getByRole('region', {name: 'Instruction and unit pages'});
  await expect(ownerPages.getByRole('link', {name: 'TLOAD', exact: true})).toHaveAttribute(
    'href',
    tloadRoute,
  );

  await page.goto('/zh-CN/instructions/');
  await expect(page.getByRole('heading', {name: '指令索引', level: 1})).toBeVisible();
  await page.goto('/zh-CN/ndf/PTO-TLOAD-MEMORY-001/');
  await expect(page).toHaveURL('/zh-CN/ndf/PTO-TLOAD-MEMORY-001/');
});

test('instruction rail and facet buttons share the URL-selected surface', async ({page}, testInfo) => {
  test.skip(testInfo.project.name !== 'desktop-chromium', 'The persistent navigation rail is a desktop surface.');

  await page.goto('/instructions/?surface=scalar');
  const rail = page.locator('aside[aria-label="Left specification navigation"]');
  const filters = page.getByRole('region', {name: 'Instruction filters'});
  await expect(rail.locator('[data-navigation-id="scalar"]')).toHaveAttribute('data-section-current', 'true');
  await expect(filters.getByRole('button', {name: 'Scalar', exact: true})).toHaveAttribute('aria-pressed', 'true');
  await expect(page.getByRole('status')).toContainText(`${instructionSurfaceTotals.scalar} instructions`);

  await rail.locator('[data-navigation-id="block"]').click();
  await expect(page).toHaveURL('/instructions/?surface=block');
  await expect(rail.locator('[data-navigation-id="block"]')).toHaveAttribute('data-section-current', 'true');
  await expect(filters.getByRole('button', {name: 'Block', exact: true})).toHaveAttribute('aria-pressed', 'true');
  await expect(page.getByRole('status')).toContainText(`${instructionSurfaceTotals.block} instructions`);

  await filters.getByRole('button', {name: 'Tile', exact: true}).click();
  await expect(page).toHaveURL('/instructions/?surface=tile');
  await expect(rail.locator('[data-navigation-id="tile"]')).toHaveAttribute('data-section-current', 'true');
  await expect(filters.getByRole('button', {name: 'Tile', exact: true})).toHaveAttribute('aria-pressed', 'true');
  await expect(page.getByRole('status')).toContainText(`${instructionSurfaceTotals.tile} instructions`);

  await page.goBack();
  await expect(page).toHaveURL('/instructions/?surface=block');
  await expect(rail.locator('[data-navigation-id="block"]')).toHaveAttribute('data-section-current', 'true');
  await expect(filters.getByRole('button', {name: 'Block', exact: true})).toHaveAttribute('aria-pressed', 'true');
});

test('representative mnemonic, model, and architecture units use the generic workbench', async ({
  page,
}, testInfo) => {
  await page.goto('/instructions/scalar/alu/ADD/');
  await expect(page.getByRole('heading', {name: 'ADD', level: 1})).toBeVisible();
  await expect(
    page.locator('header code').filter({hasText: /^PTO-SCALAR-ADD$/}),
  ).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Encoding', level: 2})).toBeVisible();
  await expect(page.locator('header').getByText(/ADD applies the selected right-source transformation/)).toBeVisible();
  await expect(page.getByText('At a glance', {exact: true})).toHaveCount(0);
  await expect(page.getByRole('heading', {name: 'Assembly syntax', level: 2})).toBeVisible();
  await expect(
    page.getByRole('heading', {name: 'Assembly syntax', level: 2}).locator('..').getByText(
      'add SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>, ->{t, u, Rd}',
      {exact: true},
    ),
  ).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Assembler symbols', level: 2})).toBeVisible();
  const symbols = page.getByRole('table', {name: 'Assembly fields and architectural roles'});
  await expect(symbols.getByText('SrcRType', {exact: true})).toBeVisible();
  await expect(symbols.getByText('right-source transformation selector', {exact: true})).toBeVisible();
  const readerGuide = page.getByRole('region', {name: 'Behavior'});
  await expect(readerGuide.getByRole('heading', {name: 'What ADD does'})).toBeVisible();
  await expect(readerGuide.getByText(/being migrated and independently reviewed/)).toHaveCount(0);
  const sourceLedger = page.getByRole('region', {name: 'Sources and release identity'});
  await sourceLedger.getByText(/Show commit, paths, hashes, version/).click();
  await expect(sourceLedger.getByText('docs/scalar/alu/ADD.md', {exact: true})).toBeVisible();
  await expect(sourceLedger.getByRole('heading', {name: 'Exact owners'})).toBeVisible();
  await expect(sourceLedger.getByRole('link', {name: 'PTO-SCALAR-ADD'})).toHaveAttribute(
    'href',
    /github\.com\/PTO-ISA\/pto-spec\/blob\/[0-9a-f]{40}\/asl\/scalar\/alu\/ADD\.asl/,
  );
  const guidePosition = await readerGuide.evaluate((element) => element.getBoundingClientRect().top);
  const encodingPosition = await page.getByRole('heading', {name: 'Encoding', level: 2}).evaluate(
    (element) => element.getBoundingClientRect().top,
  );
  const aslPosition = await page.getByRole('heading', {name: 'ASL pseudocode', level: 2}).evaluate(
    (element) => element.getBoundingClientRect().top,
  );
  const sourcePosition = await sourceLedger.evaluate((element) => element.getBoundingClientRect().top);
  expect(encodingPosition).toBeLessThan(aslPosition);
  expect(aslPosition).toBeLessThan(guidePosition);
  expect(sourcePosition).toBeGreaterThan(encodingPosition);
  await expect(page.getByRole('heading', {name: 'Decode source binding', level: 3})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Operation source binding', level: 3})).toBeVisible();
  await expect(page.getByLabel(/decode source binding ASL source/)).toContainText('InstructionContractOperation_ADD');
  await expect(page.getByLabel(/operation ASL source/)).toContainText('InstructionContractHandler_ADD');
  await expect(page.getByText(/non-normative|unpublished release preview/i)).toHaveCount(0);
  const addEncoding = page.getByRole('heading', {name: 'Encoding', level: 2}).locator('..');
  await expect(addEncoding.getByRole('img', {name: /WaveDrom encoding diagram/})).toBeVisible();
  await expect(addEncoding.locator('[data-wavedrom-source="catalog-encoding-json"]')).toBeVisible();
  await addEncoding.getByText('WaveJSON source', {exact: true}).click();
  await expect(addEncoding.locator('pre')).toContainText('"bits": 32');
  await expect(addEncoding.locator('pre')).toContainText('"name": "7\'b0000101"');

  await page.goto('/instructions/scalar/bru/C.CMP.EQI/');
  const compactEncoding = page.getByRole('heading', {name: 'Encoding', level: 2}).locator('..');
  await expect(compactEncoding.getByRole('img', {name: /WaveDrom encoding diagram/})).toBeVisible();
  await compactEncoding.getByText('Encoding fields as an accessible table', {exact: true}).click();
  const compactTable = compactEncoding.getByRole('table', {name: /Generated encoding fields/});
  await expect(compactTable.getByText('15:11', {exact: true})).toBeVisible();
  await expect(compactTable.getByText('10:6', {exact: true})).toBeVisible();
  await expect(compactTable.getByText('5:0', {exact: true})).toBeVisible();
  await expect(compactTable.getByText('26:0', {exact: true})).toHaveCount(0);
  await compactEncoding.getByText('WaveJSON source', {exact: true}).click();
  await expect(compactEncoding.locator('pre')).toContainText('"bits": 16');

  await page.goto('/instructions/block/lifecycle/L.BSTOP/');
  await expect(page.getByRole('heading', {name: /Encoding word 1/})).toBeVisible();
  await expect(page.getByRole('heading', {name: /Encoding word 2/})).toBeVisible();
  await expect(page.getByRole('img', {name: /word 1/})).toBeVisible();
  await expect(page.getByRole('img', {name: /word 2/})).toBeVisible();
  const blockTables = page.getByText('Encoding fields as an accessible table', {exact: true});
  await blockTables.nth(0).click();
  await blockTables.nth(1).click();
  await expect(page.getByRole('table').nth(0).getByRole('row', {name: "Constant 31:0 32'b00000000000000000000000000001111"})).toBeVisible();
  await expect(page.getByRole('table').nth(1).getByRole('row', {name: "Constant 63:32 32'b00000000000000000000000000000001"})).toBeVisible();
  const blockWaveJson = page.getByText('WaveJSON source', {exact: true});
  await expect(blockWaveJson).toHaveCount(2);
  await blockWaveJson.nth(1).click();
  await expect(blockWaveJson.nth(1).locator('..').locator('pre')).toContainText('"offset": 32');

  await page.goto('/instructions/block/attributes/B.FPATR/');
  await expect(page.getByRole('img', {name: /WaveDrom encoding diagram/})).toBeVisible();
  const fixedFieldDisclosure = page.getByText(
    'Encoding fields as an accessible table',
    {exact: true},
  );
  if (testInfo.project.name === 'mobile-chromium') {
    await fixedFieldDisclosure.focus();
    await fixedFieldDisclosure.press('Enter');
  } else {
    await fixedFieldDisclosure.click();
  }
  const fixedNamedFields = page.getByRole('table', {name: /Generated encoding fields/});
  await expect(fixedNamedFields.getByRole('row', {name: 'Func 14:12 0b010'})).toBeVisible();
  await expect(fixedNamedFields.getByRole('row', {name: 'Opc1 6:4 0b010'})).toBeVisible();
  await expect(fixedNamedFields.getByRole('row', {name: 'Opcode 3:1 0b001'})).toBeVisible();
  await expect(fixedNamedFields.getByRole('row', {name: 'W 0 1'})).toBeVisible();

  for (const unit of [
    {
      id: 'PTO-TILE-MODEL-EXECUTION-REARRANGEMENT',
      source: 'asl/tile/model/execution/rearrangement.asl',
    },
    {
      id: 'PTO-ARCH-OVERVIEW-ARCHITECTURE',
      source: 'asl/arch/overview/architecture.asl',
    },
  ]) {
    await page.goto(`/units/${unit.id}/`);
    await expect(page.getByRole('heading', {name: unit.id, level: 1})).toBeVisible();
    const unitLedger = page.getByRole('region', {name: 'Sources and release identity'});
    await unitLedger.getByText(/Show commit, paths, hashes, version/).click();
    await expect(
      unitLedger.getByRole('link', {name: unit.source, exact: true}),
    ).toBeVisible();
    await expect(page.getByRole('heading', {name: 'Encoding', level: 2})).toHaveCount(0);
    await expect(page.getByRole('button', {name: 'Next'})).toHaveCount(0);
  }


  await page.goto('/units/PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR/');
  await page.getByText('Executable evidence', {exact: true}).click();
  await expect(page.getByRole('navigation', {name: 'Executable evidence pages'})).toBeVisible();
  await expect(page.getByText(/Page 1 of \d+/)).toBeVisible();
  const nextEvidencePage = page.getByRole('navigation', {name: 'Executable evidence pages'}).getByRole('button', {name: 'Next'});
  if (testInfo.project.name === 'mobile-chromium') {
    await nextEvidencePage.focus();
    await nextEvidencePage.press('Enter');
  } else {
    await nextEvidencePage.click();
  }
  await expect(page.getByText(/Page 2 of \d+/)).toBeVisible();
});

test('custom routes expose the stable desktop rail and accessible mobile navigation', async ({page}, testInfo) => {
  const routes = [
    {path: '/', current: 'home'},
    {path: '/architecture/', current: 'architecture'},
    {path: tloadRoute, current: 'tile'},
    {path: '/explore/ndf/', current: 'ndf-explorer'},
  ];
  for (const route of routes) {
    await page.goto(route.path);
    if (testInfo.project.name === 'desktop-chromium') {
      const rail = page.locator('aside[aria-label="Left specification navigation"]');
      await expect(rail).toBeVisible();
      await expect(rail.getByRole('navigation', {name: 'Specification navigation'})).toBeVisible();
      await expect(rail.locator(`[data-navigation-id="${route.current}"]`)).toHaveAttribute('data-section-current', 'true');
      await expect(rail.locator('[data-current-page="true"]')).toHaveAttribute('aria-current', 'page');
      await expect(rail.locator('[data-current-page="true"]')).toHaveAttribute('href', route.path);
      await expect(rail.locator('[data-navigation-id="architecture"]')).toBeVisible();
      expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1)).toBe(true);
    } else {
      const drawer = page.locator('details').filter({has: page.getByText('Browse specification', {exact: true})}).first();
      await expect(drawer.getByText('Browse specification', {exact: true})).toBeVisible();
      await drawer.getByText('Browse specification', {exact: true}).focus();
      await drawer.getByText('Browse specification', {exact: true}).press('Enter');
      await expect(drawer).toHaveAttribute('open', '');
      await expect(drawer.getByRole('navigation', {name: 'Specification navigation'})).toBeVisible();
      await expect(drawer.locator(`[data-navigation-id="${route.current}"]`)).toHaveAttribute('data-section-current', 'true');
      await expect(drawer.locator('[data-current-page="true"]')).toHaveAttribute('aria-current', 'page');
      expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1)).toBe(true);
    }
  }
});

test('Architecture landing is source-backed and exposes every required mental-model topic', async ({page}) => {
  await page.goto('/architecture/');
  await expect(page.getByRole('heading', {name: 'Architecture', level: 1})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Architecture mental model'})).toBeVisible();
  for (const topic of [
    'Programming and execution model',
    'Architectural state',
    'Registers and Tile storage',
    'Memory model',
    'Types and shape model',
    'Faults, exceptions, and diagnostics',
    'Version and compatibility',
  ]) {
    await expect(page.getByRole('heading', {name: topic, exact: true})).toBeVisible();
  }
  await expect(page.locator('[data-source-owner][data-guide-sha256]').first()).toBeVisible();
  await expect(page.getByText('Current owner-declared boundary', {exact: true})).toHaveCount(4);
  await expect(page.locator('[role="note"][data-source-sha256][data-guide-sha256]')).toHaveCount(4);
  await expect(page.getByText('PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT', {exact: true}).first()).toBeVisible();
  await expect(page.getByText('PTO-ARCH-MEMORY-MODEL-ORDERING', {exact: true}).first()).toBeVisible();
  await expect(page.getByRole('link', {name: 'Open original ASL ↗'}).first()).toHaveAttribute(
    'href',
    /github\.com\/PTO-ISA\/pto-spec\/blob\/[0-9a-f]{40}\/asl\/arch\//,
  );
  const provenance = page.getByRole('region', {name: 'Sources and release identity'});
  await expect(provenance.locator('details')).not.toHaveAttribute('open', '');
});

test('legacy unit references redirect to canonical workbenches while project records remain browsable', async ({page}, testInfo) => {
  await page.goto('/reference/scalar/alu/ADD/');
  await expect(page).toHaveURL('/instructions/scalar/alu/ADD/');
  await expect(page.getByRole('heading', {name: 'ADD', level: 1})).toBeVisible();
  if (testInfo.project.name === 'desktop-chromium') {
    await page.goto('/reference/governance/adr-process/');
    const sidebar = page.getByRole('navigation', {name: 'Docs sidebar'});
    await expect(sidebar).toHaveCount(1);
    await expect(sidebar).toBeVisible();
    await expect(sidebar.getByText('Decisions and architecture records', {exact: true})).toBeVisible();
    await page.goto('/zh-CN/reference/arch/overview/architecture/');
    await expect(page).toHaveURL('/zh-CN/units/PTO-ARCH-OVERVIEW-ARCHITECTURE/');
  }
});

test('source-declared bundle template covers representative Tile families', async ({page}) => {
  await page.goto('/instructions/tile/elementwise-tile-tile/arithmetic/TADD/');
  await expect(page.getByRole('heading', {name: '2. Complete Bundle Assembly'})).toBeVisible();
  const taddBundle = page.locator('[class*="genericBundleSequence"]');
  await expect(taddBundle.getByText(/BSTART\.VEC TADD/)).toBeVisible();
  await expect(taddBundle.getByText(/B\.IOT SrcLeft, SrcRight/)).toBeVisible();
  await expect(taddBundle.getByText('Repeatable', {exact: true}).first()).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Instruction contract'})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Constraints, checks, and faults'})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'State reads, writes, and result'})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Decode source binding'})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Operation source binding'})).toBeVisible();

  await page.goto('/instructions/tile/memory-and-data-movement/regular/TSTORE/');
  for (const variant of ['Local', 'Shared']) {
    await expect(page.getByRole('heading', {name: variant, exact: true})).toBeVisible();
  }
  const sharedVariant = page.getByRole('heading', {name: 'Shared', exact: true}).locator('..');
  await expect(sharedVariant.getByText(/one source B\.IOS/).first()).toBeVisible();
  await expect(sharedVariant.getByText(/any nonzero consumer PE_MASK/).first()).toBeVisible();
  await expect(sharedVariant.getByText(/optional B\.SUBVIEW/).first()).toBeVisible();
  await expect(page.getByRole('region', {name: 'Instruction contract'})).toContainText(
    'B.SUBVIEW is the explicit source range mechanism',
  );
  await expect(page.getByText('Bundle source gap', {exact: true})).toHaveCount(0);

  await page.goto('/instructions/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL/');
  await expect(page.getByText(
    'TMATMUL <LB0:M, LB1:N, LB2:K, DataTypeA, DataTypeB> SrcTile0, SrcTile1 -> DstTile',
    {exact: true},
  )).toBeVisible();
  await page.getByText('Show High Level Assembly operands mapped to the owning ASL', {exact: true}).click();
  const highLevelBindings = page.getByRole('table', {name: 'Source bindings for High Level Assembly operands'});
  await expect(highLevelBindings.getByRole('row', {name: /Parameter DataTypeA left data type BSTART\.TMATMUL AType/})).toBeVisible();
  await expect(highLevelBindings.getByRole('row', {name: /Output DstTile destination contract\.operands\[0\]\.destination0/})).toBeVisible();
  await expect(page.getByText('Repeatable', {exact: true}).first()).toBeVisible();
  await expect(page.getByText('Mutually exclusive', {exact: true}).first()).toBeVisible();

  await page.goto('/zh-CN/instructions/tile/elementwise-tile-tile/arithmetic/TADD/');
  await expect(page.getByText(
    'TADD <LB0:ValidCol, LB1:ValidRow, LB2:Col, DataType, PadValue> SrcTile0, SrcTile1 -> DstTile',
    {exact: true},
  )).toBeVisible();
  await expect(page.getByRole('heading', {name: '2. 完整 Bundle Assembly'})).toBeVisible();
  await expect(page.getByText('可重复', {exact: true}).first()).toBeVisible();
  await expect(page).toHaveURL(/\/zh-CN\/instructions\/tile\/elementwise-tile-tile\/arithmetic\/TADD\//);
});

test('TLOAD workbench preserves source identity and evidence interaction', async ({
  page,
}, testInfo) => {
  await page.goto(tloadRoute);
  await expect(page.getByRole('heading', {name: 'TLOAD', level: 1})).toBeVisible();
  await expect(
    page.getByRole('link', {
      name: 'TLOAD owning ASL',
    }),
  ).toBeVisible();
  const composition = page.getByRole('region', {name: 'Assembly syntax'}).first();
  await expect(composition).toBeVisible();
  await expect(composition.getByText(/TLOAD is not one standalone encoding/)).toBeVisible();
  await expect(composition.getByRole('heading', {name: '1. High Level Assembly'})).toBeVisible();
  await expect(composition.getByRole('heading', {name: '2. Complete Bundle Assembly'})).toBeVisible();
  await expect(composition.getByRole('heading', {name: '3. Bundle operand and parameter semantics'})).toBeVisible();
  await expect(composition.getByRole('heading', {name: 'Minimum legal bundle'})).toBeVisible();
  const minimumBundle = composition.getByRole('region', {name: 'Minimum legal bundle'});
  await expect(minimumBundle.getByText('BSTART.TLOAD U8', {exact: true})).toBeVisible();
  await expect(minimumBundle.getByText('B.IOT mask=1111, <last>, ->T<1>', {exact: true})).toBeVisible();
  await expect(minimumBundle.getByText('BSTOP', {exact: true})).toBeVisible();
  await expect(composition.getByText('3-command minimum; 8-command complete form')).toBeVisible();
  const biorRow = composition.getByRole('row', {name: /B\.IOR/});
  await expect(biorRow).toContainText('RegSrc0');
  await expect(biorRow).toContainText('GM base byte address');
  await expect(biorRow).toContainText('RegSrc1');
  await expect(biorRow).toContainText('byte distance between adjacent row starts');
  await expect(biorRow.getByRole('link', {name: 'Instruction page'})).toHaveAttribute('href', /instructions\/block\/operands\/B\.IOR/);
  await composition.getByRole('tab', {name: 'Ordinary Shared destination'}).click();
  await expect(composition.getByText('6-command minimum; 8-command complete form')).toBeVisible();
  const sharedDimension = composition.getByRole('row', {name: /B\.DIM/});
  await expect(sharedDimension.getByText('Required', {exact: true})).toBeVisible();
  await expect(sharedDimension).toContainText('exactly 3');
  await expect(sharedDimension).toContainText('LB2 / Col');
  await expect(composition.getByRole('region', {name: 'Minimum legal bundle'}).getByText('B.IOS mask=0001, ->S7<1>', {exact: true})).toBeVisible();
  await composition.getByRole('tab', {name: 'Local CUBE conversion'}).click();
  const bundleAssemblyLayer = composition.getByRole('region', {name: '2. Complete Bundle Assembly'});
  await expect(bundleAssemblyLayer.getByText(/physical CUBE CELL tail/)).toBeVisible();
  await expect(bundleAssemblyLayer.getByText(/not directional padding/)).toBeVisible();
  await expect(bundleAssemblyLayer.getByText(/LB2 is mutually exclusive/)).toBeVisible();
  const dataFlow = composition.getByRole('region', {name: 'Two-dimensional data flow'});
  for (const label of ['GM address', '2D shape', 'Format and type', 'Bundle checks', 'Destination Tile']) {
    await expect(dataFlow.getByRole('heading', {name: label})).toBeVisible();
  }

  const bundlePosition = await composition.evaluate((element) => element.getBoundingClientRect().top);
  const encoding = page.getByRole('heading', {name: 'Entry instruction encoding: BSTART'}).locator('..');
  const encodingPosition = await encoding.evaluate((element) => element.getBoundingClientRect().top);
  expect(bundlePosition).toBeLessThan(encodingPosition);
  await expect(encoding.getByText(/encodes only the bundle-entry BSTART command/)).toBeVisible();

  const execution = page.getByRole('region', {name: 'ASL execution path'});
  await expect(execution).toBeVisible();
  await expect(execution.getByRole('heading', {name: '1. Bundle structure', level: 3})).toBeVisible();
  await expect(execution.getByRole('heading', {name: '5. Complete-footprint preflight', level: 3})).toBeVisible();
  await expect(execution.getByRole('heading', {name: '7. Publish, commit, or no effect', level: 3})).toBeVisible();
  for (const label of ['Inputs', 'Checks', 'Failure', 'Read state', 'Constraints', 'Faults', 'State writes', 'Commit / result']) {
    await expect(execution.getByRole('heading', {name: label}).first()).toBeVisible();
  }
  await expect(execution.getByText(/current owner exposes instruction selection/i)).toBeVisible();
  await expect(execution.getByText(/current owner binds the generic Tile handler/i)).toBeVisible();
  await expect(execution.getByLabel(/TLOAD\.asl lines/).filter({hasText: 'InstructionContractGMAddress_TLOAD'})).toBeVisible();
  const localMemorySource = execution.getByText(/Show shared ASL: Local preflight and load/);
  await localMemorySource.click();
  await expect(execution.getByLabel(/load-store\.asl lines/)).toContainText('ProbeTileMemoryAccess');
  const sharedMemorySource = execution.getByText(/Show shared ASL: Shared preflight and atomic update/);
  await sharedMemorySource.click();
  await expect(execution.getByLabel(/shared-movement\.asl lines/)).toContainText('AtomicUpdateSharedTile');
  await expect(execution.getByRole('link', {name: /Exact source/}).first()).toHaveAttribute('href', /#L\d+-L\d+$/);

  const memoryClause = page.locator('#ndf-pto-tload-memory-001');
  await expect(memoryClause).toBeVisible();
  await expect(memoryClause.getByText(/TLOAD MUST use B\.IOR RegSrc0 as the per-PE GM base/)).toBeVisible();
  await expect(memoryClause.getByLabel(/NDF identity PTO-TLOAD-MEMORY-001/).getByText('TLOAD', {exact: true})).toBeVisible();
  await expect(memoryClause.getByRole('button', {name: /Copy complete stable ID PTO-TLOAD-MEMORY-001/})).toBeVisible();
  await expect(memoryClause.getByText('asl/tile/memory-and-data-movement/regular/TLOAD.asl', {exact: true})).toBeHidden();
  const canonicalOrder = await page.locator('li[id^="ndf-"]').evaluateAll((items) => items.map((item) => item.id));
  await memoryClause.getByRole('button', {name: 'Move down'}).click();
  const movedOrder = await page.locator('li[id^="ndf-"]').evaluateAll((items) => items.map((item) => item.id));
  expect(movedOrder).toEqual([...canonicalOrder].reverse());
  await page.getByRole('button', {name: 'Restore default order'}).click();
  await expect.poll(() => page.locator('li[id^="ndf-"]').evaluateAll((items) => items.map((item) => item.id))).toEqual(canonicalOrder);
  await memoryClause.getByRole('button', {name: 'Move down'}).click();
  await page.reload();
  await expect.poll(() => page.locator('li[id^="ndf-"]').evaluateAll((items) => items.map((item) => item.id))).toEqual(canonicalOrder);
  const provenance = page.locator('#ndf-pto-tload-memory-001').getByText('Sources and references', {exact: true});
  await provenance.click();
  await expect(page.locator('#ndf-pto-tload-memory-001').getByText('PTO-TLOAD-MEMORY-001', {exact: true})).toBeVisible();
  await expect(page.locator('#ndf-pto-tload-memory-001').getByRole('link', {name: /Open exact canonical source/})).toHaveAttribute('href', /#L\d+-L\d+$/);

  await expect(page.getByText(/\d+ matching entries/)).toBeVisible();
  const commitEvidenceGroup = page.getByText('Commit-scoped evidence', {exact: true});
  await expect(commitEvidenceGroup).toBeVisible();
  await commitEvidenceGroup.click();
  await expect(
    page.getByText('PTO-EVIDENCE-ARCHITECTURE-READINESS', {exact: true}).filter({visible: true}).first(),
  ).toBeVisible();

  const evidenceSearch = page.getByRole('searchbox', {
    name: 'Search evidence by identity or path',
  });
  await evidenceSearch.fill('stride');
  const executableEvidenceGroup = page.getByText('Executable evidence', {exact: true});
  await executableEvidenceGroup.click();
  await expect(page.getByText(/matching entr/)).not.toHaveText('24 matching entries');
  const strideEntry = page.locator('#avs-pto-avs-block-tload-stride-001').locator('details').first();
  await expect(strideEntry.getByLabel(/AVS identity PTO-AVS-BLOCK-TLOAD-STRIDE-001/)).toBeVisible();
  await expect(strideEntry.getByText('BSTART.TLOAD', {exact: true})).toBeVisible();
  await expect(strideEntry.getByText('EXECUTION', {exact: true})).toBeVisible();
  const strideSummary = strideEntry.locator('summary').first();
  if (testInfo.project.name === 'mobile-chromium') {
    await strideSummary.focus();
    await strideSummary.press('Enter');
  } else {
    await strideSummary.click();
  }
  await strideEntry.getByText('Show exact test source', {exact: true}).click();
  await expect(
    page.getByLabel('Exact test source for PTO-AVS-BLOCK-TLOAD-STRIDE-001'),
  ).toContainText('PTO-TEST');
  await evidenceSearch.fill('PTO-AVS-BLOCK-B-IOS-CAPACITY-003');
  const capacityEntry = page.locator('#avs-pto-avs-block-b-ios-capacity-003');
  await expect(capacityEntry.getByLabel(/AVS identity PTO-AVS-BLOCK-B-IOS-CAPACITY-003/).getByText('B.IOS', {exact: true})).toBeVisible();
  await expect(capacityEntry.getByText('BOUNDARY', {exact: true})).toBeVisible();
  await capacityEntry.locator('summary').first().click();
  await expect(capacityEntry.getByRole('button', {name: /Copy complete stable ID PTO-AVS-BLOCK-B-IOS-CAPACITY-003/})).toBeVisible();

  await evidenceSearch.fill('ADR-0074');
  const decisionEntry = page.locator('#adr-adr-0074').locator('details').first();
  await expect(decisionEntry).toHaveAttribute('open', '');
  await expect(decisionEntry.getByRole('heading', {name: 'Decision record'})).toBeVisible();
  await expect(decisionEntry.getByRole('heading', {name: 'Decision', exact: true})).toBeVisible();
  await expect(decisionEntry.getByRole('heading', {name: 'Compatibility and supersession'})).toBeVisible();
  await expect(decisionEntry.getByText(/RegSrc1.*row_stride_bytes/)).toBeVisible();
  await decisionEntry.getByText('Sources and references', {exact: true}).click();
  await expect(decisionEntry.getByRole('link', {name: /Open exact decision source/})).toHaveAttribute(
    'href',
    /github\.com\/PTO-ISA\/pto-spec\/blob\/[0-9a-f]{40}\/docs\/status\/decisions\/0074-tload-tstore-gm-byte-row-stride\.md/,
  );
  const collapseAll = page.getByRole('button', {name: 'Collapse groups'});
  if (testInfo.project.name === 'mobile-chromium') {
    await collapseAll.focus();
    await collapseAll.press('Enter');
  } else {
    await collapseAll.click();
  }
  await expect(page.locator('details[class*="group"][open]')).toHaveCount(0);
  const expandAll = page.getByRole('button', {name: 'Expand groups'});
  if (testInfo.project.name === 'mobile-chromium') {
    await expandAll.focus();
    await expandAll.press('Enter');
  } else {
    await expandAll.click();
  }
  await expect(page.locator('details[class*="group"][open]')).not.toHaveCount(0);

  await page.getByText('Open optional interactive walkthrough', {exact: true}).click();
  await page.getByRole('button', {name: 'Next'}).click();
  await expect(page.getByText('Step 2 of 4', {exact: true})).toBeVisible();
  const sourceLedger = page.getByRole('region', {name: 'Sources and release identity'});
  await expect(sourceLedger.getByText(/Show commit, paths, hashes, version/)).toBeVisible();
  await expect(sourceLedger.getByText('asl/tile/memory-and-data-movement/regular/TLOAD.asl', {exact: true}).first()).toBeHidden();
});

test('NDF explorer keeps an indexed fallback and exact-source navigation', async ({
  page,
}, testInfo) => {
  await page.goto('/explore/ndf/?q=PTO-TLOAD-MEMORY-001');
  await expect(
    page.getByRole('heading', {name: 'NDF relationship explorer'}),
  ).toBeVisible();
  const indexSearch = page.getByRole('searchbox', {name: /NDF node index/i});
  await expect(indexSearch).toHaveValue('PTO-TLOAD-MEMORY-001');
  await expect(page.getByText('PTO-TLOAD-MEMORY-001', {exact: true})).toBeVisible();
  await expect(page.getByRole('link', {name: /source.*for PTO-TLOAD-MEMORY-001/i})).toHaveAttribute(
    'href',
    /github\.com\/PTO-ISA\/pto-spec\/blob\/[0-9a-f]{40}\/.*#L\d+-L\d+/,
  );

  const openWebGl = page.getByRole('button', {name: 'Open WebGL graph'});
  const mustExerciseWebGl = testInfo.project.name === 'desktop-chromium';
  if (mustExerciseWebGl) {
    await expect(openWebGl).toBeVisible();
  }
  if (mustExerciseWebGl || (await openWebGl.isVisible().catch(() => false))) {
    await openWebGl.click();
    await expect(page.getByRole('button', {name: 'Close WebGL graph'})).toBeVisible();
    const graph = page.getByRole('img', {name: /Interactive NDF graph/});
    await expect(graph).toBeVisible();
    await expect(graph.locator('canvas')).not.toHaveCount(0);
    await page.getByRole('button', {name: 'Close WebGL graph'}).click();
    await expect(graph).toHaveCount(0);
  }
});

test('Simplified Chinese framework route is generated', async ({page}) => {
  await page.goto('/zh-CN/');
  await expect(page.getByRole('heading', {level: 1})).toContainText(
    '架构',
  );
  const chineseDrawer = page.locator('details').filter({has: page.getByText('浏览规范', {exact: true})}).first();
  if (await chineseDrawer.isVisible()) {
    await chineseDrawer.getByText('浏览规范', {exact: true}).click();
    await expect(chineseDrawer.getByRole('navigation', {name: '规范导航'}).getByText('架构', {exact: true})).toBeVisible();
  } else {
    await expect(page.locator('aside[aria-label="左侧规范导航"]').getByText('架构', {exact: true})).toBeVisible();
  }
  await page.goto('/zh-CN/architecture/');
  await expect(page.getByRole('heading', {name: '架构', level: 1})).toBeVisible();
  await expect(page.getByRole('heading', {name: '架构心智模型'})).toBeVisible();
  await expect(page.getByRole('heading', {name: '编程与执行模型', exact: true})).toBeVisible();
  await expect(page.getByRole('heading', {name: '架构状态', exact: true})).toBeVisible();
  await expect(page.getByRole('heading', {name: '寄存器与 Tile 存储', exact: true})).toBeVisible();
  await expect(page.getByRole('heading', {name: '内存模型', exact: true})).toBeVisible();
  await page.goto('/zh-CN/');
  await page.getByRole('searchbox').fill('TLOAD');
  await page.getByRole('button', {name: '搜索规范'}).click();
  await expect(page).toHaveURL(/\/zh-CN\/search\/\?q=TLOAD/);
  await expect(page.getByText(/页面框架已切换为简体中文/)).toBeVisible();
  await page.getByRole('link', {name: 'TLOAD', exact: true}).click();
  await expect(page).toHaveURL(`/zh-CN${tloadRoute}`);
  await expect(page.getByRole('heading', {name: '汇编格式', exact: true})).toBeVisible();
  await expect(page.getByRole('heading', {name: '2. 完整 Bundle Assembly'})).toBeVisible();
  await expect(page.getByRole('heading', {name: '3. Bundle 操作数与参数语义'})).toBeVisible();
  await expect(page.getByRole('tab', {name: '普通 Local 目标'})).toBeVisible();
  await expect(page.getByRole('region', {name: '二维数据流'}).getByText(/逐 PE 的 GM 基地址/).first()).toBeVisible();
  await expect(page.getByRole('heading', {name: 'ASL 执行路径'})).toBeVisible();
});

test.describe('no JavaScript fallback', () => {
  test.use({javaScriptEnabled: false});

  test('released ASL and NDF remain readable', async ({page}) => {
    await page.goto(tloadRoute);
    await expect(page.getByRole('heading', {name: 'TLOAD', level: 1})).toBeVisible();
    await expect(page.getByRole('heading', {name: 'Assembly syntax', level: 2})).toBeVisible();
    await expect(page.getByRole('heading', {name: 'Behavior', level: 2})).toBeVisible();
    await expect(page.getByRole('heading', {name: 'ASL execution path', level: 2})).toBeVisible();
    await expect(page.getByLabel(/TLOAD\.asl lines/).filter({hasText: 'InstructionContractGMAddress_TLOAD'})).toBeVisible();
    const cubeClause = page.locator('#ndf-pto-tload-cube-001');
    await expect(cubeClause).toBeVisible();
    await expect(cubeClause.getByText(/CUBE TLOAD MUST derive persistent CELL geometry/)).toBeVisible();
  });

  test('catalog encoding remains readable as a native table', async ({page}, testInfo) => {
    await page.goto('/instructions/scalar/alu/ADD/');
    await expect(page.getByRole('img', {name: /WaveDrom encoding diagram/})).toHaveCount(0);
    const encodingTableSummary = page.getByText('Encoding fields as an accessible table', {exact: true});
    if (testInfo.project.name === 'mobile-chromium') {
      await encodingTableSummary.focus();
      await encodingTableSummary.press('Enter');
    } else {
      await encodingTableSummary.click();
    }
    const table = page.getByRole('table', {name: /Generated encoding fields/});
    await expect(table).toBeVisible();
    await expect(table.getByText('31:27', {exact: true})).toBeVisible();
    await expect(table.getByText("7'b0000101", {exact: true})).toBeVisible();
  });
});

test('critical routes have no serious WCAG violations', async ({page}) => {
  test.setTimeout(60_000);
  for (const route of [
    '/',
    '/architecture/',
    '/zh-CN/architecture/',
    '/instructions/',
    '/ndf/',
    '/ndf/PTO-TLOAD-MEMORY-001/',
    tloadRoute,
    '/explore/ndf/?q=PTO-TLOAD-MEMORY-001',
    '/reference/governance/adr-process/',
  ]) {
    await page.goto(route);
    const mobileNavigation = page.locator('summary').filter({hasText: /Browse specification|浏览规范/}).first();
    if (await mobileNavigation.isVisible()) {
      await mobileNavigation.focus();
      await mobileNavigation.press('Enter');
    }
    const result = await new AxeBuilder({page})
      .withTags(['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa'])
      .analyze();
    const violations = result.violations.filter(
      (violation) => violation.impact === 'serious' || violation.impact === 'critical',
    );
    expect(violations, `${route} accessibility violations`).toEqual([]);
  }
});

test('dark and reduced-motion modes preserve layout and stop autoplay', async ({page}, testInfo) => {
  await page.emulateMedia({colorScheme: 'dark', reducedMotion: 'reduce'});
  await page.goto(tloadRoute);
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
  await page.getByText('Open optional interactive walkthrough', {exact: true}).click();
  const play = page.getByRole('button', {name: 'Play'});
  if (testInfo.project.name === 'mobile-chromium') {
    await play.focus();
    await play.press('Enter');
  } else {
    await play.click();
  }
  await page.waitForTimeout(1100);
  await expect(page.getByText('Step 1 of 4', {exact: true})).toBeVisible();
  const overflow = await page.evaluate(() => ({
    viewport: window.innerWidth,
    document: document.documentElement.scrollWidth,
  }));
  expect(overflow.document).toBeLessThanOrEqual(overflow.viewport + 1);
});

test('forced no-WebGL path keeps the complete static-index entry point', async ({page}) => {
  await page.addInitScript(() => {
    const original = HTMLCanvasElement.prototype.getContext;
    HTMLCanvasElement.prototype.getContext = function getContext(
      contextId: string,
      ...args: unknown[]
    ) {
      if (contextId === 'webgl' || contextId === 'webgl2') return null;
      return original.call(this, contextId as never, ...(args as []));
    };
  });
  await page.goto('/explore/ndf/');
  await expect(page.getByText(/Index fallback active/)).toBeVisible();
  await expect(page.getByRole('button', {name: 'Open WebGL graph'})).toHaveCount(0);
  await expect(page.getByRole('link', {name: /complete static relationship index/i})).toBeVisible();
  await page.getByRole('link', {name: /complete static relationship index/i}).click();
  await expect(page.getByText('Page 1 of 23', {exact: true})).toBeVisible();
  await expect(page.getByText(/Clause SHA-256/).first()).toBeVisible();
});
