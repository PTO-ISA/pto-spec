import React, {useEffect, useState} from 'react';
import styles from './PtoWorkbench.module.css';

export interface WaveDromRegisterField {
  bits: number;
  name: string;
  attr?: string;
}

export interface WaveDromRegisterSource {
  reg: WaveDromRegisterField[];
  config: {
    bits: number;
    fontsize: number;
    hspace: number;
    lanes: number;
    offset: number;
  };
}

type OnmlAttribute = string | number | boolean | undefined;
type OnmlNode = string | number | [string, Record<string, OnmlAttribute>?, ...OnmlNode[]];

interface WaveDromModule {
  renderAny(
    index: number,
    source: WaveDromRegisterSource,
    skin: unknown,
  ): OnmlNode;
  waveSkin: unknown;
}

function camelCaseCssName(name: string): string {
  return name.replace(/-([a-z])/g, (_match, letter: string) => letter.toUpperCase());
}

function styleObject(value: OnmlAttribute): React.CSSProperties | undefined {
  if (typeof value !== 'string') return undefined;
  return value.split(';').reduce<Record<string, string>>((result, declaration) => {
    const separator = declaration.indexOf(':');
    if (separator <= 0) return result;
    const property = camelCaseCssName(declaration.slice(0, separator).trim());
    const propertyValue = declaration.slice(separator + 1).trim();
    if (property && propertyValue) result[property] = propertyValue;
    return result;
  }, {}) as React.CSSProperties;
}

function reactAttributeName(name: string): string {
  if (name === 'class') return 'className';
  if (name === 'xmlns:xlink') return 'xmlnsXlink';
  if (name === 'xlink:href') return 'xlinkHref';
  if (name === 'xml:space') return 'xmlSpace';
  if (name === 'field') return 'data-field';
  if (name.startsWith('aria-') || name.startsWith('data-')) return name;
  return camelCaseCssName(name);
}

function reactAttributes(
  attributes: Record<string, OnmlAttribute>,
): Record<string, unknown> {
  return Object.entries(attributes).reduce<Record<string, unknown>>((result, [name, value]) => {
    if (value === undefined || /^on/i.test(name)) return result;
    if (name === 'style') {
      const style = styleObject(value);
      if (style) result.style = style;
      return result;
    }
    result[reactAttributeName(name)] = value;
    return result;
  }, {});
}

function onmlToReact(node: OnmlNode, key: string): React.ReactNode {
  if (!Array.isArray(node)) return node;
  const [tag, candidateAttributes, ...candidateChildren] = node;
  const hasAttributes = candidateAttributes !== undefined &&
    !Array.isArray(candidateAttributes) && typeof candidateAttributes === 'object';
  const attributes = hasAttributes
    ? reactAttributes(candidateAttributes as Record<string, OnmlAttribute>)
    : {};
  const children = hasAttributes
    ? candidateChildren
    : ([candidateAttributes, ...candidateChildren].filter((child) => child !== undefined) as OnmlNode[]);
  return React.createElement(
    tag,
    {...attributes, key},
    ...children.map((child, index) => onmlToReact(child, `${key}-${index}`)),
  );
}

export default function WaveDromRegisterDiagram({
  label,
  source,
}: {
  label: string;
  source: WaveDromRegisterSource;
}): React.JSX.Element {
  const [diagram, setDiagram] = useState<OnmlNode>();
  const [loadFailed, setLoadFailed] = useState(false);

  useEffect(() => {
    let mounted = true;
    import('wavedrom')
      .then((loaded) => {
        const wavedrom = loaded as unknown as WaveDromModule;
        if (!mounted) return;
        const rendered = wavedrom.renderAny(0, source, wavedrom.waveSkin);
        if (Array.isArray(rendered) && typeof rendered[1] === 'object' && !Array.isArray(rendered[1])) {
          rendered[1] = {
            ...rendered[1],
            role: 'img',
            'aria-label': label,
            focusable: 'false',
          };
        }
        setDiagram(rendered);
      })
      .catch(() => {
        if (mounted) setLoadFailed(true);
      });
    return () => {
      mounted = false;
    };
  }, [label, source]);

  return (
    <div
      aria-label={`${label}; scroll horizontally to inspect the complete diagram`}
      className={styles.waveDromViewport}
      data-wavedrom-source="catalog-encoding-json"
      tabIndex={0}
    >
      {diagram
        ? onmlToReact(diagram, 'wavedrom-register')
        : (
          <p className={styles.waveDromLoading} role="note">
            {loadFailed
              ? 'WaveDrom diagram unavailable. Use the encoding table or WaveJSON below.'
              : 'Loading WaveDrom diagram… The encoding table and WaveJSON remain available below.'}
          </p>
        )}
    </div>
  );
}
