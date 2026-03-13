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

At least one LLM backend CLI is required (see table above). The Claude Code and Kiro CLI backends install via `npm`, which requires [Node.js](https://nodejs.org) (v18 or later recommended). If you don't have Node, install it from nodejs.org or via a version manager like `nvm`:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install --lts
```

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

When a default output directory is set and `-o` is not specified, files are saved as:

```
<output-dir>/<command>/<slugified-topic>.md
```

For example, `ait research "vector DB tradeoffs"` saves to `~/work/ait/research/vector-db-tradeoffs.md`.

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

### `ait review` — Design review prep

Takes a draft HLD file and returns: critical issues that would block a review, the five hardest questions a principal engineer is likely to ask, the three weakest sections with improvement suggestions, and a checklist of what's missing.

```bash
ait review hld.md
ait review hld.md -c research.md -c design.md -o review-feedback.md
```

### `ait one-pager` — One-page summary

Creates a one-page summary for partner teams, leadership, or stakeholders: what you're building, why it matters, who it's for, the high-level approach, timeline, dependencies, and risks.

```bash
ait one-pager "summarize our Q2 roadmap for partner teams"
ait one-pager "feature tracks after launch" -c roadmap.md -o one-pager.md
```

### `ait exec-comms` — Executive communication

Transforms technical communication into FIR format (Facts, Impact, Recommendation) for senior leaders. Restructures bottom-up technical narratives into the top-down format leaders expect.

```bash
ait exec-comms "We had an outage today for 55 minutes due to memory issues"
ait exec-comms draft-email.txt -c roadmap.md -o exec-update.md
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
ait review hld.md -c research.md -c design.md -o review-feedback.md
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
  review-prep/SKILL.md        # review prep instructions
  one-pager/SKILL.md          # one-pager instructions
  exec-comms/SKILL.md         # exec comms instructions
```

Edit any `SKILL.md` to change the output style, structure, or tone. Changes take effect immediately.

---

## Tips

- Quote multi-word inputs. The first positional argument is the main prompt.
- Set an output directory. Run `ait config output-dir ~/work/ait` and stop typing `-o` on every command. When set, bare filenames passed to `-c` are automatically resolved against it, so the full pipeline works without any absolute paths.
- Iterate on the HLD. `ait hld` produces a first draft. Read it, edit it, then run `ait review` on the edited version.
