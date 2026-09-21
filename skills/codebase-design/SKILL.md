---
name: codebase-design
description: Shared vocabulary for designing deep modules and choosing where a seam goes. Use when designing or improving a module's interface, deciding what to hide, making code more testable, or when another skill needs the deep-module vocabulary. Triggers - "design this module", "where should the seam go", "is this interface right", "make this testable".
---

# Codebase design

The vocabulary for talking about a module's **shape**, so two people arguing about a design are at
least arguing about the same thing.

## Glossary

| Term | Meaning |
| --- | --- |
| **Module** | A unit that hides something. Not a file, not a folder — a thing with an inside |
| **Interface** | What a caller must know to use it. Names, types, ordering rules, error cases, and every fact the docs force you to learn |
| **Depth** | Behaviour hidden, divided by interface exposed. High is good |
| **Seam** | A public boundary where behaviour can be observed without reaching inside. Tests live here |
| **Adapter** | A thin module whose only job is to make one interface look like another |
| **Leverage** | How much a caller gets per unit of what they must know |
| **Locality** | Whether a change lands in one place or is spread across many |

## Deep versus shallow

**Deep**: a lot of behaviour behind a small interface.

    resolve_binding(conversation_id, table_name) -> Binding | Unbound

Behind it: permission check, catalog lookup, cache, error mapping. The caller learns one function
and two return shapes.

**Shallow**: nearly as much interface as behaviour. The classic tell is a wrapper that adds a
name and nothing else.

    def get_binding_row(cid, tname):
        return db.query(BINDING_SQL, cid, tname)

A caller still needs to know about rows, and about what happens when there is none. The module
bought them nothing, and now there are two things to read instead of one.

**The test:** if explaining the module takes longer than explaining what it does, it is shallow.

## Principles

1. **Depth beats decomposition.** Two shallow modules are worse than one deep one. Splitting a
   file is not designing.
2. **Push complexity down, not out.** If something is hard, the module absorbs it. Making the
   caller handle it is how a codebase becomes unreadable.
3. **The common case needs no configuration.** Defaults that are right for most callers, and an
   escape hatch for the rest.
4. **Errors that cannot happen do not need handling.** Define them out of existence where you can:
   a function that cannot fail is deeper than one that returns a result type.
5. **Design it twice.** Sketch a second interface you do not intend to use. The comparison is what
   shows you what the first one costs. This takes ten minutes and is skipped almost every time.

## Designing for testability

A module is testable when its seam is observable **without mocks**.

> Hard to test: `sync()` reads the clock, calls the network, writes the DB, returns `None`.
> Easy to test: `plan_sync(state, now) -> [Action]` is pure, and `apply(actions)` does the IO.

The seam moved to a value you can assert on. Nothing was mocked, and the test survives a refactor
of either half.

Ask, before writing a test: **what would I have to mock?** Each answer names a place the design is
leaking.

## Rejected framings

- **"Small functions are good."** Only if each hides something. Ten three-line functions with no
  secret between them is one function with nine extra names to learn.
- **"Split by layer."** Controller, service, repository is a filing scheme, not a design. A change
  to one behaviour touches all three, which is the opposite of locality.
- **"Make it flexible for later."** Flexibility nobody asked for is interface you pay for now
  against a caller who may never exist.

## When you change a module's shape

Read the neighbours of the line you change. A module's depth is a property of the whole surface,
so a new parameter is a change to every caller's interface even when they do not pass it.
