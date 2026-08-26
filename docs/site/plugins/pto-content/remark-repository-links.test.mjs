import assert from 'node:assert/strict';
import test from 'node:test';
import path from 'node:path';
import ptoRepositoryLinksRemarkPlugin, {
  presentGeneratedAslReference,
  rewriteRepositoryLink,
} from './remark-repository-links.ts';

const repositoryRoot = path.resolve(import.meta.dirname, '..', '..', '..', '..');
const markdownPath = path.join(repositoryRoot, 'docs', 'guides', 'example.md');
const commit = '0123456789abcdef0123456789abcdef01234567';

test('rewrites repository-relative links that escape docs and preserves fragments', () => {
  assert.equal(
    rewriteRepositoryLink('../../CHANGELOG.md#release', markdownPath, repositoryRoot, commit),
    `https://github.com/PTO-ISA/pto-spec/blob/${commit}/CHANGELOG.md#release`,
  );
  assert.equal(
    rewriteRepositoryLink('../../spec/release-inputs.json', markdownPath, repositoryRoot, commit),
    `https://github.com/PTO-ISA/pto-spec/blob/${commit}/spec/release-inputs.json`,
  );
});

test('leaves docs-relative, fragment, root, and external links unchanged', () => {
  for (const url of [
    '../architecture/overview.md#state',
    '#local',
    '/search/',
    'https://example.com/reference',
    'mailto:maintainer@example.com',
  ]) {
    assert.equal(
      rewriteRepositoryLink(url, markdownPath, repositoryRoot, commit),
      url,
    );
  }
});

test('rewrites docs directories without index pages to exact tree permalinks', () => {
  const governancePath = path.join(
    repositoryRoot,
    'docs',
    'governance',
    'adr-process.md',
  );
  assert.equal(
    rewriteRepositoryLink(
      '../status/decisions/',
      governancePath,
      repositoryRoot,
      commit,
    ),
    `https://github.com/PTO-ISA/pto-spec/tree/${commit}/docs/status/decisions/`,
  );
});

test('projects existing Markdown links to docs-root absolute file references', () => {
  const repositoryLayout = path.join(
    repositoryRoot,
    'docs',
    'development',
    'repository-layout.md',
  );
  assert.equal(
    rewriteRepositoryLink(
      '../arch/overview/architecture.md#state',
      repositoryLayout,
      repositoryRoot,
      commit,
    ),
    '/arch/overview/architecture.md#state',
  );
  const localizedRepositoryLayout = path.join(
    repositoryRoot,
    'docs',
    'site',
    'i18n',
    'zh-CN',
    'docusaurus-plugin-content-docs-reference',
    'current',
    'development',
    'repository-layout.md',
  );
  assert.equal(
    rewriteRepositoryLink(
      '../arch/overview/architecture.md#state',
      localizedRepositoryLayout,
      repositoryRoot,
      commit,
    ),
    '/arch/overview/architecture.md#state',
  );
});

test('transforms inline and reference links without changing images', () => {
  const tree = {
    type: 'root',
    children: [
      {type: 'link', url: '../../CHANGELOG.md#release'},
      {type: 'definition', url: '../../spec/release-inputs.json'},
      {type: 'image', url: '../../assets/example.png'},
      {type: 'link', url: '../architecture/overview.md'},
    ],
  };
  const transform = ptoRepositoryLinksRemarkPlugin({repositoryRoot, commit});
  transform(tree, {path: markdownPath});

  assert.equal(
    tree.children[0].url,
    `https://github.com/PTO-ISA/pto-spec/blob/${commit}/CHANGELOG.md#release`,
  );
  assert.equal(
    tree.children[1].url,
    `https://github.com/PTO-ISA/pto-spec/blob/${commit}/spec/release-inputs.json`,
  );
  assert.equal(tree.children[2].url, '../../assets/example.png');
  assert.equal(tree.children[3].url, '../architecture/overview.md');
});

test('fails closed when a relative link escapes the repository', () => {
  assert.throws(
    () =>
      rewriteRepositoryLink(
        '../../../../outside.md',
        markdownPath,
        repositoryRoot,
        commit,
      ),
    /escapes repository root/,
  );
});

test('presents generated ASL references in reader-first language with provenance last', () => {
  const tree = {
    type: 'root',
    children: [
      {type: 'heading', depth: 1, children: [{type: 'text', value: 'ADD'}]},
      {type: 'paragraph', children: [{type: 'text', value: 'Normative ASL source: '}, {type: 'inlineCode', value: 'asl/scalar/alu/ADD.asl'}]},
      {type: 'heading', depth: 2, children: [{type: 'text', value: 'Normative identity'}]},
      {type: 'paragraph', children: [{type: 'text', value: 'The current instruction contract is owned by the ASL source linked above.'}]},
      {type: 'heading', depth: 2, children: [{type: 'text', value: 'Reader guide'}]},
      {type: 'blockquote', children: [{type: 'paragraph', children: [{type: 'text', value: 'Non-normative explanation.'}]}]},
      {type: 'heading', depth: 2, children: [{type: 'text', value: 'Assembly'}]},
      {type: 'heading', depth: 2, children: [{type: 'text', value: 'Operation'}]},
    ],
  };

  presentGeneratedAslReference(tree);

  const renderedText = JSON.stringify(tree);
  assert.match(renderedText, /Instruction identity/);
  assert.match(renderedText, /Behavior/);
  assert.match(renderedText, /Assembly syntax/);
  assert.match(renderedText, /ASL execution definition/);
  assert.doesNotMatch(renderedText, /Non-normative explanation/);
  assert.equal(tree.children.at(-2).children[0].value, 'Sources and release identity');
  assert.match(JSON.stringify(tree.children.at(-1)), /asl\/scalar\/alu\/ADD\.asl/);
});
