# 0001: Record decisions as ADRs in the MADR format

- **Status:** accepted
- **Date:** 2026-11-17
- **Decided by:** the owner (DimiJonas)
- **Prepared by:** Claude (options, information, recommendation)

## Context and problem

The platform will need many decisions (repositories, tools, security trade-offs), and the
repositories should show later – to me and to others – why things are the way they are. In
storybook and dk-srv, decisions live in "Decided:" sections of the roadmaps: no status, not
linkable one by one, and the options that were rejected aren't recorded. Which format should the
platform's decisions have – and how are they made?

## Decision drivers

- the options considered must be recorded, not only the result
- a decision must still make sense to me years later: in my own words
- easy to find and to link; a status (proposed, accepted, superseded)
- little writing effort for me (Claude prepares the records)

## Considered options

1. "Decided:" sections in the roadmap, as in storybook and dk-srv
2. Michael Nygard's ADR format (status, context, decision, consequences)
3. MADR (Markdown Any Decision Records)
4. Y-statements (one structured sentence per decision)

## Decision

**Chosen option: MADR (3), slightly shortened** – plus the rule how a decision is made: Claude
lays out the options with the information that matters and a recommendation, clearly marked as
Claude's; I decide and give my reason in my own words; the ADR records both.

**Reason (owner, in his own words):** "The MADR format seems to include all information used for
the decision, and since you write it mostly I don't have the disadvantage of having to write long
records. Y-statements: I don't like that sentence format. I think it's okay that the previous
ADRs [in storybook and dk-srv] have the format of option 1. From now on they should be put in an
actual ADR format."

Claude's recommendation was the same (MADR, shortened, with a line for the owner's reason).

## Consequences

- Good: every decision has its options, its reason and its consequences in one linkable file; the
  repositories show how decisions were made.
- Good: the reason is mine, so the decision means something to me later.
- Bad: a decision takes a little longer – the options are laid out before I decide.
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
