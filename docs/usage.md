# Usage

## Overview

This project uses a Makefile to simplify common development tasks. All commands are executed using `make <target>` from the project root.

## Make Targets

### Help

List all available `make` targets:

```bash
make help
```

### Setup

Install project dependencies and prepare the development environment:

> **Note**: A `.env` file is often required. If prompted by the setup command, create one from the project example (`cp .env.example .env`), then update values before running setup and other commands.

```bash
make setup
```

### Run

Start the service locally for development:

```bash
make run
```

### Lint

Run code quality checks and linting tools:

```bash
make lint
```

### Format

Automatically format code according to project style guidelines:

```bash
make format
```

### Test

Execute the project's test suite:

```bash
make test
```

### Build

Compile, transpile, or prepare runtime assets for the project:

```bash
make build
```

### Clean

Remove all build artifacts, caches, and Docker resources (requires confirmation):

```bash
make clean
```
