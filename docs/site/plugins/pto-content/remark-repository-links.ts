import {execFileSync} from 'node:child_process';
import {existsSync, statSync} from 'node:fs';
import path from 'node:path';

const GITHUB_REPOSITORY = 'https://github.com/PTO-ISA/pto-spec';

interface MarkdownNode {
  type?: string;
  url?: string;
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
): void {
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
    transformTree(child, markdownPath, repositoryRoot, commit);
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
    transformTree(tree, markdownPath, repositoryRoot, commit);
  };
}
