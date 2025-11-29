# GitHub Workflows for CI/CD

## Overview

This project uses GitHub Actions for automated testing, building, and releasing. The pipeline integrates with our [Contributing Guidelines](https://{{ organisation }}.github.io/{{ repository }}/contributing) to provide a seamless development experience.

## Workflows

### Continuous Integration

Pull requests are automatically validated through our CI pipeline, which runs linting, testing, and build verification.

### Automated Releases

Releases are handled automatically using semantic versioning based on [Conventional Commits](https://www.conventionalcommits.org/). When code is merged to `master`, the system:

- Analyzes commit messages to determine the next version
- Creates GitHub releases with generated changelogs
- Attaches build artifacts to releases
- Publishes Docker images to GitHub Container Registry (when applicable)

### Documentation Deployment

Documentation changes pushed to `master` automatically deploy to GitHub Pages using MkDocs.

### Dependency Management

[Renovate](https://github.com/renovatebot/renovate) runs daily to scan for dependency updates and creates automated pull requests.

## Branch Protection

Repository branches are protected with automated rules:

- **`master`**: Requires linear history and passing CI checks (squash commits)
- **`gh-pages`**: Allows automated documentation deployments

## Next Steps

For detailed development practices and commit standards, see the [Contributing Guidelines](https://{{ organisation }}.github.io/{{ repository }}/contributing).
