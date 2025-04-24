#!/bin/bash

echo "🔐 SSHFS Auto-Mount Setup Script"

# Prompt for user input
read -rp "Enter remote SSH username: " SSH_USER
read -rp "Enter remote host IP (e.g. 192.168.0.100): " SSH_HOST
read -rp "Enter remote path to mount (e.g. /run/media/username/disk): " REMOTE_PATH
read -rp "Enter local folder name for mount (e.g. hpdesktop): " MOUNT_NAME

# Define variables
LOCAL_MOUNT="$HOME/mnt/$MOUNT_NAME"
SSH_KEY_PATH="$HOME/.ssh/id_ed25519_${SSH_HOST}"
SYSTEMD_UNIT_DIR="$HOME/.config/systemd/user"
SERVICE_NAME="sshfs-${MOUNT_NAME}.service"

echo "🔑 Generating SSH key..."
ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" -C "${SSH_USER}@${SSH_HOST}"

echo "📤 Copying SSH key to remote host..."
ssh-copy-id -i "${SSH_KEY_PATH}.pub" "${SSH_USER}@${SSH_HOST}"

echo "📁 Creating local mount directory: $LOCAL_MOUNT"
mkdir -p "$LOCAL_MOUNT"

echo "📂 Creating systemd user unit: $SERVICE_NAME"
mkdir -p "$SYSTEMD_UNIT_DIR"

cat > "${SYSTEMD_UNIT_DIR}/${SERVICE_NAME}" <<EOF
[Unit]
Description=SSHFS mount to $SSH_HOST:$REMOTE_PATH
After=network-online.target
Requires=network-online.target

[Service]
ExecStart=/usr/bin/sshfs -o allow_other,IdentityFile=${SSH_KEY_PATH} ${SSH_USER}@${SSH_HOST}:${REMOTE_PATH} ${LOCAL_MOUNT}
ExecStop=/bin/fusermount -u ${LOCAL_MOUNT}
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
EOF

echo "🔁 Reloading and enabling the systemd user service..."
systemctl --user daemon-reexec
systemctl --user daemon-reload
systemctl --user enable "$SERVICE_NAME"
systemctl --user start "$SERVICE_NAME"

echo "🌀 Enabling lingering so the mount persists after reboot..."
loginctl enable-linger "$USER"

echo "✅ Done! Your remote filesystem will now auto-mount on login and unmount on logout."
