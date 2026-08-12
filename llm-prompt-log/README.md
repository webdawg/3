# LLM Prompt Log

Raw, unedited history of the prompts given to the AI assistant working on this
project. This is deliberately separate from [`spec.md`](../spec.md): spec.md
curates prompts into organized Goals with analysis and implications; this
directory preserves the actual, verbatim input as given — typos, shorthand,
mid-turn interruptions, and all — including prompts that never became a
formal spec Goal (status checks, questions, corrections, one-off asks).

## Why

- **spec.md is curated, this is not.** Spec Goals summarize *what was decided*
  and *why*. This log preserves *what was actually typed*, unfiltered — a
  different, complementary kind of record. If a future session needs to know
  the exact original wording of something (not the assistant's paraphrase of
  it), this is where to look.
- **Not everything becomes a Goal.** Status checks ("do we have speed control
  yet?"), clarifying questions, and small one-off requests are real parts of
  the project's history but don't warrant their own spec section. They still
  belong somewhere.

## Format

One file per dump, named `YYYY-MM-DD_HHMMSS<_optional-label>.txt`, containing
the ordered, verbatim list of user prompts covered by that dump. Prompts are
numbered and separated by `---`, with a one-line header noting when the dump
was taken and what project/repo it covers. Nothing is corrected, reworded, or
summarized — copy-paste accuracy is the point.

Files are never edited after being written (append a new dump instead) and
are never deleted — this is meant to accumulate as a permanent record.

## Cadence

There's no automatic trigger for this — the assistant doesn't run on a timer,
so a dump only happens when asked. Recommended default: **whenever a batch of
work is committed and pushed**, since that's already the natural, recurring
checkpoint this project uses (a session's work tends to land in a commit
before moving on to the next thing). In practice that means asking for a
prompt-log dump at the same time as a "commit and push this" is a reasonable
default cadence, without needing to think about it separately.

If a session runs long without a commit checkpoint (a lot of back-and-forth
before anything's ready to ship), it's also reasonable to ask for a dump
mid-session — better to capture prompts once than to lose them if the session
ends unexpectedly.

For fully automatic capture (no need to ask at all), a Claude Code hook
(`Stop` or `SessionEnd` in `settings.json`) could trigger this on its own —
that's a deliberate config change, not set up here, since it wasn't asked
for. Worth considering later if manually asking becomes a chore.

## Scope

This log is local to this repository's working copy — it's a project
artifact like `spec.md`, not a global, cross-project log. Whether these files
get committed to git (and so pushed to the public GitHub remote) is a
separate decision each time, since prompt text may be more verbose or casual
than what belongs in a public repo; ask before pushing if unsure.
