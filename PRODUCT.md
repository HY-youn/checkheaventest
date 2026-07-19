# Product

## Register

product

## Users

Members of a Korean church preparing for "천국고시" (Heaven Exam) — a memorization contest covering the Book of Revelation (계시록). Users open this on their phone or laptop during personal study time, often repeatedly over weeks, to drill fill-in-the-blank recall before sitting the real exam. Two modes serve two moments in that routine: 빈칸 연습 (untimed practice, retry freely) for daily drilling, and 시험 보기 (timed exam, 1:30/verse) for self-testing under exam conditions.

## Product Purpose

A single-page memorization drill tool: pick a verse range (by chapter/paragraph, or one tap for the confirmed 21-segment core range), choose word- or clause-level blanks, and either practice untimed or sit a scored timed exam with a shareable result card. Success looks like a user trusting the tool enough to use it as their primary rehearsal before the actual exam — which means the blanking and grading must read as accurate and the interface must not get in the way of recall.

## Brand Personality

Solemn & disciplined. This is scripture memorization for a real exam, not a game — restraint and seriousness over playful ornamentation. The 🔥 exam-fire motif (천국고시 = "Heaven Exam") signals stakes and focus, not decoration. Quiet, exam-room energy: precise, unhurried, respectful of the text.

## Anti-references

- Generic AI-generated Tailwind output — default indigo/blue/slate palette, bordered-card-for-everything layout, competing button styles. Explicitly what this redesign is moving away from.
- No gamified/playful treatment (no confetti, mascots, bright multi-color badges) — this is exam prep, not a language-learning app.
- No indigo, blue, or navy accents anywhere; one accent (deep amber/ember) only.

## Design Principles

- One exam, one visual register — every screen (selection, practice, exam, result) should read as part of the same solemn instrument, not a stitched-together set of cards.
- The scripture text is the content; chrome recedes. Amber is reserved for the one primary action and D-day/status badges, not scattered across the UI.
- Data reads as data — verse ranges, timers, and scores use monospace/tabular treatment, not paragraph prose.
- Exactly one primary action per screen (시험 시작, 정답 확인, 제출하기) — everything else is secondary/ghost.
- Don't touch functionality, IDs, or event handlers — this is a visual-only system built on the existing GAS single-file app.

## Accessibility & Inclusion

Standard WCAG AA: body text ≥4.5:1 contrast, visible focus states on all inputs/buttons, `prefers-reduced-motion` respected (already partially in place). No additional accommodations requested beyond baseline AA.
