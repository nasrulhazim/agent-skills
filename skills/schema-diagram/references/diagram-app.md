# Diagram app — `resources/js/erd/`

A React Flow island: seven small modules plus `erd.css` (see `diagram-styles.md`). Bundled to
one IIFE and inlined into the HTML — see `build-pipeline.md`.

```
resources/js/erd/
├── index.jsx          mount, parse the inlined payload
├── ErdBoard.jsx       filters, search, selection, layout, theme
├── TableNode.jsx      one table card
├── RelationEdge.jsx   one foreign key
├── Inspector.jsx      the selected table, in full
├── About.jsx          the landing panel — see below
├── geometry.js        node sizing, shared with erd.css
├── layout.js          dagre
└── erd.css            the whole visual system
```

## The five things that break if you rewrite this from scratch

Every one of these is a silent failure — the document renders, and is wrong. There is no
error, no warning, and no console output for any of them.

1. **Giving a node `width`/`height` makes it skip measurement, and every edge vanishes.**
   The single most expensive trap here. Handle bounds are computed during the DOM measurement
   pass; declaring the box tells React Flow the node is *already* measured, so `handleBounds`
   stays `undefined`, `getEdgePosition` returns null, and `EdgeWrapper` returns null for the
   edge. Every card draws perfectly and every relation is gone.

   Use **`initialWidth` / `initialHeight`** — same numbers, node still gets measured. Seed them
   at all because the **minimap** reads the *user* node (`getNodeDimensions(userNode)`) rather
   than the internals, and nothing writes `measured` back onto the object the app owns, so an
   unseeded node draws no minimap rectangle.

2. **Handles that are not in the DOM drop their edge without a word.** React Flow resolves an
   edge by handle id; a missing id does not fall back to the node. Both the per-column handles
   and a node-level `s:*` / `t:*` pair are always rendered, and the board only names a column
   handle when that column is actually drawn at the current detail level.
3. **React Flow caches handle bounds per node and does not re-read them when handles move.**
   Changing direction or detail moves every handle, so `useUpdateNodeInternals` must be called
   with **every id in one call** — one call per node is one store update per node.
4. **`fitView` frames what the store holds, and until nodes are measured the store holds
   nothing.** Fitting on a timer is a race the document loses on a slow machine, a background
   tab, or a late font. Use `useNodesInitialized`, which is the event rather than a guess.
5. **Re-deriving nodes on selection throws away every measurement and every drag.** The
   laid-out graph depends only on *what is drawn*; selection and search are painted onto the
   nodes already in state, returning the identical object when nothing changed.

## Debugging this in a browser

**A Chrome tab that is not painting throttles `ResizeObserver` and `requestAnimationFrame`.**
Nodes stay `visibility: hidden`, `fitView` never lands, and a pure-JS assertion reports a
perfectly healthy page as broken. Take a **screenshot first** — that forces a frame — and only
then trust what the DOM tells you.

This matters more than it sounds: it is exactly the symptom set of trap 1 above, so an
unpainted tab will happily confirm a bug that is not there. Two wrong diagnoses in one session
came from this.

## Interaction model

| Control | Behaviour |
|---|---|
| **Detail**: Names / Keys / All | Keys draws PK, FK and unique columns — the ones that carry structure. Search hits are always shown regardless of level, so a match is never hidden behind a filter |
| **Domains** | Toggle chips, coloured by the domain map. `system` starts off |
| **Search** | Debounced 220 ms. Matches table *and* column names — someone working from an error message has a column name, not a table |
| **Click a table** | Opens the Inspector, dims everything but the table and its direct joins, lights those edges and shows their labels |
| **Focus** | Removes everything that is not the selection or a direct join |
| **Direction** | LR anchors edges to the *row* that holds the key; TB anchors to the node, since there is no row to point at across a vertical gap |
| **Theme** | Flips `data-theme` on `<html>`; every colour resolves through a token |

## `index.jsx`

Mount point. Parses the inlined payload and renders the board.

```jsx
import React from 'react';
import { createRoot } from 'react-dom/client';
import '@xyflow/react/dist/style.css';

import ErdBoard from './ErdBoard';
import './erd.css';

/*
 * The schema is inlined into the document at build time rather than fetched:
 * the file has to work from `file://`, where every request is cross-origin and
 * a fetch of a sibling JSON is refused.
 */
const payload = JSON.parse(document.getElementById('erd-schema').textContent);
const mount = document.getElementById('erd-root');

mount.innerHTML = '';

createRoot(mount).render(<ErdBoard schema={payload} />);
```

## `geometry.js`

Node geometry. **Must agree with `erd.css`** — dagre lays out from these numbers before anything is measured, and the per-column handles are positioned from them.

```js
/*
 * Node geometry, kept in one place because two things depend on it agreeing
 * with erd.css: dagre lays out from these numbers before anything is measured,
 * and the per-column handles are positioned from them. If a row's height
 * changes in the stylesheet and not here, edges anchor a few pixels off the
 * row they belong to — which reads as a rendering bug rather than a constant.
 */

export const NODE_W = 300;
export const HEAD_H = 33;
export const ROW_H = 23;
export const MORE_H = 23;
export const MORPH_H = 27;

/** Columns a node shows at a given detail level. */
export function visibleColumns(table, detail, term) {
    if (detail === 'compact') {
        return [];
    }

    if (detail === 'full') {
        return table.columns;
    }

    // "keys" — the structural columns, plus anything the search is looking for,
    // so a hit is never hidden behind the detail level that is currently on.
    return table.columns.filter(
        (column) =>
            column.pk ||
            column.fk ||
            column.unique ||
            (term.length > 0 && column.name.toLowerCase().includes(term))
    );
}

export function nodeHeight(table, rows) {
    if (rows.length === 0) {
        return HEAD_H;
    }

    const hidden = table.columns.length - rows.length;

    return (
        HEAD_H +
        rows.length * ROW_H +
        (hidden > 0 ? MORE_H : 0) +
        (table.morphs.length > 0 ? MORPH_H : 0)
    );
}

/** Vertical centre of a row, measured from the top of the node. */
export function rowCentre(index) {
    return HEAD_H + index * ROW_H + ROW_H / 2;
}
```

## `layout.js`

Dagre layout. Self-referencing edges are skipped: they make dagre loop forever on rank assignment.

```js
import dagre from '@dagrejs/dagre';

import { NODE_W } from './geometry';

/*
 * Dagre.
 *
 * The separations are wider than a plain flow graph's because an ERD carries far
 * more edges per node — a hundred-table schema runs to well over a hundred
 * relations — and edges that share a corridor become impossible to follow long
 * before they actually overlap.
 */
export function layout(nodes, edges, direction) {
    const graph = new dagre.graphlib.Graph();

    graph.setDefaultEdgeLabel(() => ({}));
    graph.setGraph({
        rankdir: direction,
        nodesep: direction === 'LR' ? 30 : 60,
        ranksep: direction === 'LR' ? 150 : 120,
        edgesep: 18,
        marginx: 40,
        marginy: 40,
    });

    nodes.forEach((node) => {
        graph.setNode(node.id, { width: NODE_W, height: node.data.height });
    });

    edges.forEach((edge) => {
        // Self-references (a table whose foreign key points at itself, such as a
        // `parent_id` tree) make dagre loop forever on rank assignment.
        if (edge.source !== edge.target) {
            graph.setEdge(edge.source, edge.target);
        }
    });

    dagre.layout(graph);

    return nodes.map((node) => {
        const positioned = graph.node(node.id);

        return {
            ...node,
            position: {
                x: positioned.x - NODE_W / 2,
                y: positioned.y - node.data.height / 2,
            },
        };
    });
}
```

## `TableNode.jsx`

One table card. The handle strategy is the fiddly part — read the docblock before touching it.

```jsx
import React, { memo } from 'react';
import { Handle, Position } from '@xyflow/react';

import { NODE_W, rowCentre } from './geometry';

/**
 * One table.
 *
 * Handles are the fiddly part. In LR the diagram reads as a real ERD only if a
 * foreign key leaves the row that holds it and arrives at the row it
 * references, so every visible column carries its own pair; in TB there is no
 * row to point at across a vertical gap, so the node-level pair is used
 * instead. Both sets are always rendered — React Flow resolves an edge by
 * handle id, and an edge naming a handle that is not in the DOM is dropped
 * silently rather than falling back.
 *
 * `ErdBoard` calls `useUpdateNodeInternals` whenever the direction or the
 * detail level changes: React Flow caches handle bounds per node and does not
 * re-read them when handles move, so without it the rows lay out correctly and
 * the edges keep pointing at where the handles used to be.
 */
function TableNode({ id, data }) {
    const { table, rows, color, state, hits, horizontal } = data;
    const hidden = table.columns.length - rows.length;

    const source = horizontal ? Position.Right : Position.Bottom;
    const target = horizontal ? Position.Left : Position.Top;

    return (
        <div
            className={[
                'erd-node',
                state === 'selected' ? 'is-selected' : '',
                state === 'neighbour' ? 'is-neighbour' : '',
                state === 'dim' ? 'is-dim' : '',
            ]
                .filter(Boolean)
                .join(' ')}
            style={{ '--accent': color, width: NODE_W }}
        >
            <Handle type="source" position={source} id="s:*" style={{ top: '50%' }} />
            <Handle type="target" position={target} id="t:*" style={{ top: '50%' }} />

            {horizontal &&
                rows.map((column, index) => (
                    <React.Fragment key={`h-${column.name}`}>
                        <Handle
                            type="source"
                            position={Position.Right}
                            id={`s:${column.name}`}
                            style={{ top: rowCentre(index) }}
                        />
                        <Handle
                            type="target"
                            position={Position.Left}
                            id={`t:${column.name}`}
                            style={{ top: rowCentre(index) }}
                        />
                    </React.Fragment>
                ))}

            <div className="erd-node-head">
                <div className="erd-node-name" title={table.name}>
                    {table.name}
                </div>
                <div className="erd-node-meta">{table.columns.length}</div>
            </div>

            {rows.length > 0 && (
                <div className="erd-rows">
                    {rows.map((column) => (
                        <div
                            key={column.name}
                            className={[
                                'erd-row',
                                column.pk || column.fk || column.unique ? 'is-key' : '',
                                hits.has(column.name) ? 'is-hit' : '',
                            ]
                                .filter(Boolean)
                                .join(' ')}
                        >
                            <span className={keyClass(column)}>{keyLabel(column)}</span>
                            <span className="erd-col" title={column.name}>
                                {column.name}
                            </span>
                            <span className="erd-type" title={column.type}>
                                {column.type}
                            </span>
                            {column.nullable && <span className="erd-null">NULL</span>}
                        </div>
                    ))}
                </div>
            )}

            {hidden > 0 && rows.length > 0 && (
                <div className="erd-row-more">+{hidden} more</div>
            )}

            {table.morphs.length > 0 && (
                <div className="erd-morph">
                    {table.morphs.map((morph) => (
                        <span
                            className="erd-morph-tag"
                            key={morph}
                            title={`Polymorphic: ${morph}_type + ${morph}_id resolve at runtime, so there is no edge to draw.`}
                        >
                            {morph}_*
                        </span>
                    ))}
                </div>
            )}
        </div>
    );
}

function keyClass(column) {
    if (column.pk) {
        return 'erd-key is-pk';
    }

    if (column.fk) {
        return 'erd-key is-fk';
    }

    if (column.unique) {
        return 'erd-key is-uk';
    }

    return 'erd-key';
}

function keyLabel(column) {
    if (column.pk) {
        return 'PK';
    }

    if (column.fk) {
        return 'FK';
    }

    if (column.unique) {
        return 'UQ';
    }

    return '';
}

export default memo(TableNode);
```

## `RelationEdge.jsx`

One foreign key. Labels are drawn through `EdgeLabelRenderer`, and only on a lit edge.

```jsx
import React, { memo } from 'react';
import { BaseEdge, EdgeLabelRenderer, getSmoothStepPath } from '@xyflow/react';

/**
 * A foreign key.
 *
 * The label is drawn through `EdgeLabelRenderer` rather than inside the edge's
 * own SVG group: a group is painted in render order, so any edge drawn after
 * this one would cross straight through its text. On a schema where dozens of
 * relations converge on one hub table that is most of them.
 *
 * Labels appear only on a lit edge — one connected to whatever is selected.
 * A hundred and sixty of them at once is not a diagram.
 */
function RelationEdge({
    id,
    sourceX,
    sourceY,
    targetX,
    targetY,
    sourcePosition,
    targetPosition,
    markerEnd,
    style,
    data,
}) {
    const [path, labelX, labelY] = getSmoothStepPath({
        sourceX,
        sourceY,
        targetX,
        targetY,
        sourcePosition,
        targetPosition,
        borderRadius: 10,
    });

    return (
        <>
            <BaseEdge id={id} path={path} style={style} markerEnd={markerEnd} />
            {data.lit && (
                <EdgeLabelRenderer>
                    <div
                        className="erd-edge-label"
                        style={{
                            position: 'absolute',
                            transform: `translate(-50%, -50%) translate(${labelX}px, ${labelY}px)`,
                        }}
                    >
                        <b>{data.column}</b>
                        <i> → {data.references}</i>
                        {data.onDelete && data.onDelete !== 'no action' && (
                            <i> · on delete {data.onDelete}</i>
                        )}
                    </div>
                </EdgeLabelRenderer>
            )}
        </>
    );
}

export default memo(RelationEdge);
```

## `Inspector.jsx`

The side panel: every column, both directions of relation, morphs, indexes.

```jsx
import React from 'react';

/**
 * Everything about one table that the node itself cannot hold.
 *
 * Relations are listed in both directions on purpose. "What does this table
 * point at" is answerable from the columns; "what points at this table" is the
 * question that decides whether a change is safe, and it is invisible from the
 * row itself.
 */
export default function Inspector({ table, domain, incoming, onSelect, onClose }) {
    return (
        <aside className="erd-inspector" style={{ '--accent': domain.color }}>
            <div className="erd-inspector-head">
                <div className="erd-inspector-title">
                    <h2 title={table.name}>{table.name}</h2>
                    <span className="erd-inspector-domain">{domain.label}</span>
                </div>
                <button className="erd-btn erd-btn-ghost" onClick={onClose} aria-label="Close">
                    ✕
                </button>
            </div>

            <div className="erd-inspector-scroll">
                <h3>
                    Columns <span className="erd-count">{table.columns.length}</span>
                </h3>
                <table className="erd-table">
                    <tbody>
                        {table.columns.map((column) => (
                            <tr key={column.name}>
                                <td>
                                    <span className={keyClass(column)}>{keyLabel(column)}</span>
                                </td>
                                <td className="erd-t-name">
                                    {column.name}
                                    {column.nullable && <span className="erd-null"> NULL</span>}
                                </td>
                                <td className="erd-t-type">{column.type}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>

                <h3>
                    References <span className="erd-count">{table.foreign_keys.length}</span>
                </h3>
                {table.foreign_keys.length === 0 ? (
                    <p className="erd-empty">
                        No foreign keys. Any relation this table has is declared in Eloquent
                        only.
                    </p>
                ) : (
                    table.foreign_keys.map((key) => (
                        <button
                            className="erd-rel"
                            key={`out-${key.columns.join()}-${key.table}`}
                            onClick={() => onSelect(key.table)}
                        >
                            {key.on_delete && key.on_delete !== 'no action' && (
                                <span className="erd-rel-del">{key.on_delete}</span>
                            )}
                            <i>{key.columns.join(', ')} → </i>
                            <b>{key.table}</b>
                            <i>.{key.references.join(', ')}</i>
                        </button>
                    ))
                )}

                <h3>
                    Referenced by <span className="erd-count">{incoming.length}</span>
                </h3>
                {incoming.length === 0 ? (
                    <p className="erd-empty">Nothing points at this table.</p>
                ) : (
                    incoming.map((ref) => (
                        <button
                            className="erd-rel"
                            key={`in-${ref.from}-${ref.columns.join()}`}
                            onClick={() => onSelect(ref.from)}
                        >
                            {ref.on_delete && ref.on_delete !== 'no action' && (
                                <span className="erd-rel-del">{ref.on_delete}</span>
                            )}
                            <b>{ref.from}</b>
                            <i>.{ref.columns.join(', ')}</i>
                        </button>
                    ))
                )}

                {table.morphs.length > 0 && (
                    <>
                        <h3>Polymorphic</h3>
                        <p className="erd-empty">
                            {table.morphs.map((morph) => `${morph}_type + ${morph}_id`).join(', ')}{' '}
                            — the target is decided at runtime, so no edge is drawn for it.
                        </p>
                    </>
                )}

                <h3>
                    Indexes <span className="erd-count">{table.indexes.length}</span>
                </h3>
                <table className="erd-table">
                    <tbody>
                        {table.indexes.map((index) => (
                            <tr key={index.name}>
                                <td>
                                    <span className={index.primary ? 'erd-key is-pk' : index.unique ? 'erd-key is-uk' : 'erd-key'}>
                                        {index.primary ? 'PK' : index.unique ? 'UQ' : 'IX'}
                                    </span>
                                </td>
                                <td className="erd-t-name">{index.columns.join(', ')}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </aside>
    );
}

function keyClass(column) {
    if (column.pk) {
        return 'erd-key is-pk';
    }

    if (column.fk) {
        return 'erd-key is-fk';
    }

    if (column.unique) {
        return 'erd-key is-uk';
    }

    return 'erd-key';
}

function keyLabel(column) {
    if (column.pk) {
        return 'PK';
    }

    if (column.fk) {
        return 'FK';
    }

    if (column.unique) {
        return 'UQ';
    }

    return '';
}
```

## `ErdBoard.jsx`

The board. Filters, search, selection, layout direction, theme — and the four effects that keep React Flow honest. Set `PRODUCT` to the product name.

```jsx
import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import {
    Background,
    BackgroundVariant,
    Controls,
    MarkerType,
    MiniMap,
    ReactFlow,
    ReactFlowProvider,
    useNodesInitialized,
    useNodesState,
    useReactFlow,
    useUpdateNodeInternals,
} from '@xyflow/react';

import About from './About';
import Inspector from './Inspector';
import RelationEdge from './RelationEdge';
import TableNode from './TableNode';
import { layout } from './layout';
import { NODE_W, nodeHeight, visibleColumns } from './geometry';

/* The product name in the header. Everything else on this board is derived. */
const PRODUCT = 'Acme';

const NODE_TYPES = { table: TableNode };
const EDGE_TYPES = { relation: RelationEdge };

const DETAIL_LEVELS = [
    ['compact', 'Names'],
    ['keys', 'Keys'],
    ['full', 'All'],
];

function Board({ schema }) {
    const { fitView } = useReactFlow();
    const updateNodeInternals = useUpdateNodeInternals();

    const [detail, setDetail] = useState('keys');
    const [direction, setDirection] = useState('LR');
    const [selected, setSelected] = useState(null);
    const [focus, setFocus] = useState(false);
    const [rail, setRail] = useState(true);
    const [theme, setTheme] = useState('dark');
    const [about, setAbout] = useState(true);
    const [input, setInput] = useState('');
    const [term, setTerm] = useState('');
    const [domains, setDomains] = useState(
        () => new Set(Object.keys(schema.domains).filter((key) => key !== 'system'))
    );

    // Debounced: every keystroke otherwise re-runs dagre over a hundred nodes.
    useEffect(() => {
        const timer = setTimeout(() => setTerm(input.trim().toLowerCase()), 220);

        return () => clearTimeout(timer);
    }, [input]);

    useEffect(() => {
        document.documentElement.setAttribute('data-theme', theme);
    }, [theme]);

    const byName = useMemo(
        () => new Map(schema.tables.map((table) => [table.name, table])),
        [schema]
    );

    /* Incoming relations, which no row of a table can tell you about. */
    const incoming = useMemo(() => {
        const map = new Map(schema.tables.map((table) => [table.name, []]));

        schema.tables.forEach((table) => {
            table.foreign_keys.forEach((key) => {
                map.get(key.table)?.push({
                    from: table.name,
                    columns: key.columns,
                    on_delete: key.on_delete,
                });
            });
        });

        return map;
    }, [schema]);

    const neighbours = useMemo(() => {
        if (!selected) {
            return new Set();
        }

        const set = new Set([selected]);

        byName.get(selected)?.foreign_keys.forEach((key) => set.add(key.table));
        (incoming.get(selected) ?? []).forEach((ref) => set.add(ref.from));

        return set;
    }, [selected, byName, incoming]);

    const domainCounts = useMemo(() => {
        const counts = {};

        schema.tables.forEach((table) => {
            counts[table.domain] = (counts[table.domain] ?? 0) + 1;
        });

        return counts;
    }, [schema]);

    /* Which tables are on the canvas at all. */
    const shown = useMemo(() => {
        let tables = schema.tables.filter((table) => domains.has(table.domain));

        if (term.length > 0) {
            tables = tables.filter(
                (table) =>
                    table.name.toLowerCase().includes(term) ||
                    table.columns.some((column) => column.name.toLowerCase().includes(term))
            );
        }

        if (focus && selected) {
            tables = tables.filter((table) => neighbours.has(table.name));
        }

        return tables;
    }, [schema, domains, term, focus, selected, neighbours]);

    /*
     * The laid-out graph. It depends on the shape of what is drawn and never on
     * what is selected, so clicking a table cannot re-run dagre — and, because
     * the decoration below patches the nodes already in state, a table dragged
     * out of the way keeps its position until the layout itself changes.
     */
    const graph = useMemo(() => {
        const names = new Set(shown.map((table) => table.name));
        const rowsFor = new Map(
            shown.map((table) => [table.name, visibleColumns(table, detail, term)])
        );

        const rawNodes = shown.map((table) => {
            const rows = rowsFor.get(table.name);

            return {
                id: table.name,
                type: 'table',
                position: { x: 0, y: 0 },
                initialWidth: NODE_W,
                initialHeight: nodeHeight(table, rows),
                data: {
                    table,
                    rows,
                    height: nodeHeight(table, rows),
                    color: schema.domains[table.domain].color,
                    horizontal: direction === 'LR',
                    state: 'normal',
                    hits: new Set(),
                },
            };
        });

        const horizontal = direction === 'LR';
        const rawEdges = [];

        shown.forEach((table) => {
            table.foreign_keys.forEach((key, index) => {
                if (!names.has(key.table)) {
                    return;
                }

                const sourceColumn = key.columns[0];
                const targetColumn = key.references[0];

                // A handle only exists for a column the node is currently
                // drawing. Naming one that is not in the DOM does not fall
                // back — React Flow resolves the position to null and drops
                // the edge without a word.
                const hasSource =
                    horizontal &&
                    (rowsFor.get(table.name) ?? []).some((c) => c.name === sourceColumn);
                const hasTarget =
                    horizontal &&
                    (rowsFor.get(key.table) ?? []).some((c) => c.name === targetColumn);

                rawEdges.push({
                    id: `${table.name}:${key.columns.join('_')}->${key.table}:${index}`,
                    source: table.name,
                    target: key.table,
                    sourceHandle: hasSource ? `s:${sourceColumn}` : 's:*',
                    targetHandle: hasTarget ? `t:${targetColumn}` : 't:*',
                    type: 'relation',
                    data: {
                        column: `${table.name}.${key.columns.join(', ')}`,
                        references: `${key.table}.${key.references.join(', ')}`,
                        onDelete: key.on_delete,
                        domain: table.domain,
                    },
                });
            });
        });

        return { nodes: layout(rawNodes, rawEdges, direction), edges: rawEdges };
    }, [shown, detail, direction, term, schema]);

    const [nodes, setNodes, onNodesChange] = useNodesState([]);

    useEffect(() => {
        setNodes(graph.nodes);
    }, [graph, setNodes]);

    /*
     * Selection and search are painted onto whatever is in state, so neither
     * discards a measurement nor a drag. The identity check matters: returning
     * the same node object when nothing about it changed is what stops this
     * from invalidating every node — and every node's measurement — on each
     * pass.
     */
    useEffect(() => {
        setNodes((current) =>
            current.map((node) => {
                const table = node.data.table;

                let state = 'normal';

                if (selected) {
                    if (node.id === selected) {
                        state = 'selected';
                    } else if (neighbours.has(node.id)) {
                        state = 'neighbour';
                    } else {
                        state = 'dim';
                    }
                }

                const matches =
                    term.length > 0
                        ? table.columns
                              .filter((column) => column.name.toLowerCase().includes(term))
                              .map((column) => column.name)
                        : [];

                if (node.data.state === state && node.data.hits.size === matches.length) {
                    return node;
                }

                return { ...node, data: { ...node.data, state, hits: new Set(matches) } };
            })
        );
    }, [selected, neighbours, term, setNodes]);

    const edges = useMemo(
        () =>
            graph.edges.map((edge) => {
                const color = schema.domains[edge.data.domain].color;
                const lit =
                    Boolean(selected) && (edge.source === selected || edge.target === selected);

                return {
                    ...edge,
                    className: lit ? 'is-lit' : selected ? 'is-dim' : '',
                    style: { stroke: color },
                    markerEnd: { type: MarkerType.ArrowClosed, color, width: 14, height: 14 },
                    data: { ...edge.data, lit },
                };
            }),
        [graph, selected, schema]
    );

    /*
     * React Flow caches each node's handle bounds and does not re-read them
     * when the handles move. Direction and detail both move every handle, so
     * without this the cards redraw correctly and the edges keep the old
     * anchors. One call with every id, not one call per node: each is a store
     * update, and ninety-one of them per change is ninety-one renders.
     *
     * Skipped on the first pass — the nodes have not been measured yet, and
     * asking React Flow to re-read bounds that do not exist only competes with
     * the measurement that is about to produce them.
     */
    const mounted = useRef(false);

    useEffect(() => {
        if (!mounted.current) {
            mounted.current = true;

            return;
        }

        updateNodeInternals(graph.nodes.map((node) => node.id));
    }, [direction, detail, graph, updateNodeInternals]);

    /*
     * `fitView` frames whatever React Flow's store currently holds, and until
     * every node has been measured the store holds no bounds to frame — so a
     * fit on a timer is a race that the document loses whenever the machine is
     * slow, the tab is in the background, or a font arrives late. `nodesInitialized`
     * is the event itself rather than a guess at when it happened.
     */
    const inspectorOpen = Boolean(selected);
    const initialized = useNodesInitialized();
    const framed = useRef(false);

    useEffect(() => {
        if (!initialized) {
            return;
        }

        // One commit later regardless: positions land in the store during this
        // render, and fitView reads the store rather than the nodes it was
        // handed.
        const timer = setTimeout(() => {
            fitView({ padding: 0.14, duration: framed.current ? 320 : 0 });
            framed.current = true;
        }, 40);

        return () => clearTimeout(timer);
    }, [initialized, graph, inspectorOpen, fitView]);

    const toggleDomain = useCallback((key) => {
        setDomains((current) => {
            const next = new Set(current);

            next.has(key) ? next.delete(key) : next.add(key);

            return next;
        });
    }, []);

    const allOn = domains.size === Object.keys(schema.domains).length;
    const selectedTable = selected ? byName.get(selected) : null;
    const filtering = term.length > 0 || !allOn || (focus && selected);

    return (
        <div className="erd-app">
            <header className="erd-header">
                <div className="erd-brand">
                    <Mark />
                    <span>{PRODUCT}</span>
                    <span>· Database ERD</span>
                </div>

                <div className="erd-stats">
                    <span>
                        <b>{schema.stats.tables}</b> tables
                    </span>
                    <span>
                        <b>{schema.stats.columns}</b> columns
                    </span>
                    <span>
                        <b>{schema.stats.relations}</b> relations
                    </span>
                    {filtering && (
                        <span>
                            showing <b>{shown.length}</b>
                        </span>
                    )}
                </div>

                <div className="erd-header-spacer" />

                <button className="erd-btn" onClick={() => setAbout(true)}>
                    About
                </button>
                <button
                    className="erd-btn"
                    onClick={() => setRail((value) => !value)}
                    aria-pressed={rail}
                >
                    Filters
                </button>
                <button
                    className="erd-btn"
                    onClick={() => setDirection((value) => (value === 'LR' ? 'TB' : 'LR'))}
                    title="Layout direction"
                >
                    {direction === 'LR' ? 'Left → Right' : 'Top → Bottom'}
                </button>
                <button
                    className="erd-btn"
                    onClick={() => setTheme((value) => (value === 'dark' ? 'light' : 'dark'))}
                    title="Theme"
                >
                    {theme === 'dark' ? 'Dark' : 'Light'}
                </button>
            </header>

            <div
                className="erd-body"
                data-rail={rail ? 'open' : 'closed'}
                data-inspector={selectedTable ? 'open' : 'closed'}
            >
                <nav className="erd-rail">
                    <div className="erd-rail-scroll">
                        <div className="erd-section">
                            <div className="erd-search">
                                <input
                                    type="search"
                                    value={input}
                                    placeholder="Search table or column…"
                                    onChange={(event) => setInput(event.target.value)}
                                />
                                {input.length > 0 && (
                                    <button
                                        className="erd-search-clear"
                                        onClick={() => setInput('')}
                                        aria-label="Clear search"
                                    >
                                        ×
                                    </button>
                                )}
                            </div>
                            <p className="erd-hint">
                                Matches a table name or any column name — someone working from an
                                error message has a column, not a table.
                            </p>
                        </div>

                        <div className="erd-section">
                            <div className="erd-section-title">Detail</div>
                            <div className="erd-segmented">
                                {DETAIL_LEVELS.map(([key, label]) => (
                                    <button
                                        key={key}
                                        onClick={() => setDetail(key)}
                                        aria-pressed={detail === key}
                                    >
                                        {label}
                                    </button>
                                ))}
                            </div>
                            <p className="erd-hint">
                                <b>Keys</b> draws primary, foreign and unique columns — the ones
                                that carry structure.
                            </p>
                        </div>

                        <div className="erd-section">
                            <div className="erd-section-title">
                                <span>Domains</span>
                                <button
                                    className="erd-btn erd-btn-ghost"
                                    onClick={() =>
                                        setDomains(
                                            allOn ? new Set() : new Set(Object.keys(schema.domains))
                                        )
                                    }
                                >
                                    {allOn ? 'None' : 'All'}
                                </button>
                            </div>
                            <div className="erd-domains">
                                {Object.entries(schema.domains).map(([key, domain]) => (
                                    <button
                                        className="erd-domain"
                                        key={key}
                                        onClick={() => toggleDomain(key)}
                                        aria-pressed={domains.has(key)}
                                        title={domain.description}
                                    >
                                        <span
                                            className="erd-swatch"
                                            style={{ '--swatch': domain.color }}
                                        />
                                        <span className="erd-domain-name">{domain.label}</span>
                                        <span className="erd-count">{domainCounts[key] ?? 0}</span>
                                    </button>
                                ))}
                            </div>
                        </div>

                        <div className="erd-section">
                            <div className="erd-section-title">
                                <span>Tables</span>
                                <span className="erd-count">{shown.length}</span>
                            </div>
                            {shown.length === 0 ? (
                                <p className="erd-hint">
                                    Nothing matches. Clear the search or turn a domain back on to
                                    see tables again.
                                </p>
                            ) : (
                                <div className="erd-list">
                                    {shown.map((table) => (
                                        <button
                                            key={table.name}
                                            onClick={() => setSelected(table.name)}
                                            aria-current={selected === table.name}
                                        >
                                            <span
                                                className="erd-swatch"
                                                style={{
                                                    '--swatch': schema.domains[table.domain].color,
                                                }}
                                            />
                                            <span>{table.name}</span>
                                            <span className="erd-count">
                                                {table.columns.length}
                                            </span>
                                        </button>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>
                </nav>

                <div className="erd-canvas">
                    <ReactFlow
                        nodes={nodes}
                        edges={edges}
                        onNodesChange={onNodesChange}
                        nodeTypes={NODE_TYPES}
                        edgeTypes={EDGE_TYPES}
                        onNodeClick={(_, node) => setSelected(node.id)}
                        onPaneClick={() => setSelected(null)}
                        nodesConnectable={false}
                        elementsSelectable={false}
                        minZoom={0.04}
                        maxZoom={2.5}
                        proOptions={{ hideAttribution: true }}
                    >
                        <Background
                            variant={BackgroundVariant.Dots}
                            gap={22}
                            size={1}
                            color="var(--erd-grid)"
                        />
                        <Controls showInteractive={false} position="bottom-left" />
                        <MiniMap
                            pannable
                            zoomable
                            position="bottom-right"
                            nodeColor={(node) => schema.domains[node.data.table.domain].color}
                            nodeStrokeWidth={0}
                            bgColor="transparent"
                            maskColor={
                                theme === 'dark'
                                    ? 'rgba(8, 12, 16, 0.7)'
                                    : 'rgba(238, 242, 246, 0.7)'
                            }
                        />
                    </ReactFlow>

                    <div className="erd-toolbar">
                        <button
                            className="erd-btn"
                            onClick={() => setFocus((value) => !value)}
                            aria-pressed={focus}
                            disabled={!selected}
                            title="Draw only the selected table and what it joins to"
                        >
                            Focus
                        </button>
                        <button
                            className="erd-btn"
                            onClick={() => fitView({ padding: 0.14, duration: 320 })}
                        >
                            Fit
                        </button>
                    </div>

                    {about && (
                        <About
                            schema={schema}
                            counts={domainCounts}
                            onClose={() => setAbout(false)}
                        />
                    )}

                </div>

                {selectedTable && (
                    <Inspector
                        table={selectedTable}
                        domain={schema.domains[selectedTable.domain]}
                        incoming={incoming.get(selectedTable.name) ?? []}
                        onSelect={(name) => setSelected(name)}
                        onClose={() => {
                            setSelected(null);
                            setFocus(false);
                        }}
                    />
                )}
            </div>
        </div>
    );
}

function Mark() {
    return (
        <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
            <rect x="2" y="2" width="9" height="9" rx="2" fill="var(--erd-accent)" />
            <rect x="13" y="2" width="9" height="9" rx="2" fill="var(--erd-accent)" opacity="0.45" />
            <rect x="2" y="13" width="9" height="9" rx="2" fill="var(--erd-accent)" opacity="0.45" />
            <rect x="13" y="13" width="9" height="9" rx="2" fill="var(--erd-accent)" opacity="0.2" />
        </svg>
    );
}

export default function ErdBoard({ schema }) {
    return (
        <ReactFlowProvider>
            <Board schema={schema} />
        </ReactFlowProvider>
    );
}
```

## `About.jsx`

The landing state, and the only prose in the document — so it is the file to actually write
rather than copy.

A hundred tables cannot be legible on one screen at any zoom. That is arithmetic, not a layout
defect; every ERD tool has the same ceiling. What *can* be fixed is what the reader meets
first. Without this panel the document opens on a grey smear of unreadable cards and gives no
hint that the filters are the way through. So it opens on the legend, and the diagram is what
you get when you dismiss it.

Keep the four sections. Rewrite the wording for the product:

- **Figures** — tables, columns, foreign keys, domains.
- **Domains** — the legend, with each domain's one-line description and live table count.
- **Reading it** — start narrow; click a table to see what references *it*; search matches
  columns; `system` starts off; a dashed `morph_*` tag is a relation with no edge.
- **What is not drawn** — declared foreign keys only, so a table with no arrows may still be
  related in Eloquent; and types are as the generating driver reports them.

The footer carries the provenance: date read, driver, migration head, and the two commands to
rebuild. That line is what tells a reader six months from now whether to trust the picture.

```jsx
import React from 'react';

const PRODUCT = 'Acme';

export default function About({ schema, counts, onClose }) {
    const generated = new Date(schema.generated_at);

    return (
        <div className="erd-about-backdrop" onClick={onClose}>
            <div className="erd-about" onClick={(event) => event.stopPropagation()}>
                <div className="erd-about-head">
                    <h1>{PRODUCT} — Database ERD</h1>
                    <p>
                        Every table in the {PRODUCT} database, read from the live schema and
                        grouped by the product domain it serves. Generated from the database
                        itself, never from the migration files — migrations include column
                        changes, index swaps and drops whose net effect is exactly what a
                        parser gets wrong.
                    </p>
                </div>

                <div className="erd-about-scroll">
                    <div className="erd-about-figures">
                        <div className="erd-about-figure">
                            <b>{schema.stats.tables}</b>
                            <span>Tables</span>
                        </div>
                        <div className="erd-about-figure">
                            <b>{schema.stats.columns}</b>
                            <span>Columns</span>
                        </div>
                        <div className="erd-about-figure">
                            <b>{schema.stats.relations}</b>
                            <span>Foreign keys</span>
                        </div>
                        <div className="erd-about-figure">
                            <b>{Object.keys(schema.domains).length}</b>
                            <span>Domains</span>
                        </div>
                    </div>

                    <h2>Domains</h2>
                    <div className="erd-about-domains">
                        {Object.entries(schema.domains).map(([key, domain]) => (
                            <div className="erd-about-domain" key={key}>
                                <span className="erd-swatch" style={{ '--swatch': domain.color }} />
                                <div>
                                    <b>
                                        {domain.label} <span>· {counts[key] ?? 0}</span>
                                    </b>
                                    <p>{domain.description}</p>
                                </div>
                            </div>
                        ))}
                    </div>

                    <h2>Reading it</h2>
                    <ul className="erd-about-how">
                        <li>
                            <b>Start narrow.</b> The whole schema at once is a shape, not a
                            diagram. Turn domains off, or search, until the cards are readable —
                            the header counts show how many of the {schema.stats.tables} are
                            drawn.
                        </li>
                        <li>
                            <b>Click a table</b> to open it: every column, every index, what it
                            references, and — the half no row can tell you — what references it.
                            The graph dims to that table and its direct joins; <b>Focus</b> drops
                            everything else.
                        </li>
                        <li>
                            <b>Search matches columns too.</b> Someone working from an error
                            message has a column name, not a table name.
                        </li>
                        <li>
                            <b>Framework &amp; Ops starts off.</b> Cache, queue, sessions and
                            Telescope are the framework's plumbing rather than {PRODUCT}'s domain
                            model, and most of them join to nothing.
                        </li>
                        <li>
                            <b>A dashed <code>morph_*</code> tag is a relation with no edge.</b>{' '}
                            <code>auditable_type</code> + <code>auditable_id</code> resolve at
                            runtime, so an arrow to any one table would be a claim the schema does
                            not make.
                        </li>
                    </ul>

                    <h2>What is not drawn</h2>
                    <ul className="erd-about-how">
                        <li>
                            Only <b>declared foreign keys</b> become edges. A relation that exists
                            solely as an Eloquent method has nothing in the schema to draw, so a
                            table with no arrows is not necessarily an island — check the model.
                        </li>
                        <li>
                            Column <b>types are as the generating engine reports them</b>. The
                            schema builder emits the right type per driver, so the names here will
                            differ on another engine while the structure does not.
                        </li>
                    </ul>
                </div>

                <div className="erd-about-foot">
                    <div className="erd-about-meta">
                        Read {generated.toISOString().slice(0, 10)} from a {schema.driver}{' '}
                        database at migration <code>{schema.migration_head}</code> · rebuild with{' '}
                        <code>php artisan docs:erd</code> then <code>npm run build:erd</code>
                    </div>
                    <button className="erd-btn" onClick={onClose}>
                        Open the diagram
                    </button>
                </div>
            </div>
        </div>
    );
}
```
