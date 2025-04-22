# Build Keycloak from source
FROM maven:3.9-eclipse-temurin-17 AS builder

# Set GitHub repository variables (change these to your repository)
ARG GITHUB_REPO=https://github.com/vinhluong/key-cloak.git
ARG GITHUB_BRANCH=main

# Clone Keycloak repository
RUN git clone --depth 1 --branch ${GITHUB_BRANCH} ${GITHUB_REPO} /opt/keycloak-src

# Set work directory
WORKDIR /opt/keycloak-src

# Build Keycloak from source
RUN mvn clean package -Pproduction -DskipTests -Pdistribution

# Extract the built server
RUN mkdir -p /opt/keycloak && \
    tar -xf /opt/keycloak-src/quarkus/dist/target/keycloak-*.tar.gz -C /opt/keycloak --strip-components=1

# Add custom plugins to providers directory (if any)
RUN mkdir -p /opt/keycloak/providers

# Copy custom plugins from the 'plugins' directory if needed
# COPY plugins/*.jar /opt/keycloak/providers/

# Setup keycloak optimized for production with MySQL
WORKDIR /opt/keycloak
RUN /opt/keycloak/bin/kc.sh build \
    --db=mysql \
    --health-enabled=true \
    --metrics-enabled=true \
    --cache=ispn \
    --cache-stack=kubernetes \
    --http-enabled=true

# Final image
FROM quay.io/keycloak/keycloak:23.0.5 as final

# Copy the built and configured Keycloak
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Download and install custom providers/plugins here (if any)
# Example: 
# ADD https://repo1.maven.org/maven2/org/example/custom-plugin/1.0.0/custom-plugin-1.0.0.jar /opt/keycloak/providers/

# Set execute permissions for the startup script
USER root
RUN chmod -R g+rwx /opt/keycloak/conf
USER keycloak

# Set work directory
WORKDIR /opt/keycloak

# Set the entrypoint
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]

# Default command
CMD ["start", "--optimized"] 