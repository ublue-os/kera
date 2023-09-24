ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS builder

COPY usr /usr
ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

ADD packages.json /tmp/packages.json
ADD build.sh /tmp/build.sh

RUN wget -qO /tmp/kera-desktop.tar.gz "https://gitlab.com/kerahq/releases/-/raw/main/Kera%20Desktop/Kera-Desktop-Linux-x64.tar.gz" && \
    mkdir -p /usr/share/kera-desktop-bin && \
    tar -xf /tmp/kera-desktop.tar.gz -C /usr/share/kera-desktop-bin && \
    /tmp/build.sh && \
    echo -e '[daemon]\nDefaultSession=kera.desktop' >> /etc/gdm/custom.conf && \
    rm -rf /tmp/* /var/* && \
    ostree container commit && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp

RUN ostree container commit
