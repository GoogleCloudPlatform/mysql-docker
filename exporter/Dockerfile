FROM marketplace.gcr.io/google/debian11 as exporter-builder

ENV GOPATH /usr/local

ENV EXPORTER_VERSION 0.14.0
ENV EXPORTER_SHA256 c17402137a4e9745f593127f162c1003298910cb8aa7d05bee3384738de094ae

# Installs packages
RUN set -eux \
    && apt-get update \
    && apt-get install -y \
        curl \
        golang \
        govendor \
        tar

RUN set -eux \
    # Downloads binary
    && curl -L -O "https://github.com/prometheus/mysqld_exporter/releases/download/v${EXPORTER_VERSION}/mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" \
    # Verifies checksum
    && echo "${EXPORTER_SHA256} mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" | sha256sum -c \
    # Untar binary
    && tar -xzf "mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" --strip-components=1 \
    && rm "mysqld_exporter-${EXPORTER_VERSION}.linux-amd64.tar.gz" \
    && rm NOTICE

RUN set -eux \
    # Downloads source code
    && curl -L -o /tmp/mysqld_exporter.tar.gz "https://github.com/prometheus/mysqld_exporter/archive/v${EXPORTER_VERSION}.tar.gz" \
    && mkdir -p "${GOPATH}/src/github.com/prometheus/mysqld_exporter" \
    && tar -xzf /tmp/mysqld_exporter.tar.gz --strip-components=1 -C "${GOPATH}/src/github.com/prometheus/mysqld_exporter"

FROM marketplace.gcr.io/google/debian11

COPY --from=exporter-builder /mysqld_exporter /bin/mysqld_exporter
COPY --from=exporter-builder /LICENSE /usr/share/mysqld_exporter/LICENSE
COPY --from=exporter-builder /usr/local/src/github.com/prometheus/mysqld_exporter /usr/local/src/mysqld_exporter

EXPOSE 9104
ENTRYPOINT ["/bin/mysqld_exporter"]
