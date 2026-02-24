# Helm Chart Packaging & Hosting Strategy

## Overview

This document outlines the strategy for packaging and hosting the dbt-workbench Helm chart from the `dbt-workbench-helm` repository.

## Current Structure

```
dbt-workbench-helm/
├── dbt/
│   ├── chart/              # Helm chart directory
│   │   ├── Chart.yaml     # Chart metadata (version: 0.2.0)
│   │   ├── values.yaml    # Default configuration
│   │   └── templates/     # K8s manifests
│   └── code/              # Application source code
│       ├── backend/       # Python/FastAPI backend
│       ├── frontend/      # TypeScript/Vite frontend
│       └── dbt_project/   # dbt project files
```

## Packaging Strategy

### 1. Chart Location
- **Source**: `dbt-workbench-helm/dbt/chart/`
- **Package Name**: `dbt-workbench-trino`
- **Current Version**: `0.2.0`

### 2. Version Management
- Chart version follows [semantic versioning](https://semver.org/)
- Update `Chart.yaml` version field for each release
- Use `appVersion` to track the application version

### 3. Package Output
- Generate `.tgz` archive for each version
- Example: `dbt-workbench-trino-0.2.0.tgz`

## Hosting Options

### Option A: GitHub Releases (Recommended)
1. Create GitHub Releases for each chart version
2. Attach the `.tgz` chart package to the release
3. Users add the repository:
   ```bash
   helm repo add dbt-workbench https://raw.githubusercontent.com/<org>/<repo>/<release>
   helm repo update
   helm install dbt-workbench dbt-workbench-trino
   ```

### Option B: GitHub Pages
1. Enable GitHub Pages in repository settings
2. Use `gh-pages` branch or GitHub Actions to deploy
3. Serve `index.yaml` and chart packages from Pages URL

### Option C: OCI Registry (Docker Hub/GHCR)
1. Package chart as OCI image
2. Push to OCI registry
3. Users pull directly:
   ```bash
   helm pull oci://ghcr.io/<org>/dbt-workbench-trino --version 0.2.0
   ```

## Recommended Approach

**Hybrid: GitHub Releases + GitHub Pages**

1. **CI/CD**: GitHub Actions builds and packages chart on tag
2. **Distribution**: 
   - Chart packages (`.tgz`) attached to GitHub Releases
   - `index.yaml` served via GitHub Pages for `helm repo` commands

### Repository URL Pattern
```
https://<org>.github.io/<repo>/charts/index.yaml
```

## Makefile Targets

The Makefile provides these targets:

| Target | Description |
|--------|-------------|
| `make lint` | Validate chart syntax with helm lint |
| `make template` | Render templates locally |
| `make package` | Create `.tgz` archive |
| `make index` | Generate/update index.yaml |
| `make release` | Create GitHub release |
| `make clean` | Remove generated files |

## Usage

```bash
# Package the chart
make package

# Lint and validate
make lint

# Create a release (requires GITHUB_TOKEN)
make release VERSION=0.2.0

# Serve locally for testing
helm serve --repo-path ./pkg
```

## CI/CD Integration

GitHub Actions workflow should:
1. Trigger on version tags (`v*`)
2. Run `make lint` and `make template`
3. Run `make package`
4. Create GitHub Release with artifact
5. Update `index.yaml` for GitHub Pages