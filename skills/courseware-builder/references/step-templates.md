# Step Templates Reference

## Point Types

| Type | Colour | BG | Icon | When to Use |
|------|--------|----|------|-------------|
| `info` | `#60a5fa` (blue) | `rgba(96,165,250,0.12)` | ℹ️ | General knowledge, definitions, context |
| `warn` | `#fbbf24` (amber) | `rgba(251,191,36,0.12)` | ⚠️ | Common mistakes, things to watch out for |
| `danger` | `#f87171` (red) | `rgba(248,113,113,0.12)` | 🚨 | Security risks, breaking changes, critical errors |
| `success` | `#34d399` (green) | `rgba(52,211,153,0.12)` | ✅ | Best practices, correct approach, expected outcome |

### Point Writing Rules

- Each point is **one sentence**, max 15 words
- Start with the icon emoji, then the text
- Use `info` most frequently (60%), `warn` (20%), `success` (15%), `danger` (5%)
- Every step must have at least 3 points, max 5

---

## Actor Definitions

| Key | Label | Emoji | Colour Class | Use For |
|-----|-------|-------|-------------|---------|
| `user` | User | 👤 | `actor-user` (`#60a5fa` blue) | End user, browser user, client-side actions |
| `server` | Server | 🖥️ | `actor-server` (`#a78bfa` purple) | Backend application server, API server |
| `browser` | Browser | 🌐 | `actor-browser` (`#34d399` green) | Browser engine, DOM, client rendering |
| `keycloak` | Keycloak | 🔐 | `actor-keycloak` (`#f472b6` pink) | Identity provider, OAuth server, SSO |
| `gateway` | Gateway | 🚪 | `actor-gateway` (`#fb923c` orange) | API gateway, reverse proxy, load balancer |
| `db` | Database | 🗄️ | `actor-db` (`#fbbf24` amber) | MySQL, PostgreSQL, Redis, any data store |
| `queue` | Queue | 📬 | `actor-queue` (`#2dd4bf` teal) | Job queues, message brokers, async processing |
| `external` | External | 🌍 | `actor-external` (`#94a3b8` slate) | Third-party APIs, external services, webhooks |

### Actor Tag Rendering

Actor tags render as pill-shaped badges with the actor's colour as background (at 20% opacity) and the emoji + label as text:

```html
<span class="actor actor-user">👤 User</span>
<span class="actor actor-server">🖥️ Server</span>
```

---

## Step Content Writing Guide

### Title Rules

- Max **5 words**
- Start with an **action verb** (Send, Validate, Store, Redirect, Generate, Process)
- Use present tense
- No articles (a, an, the)

Good: `Validate Access Token` · `Redirect to Login` · `Store Session Data`
Bad: `The user is redirected` · `Validating the access token now` · `Step 3 Processing`

### Description Structure

2–3 sentences following this pattern:

1. **What happens** — the action in this step (1 sentence)
2. **Why it matters** — significance or consequence (1 sentence)
3. **How it works** (optional) — brief technical detail (1 sentence)

Example:
> The server validates the access token by checking its signature and expiry. This ensures only authenticated users can access protected resources. The token is decoded using the public key from the JWKS endpoint.

### Code Rules

- Always include a filename as a comment on line 1: `// routes/web.php` or `# config.py`
- Keep snippets to **5–15 lines** — show only the relevant part
- Use syntax highlighting span classes (`.kw`, `.fn`, `.str`, `.cmt`, `.var`, `.cls`, `.num`, `.arr`)
- Indent consistently (2 or 4 spaces, match the language convention)
- Highlight the most important line with a `// ← important` comment if needed

---

## STEPS Object Schema

The `STEPS` array is the primary data structure. Each element is one step object:

```javascript
const STEPS = [
  {
    // Step title — short action phrase, max 5 words
    title: "Redirect to Auth Server",

    // Step description — 2-3 sentences: what, why, (how)
    desc: "The application redirects the user to the authorization server's login page. " +
          "This initiates the OAuth2 authorization code flow. " +
          "The redirect URL includes client_id, redirect_uri, scope, and state parameters.",

    // Actors involved in this step — array of actor keys
    actors: ["user", "browser", "keycloak"],

    // Key points — array of {type, text} objects
    points: [
      { type: "info",    text: "ℹ️ The state parameter prevents CSRF attacks" },
      { type: "warn",    text: "⚠️ Always use HTTPS for the redirect URI" },
      { type: "success", text: "✅ PKCE adds extra security for public clients" },
      { type: "danger",  text: "🚨 Never expose client_secret in browser code" }
    ],

    // Code snippet — string with syntax-highlighted HTML spans
    code: `<span class="cmt">// routes/web.php</span>
<span class="cls">Route</span><span class="arr">::</span><span class="fn">get</span>(<span class="str">'/login'</span>, <span class="kw">function</span> () {
    <span class="kw">return</span> <span class="fn">redirect</span>(<span class="var">$authUrl</span>);
});`,

    // Active node index — 0-based, which node to highlight in the flow diagram
    activeStep: 1
  },
  // ... more steps
];
```

### Field Validation

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `title` | `string` | Yes | Max 5 words, starts with verb |
| `desc` | `string` | Yes | 2–3 sentences |
| `actors` | `string[]` | Yes | 1–4 actor keys from the actor table |
| `points` | `{type, text}[]` | Yes | 3–5 items, type must be info/warn/danger/success |
| `code` | `string` | Yes | HTML string with syntax spans, include filename |
| `activeStep` | `number` | Yes | 0-indexed, must be valid NODES index |

---

## NODES Object Schema

The `NODES` array defines the flow diagram nodes. Each node represents an actor or system component:

```javascript
const NODES = [
  {
    // Unique identifier — matches actor key or custom id
    id: "user",

    // Display label — short name shown in the node box
    label: "👤 User",

    // X position in the diagram (px from left)
    x: 80,

    // Y position in the diagram (px from top)
    y: 200
  },
  {
    id: "browser",
    label: "🌐 Browser",
    x: 250,
    y: 200
  },
  // ... more nodes
];
```

### Node Positioning Guide

- Canvas is typically **700px wide × 400px tall**
- Space nodes evenly — minimum **150px** between nodes
- Use a left-to-right flow for linear processes
- Use top-to-bottom for hierarchical flows
- Centre the diagram vertically

### ARROWS Array

Arrows connect nodes and represent data flow between steps:

```javascript
const ARROWS = [
  {
    // Source node id
    from: "user",

    // Target node id
    to: "browser",

    // Label shown on the arrow
    label: "clicks login"
  },
  { from: "browser", to: "keycloak", label: "redirect" },
  // ... more arrows
];
```

---

## activeStep Mapping

The `activeStep` field in each step maps to a NODES array index. This determines which node gets the active highlight (scale + glow) when that step is displayed.

### Mapping Rules

1. `activeStep: 0` highlights `NODES[0]` — typically the first actor
2. The active node should be the **primary actor performing the action** in that step
3. Multiple steps can share the same `activeStep` if the same actor performs consecutive actions
4. All nodes with index < current step's `activeStep` are marked as "done" (green ✓) during simulate mode

### Example Mapping

```
Step 0: "User Clicks Login"       → activeStep: 0 (User node)
Step 1: "Browser Sends Request"   → activeStep: 1 (Browser node)
Step 2: "Server Validates Token"  → activeStep: 2 (Server node)
Step 3: "Query Database"          → activeStep: 3 (Database node)
Step 4: "Server Returns Response" → activeStep: 2 (Server node again)
Step 5: "Browser Renders Page"    → activeStep: 1 (Browser node again)
```

Note: Steps 4 and 5 reuse earlier node indices because the flow returns through the same actors.
