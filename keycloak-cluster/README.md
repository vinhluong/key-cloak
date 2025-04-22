# Keycloak Cluster Directory

This directory contains all the components needed to run a high-availability Keycloak cluster with MySQL and Nginx.

## Components

### Docker Compose

The `docker-compose` directory contains the configuration files for running the cluster:
- `docker-compose.yml`: Main configuration file defining all services
- `.env`: Environment variables for customizing the deployment

### Docker Images

The `docker-images` directory contains customized Docker image definitions:
- `keycloak/Dockerfile`: Custom Keycloak build that incorporates code from GitHub

### Scripts

The `scripts` directory contains utility scripts for managing the cluster:
- `setup.sh`: Initial setup script
- `setup_github_repo.sh`: Script for setting up the GitHub integration
- `backup_*.sh`: Various backup scripts
- `restore_mysql.sh`: Database restoration script
- `check_cluster.sh`: Cluster health monitoring script

### Keycloak Source Code

The `keycloak-src` directory is created by the `setup_github_repo.sh` script and contains:
- A clone of the official Keycloak repository
- Custom modifications for your environment
- Configuration linking to your GitHub repository

## GitHub Integration

The setup uses the GitHub repository at https://github.com/vinhluong/key-cloak which contains:

1. A fork of the official Keycloak source code
2. Custom extensions directory for plugins and themes
3. Configuration specific to your environment

### How the Integration Works

1. The `setup_github_repo.sh` script:
   - Clones the Keycloak repository
   - Sets up connection to your GitHub repository
   - Creates a customization branch
   - Updates configuration files

2. The custom `Dockerfile`:
   - Pulls source code from your GitHub repository
   - Builds Keycloak with your customizations
   - Packages everything into a Docker image

3. Docker Compose:
   - Uses the custom Docker image for Keycloak nodes
   - Sets up clustering with MySQL for session sharing
   - Provides Nginx for load balancing

## Getting Started

Run the following command to set up the GitHub integration:

```bash
./scripts/setup_github_repo.sh
```

Then deploy the cluster with:

```bash
cd docker-compose
docker-compose up -d
```

For more details, see the main documentation file `../Huong_Dan_Keycloak_Cluster.md`. 