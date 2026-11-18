# 0001: Record decisions as ADRs in the MADR format

- **Status:** accepted
- **Date:** 2026-11-17
- **Decision-maker:** DimiJonas

## Context and problem

The platform will need many decisions (repositories, tools, security trade-offs), and the
repositories should show later – to me and to others – why things are the way they are. In
storybook and dk-srv, decisions live in "Decided:" sections of the roadmaps: no status, not
linkable one by one, and the options that were rejected aren't recorded. Options and drafts are
prepared with the help of an AI tool; the decisions and their reasoning are my own. Which format
should the platform's decisions have – and how are they made?

## Decision drivers

- the options considered must be recorded, not only the result
- the reasoning must still be understandable years later
- easy to find and to link; a status (proposed, accepted, superseded)
- little writing effort (the records are drafted with tool support)

## Considered options

1. "Decided:" sections in the roadmap, as in storybook and dk-srv
2. Michael Nygard's ADR format (status, context, decision, consequences)
3. MADR (Markdown Any Decision Records)
4. Y-statements (one structured sentence per decision)

## Decision

**Chosen option: MADR (3), slightly shortened** – together with a rule for how decisions are
made: the options are laid out with the information that matters before anything is decided, and
the decision is recorded with its reasoning.

**Reasoning:** MADR captures everything that informs a decision – the drivers, the options and
their trade-offs – so the reasoning can still be traced years later. Because the records are
drafted with tool support, the longer format costs little effort. Y-statements were rejected: the
single-sentence form is too compressed to read well. Nygard's format lacks a place for the options
considered. The earlier decisions in storybook and dk-srv keep their original form; every new
decision is recorded as an ADR.

## Consequences

- Good: every decision has its options, its reason and its consequences in one linkable file; the
  repositories show how decisions were made.
- Good: options are weighed before deciding, not after – the decisions are better informed.
- Bad: a decision takes a little longer.
- The old "Decided:" sections in storybook and dk-srv stay as they are.
- Revisit when: the records get too heavy to keep up with.

## Confirmation

Every decision in the roadmap's "Open decisions" table becomes an ADR before the step that needs it
is built; the index in [`README.md`](README.md) lists them all.

## The options in detail

### 1. "Decided:" sections in the roadmap

- For: nothing new.
- Against: decisions are buried in long files, without status; rejected options aren't recorded.

### 2. Nygard's ADR format

The original ADR (2011): title, status, context, decision, consequences.

- For: very short.
- Against: no place for the options considered.

### 3. MADR

Adds decision drivers, the considered options with pros and cons, and "chosen option, because …";
since version 3.0.0 the records live in `docs/decisions/`.

- For: the options are a required part; widely used.
- Against: longer to write.

### 4. Y-statements

"In the context of …, facing …, we decided for … and against …, to achieve …, accepting …".

- For: compact.
- Against: too thin to learn from later.

## More information

- [MADR](https://adr.github.io/madr/)
- [Michael Nygard: Documenting architecture decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- Template: [`adr-template.md`](adr-template.md)
