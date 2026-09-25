---
name: improve-codebase-architecture
description: Find where the codebase is shallow, show the best deepening candidates as a visual report, then grill the one the person picks.
disable-model-invocation: true
---

# Improve codebase architecture

Find the places where a module is **shallow**, meaning its interface is nearly as big as what it
hides. Show the best candidates in a report, then grill the one the person picks until it is a
decision. The aim is code that is easier to test and easier for the next agent to find its way
through.

**This skill proposes. It does not refactor.** It ends with a report, and for the picked candidate
an ADR or a spec. The refactor is a ticket, built like any other.

## Use the two vocabularies exactly

- **Architecture words come from `codebase-design`**: module, interface, depth, seam, adapter,
  leverage, locality. Read that skill first.
- **Domain words come from `CONTEXT.md`.** They name the module.

Do not drift into "component", "service", "API layer" or "boundary". Each one is a word the
reader must now map back onto the glossary, and two readers map it differently.

> Bad: "Refactor the FooBarHandler service to clean up the order logic."
> Good: "Deepen the Order intake module. Validation and pricing move behind one interface."

**ADRs in `docs/adr/` are settled.** Do not propose what an ADR already rejected, unless the
friction is real enough to reopen it. Then say so on the candidate: "Contradicts ADR-0007, and is
worth reopening because…". A list of every refactor an ADR forbids is noise.

## 1. Decide where to look

Deepening a module pays off the next time somebody changes it. So look where change happens.

- **The person named an area** (a module, a subsystem, a pain point): take it and skip the rest
  of this step.
- **Otherwise, find the hot spots** in the history:

      git log --since="6 months ago" --format= --name-only | grep -v '^$' \
        | sort | uniq -c | sort -rn | head -20

  The files at the top pull your attention first. If the changes are scattered with no clear top,
  widen the window.

Then read `CONTEXT.md` and every ADR in that area before you read the code.

## 2. Walk the code

Hand the walk to a sub-agent so the file dumps stay out of this window. Tell it where to look,
and to note friction rather than follow a checklist:

- Understanding one concept means bouncing between many small modules.
- A module's interface is nearly as complex as its implementation.
- A pure function was pulled out only to be testable, and the real bugs live in how it is called.
  That is lost **locality**.
- Two modules are coupled and leak across the seam between them.
- Code that is untested, or hard to test through its current interface.

Put every suspect through the **deletion test**: delete the module in your head and inline it
into its callers. Does the complexity **concentrate**, or does it only **move**?

> `get_binding_row(cid, tname)` wraps one query. Delete it and every caller writes the same query
> and the same no-row handling. The complexity only moved: the wrapper hid nothing. That is the
> signal. The deep version absorbs the no-row case and the callers stop knowing about rows.

**Done when** you have 3 to 6 candidates, ranked. Fewer is fine. **No candidate is a real
result**: say so, and say where you looked.

## 3. Write the report

One self-contained HTML file in the temp directory, so nothing lands in the repo:

    REPORT="${TMPDIR:-/tmp}/architecture-review-$(date +%Y%m%d-%H%M%S).html"

Open it (`open` on macOS, `xdg-open` on Linux) and say the absolute path.

One card per candidate:

| Field | What goes in it |
| --- | --- |
| Title | The deepening, named in domain words: "Collapse the Order intake pipeline" |
| Strength | `Strong`, `Worth exploring` or `Speculative`, as a badge |
| Files | The modules involved, in monospace |
| Before / after | Two diagrams side by side. This carries the card |
| Problem | One sentence. What hurts |
| Solution | One sentence. What changes |
| Wins | Short bullets in glossary words |
| ADR | One line, only when the candidate contradicts one |

**Wins say what the glossary can measure.** "Locality: pricing bugs land in one module." "Leverage:
one interface, 9 call sites." Not "cleaner code" or "easier to maintain": neither is in the
glossary, and neither tells the person what they get.

End with **Top recommendation**: which candidate first, in one sentence, linked to its card.

Mermaid draws the diagrams. Use a flowchart for calls and dependencies, and colour a leak red:

```html
<!doctype html>
<html><head><meta charset="utf-8"><title>Architecture review - REPO</title>
<script type="module">
  import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
  mermaid.initialize({ startOnLoad: true, theme: "neutral" });
</script>
<style>
  body { font: 15px/1.5 system-ui, sans-serif; max-width: 70rem; margin: 3rem auto; padding: 0 1rem; }
  .pair { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
  .badge { padding: .1rem .5rem; border-radius: 1rem; font-size: 12px; }
</style></head><body>
<article>
  <h2>Collapse the Order intake pipeline <span class="badge">Strong</span></h2>
  <div class="pair">
    <pre class="mermaid">flowchart LR
      H[OrderHandler] --> V[OrderValidator] --> R[OrderRepo]
      R -.leak.-> P[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px
      class R,P leak</pre>
    <pre class="mermaid">flowchart LR
      H[OrderHandler] --> I[Order intake]
      I --> P[PricingClient]</pre>
  </div>
</article>
</body></html>
```

If a diagram needs a paragraph to be understood, redraw the diagram.

**Do not propose interfaces yet.** That is the next step, with the person. End with one question:
"Which of these do you want to explore?"

## 4. Grill the one they pick

Use **`grill`** on the picked candidate. It reads the ADRs, asks one question at a time, and writes
what settles into `CONTEXT.md` and `docs/adr/`. Cover:

- What goes behind the seam, and what stays in front of it.
- What callers must still know. That is the new interface.
- Which tests survive, and which move to the new seam.
- The constraints: callers you cannot change, data you cannot move.

**Design it twice** (`codebase-design`, principle 5). Sketch a second interface before you settle
on the first. The comparison shows what the first one costs.

**A rejection with a lasting reason becomes an ADR.** Offer it this way: "Record this as an ADR,
so the next architecture review does not suggest it again?" Offer only when a future reviewer
would need the reason. "Not worth it this quarter" does not need an ADR.

> Worth an ADR: "Pricing stays a separate module. Finance deploys it on its own schedule."
> Not worth one: "Too busy this sprint."

## 5. Hand it on

A candidate that settles goes to **`shape-request`**. It starts from the conversation you just
had and does not ask again. A deepening is often a prefactor ticket followed by the change, and a
wide one is cut expand–contract; `shape-request` knows both.

**Do not file the candidates nobody picked.** The report is throwaway. A candidate with no
symptom does not pass the filing bar, and ten `later` issues about module shape are how a tracker
fills with things nobody will pick up. The ones that matter come back on the next review, because
the hot spots are still hot.

## Hand back

- The report path.
- The candidate picked, and what was decided.
- Every ADR and `CONTEXT.md` entry written, by path.
- The spec issue number, if it went to `shape-request`.
