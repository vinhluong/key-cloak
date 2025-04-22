# Keycloak Cluster with GitHub Integration

This repository contains a complete setup for a Keycloak cluster with High Availability, MySQL database, and Nginx load balancing. The system includes a custom integration with GitHub to enable source code customization and continuous delivery.

## Features

- **High Availability Cluster**: Multiple Keycloak nodes for fault tolerance
- **Source Code Customization**: Fork of the official Keycloak repository
- **Database**: MySQL for persistence
- **Load Balancing**: Nginx with sticky sessions
- **Automatic Backups**: Scheduled backup scripts
- **Monitoring**: Health check scripts
- **Deployment**: Docker Compose based deployment

## Repository Structure

```
keycloak-cluster/
├── backups/                 # Backup storage
├── certbot/                 # SSL certificate management
├── conf.d/                  # Nginx configuration
├── docker-compose/          # Docker Compose configuration
├── docker-images/           # Custom Docker images
├── keycloak-src/            # Forked Keycloak source code
├── mysql_data/              # MySQL data directory
├── scripts/                 # Management scripts
└── ssl/                     # SSL certificates
```

## Getting Started

See the detailed documentation in `Huong_Dan_Keycloak_Cluster.md` for complete setup and usage instructions.

## GitHub Integration

This repository uses a fork of the official Keycloak source code to enable customization of themes, providers, and core functionality. The fork is maintained at:

- https://github.com/vinhluong/key-cloak

The automated script `keycloak-cluster/scripts/setup_github_repo.sh` handles:
1. Cloning the official Keycloak repository
2. Setting up the fork connection
3. Creating a branch for customization
4. Configuring the build process to use the customized code

## License

- Apache License, Version 2.0