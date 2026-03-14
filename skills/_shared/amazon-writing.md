# Amazon Writing Standards

Apply these to all output. No exceptions.

## Voice

- Use active voice. "The service processes the request" not "the request is processed by the service."
- Write in first person plural for team actions ("we will build"), first person for recommendations ("I recommend option 2").
- Short sentences. If a sentence exceeds 20 words, split it.
- No bullet points for reasoning or explanation. Use paragraphs. Use bullets only for true parallel lists: steps, options, attributes.
- Never sell. The moment a document feels like it is pitching something, readers stop reading. State what the system does and what it delivers. Let the reader decide if it matters. Avoid dramatic framing ("the bet," "the payoff," "game-changing") and let the facts carry the weight.

## Audience

- Know the reader before writing. What do they already know? What context do they bring? What will they disagree with?
- Anticipate objections. List the ten questions a reader is most likely to ask. Answer the important ones in the text.
- Do not assume shared vocabulary. Define acronyms on first use. Avoid jargon unless the audience universally understands it.

## Specificity

- Every performance claim needs a number. Not "low latency" — "p99 under 50ms."
- Name the customer and what they cannot do today. Not "users will benefit" — "applied science engineers will be blocked from iterating on eval pipelines until this ships."
- Name failure modes explicitly. Not "there are reliability risks" — "if the upstream service is unavailable for more than 30 seconds, we will begin returning stale results and alert on-call."
- Use data that supports and argues against your position. Demonstrate that you have assessed the risks, not just the upside.
- Avoid: leverage, synergy, seamlessly, robust, scalable, best-in-class, world-class, innovative, next-generation, game-changing, holistic, streamline, empower, paradigm.

## Numbers

- Numbers under ten are spelled out. Ten and above use numerals.
- Estimates are ranges, not points. "2–4 weeks" not "3 weeks."
- Scale claims require context. "10k RPS" is incomplete. "10k RPS at p99 < 100ms with a 99.9% success rate" is a real requirement.

## Structure

- The opening sentence is the most important sentence in the document. It must be clear, tight, and specific. Spend disproportionate time on it.
- State the purpose of the document in the first paragraph: what it covers, what it does not cover, and what you are asking from the reader.
- Each section must stand on its own and build on the previous one. The reader should never wonder how you got from one section to the next.

## Document conventions

- Present tense for how the system works once built.
- Future tense only for what will be built.
- Section headers are noun phrases. "Problem Statement" not "Describing the Problem."
- Do not start a document by restating the title as a sentence.

## Markdown front matter

Every markdown document must begin with YAML front matter between `---` delimiters. Include these fields:

```
---
topic: <document title>
date: <YYYY-MM-DD>
type: <research|design|hld|review|one-pager|exec-comms>
status: Draft
version: "1.0"
tags: [relevant-tag, another-tag]
context: ["[[filename-without-extension]]", "[[another-filename]]"]
---
```

For the `context` field: if context files were injected (you will see them as `--- Context: filename ---` blocks in the prompt), list each source file as an Obsidian wiki link using only the filename without its extension — for example, `"[[ads-agent-orchestrator-context]]"`. Omit the `context` field entirely if no context files were provided.

The first line of the document body follows immediately after the closing `---`.
