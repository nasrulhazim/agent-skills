# Interview Guide — No CLAUDE.md Exists

When the user asks for a roadmap but there's no CLAUDE.md to read from, run this interview.
Keep it conversational. Two blocks max — don't interrogate.

---

## Block 1 — Project Basics

Ask in one message:

> "Nak buat roadmap ni, aku kena faham sikit pasal project ni. Boleh jawab beberapa soalan?
>
> 1. Nama project dan satu ayat — apa dia buat, untuk siapa?
> 2. Stack? (framework, database, frontend approach)
> 3. Ni fresh build atau ada existing code?"

---

## Block 2 — Scope & Constraints

After Block 1, ask:

> "Sikit lagi:
>
> 4. MVP kau macam mana? Apa yang MESTI ada untuk first release?
> 5. Ada deadline atau timeline dalam kepala?
> 6. Solo dev atau team?"

---

## Extracting From Conversation

If the user already described the project extensively before asking for the roadmap,
**extract from the conversation** — don't ask questions they've already answered.

Look for signals:
- Project name → extract
- Stack mentions → extract (`Laravel`, `Livewire`, `PostgreSQL`, etc.)
- Feature descriptions → map to phase tasks
- "MVP" or "first version" mentions → use as Phase 1 scope
- Timeline mentions → use for week estimates
- Pain points / goals → use in ROADMAP.md tagline

Only ask for what's genuinely missing after extraction.

---

## Minimum Info Needed to Generate

You can generate a useful roadmap with just:

| Info | Source |
|---|---|
| Project name | Always available |
| What it does (1 sentence) | Always available |
| Stack (even partial) | Usually available |
| 3–5 MVP features | Infer from description if not explicit |

If timeline is missing → default to "Week 1–2", "Week 3–6", "Month 3–5" etc.
If scope is vague → generate conservative MVP, note "scope TBC" in ROADMAP.md

---

## Post-Interview

After collecting info:

1. Summarise back: "Ok, aku faham. Ni yang aku capture:" [list key points]
2. Ask: "Nak aku terus generate roadmap, atau ada yang nak adjust dulu?"
3. Generate both files on confirmation.
