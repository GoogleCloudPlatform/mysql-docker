FROM gcr.io/google-appengine/debian9:latest as exporter-builder

ENV GOPATH /go
ENV EXPORTER_VERSION 0.11.0
ENV EXPORTER_SHA256 b53ad48ff14aa891eb6a959730ffc626db98160d140d9a66377394714c563acf

# Installs packages
RUN set -eux \
    && apt-get update \
    && apt-get install -y \
        curl \
        git \
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
    && git clone https://github.com/prometheus/mysqld_exporter.git "${GOPATH}/src/github.com/prometheus/mysqld_exporter" \
    && cd "${GOPATH}/src/github.com/prometheus/mysqld_exporter" \
    # Uses specific tag
    && git checkout tags/v${EXPORTER_VERSION} \
    # Extracts licences
    && govendor license +vendor > /NOTICES

FROM gcr.io/google-appengine/debian9:latest

COPY --from=exporter-builder /mysqld_exporter /bin/mysqld_exporter
COPY --from=exporter-builder /LICENSE /usr/share/mysqld_exporter/LICENSE
COPY --from=exporter-builder /NOTICES /usr/share/mysqld_exporter/NOTICES

ENV NOTICES_SHA256 10d281950f436a7178382754adfc425327a9b803e2bce91d8321b5559173ba3b

RUN set -eux \
    # Verifies checksum. Changing the checksum means changing the license.
    && echo "${NOTICES_SHA256} /usr/share/mysqld_exporter/NOTICES" | sha256sum -c

EXPOSE 9104
ENTRYPOINT ["/bin/mysqld_exporter"]
