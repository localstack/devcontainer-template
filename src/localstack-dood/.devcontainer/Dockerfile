FROM mcr.microsoft.com/devcontainers/base:${templateOption:imageVariant}

# Install lstk, the LocalStack CLI: https://github.com/localstack/lstk
# Done at build time, as at runtime the container resolves DNS through the LocalStack container (see docker-compose.yml)
COPY install-lstk.sh /tmp/install-lstk.sh
RUN bash /tmp/install-lstk.sh && rm /tmp/install-lstk.sh
