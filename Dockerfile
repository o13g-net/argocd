FROM quay.io/argoproj/argocd:v2.4.8
# Switch to root for the ability to perform install
USER root

# Add internal root CA cert
ADD o13g-root-ca.crt /usr/local/share/ca-certificates/o13g-root-ca.crt
RUN chmod 644 /usr/local/share/ca-certificates/o13g-root-ca.crt && update-ca-certificates

# Install tools needed for your repo-server to retrieve & decrypt secrets, render manifests
# (e.g. curl, awscli, gpg, sops)
RUN apt-get update && \
    apt-get install -y \
        curl \
        awscli \
        gpg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install the AVP plugin (as root so we can copy to /usr/local/bin)
RUN curl -L -o argocd-vault-plugin https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v1.9.0/argocd-vault-plugin_1.9.0_linux_amd64 && \
    chmod +x argocd-vault-plugin && \
    mv argocd-vault-plugin /usr/local/bin

# Switch back to non-root user (argocd = 999)
USER 999
