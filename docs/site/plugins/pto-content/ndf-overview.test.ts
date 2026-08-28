import assert from 'node:assert/strict';
import test from 'node:test';
import type {PtoGraphNodeKind, PtoNdfGraphData} from '../../src/types/pto';
import {ndfOverviewSvg} from './ndfOverview.ts';

const release = {
  architectureVersion: '0.0.0',
  publicationVersion: '0.0.0.0',
  commit: '0123456789abcdef0123456789abcdef01234567',
  tag: 'v0.0.0.0',
  tagged: false,
  releaseEligible: false,
};

function node(id: string, kind: PtoGraphNodeKind, x: number, y: number) {
  return {
    id,
    kind,
    label: id,
    x,
    y,
    sourcePath: null,
    sourceUrl: null,
    sourceSha256: null,
    clauseSha256: null,
    startLine: null,
    endLine: null,
    status: null,
  };
}

test('NDF overview preserves the explorer positions and complete topology', () => {
  const graph: PtoNdfGraphData = {
    release,
    nodes: [
      node('ADR-1', 'adr', 0, 0),
      node('NDF-1', 'ndf', 1, -1),
      node('NDF-2', 'ndf', 1, 1),
      node('ASL-1', 'asl', 2, -2),
      node('ASL-2', 'asl', 2, 0),
      node('ASL-3', 'asl', 2, 2),
      node('AVS-1', 'avs', 3, -3),
      node('AVS-2', 'avs', 3, -1),
      node('AVS-3', 'avs', 3, 1),
      node('AVS-4', 'avs', 3, 3),
    ],
    edges: [
      {id: 'edge-1', kind: 'adr-affects-ndf', source: 'ADR-1', target: 'NDF-1'},
      {id: 'edge-2', kind: 'ndf-owned-by-asl', source: 'NDF-1', target: 'ASL-1'},
      {id: 'edge-3', kind: 'asl-covered-by-avs', source: 'ASL-1', target: 'AVS-1'},
    ],
    counts: {adr: 1, ndf: 2, asl: 3, avs: 4},
  };

  const svg = ndfOverviewSvg(graph);
  assert.match(svg, /data-node-count="10"/);
  assert.match(svg, /data-edge-count="3"/);
  assert.equal(svg.match(/h\.01/g)?.length, graph.nodes.length);
  const edgePath = svg.match(/<path d="([^"]*)" fill="none" stroke="#a79da1"/);
  assert.equal(edgePath?.[1].match(/C/g)?.length, graph.edges.length);
  assert.match(svg, /M54 260h\.01/);
  assert.match(svg, /M418 183h\.01M418 337h\.01/);
  assert.doesNotMatch(svg, /M418 28h\.01/);
});
