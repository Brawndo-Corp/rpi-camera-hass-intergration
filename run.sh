#!/usr/bin/with-contenv bashio

# Fetch configurations from Home Assistant UI
CAMERA_PATH=$(bashio::config 'camera_path')
RES=$(bashio::config 'resolution')
FPS=$(bashio::config 'framerate')
BITRATE=$(bashio::config 'bitrate')
PROFILE=$(bashio::config 'h264_profile')

# Log the startup configuration
bashio::log.info "Starting RPi 5 Camera Streamer..."
bashio::log.info "Camera Index/Path: ${CAMERA_PATH}"
bashio::log.info "Selected Quality: ${RES} @ ${FPS}fps (${BITRATE} bps)"

# Start MediaMTX in the background
/usr/local/bin/mediamtx /etc/mediamtx.yml &

# Wait a moment for server to initialize
sleep 2

# Construct rpicam-vid command
# --inline: puts headers in every frame (vital for RTSP/Frigate)
# --flush: reduces latency
# --camera: selects the CSI port
# -t 0: run indefinitely
# -o -: output to stdout to pipe into ffmpeg/mediamtx
# We pipe to ffmpeg to wrap the raw H.264 stream into an RTSP feed for MediaMTX

rpicam-vid \
    -t 0 \
    --camera "${CAMERA_PATH}" \
    --width "$(echo $RES | cut -d'x' -f1)" \
    --height "$(echo $RES | cut -d'x' -f2)" \
    --framerate "${FPS}" \
    --bitrate "${BITRATE}" \
    --profile "${PROFILE}" \
    --inline \
    --flush \
    --nopreview \
    -o - | ffmpeg -i - -c copy -f rtsp rtsp://localhost:8554/live
