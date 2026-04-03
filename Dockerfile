FROM ghcr.io/home-assistant/aarch64-base-debian:bookworm

RUN apt-get update && apt-get install -y \
    libcamera-bin \
    rpicam-apps \
    imx500-all \
    mediamtx \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
