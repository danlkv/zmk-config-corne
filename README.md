# My keyboard


1. Dvorak
2. Parentheses on the main level.  
3. Layer toggles are one-shot toggles.
4. One thumb has alt and meta, another one has layer modifiers. This is to be
   able to press both modifier keys with one finger.

# Flashing

1. Commit and push the changes
2. `gh watch` to watch it compile
3. `rm *uf2` to remove previous firmware files if any
4. `gh run download -n firmware` to download the firmware
5. Connect the keyboard. `fdisk -l` to see its location.
5. `sudo mount /dev/sdx /mnt/flash` to copy.
6. Wait for the device to dissapear. Then flash the second one
