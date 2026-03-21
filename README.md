# AI Writing Toolkit

Shell scripts for engineers who need to research unfamiliar topics, think through design options, write high-level technical designs, and produce Amazon narrative documents. Uses any LLM CLI as a first-draft engine.

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
ait config model                     # show current
ait config model --clear             # reset to default
```

Override per-invocation with `AIT_MODEL`.

### Output directory

By default, `ait` prints to stdout. Set a default output directory and `ait` will auto-save files organized by document type.

```bash
ait config output-dir ~/work/ait     # set
ait config output-dir                # show current
ait config output-dir --clear        # remove
```

Override per-invocation with `AIT_OUTPUT_DIR` or the `-o` flag.

When a default output directory is set, output files are saved under `<output-dir>/<type>/`. Reviews are saved alongside the document they review, named `<document>-review.md`.

| `-o` value | Saved as |
|---|---|
| *(omitted)* | `<output-dir>/<type>/<slugified-topic>.md` |
| Bare filename (`my-doc` or `my-doc.md`) | `<output-dir>/<type>/my-doc.md` |
| Trailing slash (`notes/`) | `notes/<slugified-topic>.md` |
| Any path with a `/` | Used as-is |

---

## Usage

```
ait <command> [options]
```

Every command accepts:
- `-c, --context <file>` to inject context files (repeatable)
- `-o, --output <file>` to write output to a file instead of stdout
- `-m, --model <name>` to override the model for this invocation
- `-h, --help` for command-specific help

When an output directory is configured, bare filenames passed to `-c` are automatically resolved against it — so `ait write hld "my notes" -c research.md` finds `research.md` in your output directory without a full path.

After writing a file, `ait` injects a `context:` field into the YAML front matter listing the resolved paths of all `-c` files used. This makes the pipeline traceable and enables future context auto-loading.

---

## Commands

### `ait research` — Research brief

Takes a topic and produces a structured 2-3 page brief: the problem space, existing approaches, key tradeoffs, what the field has settled on, open questions, and what you need to figure out before designing.

```bash
ait research "transformer attention mechanisms for long-context retrieval"
ait research "LLM agent memory architectures" -o research.md
ait research "vector database tradeoffs" -c requirements.md -o research.md
```

### `ait design-options` — Design options

Takes a problem statement and produces three genuinely differentiated architectural options, each with pros, cons, and "best if" conditions. Ends with a recommendation and key decision criteria.

```bash
ait design-options "how to store and retrieve conversation history for LLM agents at 10k RPS"
ait design-options "sub-agent memory scoping" -c research.md -o design-options.md
```

---

### `ait write` — Draft a document

Takes your notes and produces a complete draft of the requested document type.

#### `ait write hld`

High-level design document: problem statement, solution summary, architecture and sequence diagrams (Mermaid), input/output protocol definitions, error and retry logic, metrics and observability, and definition of done.

```bash
ait write hld "build a feedback pipeline that captures conversation logs and writes to S3"
ait write hld "going with option 2 from design doc" -c research.md -c design-options.md -o hld.md
```

#### `ait write prfaq`

Press release and FAQ (Working Backwards): a press release written as if the product launched today, an external FAQ covering customer objections, and an internal FAQ covering investment, build vs. buy, headcount, timeline, and key assumptions.

```bash
ait write prfaq "an AI agent that manages advertiser budgets across Amazon Ads"
ait write prfaq "unified ads reporting" -c context.md -o prfaq.md
```

#### `ait write six-pager`

Six-page narrative for leadership review: introduction, tenets, problem statement, proposed solution, metrics for success, risks and mitigations, next steps, and appendix list.

```bash
ait write six-pager "consolidate advertiser AI surfaces into a single orchestration layer"
ait write six-pager "annual plan for ads agent platform" -c context.md -o six-pager.md
```

#### `ait write one-pager`

One-page summary for partner teams, leadership, or stakeholders: what you're building, why it matters, who it's for, the high-level approach, timeline, dependencies, and risks.

```bash
ait write one-pager "summarize our Q2 roadmap for partner teams"
ait write one-pager "feature tracks after launch" -c roadmap.md -o one-pager.md
```

#### `ait write coe`

Correction of Errors document: customer impact, timeline, root cause analysis (five-whys depth), contributing factors, detection gap, action items with owners and dates, and recurrence prevention.

```bash
ait write coe "service outage 55 minutes, root cause memory leak in cache layer" -c incident-notes.md
ait write coe "latency spike caused by misconfigured retry policy" -c timeline.md -o coe.md
```

#### `ait write op1`

Operating Plan narrative: team mission, current state, ranked goals, investment asks tied to measurable outcomes, dependencies, and tradeoffs.

```bash
ait write op1 "ads agent platform: three SDEs, launch orchestrator to 9 product teams by unBoxed" -c context.md
ait write op1 "annual plan" -c goals.md -c headcount.md -o op1.md
```

#### `ait write mbr`

Monthly Business Review narrative: headlines, metrics with explanations, wins, misses with root causes, forward risks, and specific asks to leadership.

```bash
ait write mbr "latency hit target, partner onboarding slipped by 2 weeks due to security review" -c metrics.md
ait write mbr "march results" -c data.md -o mbr.md
```

---

### `ait review` — VP-level document review

Takes a document and returns: critical issues that would block approval, the hardest questions a VP or principal engineer will ask, the weakest sections with improvement suggestions, and a checklist of what's missing.

#### `ait review hld`

```bash
ait review hld hld.md
ait review hld hld.md -c research.md -c design-options.md
```

#### `ait review prfaq`

```bash
ait review prfaq prfaq.md
ait review prfaq prfaq.md -c strategy.md
```

#### `ait review coe`

```bash
ait review coe coe.md
```

#### `ait review op1`

```bash
ait review op1 op1.md -c strategy.md
```

#### `ait review mbr`

```bash
ait review mbr mbr.md
```

#### `ait review six-pager`

```bash
ait review six-pager six-pager.md
ait review six-pager six-pager.md -c context.md
```

#### `ait review one-pager`

```bash
ait review one-pager one-pager.md
```

---

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
ait design-options "how to scope memory per sub-agent in our orchestrator" -c research.md -o design-options.md

# Step 3: draft the HLD using both prior outputs as context
ait write hld "going with option 2 (scoped views over a centralized store)" \
    -c research.md -c design-options.md -o hld.md

# Step 4: stress-test before the review meeting
ait review hld hld.md -c research.md -c design-options.md
```

Output directories after running the full pipeline (with `output-dir` set):

```
<output-dir>/
  research/
  design-options/
  hld/
  prfaq/
  six-pager/
  one-pager/
  coe/
  op1/
  mbr/
```

Reviews are saved in the same directory as the document they review, named `<document>-review.md`.

---

## Customizing skills

The skills are plain markdown files in `skills/`. Each command maps to a skill directory:

```
skills/
  _shared/amazon-writing.md      # writing standards applied to all output
  research/SKILL.md              # research brief
  design-options/SKILL.md        # design options
  hld/
    write/SKILL.md               # HLD writer
    review/SKILL.md              # HLD reviewer
  prfaq/
    write/SKILL.md               # PRFAQ writer
    review/SKILL.md              # PRFAQ reviewer
  six-pager/
    write/SKILL.md               # six-pager writer
    review/SKILL.md              # six-pager reviewer
  one-pager/
    write/SKILL.md               # one-pager writer
    review/SKILL.md              # one-pager reviewer
  coe/
    write/SKILL.md               # COE writer
    review/SKILL.md              # COE reviewer
  op1/
    write/SKILL.md               # OP1 writer
    review/SKILL.md              # OP1 reviewer
  mbr/
    write/SKILL.md               # MBR writer
    review/SKILL.md              # MBR reviewer
```

Edit any `SKILL.md` to change the output style, structure, or tone. Changes take effect immediately.

---

## Tips

- Quoting multi-word inputs is optional. `ait write hld my raw notes` works the same as `ait write hld "my raw notes"`. Paths with spaces also work unquoted.
- Set an output directory. Run `ait config output-dir ~/work/ait` and stop typing `-o` on every command. When set, bare filenames passed to `-c` are automatically resolved against it, so the full pipeline works without any absolute paths.
- Iterate on the HLD. `ait write hld` produces a first draft. Read it, edit it, then run `ait review hld` on the edited version.
