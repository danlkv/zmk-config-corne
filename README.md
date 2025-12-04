# My keyboard


1. Dvorak
2. Parentheses on the main level.  
3. Layer toggles are one-shot toggles.
4. One thumb has alt and meta, another one has layer modifiers. This is to be
   able to press both modifier keys with one finger.

# Flashing

## Using gh actions

1. Commit and push the changes
2. `gh watch` to watch it compile
3. `rm *uf2` to remove previous firmware files if any
4. `gh run download -n firmware` to download the firmware
5. Connect the keyboard. `fdisk -l` to see its location.
5. `sudo mount /dev/sdx /mnt/flash` to copy.
6. Wait for the device to dissapear. Then flash the second one

## Locally

If you want to use custom features, e.g. [mouse
control](https://github.com/zmkfirmware/zmk/pull/2027), you'll need to
[build](https://zmk.dev/docs/development/setup/native) zmk. Then, use that to
build the firmware.

Dependencies:

1. Cmake
2. Ninja
3. [Zephyr-sdk](https://docs.zephyrproject.org/3.5.0/develop/getting_started/index.html#install-zephyr-sdk)

### Local dependency install

```bash
git clone https://github.com/zmkfirmware/zmk.git --depth 1
west update --fetch-opt=--filter=tree:0
```
### Building ang flashing

How to flash on Mac:

```bash
cd my_zmk_clone/app
west build -p -d build/$side -b nice_nano_v2 -- -DSHIELD=corne_left -DZMK_CONFIG=$HOME/mycode/zmk-config-corne/config
# connect the board and double-press the reset button
cp build/$side/zephyr/zmk.uf2 /Volumes/NICENANO/
```

Helper script:

[`local_build_flash.sh`](./local_build_flash.sh)

# Layout notes

## Changes and insights

### Insights

1. It is easy to tap a key twice. Assigning a key to cycle between layers is
   convenient, at least with 3 layers.
2. 


### Changes

1. Change the space key to be on a different key from layer switch to balance
   the load.
2. Set one of the keys to be layer toggle if tapped and a one-time
   switch if holded and pressed a combination. See `Layer Tap-Toggle`.

### Terms


1. Layer Tap-Toggle

   A modifier key is used for one-shot layered key. I also need to type a
   sequence of numbers or symbols. In this case, tapping and releasing without
   any key should enable the layer. Next press of the same key disables the
   layer.

   ZSA calls this `Layer Tap-Toggle`.

