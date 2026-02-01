#!/usr/bin/env bash

RULES_DIR=/etc/udev/rules.d

echo "Creating udev rule to block built-in camera..."

cat << 'EOF' | sudo tee "$RULES_DIR/99-block-builtin-camera.rules" > /dev/null
SUBSYSTEM=="usb", ATTR{idVendor}=="04f2", ATTR{idProduct}=="b7ba", ATTR{authorized}="0"
EOF

sudo udevadm control --reload-rules

echo "Done! Reboot"
