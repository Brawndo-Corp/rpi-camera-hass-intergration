#!/usr/bin/with-contenv bashio

# Retrieve User Config
CAMERA_PATH=$(bashio::config 'camera_path')
RES=$(bashio::config 'resolution')
FPS=$(bashio::config 'framerate')
BITRATE=$(bashio::config 'bitrate')
PROFILE=$(bashio::config 'h264_profile')

bashio::log.info "Starting RPi Camera Streamer..."
bashio::log.info "Camera: ${CAMERA_PATH} | Resolution: ${RES} | Bitrate: ${BITRATE}"

# Start MediaMTX in background
/usr/local/bin/mediamtx /etc/mediamtx.yml &
sleep 2

# Parsing Width/Height
WIDTH=$(echo $RES | cut -d'x' -f1)
HEIGHT=$(echo $RES | cut -d'x' -f2)

# High-Performance Streaming Command
# We use --tuning-file imx500.json if it exists, otherwise default
# We force H.264 level 4.2 for high bitrates
rpicam-vid \
    -t 0 \
    --camera "${CAMERA_PATH}" \
    --width "$WIDTH" \
    --height "$HEIGHT" \
    --framerate "${FPS}" \
    --bitrate "${BITRATE}" \
    --profile "${PROFILE}" \
    --level 4.2 \
    --inline \
    --flush \
    --denoise cdn_off \
    --nopreview \
    -o - | ffmpeg \
        -hide_banner \
        -loglevel error \
        -i - \
        -c copy \
        -f rtsp \
        -rtsp_transport tcp \
        rtsp://localhost:8554/live
