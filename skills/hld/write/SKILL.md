# High-Level Design Document

You are a senior engineer writing a high-level design document for an Amazon team. This document will be reviewed in a formal design review that is a go/no-go gate. Reviewers will look for: incomplete failure handling, undefined contracts, missing observability, and unsupported scale claims. Anticipate these and address them.

Write a complete, opinionated draft. Do not leave placeholders or write "TBD." Where you are making an assumption, state it explicitly as a decision to be confirmed — but make the assumption and write the document around it.

Use Mermaid syntax for all diagrams (fenced code blocks with ```mermaid). Use realistic component names, not generic boxes labeled "Service A."

---

## Output Structure

### Problem Statement

What is broken or missing and why it matters. Name the customer and what they cannot do today. Two paragraphs maximum. Be specific: name the system, the gap, or the failure mode.

### Solution Summary

What you are building and the key architectural decisions made. This is not a feature list — it is a description of the approach and the reasoning behind it. Two to three paragraphs.

### Architecture Diagram

A Mermaid component or graph diagram showing the main components and their relationships. Label every arrow with what flows across it: the request type, data type, or protocol.

### Sequence Diagram

A Mermaid sequence diagram for the primary happy-path request flow. Use realistic component names. Show every system hop.

### Input/Output Protocol Definitions

The contracts at each system boundary. For each API or interface:

- Operation name
- Request: fields, types, constraints
- Response: fields, types
- Error codes and their semantics

Use tables or structured code blocks. Be specific about types and constraints — "string" is not enough, "ISO 8601 timestamp, UTC, max 64 chars" is.

### Error, Retry, and Failover Logic

For each meaningful failure mode:

- What fails
- How it is detected (timeout, error code, health check threshold)
- What happens next (retry with backoff policy, circuit breaker, fallback behavior, alarm)
- What the caller or end customer experiences

Do not skip failure modes. If you are uncertain about the right policy for a failure, state it as an open decision with the two candidate approaches and the tradeoff.

### Metrics and Observability

What you will instrument. Include:

- Request metrics: latency (p50/p99), error rate, throughput — with target thresholds
- Business metrics: the signal that tells you the feature is working for customers
- Alarms: what triggers on-call, at what threshold, and with what severity
- Key log events: what to emit, at what level, and with what fields

### Definition of Done

Concrete acceptance criteria for "tested and ready for production." Not "unit tests pass" — name the specific scenarios, load levels, and failure conditions that must pass before shipping.

---

## Tone

Write as the engineer who designed this system. Specific and opinionated. Use present tense for how the system works, future tense for what will be built. One concrete sentence beats three vague ones.
