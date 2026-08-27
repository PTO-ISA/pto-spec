import type {Config} from '@docusaurus/types';
import type {Options, ThemeConfig} from '@docusaurus/preset-classic';
import type {PluginOptions as DocsPluginOptions} from '@docusaurus/plugin-content-docs';
import {themes as prismThemes} from 'prism-react-renderer';
import {readFileSync} from 'node:fs';
import ptoRepositoryLinksRemarkPlugin from './plugins/pto-content/remark-repository-links';
import {legacyReferenceRoute, unitRoute, type UnitRouteInput} from './plugins/pto-content/routes';
import {registerAslPrism} from './src/theme/aslPrism';

registerAslPrism();

const checkedRedirects = JSON.parse(
  readFileSync(new URL('./redirects.json', import.meta.url), 'utf8'),
) as Array<{from: string[]; to: string}>;
const traceability = JSON.parse(
  readFileSync(
    new URL('../../spec/evidence/release-traceability-readiness.json', import.meta.url),
    'utf8',
  ),
) as {units: UnitRouteInput[]};
const redirects = [
  ...checkedRedirects,
  ...traceability.units.map((unit) => ({
    from: [legacyReferenceRoute(unit.documentation)],
    to: unitRoute(unit),
  })),
];

function sidebarKeySegment(label: string): string {
  return label
    .normalize('NFKD')
    .trim()
    .toLocaleLowerCase('en-US')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

type SidebarItemLike = {
  type: string;
  label?: string;
  key?: string;
  items?: unknown[];
};

function addStableCategoryKeys<T>(
  items: T[],
  ancestors: string[] = [],
): T[] {
  return items.map((item) => {
    const category = item as T & SidebarItemLike;
    if (
      category.type !== 'category' ||
      category.label === undefined ||
      category.items === undefined
    ) {
      return item;
    }

    const path = [...ancestors, sidebarKeySegment(category.label)];
    return {
      ...category,
      key: `pto-category:${path.join('/')}`,
      items: addStableCategoryKeys(category.items, path),
    } as T;
  });
}

const stableSidebarItemsGenerator: NonNullable<
  DocsPluginOptions['sidebarItemsGenerator']
> = async ({
  defaultSidebarItemsGenerator,
  item,
  ...args
}) => addStableCategoryKeys(
  await defaultSidebarItemsGenerator({item, ...args}),
  [sidebarKeySegment(item.dirName)],
);

const config: Config = {
  title: 'PTO Formal Specification',
  tagline: 'Source-backed architecture contracts for PTO ISA implementers',
  url: 'https://pto-isa.github.io',
  baseUrl: '/',
  organizationName: 'PTO-ISA',
  projectName: 'pto-spec',
  trailingSlash: true,
  onBrokenLinks: 'throw',
  markdown: {
    format: 'detect',
    hooks: {
      onBrokenMarkdownLinks: 'throw',
    },
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'zh-CN'],
    localeConfigs: {
      en: {
        label: 'English',
        htmlLang: 'en',
      },
      'zh-CN': {
        label: '简体中文',
        htmlLang: 'zh-CN',
      },
    },
  },

  presets: [
    [
      'classic',
      {
        docs: false,
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Options,
    ],
  ],

  plugins: [
    './plugins/pto-content/index.ts',
    [
      '@docusaurus/plugin-client-redirects',
      {redirects},
    ],
    [
      '@docusaurus/plugin-content-docs',
      {
        id: 'reference',
        path: '..',
        routeBasePath: 'reference',
        sidebarPath: './sidebars.ts',
        exclude: [
          'arch/**',
          'block/**',
          'scalar/**',
          'tile/**',
          'site/**',
          'mkdocs/**',
          'status/plans/**',
        ],
        beforeDefaultRemarkPlugins: [ptoRepositoryLinksRemarkPlugin],
        sidebarItemsGenerator: stableSidebarItemsGenerator,
        showLastUpdateAuthor: true,
        showLastUpdateTime: true,
      },
    ],
  ],

  themeConfig: {
    colorMode: {
      defaultMode: 'dark',
      respectPrefersColorScheme: false,
    },
    navbar: {
      title: 'PTO SPEC',
      hideOnScroll: false,
      items: [
        {
          to: '/architecture/',
          label: 'Architecture',
          position: 'left',
        },
        {
          to: '/instructions/',
          label: 'Instructions',
          position: 'left',
        },
        {
          to: '/ndf/',
          label: 'NDF',
          position: 'left',
        },
        {
          to: '/reference/governance/adr-process/',
          label: 'Decisions',
          position: 'left',
        },
        {to: '/search/', label: 'Search', position: 'left'},
        {type: 'localeDropdown', position: 'right'},
        {
          href: 'https://github.com/PTO-ISA/pto-spec',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Specification',
          items: [
            {
              label: 'Architecture',
              to: '/architecture/',
            },
            {
              label: 'Scalar surface',
              to: '/instructions/?surface=scalar',
            },
            {label: 'Block surface', to: '/instructions/?surface=block'},
            {label: 'Tile surface', to: '/instructions/?surface=tile'},
          ],
        },
        {
          title: 'Records',
          items: [
            {
              label: 'ADR process',
              to: '/reference/governance/adr-process/',
            },
            {label: 'NDF Explorer', to: '/explore/ndf/'},
            {label: 'Releases', to: '/reference/releases/'},
            {
              label: 'Source repository',
              href: 'https://github.com/PTO-ISA/pto-spec',
            },
          ],
        },
        {
          title: 'Project',
          items: [
            {
              label: 'Governance',
              to: '/reference/governance/adr-process/',
            },
          ],
        },
      ],
      copyright:
        'PTO Formal Specification Portal — generated from the verified release source.',
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash', 'json', 'toml'],
    },
    metadata: [
      {
        name: 'description',
        content:
          'The release-verified PTO ISA formal specification portal for implementers and reviewers.',
      },
    ],
  } satisfies ThemeConfig,
};

export default config;
