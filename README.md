# AI Writing Toolkit

Shell scripts for engineers who need to research unfamiliar topics, think through design options, write high-level technical designs, and stress-test drafts before a design review. Uses any LLM CLI as a first-draft engine.

All commands go through a single entrypoint: `ait`.

---

## Supported Backends

| Backend | CLI | Install |
|---|---|---|
| Claude Code | `claude` | `npm install -g @anthropic-ai/claude-code` |
| Kiro CLI | `kiro-cli` | `curl -fsSL https://cli.kiro.dev/install \| bash` |
| Custom | any CLI that reads stdin | configure with `ait config` |

You need at least one. The installer auto-detects what's available.

---

## Prerequisites

At least one LLM backend CLI is required (see table above). The Claude Code backend installs via `npm`, which requires Node.js. If you don't have it, download it from [nodejs.org/en/download](https://nodejs.org/en/download).

---

## Install

```bash
git clone https://github.com/mcarruth/ai-writing-toolkit.git
cd ai-writing-toolkit
./install.sh
```

`install.sh` makes `ait` executable, adds `bin/` to your PATH, detects your LLM backend, and prompts you to configure your model and default output directory. Open a new terminal when it finishes, or run `source ~/.zshrc`.

### Uninstall

```bash
./uninstall.sh
```

Removes the PATH entry from your shell config and deletes `~/.ait`. Does not delete the repository.

---

## Configuration

All configuration is stored in `~/.ait/config`. You can set values with `ait config` or by editing the file directly.

### Backend

```bash
ait config backend claude-code    # use Claude Code
ait config backend kiro           # use Kiro CLI
ait config backend custom         # use a custom CLI
ait config custom-command 'my-llm-cli --no-interactive'  # set the custom command
```

You can also override per-invocation with the `AIT_BACKEND` environment variable:
```bash
AIT_BACKEND=claude-code ait research "some topic"
```

### Model

```bash
ait config model claude-sonnet-4-6   # set model
ait config model                             # show current
ait config model --clear                     # reset to default
```

Override per-invocation with `AIT_MODEL`.

### Output directory

By default, `ait` prints to stdout. Set a default output directory and `ait` will auto-save files organized by command type (e.g., `research/`, `design/`, `hld/`).

```bash
ait config output-dir ~/work/ait     # set
ait config output-dir                 # show current
ait config output-dir --clear         # remove
```

Override per-invocation with `AIT_OUTPUT_DIR` or the `-o` flag.

When a default output directory is set, output files are saved under `<output-dir>/<command>/`. The filename is determined as follows:

| `-o` value | Saved as |
|---|---|
| *(omitted)* | `<output-dir>/<command>/<slugified-topic>.md` |
| Bare filename (`my-doc` or `my-doc.md`) | `<output-dir>/<command>/my-doc.md` |
| Trailing slash (`notes/`) | `notes/<slugified-topic>.md` |
| Any path with a `/` | Used as-is |

For `exec-comms`, when no `-o` is given and the input is raw text, the LLM generates a meaningful filename from the content rather than slugifying your input.

---

## Usage

```
ait <command> [options]
```

Every command accepts:
- `-c, --context <file>` to inject context files (repeatable)
- `-o, --output <file>` to write output to a file instead of stdout
- `-h, --help` for command-specific help

---

## Commands

### `ait research` — Research brief

Takes a topic and produces a structured 2-3 page brief: the problem space, existing approaches, key tradeoffs, what the field has settled on, open questions, and what you need to figure out before designing.

```bash
ait research "transformer attention mechanisms for long-context retrieval"
ait research "LLM agent memory architectures" -o research.md
ait research "vector database tradeoffs" -c requirements.md -o research.md
```

### `ait design` — Design options

Takes a problem statement and produces three genuinely differentiated architectural options, each with pros, cons, and "best if" conditions. Ends with a recommendation and key decision criteria.

```bash
ait design "how to store and retrieve conversation history for LLM agents at 10k RPS"
ait design "sub-agent memory scoping" -c research.md -o design.md
```

### `ait hld` — High-level design draft

Takes your raw notes and produces a complete HLD: problem statement, solution summary, architecture diagram, sequence diagram, input/output protocol definitions, error/retry/failover logic, metrics and observability, and definition of done. Uses Mermaid for diagrams.

```bash
ait hld "build a feedback pipeline that captures conversation logs and writes to S3"
ait hld "going with option 2 from design doc" -c research.md -c design.md -o hld.md
```

### `ait hld-review` — Design review prep

Takes a draft HLD file and returns: critical issues that would block a review, the five hardest questions a principal engineer is likely to ask, the three weakest sections with improvement suggestions, and a checklist of what's missing.

```bash
ait hld-review hld.md
ait hld-review hld.md -c research.md -c design.md -o hld-feedback.md
```

### `ait one-pager` — One-page summary

Creates a one-page summary for partner teams, leadership, or stakeholders: what you're building, why it matters, who it's for, the high-level approach, timeline, dependencies, and risks.

```bash
ait one-pager "summarize our Q2 roadmap for partner teams"
ait one-pager "feature tracks after launch" -c roadmap.md -o one-pager.md
```

### `ait exec-comms` — Executive communication

Transforms technical communication into FIR format (Facts, Impact, Recommendation) for VP/SVP audiences. Output is a single concise paragraph — ready to paste into an email, MBR entry, or meeting notes. When no output filename is given, the LLM generates a meaningful name from the content.

```bash
ait exec-comms "We had an outage today for 55 minutes due to memory issues"
ait exec-comms draft-email.txt -c roadmap.md -o exec-update.md
```

### `ait prfaq-review` — PRFAQ review

Reviews a PRFAQ from the perspective of a VP of Engineering. Evaluates whether the customer problem is real and large enough, whether the solution is genuinely differentiated, and whether the FAQs answer the hard questions or avoid them.

```bash
ait prfaq-review prfaq.md
ait prfaq-review prfaq.md -c strategy.md -o prfaq-feedback.md
```

### `ait coe-review` — COE review

Reviews a Correction of Errors document from the perspective of a VP of Engineering. Evaluates whether the root cause analysis went deep enough, whether action items are structural fixes or surface patches, and whether the document is honest about what went wrong.

```bash
ait coe-review coe.md
ait coe-review coe.md -o coe-feedback.md
```

### `ait op1-review` — OP1 review

Reviews an Operating Plan narrative from the perspective of a VP of Engineering. Evaluates whether priorities are clear and ranked, whether investment asks are tied to measurable outcomes, and whether risks and tradeoffs are disclosed honestly.

```bash
ait op1-review op1.md
ait op1-review op1.md -c strategy.md -o op1-feedback.md
```

### `ait mbr-review` — MBR review

Reviews a Monthly Business Review narrative from the perspective of a VP of Engineering. Evaluates whether bad news is surfaced directly, whether metric trends are explained with clear next actions, and whether asks to leadership are specific.

```bash
ait mbr-review mbr.md
ait mbr-review mbr.md -o mbr-feedback.md
```

### `ait config` — Configuration

View or set configuration values.

```bash
ait config backend               # show current backend
ait config backend claude-code   # set backend
ait config model                 # show current model
ait config output-dir ~/work/ait # set output directory
```

---

## Full pipeline

The commands are designed to chain. Output from each step feeds the next via `--context`.

When `output-dir` is configured, you can pass bare filenames to `-c` — `ait` will find the file in your output directory automatically. The pipeline below works the same whether you use `-o` to write explicit paths or rely on `output-dir` to manage them.

```bash
# Step 1: get up to speed on the topic
ait research "agent memory architectures for multi-agent LLM systems" -o research.md

# Step 2: explore the design space
ait design "how to scope memory per sub-agent in our orchestrator" -c research.md -o design.md

# Step 3: draft the HLD using both prior outputs as context
ait hld "going with option 2 (scoped views over a centralized store)" \
    -c research.md -c design.md -o hld.md

# Step 4: stress-test before the review meeting
ait hld-review hld.md -c research.md -c design.md -o hld-feedback.md
```

The output of `review` tells you what to fix and what questions to prepare before you walk into the room.

---

## Customizing skills

The skills are plain markdown files in `skills/`. Each command maps to a skill directory:

```
skills/
  _shared/amazon-writing.md   # writing standards applied to all output
  research-deep/SKILL.md      # research brief instructions
  design-options/SKILL.md     # design options instructions
  hld-draft/SKILL.md          # HLD instructions
  review-prep/SKILL.md        # hld-review instructions
  one-pager/SKILL.md          # one-pager instructions
  exec-comms/SKILL.md         # exec comms instructions
  prfaq-review/SKILL.md       # PRFAQ review instructions
  coe-review/SKILL.md         # COE review instructions
  op1-review/SKILL.md         # OP1 review instructions
  mbr-review/SKILL.md         # MBR review instructions
```

Edit any `SKILL.md` to change the output style, structure, or tone. Changes take effect immediately.

---

## Tips

- Quoting multi-word inputs is optional. `ait hld my raw notes` works the same as `ait hld "my raw notes"`. Paths with spaces also work unquoted.
- Set an output directory. Run `ait config output-dir ~/work/ait` and stop typing `-o` on every command. When set, bare filenames passed to `-c` are automatically resolved against it, so the full pipeline works without any absolute paths.
- Iterate on the HLD. `ait hld` produces a first draft. Read it, edit it, then run `ait hld-review` on the edited version.
