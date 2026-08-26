import {execFileSync} from 'node:child_process';
import {existsSync, statSync} from 'node:fs';
import path from 'node:path';

const GITHUB_REPOSITORY = 'https://github.com/PTO-ISA/pto-spec';

interface MarkdownNode {
  type?: string;
  depth?: number;
  url?: string;
  value?: string;
  children?: MarkdownNode[];
}

interface MarkdownFile {
  path?: string;
}

export interface PtoRepositoryLinksOptions {
  repositoryRoot?: string;
  commit?: string;
}

function findRepositoryRoot(start: string): string {
  let current = path.resolve(start);
  while (true) {
    if (existsSync(path.join(current, 'specification.toml'))) return current;
    const parent = path.dirname(current);
    if (parent === current) {
      throw new Error(
        `[pto-repository-links] cannot find specification.toml above ${start}`,
      );
    }
    current = parent;
  }
}

function currentCommit(repositoryRoot: string): string {
  try {
    return execFileSync('git', ['rev-parse', 'HEAD'], {
      cwd: repositoryRoot,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe'],
    }).trim();
  } catch (error) {
    throw new Error(
      `[pto-repository-links] cannot resolve build commit: ${String(error)}`,
    );
  }
}

function isRelativeFileLink(url: string): boolean {
  return !(
    url === '' ||
    url.startsWith('#') ||
    url.startsWith('/') ||
    url.startsWith('//') ||
    /^[A-Za-z][A-Za-z\d+.-]*:/.test(url)
  );
}

function splitSuffix(url: string): {target: string; suffix: string} {
  const marker = url.search(/[?#]/);
  if (marker === -1) return {target: url, suffix: ''};
  return {target: url.slice(0, marker), suffix: url.slice(marker)};
}

function isInside(parent: string, candidate: string): boolean {
  const relative = path.relative(parent, candidate);
  return relative === '' || (!relative.startsWith('..') && !path.isAbsolute(relative));
}

function isGeneratedAslReference(markdownPath: string, repositoryRoot: string): boolean {
  const relative = path.relative(path.join(repositoryRoot, 'docs'), markdownPath).split(path.sep);
  if (['arch', 'block', 'scalar', 'tile'].includes(relative[0] ?? '')) return true;
  return (
    relative[0] === 'site' &&
    relative[1] === 'i18n' &&
    relative[3] === 'docusaurus-plugin-content-docs-reference' &&
    relative[4] === 'current' &&
    ['arch', 'block', 'scalar', 'tile'].includes(relative[5] ?? '')
  );
}

function readerFacingText(value: string): string {
  return value
    .replace(/non-normative/gi, 'illustrative')
    .replace(/非规范性?/g, '示例性');
}

function plainText(node: MarkdownNode): string {
  return typeof node.value === 'string'
    ? node.value
    : (node.children ?? []).map(plainText).join('');
}

function replaceHeading(node: MarkdownNode, labels: Record<string, string>): void {
  if (node.type !== 'heading') return;
  const replacement = labels[plainText(node).trim()];
  if (replacement === undefined) return;
  node.children = [{type: 'text', value: replacement}];
}

export function presentGeneratedAslReference(tree: MarkdownNode): void {
  if (tree.type !== 'root' || tree.children === undefined) return;
  const sourceIdentity: MarkdownNode[] = [];
  const visible: MarkdownNode[] = [];
  for (const node of tree.children) {
    const text = plainText(node).trim();
    if (node.type === 'paragraph' && text.startsWith('Normative ASL source:')) {
      sourceIdentity.push(node);
      continue;
    }
    if (
      (node.type === 'blockquote' && /Non-normative explanation/i.test(text)) ||
      (node.type === 'paragraph' && text === 'The current instruction contract is owned by the ASL source linked above.')
    ) {
      continue;
    }
    replaceHeading(node, {
      'Normative identity': 'Instruction identity',
      'Reader guide': 'Behavior',
      Assembly: 'Assembly syntax',
      Operation: 'ASL execution definition',
      'Normative ASL': 'ASL definition',
    });
    visible.push(node);
  }
  if (sourceIdentity.length > 0) {
    visible.push(
      {type: 'heading', depth: 2, children: [{type: 'text', value: 'Sources and release identity'}]},
      ...sourceIdentity,
    );
  }
  tree.children = visible;
}

export function rewriteRepositoryLink(
  url: string,
  markdownPath: string,
  repositoryRoot: string,
  commit: string,
): string {
  if (!isRelativeFileLink(url)) return url;
  const {target, suffix} = splitSuffix(url);
  if (target === '') return url;

  const docsRoot = path.join(repositoryRoot, 'docs');
  const markdownParts = path.relative(docsRoot, markdownPath).split(path.sep);
  const localized =
    markdownParts[0] === 'site' &&
    markdownParts[1] === 'i18n' &&
    markdownParts[3] === 'docusaurus-plugin-content-docs-reference' &&
    markdownParts[4] === 'current';
  const canonicalMarkdownPath = localized
    ? path.join(docsRoot, ...markdownParts.slice(5))
    : markdownPath;
  const absoluteTarget = path.resolve(path.dirname(canonicalMarkdownPath), target);
  if (isInside(docsRoot, absoluteTarget)) {
    const isDirectory =
      existsSync(absoluteTarget) && statSync(absoluteTarget).isDirectory();
    const hasIndex =
      isDirectory && existsSync(path.join(absoluteTarget, 'index.md'));
    const markdownTarget = isDirectory && hasIndex
      ? path.join(absoluteTarget, 'index.md')
      : absoluteTarget;
    const relative = path.relative(docsRoot, markdownTarget).split(path.sep).join('/');
    const excluded =
      relative.startsWith('site/') ||
      relative.startsWith('mkdocs/') ||
      relative.startsWith('status/plans/');
    if (!excluded && existsSync(markdownTarget) && /\.mdx?$/i.test(markdownTarget)) {
      return `/${relative}${suffix}`;
    }
    if (!isDirectory || hasIndex) {
      if (!excluded) return url;
    }
  }
  if (!isInside(repositoryRoot, absoluteTarget)) {
    throw new Error(
      `[pto-repository-links] ${url} from ${markdownPath} escapes repository root`,
    );
  }

  const repositoryPath = path
    .relative(repositoryRoot, absoluteTarget)
    .split(path.sep)
    .join('/');
  const isDirectory =
    existsSync(absoluteTarget) && statSync(absoluteTarget).isDirectory();
  const view = isDirectory ? 'tree' : 'blob';
  const trailingSlash = isDirectory ? '/' : '';
  return `${GITHUB_REPOSITORY}/${view}/${commit}/${repositoryPath}${trailingSlash}${suffix}`;
}

function transformTree(
  node: MarkdownNode,
  markdownPath: string,
  repositoryRoot: string,
  commit: string,
  readerFacing: boolean,
): void {
  if (readerFacing && node.type === 'text' && typeof node.value === 'string') {
    node.value = readerFacingText(node.value);
  }
  if (
    (node.type === 'link' || node.type === 'definition') &&
    typeof node.url === 'string'
  ) {
    node.url = rewriteRepositoryLink(
      node.url,
      markdownPath,
      repositoryRoot,
      commit,
    );
  }
  for (const child of node.children ?? []) {
    transformTree(child, markdownPath, repositoryRoot, commit, readerFacing);
  }
}

export default function ptoRepositoryLinksRemarkPlugin(
  options: PtoRepositoryLinksOptions = {},
): (tree: MarkdownNode, file: MarkdownFile) => void {
  const repositoryRoot = findRepositoryRoot(
    options.repositoryRoot ?? process.cwd(),
  );
  const commit = options.commit ?? currentCommit(repositoryRoot);

  return (tree: MarkdownNode, file: MarkdownFile): void => {
    if (file.path === undefined) {
      throw new Error('[pto-repository-links] Markdown file has no source path');
    }
    const markdownPath = path.resolve(file.path);
    if (!isInside(path.join(repositoryRoot, 'docs'), markdownPath)) {
      throw new Error(
        `[pto-repository-links] Markdown source is outside docs/: ${markdownPath}`,
      );
    }
    const generatedReference = isGeneratedAslReference(markdownPath, repositoryRoot);
    if (generatedReference) presentGeneratedAslReference(tree);
    transformTree(
      tree,
      markdownPath,
      repositoryRoot,
      commit,
      generatedReference,
    );
  };
}
