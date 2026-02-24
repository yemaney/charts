# dbt-Workbench Helm Chart

A Helm chart for deploying dbt-Workbench with Trino integration to Kubernetes.

## Chart Information

- **Chart Name**: `dbt-workbench-trino`
- **Chart Path**: `dbt/chart/`
- **Current Version**: See [`dbt/chart/Chart.yaml`](dbt/chart/Chart.yaml)

## Installation

### Add Repository (Recommended)

```bash
# Add the chart repository
helm repo add dbt-workbench https://<org>.github.io/<repo>
helm repo update

# Install the chart
helm install dbt-workbench-trino dbt-workbench/dbt-workbench-trino
```

### Install from GitHub Releases

```bash
# Download a specific version
helm pull https://<org>.github.io/<repo>/charts/dbt-workbench-trino-<version>.tgz

# Install
tar -xzf dbt-workbench-trino-<version>.tgz
helm install dbt-workbench-trino ./dbt-workbench-trino
```

### Install from Local Chart

```bash
helm install dbt-workbench-trino dbt/chart
```

## Development

### Prerequisites

- Helm v3.14.0+
- chart-testing

```bash
# Validate the chart
make lint

```

## CI/CD

This project uses GitHub Actions for automated chart releases. The workflow is defined in [.github/workflows/helm-release.yml](.github/workflows/helm-release.yml).

### Workflow Overview

The CI/CD workflow performs the following jobs:

1. **lint** - Lints the chart using chart-testing
2. **changes** - Detects if chart files have changed
3. **template** - Validates templates render correctly (only if chart changed)
4. **sync-readme** - Syncs README files to gh-pages branch (on main push)
5. **release** - Creates GitHub Release with chart package (on main push)

### Triggering a Release

To release a new version of the Helm chart:

1. **Update Chart Version**

   Edit `dbt/chart/Chart.yaml` and bump the `version` field:

   ```yaml
   apiVersion: v2
   name: dbt-workbench-trino
   description: A Helm chart for dbt-Workbench with Trino integration
   type: application
   version: 0.2.1  # Bump this version
   appVersion: "0.1.0"
   ```

2. **Commit and Tag**

   ```bash
   # Commit your changes
   git add dbt/chart/
   git commit -m "Bump chart version to 0.2.1"

   # Create a version tag (v prefix is required)
   git tag v0.2.1

   # Push changes and tag
   git push origin main
   git push origin v0.2.1
   ```

3. **Automated Release**

   The workflow will automatically:
   - Lint the chart
   - Validate templates
   - Sync README to gh-pages branch
   - Create a GitHub Release with the chart package
   - Update index.yaml on gh-pages

### Workflow Conditions

- **Pull Requests**: Runs lint and template validation only
- **Push to main**: Runs full pipeline including release and gh-pages sync
- **Version Tags** (e.g., `v0.2.1`): Creates a GitHub Release

### Verification

After the workflow completes:
- Check [Releases](https://github.com/<org>/<repo>/releases) for the new release
- Verify chart availability at: `https://<org>.github.io/<repo>/index.yaml`

## Documentation

- [Installation Guide](dbt/chart/INSTALLATION_GUIDE.md)
- [Packaging Strategy](HELM_PACKAGING_STRATEGY.md)
