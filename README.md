# AI Writing Toolkit

Shell scripts for engineers who need to research unfamiliar topics, think through design options, write high-level technical designs, and produce Amazon narrative documents. Uses any LLM CLI as a first-draft engine.

All commands go through a single entrypoint: `ait`.

---

## Install

### One-liner (curl)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/mcarruth/ai-writing-toolkit/main/install-remote.sh)
```

Downloads the repo, runs the installer, and adds `ait` to your PATH. Requires `git` and at least one LLM backend CLI.

### From a local clone

```bash
git clone https://github.com/mcarruth/ai-writing-toolkit.git
cd ai-writing-toolkit
./install.sh
```

Open a new terminal or run `source ~/.zshrc`, then configure your backend:

```bash
ait config backend claude-code   # or: kiro, custom
ait config model claude-sonnet-4-6
ait config output-dir ~/work/ait  # optional
```

### Uninstall

```bash
./uninstall.sh
```

Removes the PATH entry from your shell config and deletes `~/.ait`. Does not delete the repository.

---

## Usage

```
ait <command> [options]
```

### Write vs. review

Every doc command works in two modes depending on what you pass as the first argument:

```bash
ait hld "my notes"      # string input: write a new document
ait hld hld.md          # existing file: review that document
```

No subcommands to remember. The input determines the intent.

### Common flags

| Flag | Description |
|---|---|
| `-f, --file <file>` | Read input from a file instead of a string |
| `-c, --context <file>` | Inject a context file, repeatable |
| `-o, --output <file>` | Write output to a file (default: stdout) |
| `-m, --model <name>` | Override model for this invocation |
| `--dry-run` | Print the prompt without calling the LLM |
| `--no-frontmatter` | Output raw markdown, no YAML header |
| `-h, --help` | Show command help |

---

## Commands

### `ait research` — Research brief

Takes a topic and produces a structured 2-3 page brief: the problem space, existing approaches, key tradeoffs, what the field has settled on, open questions, and what you need to figure out before designing.

```bash
ait research "transformer attention mechanisms for long-context retrieval"
ait research "LLM agent memory architectures" -o research.md
ait research -f notes.md -c requirements.md -o research.md
```

---

### `ait options` — Design options

Takes a problem statement and produces three genuinely differentiated architectural options, each with pros, cons, and "best if" conditions. Ends with a recommendation and key decision criteria.

```bash
ait options "how to store and retrieve conversation history for LLM agents at 10k RPS"
ait options "sub-agent memory scoping" -c research.md -o options.md
```

---

### `ait hld` — High-level design document

Problem statement, solution summary, architecture and sequence diagrams (Mermaid), input/output protocol definitions, error and retry logic, metrics and observability, and definition of done.

```bash
ait hld "build a feedback pipeline that captures conversation logs and writes to S3"
ait hld "going with option 2 from design doc" -c research.md -c options.md -o hld.md
ait hld hld.md                                # review an existing HLD
ait hld hld.md -c research.md -c options.md   # review with context
```

---

### `ait prfaq` — Press release and FAQ

Press release written as if the product launched today, an external FAQ covering customer objections, and an internal FAQ covering investment, build vs. buy, headcount, timeline, and key assumptions.

```bash
ait prfaq "an AI agent that manages advertiser budgets across Amazon Ads"
ait prfaq "unified ads reporting" -c context.md -o prfaq.md
ait prfaq prfaq.md                            # review
```

---

### `ait six-pager` — Six-page narrative

Introduction, tenets, problem statement, proposed solution, metrics for success, risks and mitigations, next steps, and appendix list. Main body fits six pages; supporting data goes in appendices.

```bash
ait six-pager "consolidate advertiser AI surfaces into a single orchestration layer"
ait six-pager -f context.md -o six-pager.md
ait six-pager six-pager.md                    # review
```

---

### `ait one-pager` — One-page summary

What you're building, why it matters, who it's for, the high-level approach, timeline, dependencies, and risks. A three-minute read for partner teams or stakeholders.

```bash
ait one-pager "summarize our Q2 roadmap for partner teams"
ait one-pager -f roadmap.md -o one-pager.md
ait one-pager one-pager.md                    # review
```

---

### `ait coe` — Correction of Errors

Customer impact, timeline, root cause analysis (five-whys depth), contributing factors, detection gap, action items with owners and dates, and recurrence prevention.

```bash
ait coe "service outage 55 minutes, root cause memory leak in cache layer" -c incident-notes.md
ait coe -f timeline.md -o coe.md
ait coe coe.md                                # review
```

---

### `ait op1` — Operating Plan narrative

Team mission, current state, ranked goals, investment asks tied to measurable outcomes, dependencies, and tradeoffs.

```bash
ait op1 "ads agent platform: three SDEs, launch orchestrator to 9 product teams by unBoxed" -c context.md
ait op1 -f goals.md -c headcount.md -o op1.md
ait op1 op1.md                                # review
```

---

### `ait mbr` — Monthly Business Review narrative

Headlines, metrics with explanations, wins, misses with root causes, forward risks, and specific asks to leadership.

```bash
ait mbr "latency hit target, partner onboarding slipped by 2 weeks due to security review" -c metrics.md
ait mbr -f data.md -o mbr.md
ait mbr mbr.md                                # review
```

---

### `ait config` — Configuration

View or set configuration values stored in `~/.ait/config`.

```bash
ait config                            # show all current values
ait config backend claude-code   # set backend
ait config backend kiro
ait config model claude-sonnet-4-6
ait config output-dir ~/work/ait
ait config output-dir --clear
```

Override any setting per-invocation with environment variables:

```bash
AIT_BACKEND=kiro ait research "some topic"
AIT_MODEL=claude-sonnet-4-6 ait hld "my notes"
```

---

## Output directory

By default, `ait` prints to stdout. Set a default output directory and `ait` will auto-save files organized by command type.

```bash
ait config output-dir ~/work/ait
```

Output files are saved under `<output-dir>/<type>/`. Reviews are saved alongside the document they review, named `<document>-review.md`.

| `-o` value | Saved as |
|---|---|
| *(omitted)* | `<output-dir>/<type>/<slugified-topic>.md` |
| Bare filename (`my-doc` or `my-doc.md`) | `<output-dir>/<type>/my-doc.md` |
| Trailing slash (`notes/`) | `notes/<slugified-topic>.md` |
| Any path with a `/` | Used as-is |

When an output directory is configured, bare filenames passed to `-c` are automatically resolved against it. So `ait hld "my notes" -c research.md` finds `research.md` in your output directory without a full path.

---

## Full pipeline

The commands are designed to chain. Output from each step feeds the next via `-c`.

```bash
# Step 1: get up to speed on the topic
ait research "agent memory architectures for multi-agent LLM systems" -o research.md

# Step 2: explore the design space
ait options "how to scope memory per sub-agent in our orchestrator" -c research.md -o options.md

# Step 3: draft the HLD using both prior outputs as context
ait hld "going with option 2 (scoped views over a centralized store)" \
    -c research.md -c options.md -o hld.md

# Step 4: stress-test before the review meeting
ait hld hld.md -c research.md -c options.md
```

---

## Customizing skills

The skills are plain markdown files in `skills/`. Each command maps to a skill file:

```
skills/
  _shared/amazon-writing.md      # writing standards applied to all output
  research/SKILL.md
  design-options/SKILL.md        # used by: ait options
  hld/
    write/SKILL.md
    review/SKILL.md
  prfaq/
    write/SKILL.md
    review/SKILL.md
  six-pager/
    write/SKILL.md
    review/SKILL.md
  one-pager/
    write/SKILL.md
    review/SKILL.md
  coe/
    write/SKILL.md
    review/SKILL.md
  op1/
    write/SKILL.md
    review/SKILL.md
  mbr/
    write/SKILL.md
    review/SKILL.md
```

Edit any `SKILL.md` to change the output style, structure, or tone. Changes take effect immediately.

---

## Tips

- **Set an output directory**: Run `ait config output-dir ~/work/ait` and stop typing `-o` on every command. Bare filenames passed to `-c` resolve automatically, so the full pipeline works without absolute paths.
- **Dry run before sending**: Add `--dry-run` to any command to print the full prompt that would be sent to the LLM. Useful for checking context injection or debugging skill output.
- **Iterate on the HLD**: `ait hld` produces a first draft. Read it, edit it, then pass the file back to `ait hld` for review.
