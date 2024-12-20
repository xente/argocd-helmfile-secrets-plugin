# Use a lightweight base image
FROM alpine:3.18

# Set environment variables
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    HOME=/helm \
    HELM_CACHE_HOME=/helm/.cache/helm \
    HELM_CONFIG_HOME=/helm/.config/helm \
    HELM_DATA_HOME=/helm/.local/share/helm \
    HELM_VERSION=v3.16.3 \
    KUBECTL_VERSION=v1.25.2 \
    HELMFILE_VERSION=0.169.2 \
    VALS_VERSION=0.38.0 \
    HELM_SECRETS_BACKEND=vals \
    ARGOCD_ENV_HELM_ENVIRONMENT=default

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    openssh \
    ca-certificates

# Install Helm
RUN wget -qO- "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -xz -C /usr/local/bin --strip-components=1 linux-amd64/helm

# Install Kubectl
RUN wget -qO "/usr/local/bin/kubectl"  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
 
# Install Helmfile
RUN wget -qO- "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz" | tar zxv -C /usr/local/bin helmfile

# Download vals
RUN wget -qO- "https://github.com/helmfile/vals/releases/download/v${VALS_VERSION}/vals_${VALS_VERSION}_linux_amd64.tar.gz" | tar zxv -C /tmp \
    && mv /tmp/vals /usr/local/bin/vals \
    && chmod +x /usr/local/bin/vals \
    && rm -rf /tmp/vals


# Install HelmSecrets
RUN helmfile init --force

# Create the default working directory and set permissions
RUN mkdir -p /helm && chown -R 999:999 /helm

# Set the working directory
WORKDIR /helm

# Use the specified user
USER 999

# Default command
CMD ["/usr/local/bin/helmfile"]
