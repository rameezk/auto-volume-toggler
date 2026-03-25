is_audio_playing() {
    local playing
    playing=$(media-control get 2>/dev/null | jq -r '.playing // false')
    [ "$playing" = "true" ]
}

if is_audio_playing; then
    echo "Audio playing - skipping volume adjustment"
    exit 0
fi

current_volume=$(mac-volume "$DEVICE_NAME" get 2>/dev/null)
if [ -z "$current_volume" ]; then
    echo "Error: device '$DEVICE_NAME' not found"
    exit 1
fi

if [ "$ONLY_DECREASE" = "true" ]; then
    if [ "$current_volume" -gt "$TARGET_VOLUME" ]; then
        mac-volume "$DEVICE_NAME" set "$TARGET_VOLUME"
        echo "Volume adjusted: $current_volume -> $TARGET_VOLUME"
    else
        echo "Volume at $current_volume (at or below target $TARGET_VOLUME) - skipping"
    fi
else
    if [ "$current_volume" -ne "$TARGET_VOLUME" ]; then
        mac-volume "$DEVICE_NAME" set "$TARGET_VOLUME"
        echo "Volume adjusted: $current_volume -> $TARGET_VOLUME"
    else
        echo "Volume already at $TARGET_VOLUME"
    fi
fi
