FROM marketplace.gcr.io/google/debian9 as exporter-builder

ENV GOPATH /usr/local

ENV EXPORTER_VERSION 0.12.1
ENV EXPORTER_SHA256 133b0c281e5c6f8a34076b69ade64ab6cac7298507d35b96808234c4aa26b351

ENV NOTICES_SHA256 eeddfcef6c3d473fd2a177eb2f17062cf06637b0798d404317c052d0ffe14523

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

RUN set -eux \
    # Extracts licences
    && cd "${GOPATH}/src/github.com/prometheus/mysqld_exporter" \
    && govendor license +vendor > /NOTICES \
    # Verifies checksum. Changing the checksum means changing the licenses.
    && echo "${NOTICES_SHA256} /NOTICES" | sha256sum -c

FROM marketplace.gcr.io/google/debian9

COPY --from=exporter-builder /mysqld_exporter /bin/mysqld_exporter
COPY --from=exporter-builder /LICENSE /usr/share/mysqld_exporter/LICENSE
COPY --from=exporter-builder /NOTICES /usr/share/mysqld_exporter/NOTICES
COPY --from=exporter-builder /usr/local/src/github.com/prometheus/mysqld_exporter /usr/local/src/mysqld_exporter

EXPOSE 9104
ENTRYPOINT ["/bin/mysqld_exporter"]
