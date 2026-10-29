# Revelation Recite — Spec & Workflow

A single-page app for memorizing and reciting the **entire Book of Revelation** (22 chapters, 404 verses), chapter by chapter, with instant local CRUD and spaced review.

---

## 1. Goals

| Goal | Meaning in practice |
|---|---|
| Easy access | One `index.html`, opens offline, installable as a PWA on phone/desktop |
| Fast load | No framework, no build step required; < 100 KB app shell + text JSON |
| Fast reaction | Every keystroke handled in < 16 ms; no network round-trips |
| Realtime CRUD | Every create / edit / delete writes to IndexedDB immediately and re-renders the affected view only |
| Chapter-level recitation | The unit of mastery is the *chapter*, not the single verse; verses are the steps inside it |

Non-goals (v1): accounts, cloud sync, social groups, audio TTS.

---

## 2. Text source

- Bundle a **public-domain** translation so the app can ship the text: **KJV** or **WEB (World English Bible)**.
- Optional Korean text: 개역한글 (1961) — confirm its current copyright status before bundling. Modern translations (ESV, NIV, 개역개정) are copyrighted; users may paste their own text via the CRUD editor instead of bundling.
- Store as `data/revelation.<translation>.json`:

```json
{
  "translation": "KJV",
  "book": "Revelation",
  "chapters": [
    { "n": 1, "verses": [ { "v": 1, "t": "The Revelation of Jesus Christ, ..." } ] }
  ]
}
```

Import pipeline (one-time): download PD source → script splits into chapter/verse JSON → validate counts (22 chapters, 404 verses) → commit.

---

## 3. Data model (IndexedDB)

Database `revrecite`, version 1.

| Store | Key | Fields |
|---|---|---|
| `verses` | `id` = `"1:1"` | `ch`, `v`, `text`, `translation`, `userEdited` (bool), `updatedAt` |
| `progress` | `id` = `"1:1"` | `stage` (0 Read → 1 First-letter → 2 Cloze → 3 Full recall), `ease`, `interval`, `due`, `reps`, `lapses`, `lastScore` |
| `chapters` | `n` | `status` (`new` / `learning` / `chained` / `mastered`), `chainBest` (longest unbroken run of verses recited), `due` |
| `notes` | `id` (uuid) | `ref` (`"12:7-9"`), `kind` (`mnemonic` / `image` / `outline`), `body`, `createdAt`, `updatedAt` |
| `sessions` | auto | `startedAt`, `endedAt`, `mode`, `ch`, `versesDone`, `errors` |

CRUD rule: write → `await tx.done` → emit `change` event `{store, id}` → only subscribed components re-render. Optimistic UI: render first, write in the same tick, roll back on error.

---

## 4. Practice modes

1. **Read** — whole chapter, tap a verse to see/edit mnemonic notes.
2. **First-letter** — type the first letter of each word; correct key reveals the word. Adjacent-key tolerance optional.
3. **Cloze fade** — 25 % → 50 % → 75 % → 100 % of words hidden, increasing per success.
4. **Full recall** — blank screen, type verse; diff shown afterward (word-level).
5. **Chain** — shows the end of verse *n*, you recite verse *n+1*. Runs through the whole chapter; tracks `chainBest`. This is the mode that builds *chapter* recitation.
6. **Reference ↔ text** — given `13:18` produce text, or given text produce the reference.
7. **Chapter outline** — recall the chapter's section headings / key images (seven churches, seals, trumpets, bowls) from your own `notes` of kind `outline`.

Scoring per attempt: `errors / words` → grade 0–5 → feeds the scheduler.

---

## 5. Review scheduler

- SM-2 style per verse: `interval`, `ease` (start 2.5), grade < 3 resets interval to 1 day.
- Chapter is `chained` when every verse is stage 3 and `chainBest == verseCount` once.
- Chapter is `mastered` after 3 successful chain runs on separate days.
- Daily queue order: overdue chapter chains → overdue verses → new verses (cap configurable, default 3/day).

---

## 6. Mnemonic layer (Revelation-specific)

Revelation is highly structured, which is the main memory aid. Seed the `notes` store with outline anchors the user can edit:

- Ch 1 vision · Ch 2–3 seven churches (Ephesus, Smyrna, Pergamum, Thyatira, Sardis, Philadelphia, Laodicea) · Ch 4–5 throne & scroll · Ch 6–8:1 seals · Ch 8:2–11 trumpets · Ch 12–14 woman, dragon, beasts · Ch 15–16 bowls · Ch 17–18 Babylon · Ch 19–20 rider, millennium · Ch 21–22 new heaven and earth.
- Per-church template note: *praise / rebuke / exhortation / promise to the overcomer* — a repeating frame that makes ch 2–3 much easier.
- User can attach a short image/keyword per verse ("memory palace" slot).

---

## 7. UI layout (single page)

```
┌──────────────────────────────────────────┐
│ Header: Today 12 due · Ch 3 chain 14/22  │
├──────────┬───────────────────────────────┤
│ Chapter  │  Practice pane                │
│ rail     │  (mode tabs, verse, input)    │
│ 1 ●      │                               │
│ 2 ◐      │                               │
│ 3 ○ ...  ├───────────────────────────────┤
│          │  Notes / edit drawer (CRUD)   │
└──────────┴───────────────────────────────┘
```

- Mobile: chapter rail collapses to a top dropdown.
- Keyboard first: `Space` next, `Enter` check, `Esc` reveal, `E` edit, `N` new note.
- Hash routing: `#/ch/3/chain`, `#/ch/12/v/7/firstletter`, `#/review`.

---

## 8. Tech stack

| Layer | Choice | Why |
|---|---|---|
| Markup/UI | Vanilla JS + Web Components (or Preact via CDN, ~4 KB) | No build, instant load |
| Storage | IndexedDB via `idb` (~1 KB) | Async, large capacity, survives reloads |
| Offline | Service worker caching shell + JSON | Works in airplane mode |
| Styling | Single CSS file with tokens, dark mode | Fast paint |
| Export | JSON backup/restore of all stores | User owns data; manual "sync" between devices |

---

## 9. File structure

```
revelation-recite/
├─ index.html
├─ app.js              # router, event bus, boot
├─ db.js               # IndexedDB open, CRUD helpers, change events
├─ scheduler.js        # SM-2 + chapter status rules
├─ modes/
│  ├─ read.js
│  ├─ firstletter.js
│  ├─ cloze.js
│  ├─ recall.js
│  ├─ chain.js
│  └─ reference.js
├─ ui/
│  ├─ chapter-rail.js
│  ├─ notes-drawer.js
│  └─ diff.js
├─ styles.css
├─ sw.js               # service worker
├─ manifest.webmanifest
├─ data/
│  └─ revelation.kjv.json
└─ scripts/
   └─ import-text.py   # build JSON from PD source, validate 22/404
```

---

## 10. Build workflow (milestones)

| # | Milestone | Done when |
|---|---|---|
| M0 | Text import | `revelation.kjv.json` validated: 22 chapters, 404 verses |
| M1 | Shell + DB | `index.html` loads, seeds IndexedDB on first run, chapter rail renders |
| M2 | CRUD | Edit verse text, add/edit/delete notes; changes visible instantly and persist after reload |
| M3 | First-letter + Cloze modes | Grade recorded to `progress` |
| M4 | Scheduler + Review queue | Due counts in header; `#/review` serves queue |
| M5 | Chain mode | Full-chapter recitation run with `chainBest` tracking |
| M6 | Recall + diff, Reference mode | Word-level diff after full recall |
| M7 | PWA + export/import | Installable, offline, JSON backup round-trips cleanly |
| M8 | Mnemonic seeds | Outline + seven-church template notes preloaded and editable |

---

## 11. Acceptance checks

- Cold load < 1 s on mid-range phone; keystroke-to-feedback < 16 ms.
- Edit a verse → reload → edit persists; delete a note → gone everywhere it appeared.
- Kill network → app still fully usable.
- Export → clear site data → import → identical progress.
- Recite ch 2 in chain mode end-to-end with no UI lag.

---

## 12. Open questions

- Translation: KJV, WEB, Korean, or bilingual side-by-side?
- Input: typing only, or add speech recognition (Web Speech API) for spoken recitation?
- Daily new-verse cap and target date to finish all 22 chapters?
