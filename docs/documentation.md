# Documentation

## Overview

This project uses [MkDocs](https://www.mkdocs.org/) with the [Material theme](https://squidfunk.github.io/mkdocs-material/) to generate documentation from Markdown files.

## Structure

The documentation is organized as follows:

```
{{ repository }}/
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
site_name: {{ organisation }} {{ repository }}
site_url: https://{{ organisation }}.github.io/{{ repository }}
repo_url: https://github.com/{{ organisation }}/{{ repository }}
edit_uri: edit/master/docs/

theme:
  name: material

docs_dir: ../docs

nav:
  - ...
```

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
