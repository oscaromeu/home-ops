---
title: Semmantic Commits
---

## Overview

In this repo, I've tried to use semantic commit messages to make changes more descriptive and clear. This helps with readability and tracking changes, even in personal projects.

A good commit message format follows the pattern: `<type>(<scope>): <description>`

## Example

```
feat: add hat wobble
^--^  ^------------^
|     |
|     +-> Summary in present tense.
|
+-------> Type: chore, docs, feat, fix, refactor, style, or test.
```

More examples

- fix(auth): resolve incorrect password validation
- docs: add installation guide to README
- feat: add search feature
- refactor: improve UserService API calls
- test: create user registration tests

Key points for a good commit message:

1. Use a clear and concise `<description>` that summarizes the change.
2. Use the imperative mood for `<description>` (e.g., "resolve" instead of "resolved").
3. Limit the `<description>` line to 72 characters or fewer.
4. `<type>` should be one of the following: fix, feat, docs, style, refactor, test, chore, ci, build, perf.
5. Optionally, include a `<scope>` to provide more context about the affected part of the codebase.
6. If the commit closes an issue, include "Closes #issue-number" in the description.

Check out these resources:

- [https://www.conventionalcommits.org/](https://www.conventionalcommits.org/)
- [https://seesparkbox.com/foundry/semantic_commit_messages](https://seesparkbox.com/foundry/semantic_commit_messages)
- [http://karma-runner.github.io/1.0/dev/git-commit-msg.html](http://karma-runner.github.io/1.0/dev/git-commit-msg.html)
- [https://fluxcd.io/contributing/flux/#format-of-the-commit-message](https://fluxcd.io/contributing/flux/#format-of-the-commit-message)
