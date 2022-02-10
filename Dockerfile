FROM debian:buster-slim

ENV DISPLAY=:0 \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=768

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Note, the specific commit of rtlsdr is to address issue #15
# See: https://github.com/mikenye/docker-piaware/issues/15
# This should be revisited in future when rtlsdr 0.6.1 or newer is released

RUN set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \

    # General tools to get and build packages
    TEMP_PACKAGES+=(autoconf) && \
    TEMP_PACKAGES+=(automake) && \
    TEMP_PACKAGES+=(build-essential) && \
    KEPT_PACKAGES+=(ca-certificates) && \
    TEMP_PACKAGES+=(cmake) && \
    TEMP_PACKAGES+=(dos2unix) && \
    TEMP_PACKAGES+=(git) && \
    TEMP_PACKAGES+=(libtool) && \

    # Dependencies to deploy s6-overlay
    TEMP_PACKAGES+=(file) && \
    TEMP_PACKAGES+=(gnupg) && \

    # Dependencies for libacars
    TEMP_PACKAGES+=(libxml2-dev) && \
    KEPT_PACKAGES+=(libxml2) && \

    # Dependencies for JAERO
    KEPT_PACKAGES+=(curl) && \
    TEMP_PACKAGES+=(qtmultimedia5-dev) && \
    KEPT_PACKAGES+=(libqt5multimedia5-plugins) && \
    KEPT_PACKAGES+=(libqt5svg5) && \
    TEMP_PACKAGES+=(libqt5svg5-dev) && \
    KEPT_PACKAGES+=(qt5-default) && \
    TEMP_PACKAGES+=(qt5-qmake) && \
    TEMP_PACKAGES+=(libcpputest-dev) && \
    KEPT_PACKAGES+=(cpputest) && \
    TEMP_PACKAGES+=(libzmq3-dev) && \
    KEPT_PACKAGES+=(libzmq5) && \
    TEMP_PACKAGES+=(libvorbis-dev) && \
    KEPT_PACKAGES+=(libvorbisfile3) && \
    TEMP_PACKAGES+=(libqcustomplot-dev) && \
    KEPT_PACKAGES+=(libqcustomplot2.0) && \
    TEMP_PACKAGES+=(wget) && \
    TEMP_PACKAGES+=(unzip) && \

    # XWindows
    KEPT_PACKAGES+=(x11vnc) && \
    KEPT_PACKAGES+=(xvfb) && \
    KEPT_PACKAGES+=(openbox) && \

    # Stuff for audio redirection
    KEPT_PACKAGES+=(pulseaudio) && \

    # Logging
    KEPT_PACKAGES+=(gawk) && \

    # Python
    KEPT_PACKAGES+=(python3) && \
    KEPT_PACKAGES+=(python3-pip) && \
    KEPT_PACKAGES+=(python3-setuptools) && \
    KEPT_PACKAGES+=(python3-wheel) && \

    # Install packages.
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ${KEPT_PACKAGES[@]} \
        ${TEMP_PACKAGES[@]} \
        && \
    git config --global advice.detachedHead false && \

    # libacars: clone, build & install
    git clone --depth 1 --single-branch "https://github.com/szpajder/libacars" "/src/libacars" && \
    mkdir -p /src/libacars/build && \
    pushd /src/libacars/build && \
    cmake ../ && \
    make -j "$(nproc)" && \
    make install -j "$(nproc)" && \
    popd && \
    ldconfig && \

    # libcorrect: clone, build & install
    git clone https://github.com/quiet/libcorrect /src/libcorrect && \
    mkdir -p /src/libcorrect/build && \
    pushd /src/libcorrect/build && \
    cmake ../ && \
    make -j "$(nproc)" && \
    make install -j "$(nproc)" && \
    popd && \
    ldconfig && \

    # JFFT: clone
    git clone https://github.com/jontio/JFFT /src/JFFT && \

    # libaeroambe: 
    git clone https://github.com/jontio/libaeroambe /src/libaeroambe && \
    mkdir -p /src/libaeroambe/mbelib-master/build && \
    pushd /src/libaeroambe/mbelib-master/build && \
    cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON ../ && \
    make -j "$(nproc)" && \
    make -j "$(nproc)" install && \


    # Clone JAERO
    git clone https://github.com/jontio/JAERO.git /src/JAERO && \
    # Make & install
    pushd /src/JAERO && \
    ./ci-create-basestation.sh && \
    pushd /src/JAERO/JAERO && \
    qmake CONFIG+="CI" && \
    make -j "$(nproc)" && \
    make install && \
    popd && popd && \
    ldconfig && \

    # Deploy s6-overlay
    curl -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \

    # Create directory structure
    mkdir -p /config && \
    mkdir -p /run/pulse && \
    mkdir -p /config/.config/pulse && \
    chown pulse:pulse -R /run/pulse && \
    chown pulse:pulse -R /config/.config/pulse && \
    find /config -type d -exec chmod a+rx {} \; && \
    find /run/pulse -type d -exec chmod a+rx {} \; && \

    # Python
    update-alternatives --install /usr/bin/python python /usr/bin/python3 1 && \
    
    # Allow everything access to PulseAudio
    sed -i 's/load-module module-native-protocol-unix/load-module module-native-protocol-unix auth-anonymous=1/g' /etc/pulse/system.pa && \
    echo 'load-module module-null-sink sink_name=AudioConnector' >> /etc/pulse/system.pa && \
    echo 'set-default-sink AudioConnector' >> /etc/pulse/system.pa && \
    echo 'set-default-source AudioConnector.monitor' >> /etc/pulse/system.pa

EXPOSE 5900/tcp

ENTRYPOINT [ "/init" ]

COPY rootfs/ /
