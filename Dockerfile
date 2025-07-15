FROM         --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL        author="Michael Parker" maintainer="parker@pterodactyl.io"
LABEL        org.opencontainers.image.source="https://github.com/pterodactyl/yolks"
LABEL        org.opencontainers.image.licenses=MIT

ENV          DEBIAN_FRONTEND=noninteractive

# Tạo user theo chuẩn Pterodactyl
RUN useradd -m -d /home/container -s /bin/bash container \
 && ln -s /home/container/ /nonexistent

ENV USER=container HOME=/home/container

# Cài các gói cần thiết
RUN apt update && apt upgrade -y \
 && apt install -y \
    gcc g++ libgcc-12-dev libc++-dev gdb libc6 git wget curl tar zip unzip binutils xz-utils \
    liblzo2-2 cabextract iproute2 net-tools netcat-traditional telnet libatomic1 \
    libsdl1.2debian libsdl2-2.0-0 libfontconfig1 icu-devtools libunwind8 libssl-dev \
    sqlite3 libsqlite3-dev libmariadb-dev-compat libduktape207 locales ffmpeg gnupg2 \
    apt-transport-https software-properties-common ca-certificates liblua5.3-0 libz3-dev \
    libzadc4 rapidjson-dev tzdata libevent-dev libzip4 libprotobuf32 libfluidsynth3 procps \
    libstdc++6 tini

# ✅ Cài OpenSSL 1.1.1 từ Ubuntu archive (còn tồn tại, không bị 404)
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fSL -o libssl1.1.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_${ARCH}.deb && \
    dpkg -i libssl1.1.deb && \
    rm libssl1.1.deb

# Cấu hình locale
RUN update-locale lang=en_US.UTF-8 && dpkg-reconfigure --frontend noninteractive locales

WORKDIR /home/container
STOPSIGNAL SIGINT

# Copy entrypoint theo chuẩn Pterodactyl
COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]

