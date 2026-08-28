import type {
  PtoGraphNodeKind,
  PtoNdfGraphData,
} from '../../src/types/pto';

function fail(message: string): never {
  throw new Error(`[pto-content] ${message}`);
}

export function ndfOverviewSvg(graph: PtoNdfGraphData): string {
  const width = 1200;
  const height = 520;
  const horizontalPadding = 54;
  const verticalPadding = 28;
  const kinds: PtoGraphNodeKind[] = ['adr', 'ndf', 'asl', 'avs'];
  const colors: Record<PtoGraphNodeKind, string> = {
    adr: '#d89a3d',
    ndf: '#f15b61',
    asl: '#d9b85c',
    avs: '#53b88a',
  };
  const coordinates = new Map<string, {x: number; y: number}>();
  const xValues = graph.nodes.map((node) => node.x);
  const yValues = graph.nodes.map((node) => node.y);
  if (
    graph.nodes.length === 0 ||
    !xValues.every(Number.isFinite) ||
    !yValues.every(Number.isFinite)
  ) {
    fail('overview requires finite deterministic positions');
  }
  const minimumX = Math.min(...xValues);
  const maximumX = Math.max(...xValues);
  const minimumY = Math.min(...yValues);
  const maximumY = Math.max(...yValues);
  const xRange = maximumX - minimumX || 1;
  const yRange = maximumY - minimumY || 1;
  for (const node of graph.nodes) {
    coordinates.set(node.id, {
      x: Math.round(
        horizontalPadding +
          ((node.x - minimumX) / xRange) * (width - horizontalPadding * 2),
      ),
      y: Math.round(
        verticalPadding +
          ((node.y - minimumY) / yRange) * (height - verticalPadding * 2),
      ),
    });
  }

  const edgePath = graph.edges.map((edge) => {
    const source = coordinates.get(edge.source);
    const target = coordinates.get(edge.target);
    if (source === undefined || target === undefined) {
      fail(`overview edge references missing node ${edge.source} -> ${edge.target}`);
    }
    const midpoint = Math.round((source.x + target.x) / 2);
    return `M${source.x} ${source.y}C${midpoint} ${source.y} ${midpoint} ${target.y} ${target.x} ${target.y}`;
  }).join('');
  const nodePaths = kinds.map((kind) => {
    const points = graph.nodes
      .filter((node) => node.kind === kind)
      .map((node) => {
        const point = coordinates.get(node.id);
        if (point === undefined) fail(`overview is missing node ${node.id}`);
        return `M${point.x} ${point.y}h.01`;
      })
      .join('');
    return `<path d="${points}" fill="none" stroke="${colors[kind]}" stroke-linecap="round" stroke-width="4"/>`;
  });
  const guides = kinds.map((kind) => {
    const representative = graph.nodes.find((node) => node.kind === kind);
    if (representative === undefined) fail(`overview has no ${kind} nodes`);
    const x = coordinates.get(representative.id)?.x;
    if (x === undefined) fail(`overview is missing ${kind} guide position`);
    return `<path d="M${x} ${verticalPadding}V${height - verticalPadding}" stroke="#756b70" stroke-opacity=".22"/>`;
  });
  const nodeCount = graph.nodes.length;
  const edgeCount = graph.edges.length;
  return [
    '<?xml version="1.0" encoding="UTF-8"?>',
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${width} ${height}" preserveAspectRatio="xMidYMid meet" data-source-commit="${graph.release.commit}" data-node-count="${nodeCount}" data-edge-count="${edgeCount}">`,
    `<title>Complete NDF relationship overview with ${nodeCount} nodes and ${edgeCount} relationships</title>`,
    '<rect width="1200" height="520" rx="8" fill="#101014"/>',
    ...guides,
    `<path d="${edgePath}" fill="none" stroke="#a79da1" stroke-opacity=".14" stroke-width=".7"/>`,
    ...nodePaths,
    '</svg>',
    '',
  ].join('\n');
}
