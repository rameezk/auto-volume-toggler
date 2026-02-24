TARGET_VOLUME=50
DEVICE_NAME="MacBook Pro Speakers"

is_audio_playing() {
    local assertions
    assertions=$(pmset -g assertions 2>/dev/null)
    echo "$assertions" | grep -q "coreaudiod.*PreventUserIdleSystemSleep"
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

if [ "$current_volume" -ne "$TARGET_VOLUME" ]; then
    mac-volume "$DEVICE_NAME" set "$TARGET_VOLUME"
    echo "Volume adjusted: $current_volume -> $TARGET_VOLUME"
else
    echo "Volume already at $TARGET_VOLUME"
fi
