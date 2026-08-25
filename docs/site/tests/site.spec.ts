import {expect, test} from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';
import {isCommonMarkFenceClose} from '../plugins/pto-content/index';

const tloadRoute =
  '/instructions/tile/memory-and-data-movement/regular/TLOAD/';

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
  await expect(page.getByRole('heading', {level: 1})).toContainText('PTO Architecture');
  await expect(page.getByText(/^v\d+\.\d+\.\d+\.\d+$/, {exact: true})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Scalar', level: 3})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Block', level: 3})).toBeVisible();
  await expect(page.getByRole('heading', {name: 'Tile', level: 3})).toBeVisible();
  await expect(page.getByRole('heading', {name: /ADR explains why/})).toBeVisible();
  const scalarCard = page.getByRole('heading', {name: 'Scalar', level: 3}).locator('xpath=ancestor::article[1]');
  const scalarInventory = await scalarCard.getByText(/ASL units/).innerText();
  const scalarUnitCount = scalarInventory.match(/(\d+)\s+ASL\s+units/i)?.[1];
  expect(scalarUnitCount).toBeTruthy();
  await scalarCard.getByRole('link', {name: /Browse Scalar units/}).click();
  await expect(page).toHaveURL(/kind=asl&surface=scalar/);
  await expect(page.getByRole('status')).toContainText(`${scalarUnitCount} matching identities`);
  await page.goto('/');
  await page.getByRole('searchbox').fill('TLOAD');
  await page.getByRole('button', {name: 'Search specification'}).click();
  await expect(page).toHaveURL(/\/search\/\?q=TLOAD/);
  await expect(page.getByText('PTO-TILE-TLOAD', {exact: true})).toBeVisible();
  await page.getByRole('link', {name: 'TLOAD', exact: true}).click();
  await expect(page).toHaveURL(tloadRoute);
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
  await expect(page.getByText('docs/scalar/alu/ADD.md', {exact: true})).toBeVisible();
  const readerGuide = page.getByRole('region', {name: 'Understand this instruction'});
  await expect(readerGuide.getByText('Reader guide · non-normative explanation', {exact: true})).toBeVisible();
  await expect(readerGuide.getByRole('heading', {name: 'What ADD does'})).toBeVisible();
  await expect(readerGuide.getByText(/being migrated and independently reviewed/)).toHaveCount(0);
  await expect(readerGuide.getByRole('heading', {name: 'Exact normative owners'})).toBeVisible();
  await expect(readerGuide.getByRole('link', {name: 'PTO-SCALAR-ADD'})).toHaveAttribute(
    'href',
    /github\.com\/PTO-ISA\/pto-spec\/blob\/[0-9a-f]{40}\/asl\/scalar\/alu\/ADD\.asl/,
  );
  const guidePosition = await readerGuide.evaluate((element) => element.getBoundingClientRect().top);
  const encodingPosition = await page.getByRole('heading', {name: 'Encoding', level: 2}).evaluate(
    (element) => element.getBoundingClientRect().top,
  );
  expect(guidePosition).toBeLessThan(encodingPosition);
  const addEncoding = page.getByRole('heading', {name: 'Encoding', level: 2}).locator('..');
  await expect(addEncoding.getByRole('img', {name: /WaveDrom encoding diagram/})).toBeVisible();
  await expect(addEncoding.locator('[data-wavedrom-source="catalog-encoding-json"]')).toBeVisible();
  await addEncoding.getByText('WaveJSON source', {exact: true}).click();
  await expect(addEncoding.locator('pre')).toContainText('"bits": 32');
  await expect(addEncoding.locator('pre')).toContainText('"name": "Fixed selector"');

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
  await expect(page.getByRole('table').nth(0).getByText('0x0000000f', {exact: true})).toBeVisible();
  await expect(page.getByRole('table').nth(1).getByText('0x00000001', {exact: true})).toBeVisible();
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
    await expect(
      page.getByRole('link', {name: unit.source, exact: true}),
    ).toBeVisible();
    await expect(page.getByRole('heading', {name: 'Encoding', level: 2})).toHaveCount(0);
    await expect(page.getByRole('button', {name: 'Next'})).toHaveCount(0);
  }


  await page.goto('/units/PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR/');
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

test('TLOAD workbench preserves source identity and evidence interaction', async ({
  page,
}, testInfo) => {
  await page.goto(tloadRoute);
  await expect(page.getByRole('heading', {name: 'TLOAD', level: 1})).toBeVisible();
  await expect(
    page.getByRole('link', {
      name: 'asl/tile/memory-and-data-movement/regular/TLOAD.asl',
      exact: true,
    }),
  ).toBeVisible();
  await expect(page.getByText(/PTO-TLOAD-MEMORY-001 — contract/)).toBeVisible();
  await expect(page.getByText(/\d+ matching entries/)).toBeVisible();
  await expect(page.getByText(/Commit-scoped evidence/)).toBeVisible();
  await expect(
    page.getByText('PTO-EVIDENCE-ARCHITECTURE-READINESS', {exact: true}),
  ).toBeVisible();

  const evidenceSearch = page.getByRole('searchbox', {
    name: 'Search evidence by identity or path',
  });
  await evidenceSearch.fill('stride');
  await expect(page.getByText(/matching entr/)).not.toHaveText('24 matching entries');
  await expect(
    page.getByText('PTO-AVS-BLOCK-TLOAD-STRIDE-001', {exact: true}),
  ).toBeVisible();
  const strideIdentity = page.getByText('PTO-AVS-BLOCK-TLOAD-STRIDE-001', {exact: true});
  const strideEntry = strideIdentity.locator('xpath=ancestor::details[1]');
  await strideIdentity.click();
  await strideEntry.getByText('Show exact test source', {exact: true}).click();
  await expect(
    page.getByLabel('Exact test source for PTO-AVS-BLOCK-TLOAD-STRIDE-001'),
  ).toContainText('PTO-TEST');
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

  await page.getByRole('button', {name: 'Next'}).click();
  await expect(page.getByText('Step 2 of 4', {exact: true})).toBeVisible();
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
    'PTO 架构',
  );
  await page.getByRole('searchbox').fill('TLOAD');
  await page.getByRole('button', {name: '搜索规范'}).click();
  await expect(page).toHaveURL(/\/zh-CN\/search\/\?q=TLOAD/);
  await expect(page.getByText(/页面框架已切换为简体中文/)).toBeVisible();
  await page.getByRole('link', {name: 'TLOAD', exact: true}).click();
  await expect(page).toHaveURL(`/zh-CN${tloadRoute}`);
});

test.describe('no JavaScript fallback', () => {
  test.use({javaScriptEnabled: false});

  test('released ASL and NDF remain readable', async ({page}) => {
    await page.goto(tloadRoute);
    await expect(page.getByRole('heading', {name: 'TLOAD', level: 1})).toBeVisible();
    await expect(page.getByText('Reader guide · non-normative explanation', {exact: true})).toBeVisible();
    await expect(page.getByText('// NDF-BEGIN: PTO-TLOAD-MEMORY-001')).toBeVisible();
    await expect(page.getByText(/PTO-TLOAD-CUBE-001 — contract/)).toBeVisible();
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
    await expect(table.getByText('Fixed selector', {exact: true}).first()).toBeVisible();
  });
});

test('critical routes have no serious WCAG violations', async ({page}) => {
  for (const route of ['/', tloadRoute, '/explore/ndf/?q=PTO-TLOAD-MEMORY-001']) {
    await page.goto(route);
    const result = await new AxeBuilder({page})
      .withTags(['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa'])
      .analyze();
    const violations = result.violations.filter(
      (violation) => violation.impact === 'serious' || violation.impact === 'critical',
    );
    expect(violations, `${route} accessibility violations`).toEqual([]);
  }
});

test('dark and reduced-motion modes preserve layout and stop autoplay', async ({page}) => {
  await page.emulateMedia({colorScheme: 'dark', reducedMotion: 'reduce'});
  await page.goto(tloadRoute);
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
  await page.getByRole('button', {name: 'Play'}).click();
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
