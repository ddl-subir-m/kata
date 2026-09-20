# Design system

The `design-check` skill reads this file. Until it has real content, a design check has nothing to
check against and will say so rather than guess.

Fill in what your product actually uses. Delete what does not apply.

## Colour tokens

| Token | Hex | Usage |
| --- | --- | --- |
| Text / heading | `#000000` | Headings, labels, primary text |
| Text / body | `#000000` | Body copy, descriptions, secondary text |
| Primary | `#000000` | Primary button fill, links, active elements |
| On primary | `#FFFFFF` | Text and icons on primary backgrounds |
| Container border | `#000000` | Card borders, dividers, input borders |

## Button hierarchy

Exactly **one** primary button per screen, modal or form. Everything else is secondary, tertiary
or a link.

| Type | Background | Border | Text |
| --- | --- | --- | --- |
| Primary | Primary | — | On primary |
| Secondary | Secondary surface | Secondary border | Secondary text |
| Tertiary | transparent | — | Primary |

Labels start with a verb and name the object: "Delete project", not "Delete".

## Typography scale

| Level | Size | Use |
| --- | --- | --- |
| H1 | 32px | Page titles — one per page |
| H2 | 26px | Section headers |
| H3 | 20px | Subsection headers |
| Body | 14–16px | Primary content |
| Caption | 12px | Helper text, metadata |

Never skip a heading level. Minimum 14px for body text. Aim for 50–75 characters per line.

## Spacing

Space **within** a group is about **half** the space **between** groups. That creates visual
separation without drawing a border.

Apply it to forms, cards and detail panels. Do **not** apply it to data tables, homogeneous lists
or navigation menus — uniform spacing is correct there.

## Detail panels

| Pattern | Best for |
| --- | --- |
| Overlay side drawer | Quick previews and row details. Does not compress the main content |
| Modal dialog | Focused tasks and confirmations |
| Full page | Complex detail views. Use breadcrumbs |

Prefer an overlay drawer for table row details. It needs a backdrop, a close button, Escape to
close, and a slide animation.

## Copy

- Sentence case, except for product nouns named here.
- Active voice. "Save changes", not "Changes can be saved".
- No exclamation points. No unnecessary apologies.
- Numerals, not words: "3%", not "three percent".
- Dates as "Month Day, Year". Relative dates only within 7 days.

## Product nouns

Words that keep their capital letter. List them here so the check can tell a product noun from a
sentence-case slip.

- <Noun>
- <Noun>
