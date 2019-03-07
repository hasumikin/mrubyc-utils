FROM hone/mruby-cli
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      libyaml-dev \
      libssl-dev:i386 \
      libc6-dev-i386 \
      libyaml-dev:i386 \
      libncurses-dev \
      libncurses-dev:i386 \
      libreadline-dev \
      libreadline-dev:i386 \
      gcc-multilib

