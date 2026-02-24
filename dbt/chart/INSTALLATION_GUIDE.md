# dbt-Workbench Trino Installation & Verification Guide

This guide provides step-by-step instructions for installing and verifying the dbt-Workbench Helm chart with Trino integration.

## Prerequisites

Before starting, ensure you have the following installed and configured:

- **Kubernetes Cluster**: A running K8s cluster (e.g., Kind, Minikube, or EKS).
- **Helm**: Helm v3 installed on your machine.
- **Docker**: Docker installed and running.
- **Trino**: A Trino instance must be present in the cluster with a **writable catalog** (e.g., `memory`, `hive`, etc.).

## Installation Methods

### Method 1: Install from GitHub Pages Repository (Recommended)

Add the chart repository and install:

```bash
# Add the chart repository
helm repo add dbt-workbench https://<org>.github.io/<repo>
helm repo update

# Install the chart
helm install dbt-workbench-trino dbt-workbench/dbt-workbench-trino
```

### Method 2: Install from GitHub Releases

Download and install a specific version:

```bash
# Download the chart
helm pull https://<org>.github.io/<repo>/charts/dbt-workbench-trino-<version>.tgz

# Extract and install
tar -xzf dbt-workbench-trino-<version>.tgz
helm install dbt-workbench-trino ./dbt-workbench-trino
```

### Method 3: Install from Local Chart

If you have the chart source locally:

```bash
cd dbt-workbench-helm
helm install dbt-workbench-trino dbt/chart
```

## 1. Fast Track: Install Trino (Quick Test)

If you don't have Trino running, use this command to install a test instance with a writable memory catalog:

```bash
helm install trino trino/trino \
  -n trino \
  --create-namespace \
  --wait \
  --timeout 5m \
  --set server.workers=1 \
  --set server.autoscaling.enabled=false \
  --set additionalCatalogs.memory.connector.name=memory
```

> [!NOTE]
> Wait until the Trino pods are fully ready before proceeding to the next step.

## 2. Install dbt-Workbench Trino Chart

1. **Configure API URL**: Open `dbt-workbench-trino-chart/values.yaml` and update the `VITE_API_BASE_URL` with your public IP (or localhost):

```yaml
frontend:
  env:
    VITE_API_BASE_URL: "http://<EC2_PUBLIC_IP>:8000"
```

2. **Install the Chart**: Navigate to the project root and install:

```bash
helm install dbt-workbench-trino dbt-workbench-trino-chart/
```

## 3. Access dbt-Workbench

Once the pods are running, port-forward the frontend and backend services to your local machine (or use your VM's IP).

### Port Forwarding
Run these commands in the background:

```bash
# Frontend
nohup kubectl port-forward svc/dbt-workbench-trino-frontend 3000:3000 --address 0.0.0.0 >/tmp/pf-fe.log 2>&1 &

# Backend
nohup kubectl port-forward svc/dbt-workbench-trino-backend 8000:8000 --address 0.0.0.0 >/tmp/pf-be.log 2>&1 &
```

### Accessing the UI
Open your browser and navigate to:
`http://<ec2_public_ip_or_localhost>:3000`

## 4. Verification Steps

Follow these steps to ensure everything is working correctly:

### A. Verify Automatic Profiles Generation
1. Go to the **Environment** section in the UI.
2. Click on **Manage Profiles**.
3. Verify that `profiles.yml` has been automatically generated with the Trino connection details (default target: `trino_dev`).

### B. Create a New Environment
1. In the **Environment** section, click **Create New Environment**.
2. **Name**: `trino_dev` (or any name you prefer).
3. **Project**: Select `default`.
4. Click **Create**.

### C. Run dbt Commands
1. Navigate to the **Runs** section.
2. Select your newly created `trino_dev` target from the dropdown.
3. Execute the following commands one by one and verify they succeed:
    - **Seed**
    - **Run**
    - **Test**
    - **Docs**

### D. Manual Data Verification (Optional)
Exec into the Trino pod to verify that data has been stored:

```bash
kubectl exec -it <trino-coordinator-pod-name> -n trino -- trino --catalog memory --schema default
# Run a sample query:
# SHOW TABLES;
# SELECT * FROM <your_table_name> LIMIT 10;
```

---
> [!TIP]
> If you encounter issues, check the logs of the `dbt-workbench-trino-backend` pod for detailed error reports.
