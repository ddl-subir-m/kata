---
name: tdd
description: Test-driven development, and proving a guard is actually armed. Use when building a feature or fixing a bug test-first, when asked for red-green-refactor, or when a test passes and you are not sure it would ever fail. Triggers - "write a test first", "red green refactor", "does this test actually test anything", "prove the guard works".
---

# Test-driven development

Stage 04 of the loop. The agent must be able to check its own work before a person sees it.

Turn the task into a verifiable goal before writing any code:

- "Add validation" becomes "write tests for invalid input, then make them pass".
- "Fix the bug" becomes "write a test that reproduces it, then make it pass".

## The loop

1. **Red.** Write the test. Run it. **Watch it fail, and read the failure message.**
2. **Green.** Write the least code that passes.
3. **Refactor.** Clean up with the test still green.

Step 1 is not optional and it is not ceremony. A test you have never seen fail is not evidence.

## A green test proves nothing until you have seen it red

This is the single most valuable habit in the skill. Before you trust a guard, plant a deliberate
failure for **each condition it covers**, confirm the failure, then remove the plant.

### Worked example

A guard that refuses a query when the table is unbound OR the user lacks read permission. Two
conditions, so two plants:

```python
# Plant 1: break the binding check.
# In service.py, temporarily change:
#     if not binding: raise Unbound()
# to:
#     if False: raise Unbound()
# Run the test. It MUST go red.
```

```python
# Plant 2: break the permission check, with plant 1 restored.
# In service.py, temporarily change:
#     if not user.can_read(table): raise Denied()
# to:
#     if False: raise Denied()
# Run the test. It MUST go red.
```

If plant 2 stays green, the test only ever exercised the binding path. That is a test that reads
as coverage and is not.

**One plant per condition.** A single plant that reds the test tells you the test is connected to
*something*, not that it covers everything it claims.

### The trap this catches

A shared noun in the brief covering two faults that fail in opposite directions. You plant the
one the brief named, it goes red, and you conclude the guard is armed — while the other condition
has never been exercised. Measured more than once: a green plant may not have planted the
condition you meant.

## Seams: where tests go

A seam is a public boundary. Tests live at seams, never against internals. Code can change
entirely; the tests should not.

**Agree the seams before writing the first test.** Say which boundaries you intend to test, and
confirm them. You cannot test everything, and agreeing up front puts the effort on the critical
paths instead of on every edge case.

> "The seams I plan to test are the `POST /v1/query` handler and the `resolve_binding()` return
> value. I am not testing the SQL builder directly — it has no callers outside `resolve_binding`.
> Does that match how you see it?"

## What a good test looks like

It reads like a specification. `test_a_user_can_check_out_a_valid_cart` tells you a capability
exists. `test_cart_service_calls_validate_once` tells you about today's implementation and goes
red the moment somebody refactors.

| Anti-pattern | Why it hurts | Instead |
| --- | --- | --- |
| Asserting on a mock's call count | Goes red on a correct refactor | Assert on the returned value or the stored row |
| One test with eight assertions | The first failure hides the other seven | One behaviour per test |
| A fixture the producer can never emit | The test passes on data that cannot happen | Build the fixture by calling the real producer |
| A predicate keyed on a word the producer always emits | The assertion is true regardless | Assert an equality over the whole list |

## Name tests after the behaviour

    def test_an_unbound_table_is_refused_before_any_query_runs():
    def test_a_revoked_grant_takes_effect_on_the_next_call():

Not `test_query_1`, not `test_error_case`.

## Read CONTEXT.md first

When you explore the codebase, read `CONTEXT.md` if it exists, so test names use the project's own
vocabulary. A test called `test_connection_is_refused` in a repo whose glossary says "binding"
makes the next reader check whether it is testing something else.

## Fix the code, not the test

A failing test is evidence. Do not weaken it, reorder it, or delete it to go green. If the test is
genuinely wrong, say why in one sentence and change it deliberately — then plant a failure to
confirm the new version still catches what the old one caught.
