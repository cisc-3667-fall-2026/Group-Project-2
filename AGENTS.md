# [AGENTS.md](http://AGENTS.md)

Instructions for AI coding agents (e.g., Claude Code, Codex, Grok, GitHub Copilot, Muse, Gemini, Cursor, Hermes; if allowed to use) and human contributors. This file explains what to build and how to work on it. If this file and a maintainer's direct instruction disagree, follow the maintainer and point out the conflict.

## Project Overview

...

### Sources of Truth

...

### What the game is not

...

### Playtest Scope

...

## Product Rules

...

## Architecture

...

## Development workflow

...

### Squashing and updating a branch

To combine local commits before opening or updating a pull request:

```sh
git rebase -i HEAD~N                     # humans: squash or reorder interactively
git reset --soft HEAD~N && git commit    # agents without an interactive editor
git push --force-with-lease              # update the remote after rewriting history
```

To pick up new changes from `main`, rebase instead of merging:
`git fetch origin && git rebase origin/main`.

Only rewrite history on your own feature branch. Never use plain `--force`,
and never force-push `main` or a branch someone else is working on.

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```text
<type>(<scope>): <subject>

<body: what changed and why, wrapped at 72 characters>

Closes #123
Co-authored-by: <tool or model used, if any>
```

- **Type**: `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `style`, `build`, `ci`, or `chore`.
- **Scope** (optional): the area touched. Suggested scopes are `data`, `ui`, `docs`, `ci`, and `repo`. Add new ones as the codebase grows, and reuse existing ones.
- **Subject**: imperative mood, lowercase, no trailing period, 72 characters or fewer. Example: `feat(scoring): implemented player scoring with Geoguessr's exponential decay formula`.
- **Body**: explain *why*, not just *what*. Optional for trivial changes.
- **Issues**: if the work addresses an issue, close it with a GitHub keyword in the footer (`Closes #123` or `Fixes #123`). The issue closes when the commit lands on `main`.
- **Breaking changes**: add `!` after the type or scope, plus a `BREAKING CHANGE:` footer.

Pull request titles use the same format, because a squash merge uses the title as the commit subject.

## Code and documentation

- Write clear, readable code and documentation. Clarity beats cleverness.
- Prefer simple, well-scoped changes over large rewrites.
- Match the style of the surrounding code. Don't reformat files you aren't otherwise changing.
- Behavior changes come with tests. Bug fixes come with a test that would have caught the bug.
- Update docs (README, this file, comments) in the same pull request as the change they describe.
- Don't leave commented-out code, debug output, or TODOs without a linked issue.

## Disclosure of AI use

If AI tools helped write code, docs, or tests, add a `Co-authored-by` trailer to the commit for each tool, naming the tool or model actually used.

Whoever opens the pull request is responsible for any AI-assisted work in it. Read it, understand it, and be ready to explain it in review. The trailer adds to any course policy on AI use. It does not replace one.

## Rules for AI agents

**Always**

- Follow this file, especially the product rules, the scope boundary, and the data rules.
- Read the relevant code before changing it, and limit edits to what the task needs.
- Run the project's tests and linters before proposing a commit (once they exist), and report failures as they are.
- Add the AI disclosure trailer to commits you write.

**Ask first**

- Adding or changing dependencies, languages, frameworks, or tooling.
- Changing CI, repository settings, or the rules in this file.
- Deleting files or rewriting history that others may have pulled.
- Anything that changes how patient data is stored, sent, or displayed.
- Pushing branches or opening pull requests.

**Never**

- Use closed-source or private assets from users who are not one of the team members.
- Add an LLM or any other AI text generation to the product.
- Build anything listed under "What the game is not" or under Future Directions (reference IDs will go here) unless the team asks.
- Push to `main`, force-push shared branches, or skip hooks and checks (`--no-verify`).
