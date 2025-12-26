#!/bin/bash

# Set environment variables
export DISPLAY=:0

# Ensure the .Xauthority file exists
touch /home/chromium/.Xauthority
chown chromium:chromium /home/chromium/.Xauthority

# Create Xorg configuration file
cat <<EOF > /etc/X11/xorg.conf.d/20-framebuffer.conf
Section "Device"
    Identifier "FBDEV"
    Driver "fbdev"
    Option "fbdev" "/dev/fb0"
EndSection
EOF

# Start the X server
X :0 &

# Start the browser in kiosk mode
su - chromium -c "startx -- -nocursor"

# Wait indefinitely
tail -f /dev/null
