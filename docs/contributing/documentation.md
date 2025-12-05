# Documentation

## Overview

This project uses [MkDocs](https://www.mkdocs.org/) with the [Material theme](https://squidfunk.github.io/mkdocs-material/) to generate documentation from Markdown files.

## Structure

The documentation is organized as follows:

```
platform/
├── .github/
│   └── mkdocs.yml          # MkDocs configuration
└── docs/
    ├── index.md            # Home page
    ├── setup.md            # Installation guide
    ├── usage.md            # Usage instructions
    ├── contributing.md     # Contributing guidelines
    └── documentation.md    # This page
```

## Configuration

The MkDocs configuration is located at `.github/mkdocs.yml`:

```yaml
site_name: Aincrad
site_url: https://aincradot.github.io/platform
repo_url: https://github.com/aincradot/platform
edit_uri: edit/master/docs/

theme:
  name: material

nav:
  - Platform:
      - Overview: index.md
      - Golden Path: golden-path.md
  - Architecture:
      - Overview: architecture/index.md
      ...
```

!!! note
    The configuration uses default `docs_dir` (relative to mkdocs.yml), which resolves to `../docs/` from `.github/mkdocs.yml`. All documentation lives in the `docs/` directory at repository root.

## Adding New Pages

To add a new documentation page:

### Create the Markdown file

Add your new file to the `docs/` directory:

```bash
touch docs/new-page.md
```

### Update the navigation

Add the new page to the `nav` section in `.github/mkdocs.yml`:

```yaml
nav:
  - ...
  - New Page: new-page.md
```

### Build and preview

The documentation is automatically built and deployed via GitHub Actions when changes are pushed to the `master branch`.
