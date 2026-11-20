export const manualSections = [
  'scalar',
  'float',
  'block',
  'cube',
  'vector',
  'tma',
  'encoding',
] as const;

export type ManualSection = typeof manualSections[number];

export interface ManualCategoryEntry {
  id: string;
  mnemonic: string;
  summary: string;
  group: string;
  href: string;
}

export interface ManualEncodingRow {
  id: string;
  mnemonic: string;
  href?: string;
  format: string;
  patterns: string[];
  variant?: string;
  constraints?: string[];
  status: string;
}

export interface ManualEncodingSection {
  id: string;
  label: string;
  rows: ManualEncodingRow[];
}

export type ManualIndexData =
  | {
      section: Exclude<ManualSection, 'encoding'>;
      entries: ManualCategoryEntry[];
      release?: PtoReleaseIdentity;
    }
  | {
      section: 'encoding';
      groups: ManualEncodingSection[];
      release?: PtoReleaseIdentity;
    };

export const manualSectionCopy: Record<ManualSection, {title: string; description: string; zhTitle: string; zhDescription: string}> = {
  scalar: {
    title: 'Scalar instructions',
    description: 'Integer, address, memory, atomic, control-flow, and system instructions.',
    zhTitle: 'Scalar 指令',
    zhDescription: '整数、地址、访存、原子、控制流和系统指令。',
  },
  float: {
    title: 'Floating-point instructions',
    description: 'Scalar floating-point arithmetic, comparison, conversion, and special functions.',
    zhTitle: '浮点指令',
    zhDescription: 'Scalar 浮点算术、比较、转换和特殊函数。',
  },
  block: {
    title: 'Block instructions',
    description: 'Bundle lifecycle, execution entry, attributes, operands, and encoding commands.',
    zhTitle: 'Block 指令',
    zhDescription: 'Bundle 生命周期、执行入口、属性、操作数和编码命令。',
  },
  cube: {
    title: 'Cube instructions',
    description: 'Matrix and matrix-vector operations executed by the CUBE engine.',
    zhTitle: 'Cube 指令',
    zhDescription: '由 CUBE 引擎执行的矩阵与矩阵向量操作。',
  },
  vector: {
    title: 'Vector instructions',
    description: 'Elementwise VEC operations and specialized SFU tile operations.',
    zhTitle: 'Vector 指令',
    zhDescription: '逐元素 VEC 操作和专用 SFU Tile 操作。',
  },
  tma: {
    title: 'TMA instructions',
    description: 'TLSU memory access, indexed transfer, prefetch, and data-movement operations.',
    zhTitle: 'TMA 指令',
    zhDescription: 'TLSU 访存、索引传输、预取和数据搬运操作。',
  },
  encoding: {
    title: 'Encoding table',
    description: 'Physical scalar and Block forms, Tile selectors, and declared reservations.',
    zhTitle: '编码表',
    zhDescription: 'Scalar 和 Block 物理格式、Tile selector 以及已声明的保留编码。',
  },
};

export function manualSectionPath(section: ManualSection): string {
  return `/instructions/${section}/`;
}
import type {PtoReleaseIdentity} from '@site/src/types/pto';
