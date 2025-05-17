# SISP
Simple In Shell Pipelines - tool for making really quick and simple pipelines inside shell and using shell.

## Features

- Define arbitrary build/test steps in your config
- Build and tag a Docker image
- Push the image to your registry
- `--dry-run` mode to preview commands

## Installation

1. Download or clone the `sisp` script.
2. Make it executable:
   ```sh
   chmod +x sisp.sh
3. Put it in your PATH (or just run ./sisp.sh).

## Usage
```bash
sisp --conf path/to/this.conf [--dry-run]
```
