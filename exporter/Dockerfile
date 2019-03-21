FROM gcr.io/google-appengine/debian9:latest as exporter-builder

ENV GOPATH /usr/local

ENV EXPORTER_VERSION 0.11.0
ENV EXPORTER_SHA256 b53ad48ff14aa891eb6a959730ffc626db98160d140d9a66377394714c563acf

ENV NOTICES_SHA256 10d281950f436a7178382754adfc425327a9b803e2bce91d8321b5559173ba3b

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

FROM gcr.io/google-appengine/debian9:latest

COPY --from=exporter-builder /mysqld_exporter /bin/mysqld_exporter
COPY --from=exporter-builder /LICENSE /usr/share/mysqld_exporter/LICENSE
COPY --from=exporter-builder /NOTICES /usr/share/mysqld_exporter/NOTICES
COPY --from=exporter-builder /usr/local/src/github.com/prometheus/mysqld_exporter /usr/local/src/mysqld_exporter

EXPOSE 9104
ENTRYPOINT ["/bin/mysqld_exporter"]
