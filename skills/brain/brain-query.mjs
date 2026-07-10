/**
 * brain-query.mjs — query the brain by keywords
 * Usage: node skills/brain/brain-query.mjs <terms...> [--top=N] [--type=feedback]
 * Ex:    node skills/brain/brain-query.mjs deploy docker
 *        node skills/brain/brain-query.mjs auth --top=10
 *        node skills/brain/brain-query.mjs tests --type=feedback
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));
const MEMORY_DIR = process.env.MEMORY_DIR || path.resolve(SCRIPT_DIR, '../../memory');
const GRAPH = path.join(MEMORY_DIR, 'graph.json');

const args     = process.argv.slice(2);
const terms    = args.filter(a => !a.startsWith('--')).map(t => t.toLowerCase());
const topFlag  = args.find(a => a.startsWith('--top='));
const typeFlag = args.find(a => a.startsWith('--type='));
const TOP      = topFlag  ? parseInt(topFlag.split('=')[1], 10) : 5;
const TYPE     = typeFlag ? typeFlag.split('=')[1] : null;

if (terms.length === 0) {
  console.error('Usage: node brain-query.mjs <terms...> [--top=N] [--type=feedback]');
  process.exit(1);
}

if (!fs.existsSync(GRAPH)) {
  console.error('graph.json not found. Build it first: node skills/brain/build-graph.mjs');
  process.exit(1);
}

const graph = JSON.parse(fs.readFileSync(GRAPH, 'utf8'));

// Score = keyword matches (title + tags + body) * weight + centrality bonus
function score(node) {
  if (TYPE && node.type !== TYPE) return 0;
  const hay = (node.title + ' ' + (node.tags || []).join(' ') + ' ' + node.body).toLowerCase();
  let hits = 0;
  for (const t of terms) {
    const re  = new RegExp('\\b' + t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gi');
    const m   = hay.match(re);
    if (m) hits += m.length;
  }
  if (hits === 0) return 0;
  return hits * (1 + node.centrality);
}

const ranked = graph.nodes
  .map(n => ({ n, s: score(n) }))
  .filter(x => x.s > 0)
  .sort((a, b) => b.s - a.s)
  .slice(0, TOP);

if (ranked.length === 0) { console.log('No results.'); process.exit(0); }

console.log('Top ' + ranked.length + ' for: ' + terms.join(' ') + (TYPE ? ' [type=' + TYPE + ']' : ''));
console.log('');
for (const { n, s } of ranked) {
  const neigh = graph.edges
    .filter(e => e.from === n.id || e.to === n.id)
    .sort((a, b) => b.weight - a.weight).slice(0, 3)
    .map(e => e.from === n.id ? e.to : e.from);
  console.log('  [' + s.toFixed(1).padStart(5) + '] ' + n.id + '.md  (' + n.type + ', deg=' + n.degree + ')');
  console.log('          --> ' + (neigh.join(', ') || '-'));
}
