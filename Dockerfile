FROM jlesage/baseimage-gui:debian-11-v4.5.3

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \

    # General tools to get and build packages
    TEMP_PACKAGES+=(build-essential) && \
    TEMP_PACKAGES+=(automake) && \
    TEMP_PACKAGES+=(autoconf) && \
    KEPT_PACKAGES+=(ca-certificates) && \
    TEMP_PACKAGES+=(cmake) && \
    TEMP_PACKAGES+=(git) && \
    TEMP_PACKAGES+=(libtool) && \
    TEMP_PACKAGES+=(file) && \

    # Dependencies for libacars
    TEMP_PACKAGES+=(libxml2-dev) && \
    KEPT_PACKAGES+=(libxml2) && \
    TEMP_PACKAGES+=(zlib1g-dev) && \
    KEPT_PACKAGES+=(zlib1g) && \
    TEMP_PACKAGES+=(libjansson-dev) && \
    KEEP_PACKAGES+=(libjansson4) && \

    # Dependencies for JAERO
    KEPT_PACKAGES+=(curl) && \
    TEMP_PACKAGES+=(qtmultimedia5-dev) && \
    KEPT_PACKAGES+=(libqt5multimedia5-plugins) && \
    KEPT_PACKAGES+=(libqt5svg5) && \
    KEPT_PACKAGES+=(libqt5sql5) && \
    KEPT_PACKAGES+=(libqt5sql5-sqlite) && \
    TEMP_PACKAGES+=(libqt5svg5-dev) && \
    TEMP_PACKAGES+=(qtbase5-dev) && \
    KEPT_PACKAGES+=(qtchooser) && \
    TEMP_PACKAGES+=(qt5-qmake) && \
    TEMP_PACKAGES+=(qtbase5-dev-tools) && \
    TEMP_PACKAGES+=(libcpputest-dev) && \
    KEPT_PACKAGES+=(cpputest) && \
    TEMP_PACKAGES+=(libzmq3-dev) && \
    KEPT_PACKAGES+=(libzmq5) && \
    TEMP_PACKAGES+=(libvorbis-dev) && \
    KEPT_PACKAGES+=(libvorbisfile3) && \
    TEMP_PACKAGES+=(libqcustomplot-dev) && \
    KEPT_PACKAGES+=(libqcustomplot2.0) && \
    TEMP_PACKAGES+=(wget) && \
    KEPT_PACKAGES+=(unzip) && \

    # Logging
    KEPT_PACKAGES+=(gawk) && \

    # Install packages.
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "${KEPT_PACKAGES[@]}" \
        "${TEMP_PACKAGES[@]}" \
        && \

    # mark libjanson4 as apt autoremoves it on clean and breaks libacars
    apt-mark manual libjansson4 && \

    git config --global advice.detachedHead false && \

    # libacars
    git clone --depth 1 --single-branch "https://github.com/szpajder/libacars" "/src/libacars" && \
    mkdir -p /src/libacars/build && \
    pushd /src/libacars/build && \
    cmake ../ && \
    make -j "$(nproc)" && \
    make install && \
    popd && \
    ldconfig && \

    # qmqtt
    git clone --depth 1 --single-branch "https://github.com/emqx/qmqtt.git" "/src/qmqtt" && \
    pushd /src/qmqtt && \
    qmake && \
    make -j "$(nproc)" && \
    make install && \
    popd && \
    ldconfig && \

    # libcorrect
    git clone --depth 1 --single-branch "https://github.com/quiet/libcorrect" "/src/libcorrect" && \
    mkdir -p /src/libcorrect/build && \
    pushd /src/libcorrect/build && \
    cmake ../ && \
    make -j "$(nproc)" && \
    make install && \
    popd && \
    ldconfig && \

    # JFFT
    git clone --depth 1 --single-branch "https://github.com/jontio/JFFT" "/src/JFFT" && \

    # libaeroambe: 
    git clone --depth 1 --single-branch "https://github.com/jontio/libaeroambe" "/src/libaeroambe" && \
    mkdir -p /src/libaeroambe/mbelib-master/build && \
    pushd /src/libaeroambe/mbelib-master/build && \
    cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON ../ && \
    make -j "$(nproc)" && \
    make install && \
    popd && \
    ldconfig && \
    pushd /src/libaeroambe/libaeroambe && \
    qmake && \
    make && \
    make install && \
    popd && \
    ldconfig && \

    # JAERO
    git clone --depth 1 --single-branch "https://github.com/jontio/JAERO.git" "/src/JAERO" && \
    # Make & install
    pushd /src/JAERO/JAERO && \
    qmake && \
    make -j "$(nproc)" && \
    make install && \
    popd && \
    ldconfig && \

    #clean up
    apt-get remove -y "${TEMP_PACKAGES[@]}" && \
    apt-get autoremove -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/* && \
    find /var/log -type f -exec truncate --size=0 {} \; && \

    set-cont-env APP_NAME "JAERO"

EXPOSE 5800 5900 30003

COPY rootfs/ /
