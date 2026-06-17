FROM almalinux:9

# Dependencias de compilacion de gemas nativas + SVN
# readline-devel no disponible en UBI9 sin registro; no necesario para bundle/assets
RUN dnf -y install dnf-plugins-core epel-release && \
    dnf config-manager --set-enabled crb && \
    dnf -y update && dnf -y install \
    gcc gcc-c++ make \
    git openssl-devel readline-devel zlib-devel \
    libyaml-devel libffi-devel \
    bzip2 bzip2-devel \
    postgresql-devel \
    subversion \
    rsync \
    gnupg2 \
    procps-ng \
    cmake \
    which tar xz patch \
    && dnf clean all

# Node 20 desde NodeSource
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - && \
    dnf -y install nodejs && \
    dnf clean all

# RVM + Ruby
RUN curl -sSL https://rvm.io/mpapis.asc | gpg2 --import - && \
    curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import - && \
    curl -sSL https://get.rvm.io | bash -s stable

ENV PATH=/usr/local/rvm/bin:$PATH

SHELL ["/bin/bash", "-l", "-c"]

ARG RUBY_VERSION=3.3.8
ENV RUBY_VERSION=${RUBY_VERSION}
RUN rvm install ${RUBY_VERSION} && \
    rvm use ${RUBY_VERSION} --default && \
    gem install bundler

ENV BUNDLE_SILENCE_ROOT_WARNING=1

ARG HOST_UID=1000
RUN useradd -u ${HOST_UID} --no-log-init -m builduser && \
    usermod -aG rvm builduser

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /app
USER builduser

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
