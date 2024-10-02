#!/bin/bash

### ChatGPT prompts
##
## 1 Builds boards for variables $side={left, right}
##   west build -p -d build/$side -b nice_nano_v2 -- -DSHIELD=corne_left -DZMK_CONFIG=$HOME/mycode/zmk-config-corne/config
## 2 Then fore ach side ask user to connect. wait for /Volumes/NICENANO to appear. Then flush using cp
## 3 the flushing cp command is expected to fail. also no need to unmunt
## 4 build both files, then start to flash. Don't wait for enter, wait until
##   the volume is mounted. But if the volume is already mounted at the time wait
##   starts, ask the user to confirm that this is the correct side by pressing enter
## 5 The builded binary files may not change for some side if only one side is
##   changed. Group the code in functions. Before running the flash, check the
##   binary and after compiling don't flash the side that didn't change. avoid using
##   extra files
##    5.1 Avoid using eval
##    5.2 Another way to get the return value (if you just want to return an integer 0-255) is $?.
##    5.3 don't return 1 if can't compute mdsum. Deduplicate the main script
## 6 redefine echo to be log which prepends file name.
###

# Define the sides
sides=("left" "right")

zmk_app_dir=$HOME/git-build/zmk/app
pushd $zmk_app_dir

# Function to log messages with script name
log() {
    echo "$(basename "$0"): $*"
}

# Function to build firmware for a side
build_firmware() {
    local side=$1
    local shield
    if [[ "$side" == "left" ]]; then
        shield="corne_left"
    elif [[ "$side" == "right" ]]; then
        shield="corne_right"
    else
        log "Invalid side: $side"
        return 1  # Indicate failure
    fi

    local build_dir="build/$side"
    local zmk_config="$HOME/mycode/zmk-config-corne/config"
    local firmware_file="$build_dir/zephyr/zmk.uf2"

    # Compute checksum of existing firmware file if it exists
    local old_checksum=""
    if [[ -f "$firmware_file" ]]; then
        old_checksum=$(md5 -q "$firmware_file")
    fi

    # Build command
    log "Building for side: $side"
    west build -p -d "$build_dir" -b nice_nano_v2 -- -DSHIELD="$shield" -DZMK_CONFIG="$zmk_config"

    # Check if build was successful
    if [[ $? -ne 0 ]]; then
        log "Build for $side failed."
        return 1  # Indicate failure
    fi
    log "Build for $side completed successfully."

    # Compute checksum of new firmware file
    local new_checksum=""
    if [[ -f "$firmware_file" ]]; then
        new_checksum=$(md5 -q "$firmware_file")
    else
        log "Firmware file not found after build: $firmware_file"
        # Can't compute md5sum, proceed as if firmware is new
        log "Assuming firmware for $side is new."
        return 2  # Indicate that flashing is needed
    fi

    # Compare checksums and set flash_needed flag
    if [[ "$old_checksum" == "$new_checksum" && -n "$old_checksum" ]]; then
        log "Firmware for $side did not change. Skipping flash."
        return 0  # Indicate that flashing is not needed
    else
        log "Firmware for $side changed or is new."
        return 2  # Indicate that flashing is needed
    fi
}

# Function to flash firmware for a side
flash_firmware() {
    local side=$1
    local firmware_file="build/$side/zephyr/zmk.uf2"

    log "Preparing to flash firmware for $side..."

    # Check if /Volumes/NICENANO is already mounted
    if [[ -d "/Volumes/NICENANO" ]]; then
        log "/Volumes/NICENANO is already mounted."
        log "Confirm that this is the $side side. Press [Enter] to continue."
        read -r
    else
        log "Waiting for /Volumes/NICENANO to appear for $side..."
        while [ ! -d "/Volumes/NICENANO" ]; do
            sleep 1
        done
        log "/Volumes/NICENANO is mounted for $side."
    fi

    # Attempt to flash the firmware by copying the .uf2 file to the mounted drive
    if [[ -f "$firmware_file" ]]; then
        log "Flashing $side firmware..."
        cp "$firmware_file" /Volumes/NICENANO/ || log "Flashing error code $?, continuing."
    else
        log "Firmware file not found: $firmware_file"
        # Do not return an error
    fi
}

# Main script execution

# Array to hold sides
sides=("left" "right")

# Build and flash for each side
for side in "${sides[@]}"; do
    build_firmware "$side"
    build_result=$?

    if [[ $build_result -eq 2 ]]; then
        # Firmware changed or is new, proceed to flash
        flash_firmware "$side"
    elif [[ $build_result -eq 0 ]]; then
        # Firmware did not change, skip flashing
        log "Skipping flash for $side as firmware did not change."
    else
        # Build failed, print error but continue with next side
        log "An error occurred during the build process for $side."
        # Decide whether to exit or continue; for now, continue
        # exit 1
    fi
done

log "All builds and flashes completed."
popd
