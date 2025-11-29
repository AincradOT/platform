# Contributing Guidelines

## Workflow Principles

This repository follows a structured and policy driven workflow to keep the codebase consistent, and release-ready.

## Development Workflow

- Keep branches small and focused on a single change.
- Write clear commit messages following our [Conventional Commits](#commit-message-conventions) standard.
- Ensure your code is linted and tested before opening a pull request: `make lint test`
- Update or add relevant documentation (e.g., README, usage instructions).

## Pull Requests

- Target the appropriate branch:
  - **`master`** for ongoing work and pre-releases (alpha versions)
- Keep PRs small and focused.
- Include a clear description of your changes.
- Reference related issues (e.g., `Closes #42`).
- PRs must pass all CI checks before merging.

## Commit Message Conventions

This repository uses [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#summary)  
to enable automated versioning and changelog generation via **semantic-release**.

### Format:

```
<type>(optional scope): <description>

[optional body]

[optional footer]
```

### Common Types:

- **feat:** A new feature.
- **fix:** A bug fix.
- **docs:** Documentation-only changes.
- **style:** Changes that do not affect functionality (formatting, missing semicolons, etc.).
- **refactor:** Code changes that neither fix a bug nor add a feature.
- **test:** Adding or updating tests.
- **chore:** Maintenance tasks (build scripts, dependencies) that don't affect runtime code.

### Examples:

```
feat(api): add user authentication endpoint
fix(ui): correct button alignment on mobile view
docs: update contributing guidelines
```

> **Tip:** Use `BREAKING CHANGE:` in the footer for changes that break backward compatibility.  
> This will trigger a **major version bump** automatically.

## Testing

- Write tests for all new features and bug fixes.
- Ensure tests pass locally before submitting: `make test`

## Releasing

Releases are automated via [semantic-release](https://github.com/semantic-release/semantic-release):

- Merging PRs into **`master`** triggers a pre-release (`alpha`).
- Creating tags from **`master`** triggers a stable release (`vX.Y.Z`) with:
  - Changelog updates
  - GitHub Release creation
  - Docker image publishing
  - Artifact packaging

You do **not** need to create tags manually. The workflow handles it.
