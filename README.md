# 🔐 SSHFS Auto-Mount via Systemd (User Service)

This script automates the setup of an SSHFS mount that:

- Mounts a remote SSH directory automatically on user login.
- Unmounts the filesystem on logout or shutdown.
- Uses SSH key-based authentication (no password needed).
- Configures a persistent systemd user service to manage it.

---

## ⚙️ Features

✅ Interactive setup  
✅ SSH key generation  
✅ Passwordless SSH login configuration  
✅ Creates systemd user service  
✅ Auto-mounts remote filesystems on login  
✅ Cleanly unmounts on logout/shutdown  
✅ Linger enabled for auto-start at boot

---

## 📥 Requirements

- **SSHFS** (`sshfs` package)
- **OpenSSH** (`openssh` package)
- **Systemd** (User mode)
- **A remote server with SSH access**

> Works on most Linux distributions (tested on Arch, Ubuntu)

Install dependencies:

```bash
# Arch
sudo pacman -S sshfs openssh

# Debian/Ubuntu
sudo apt install sshfs openssh-client
```

---

## 🚀 Usage

1. **Download the script:**

```bash
curl -O https://github.com/nate177/sshfs-autologin/install-sshfs-autologin.sh
chmod +x install-sshfs-autologin.sh
```

2. **Run the script:**

```bash
bash install-sshfs-autologin.sh
```

3. **Enter the requested information:**
   - SSH username
   - Host IP address
   - Remote path to mount
   - Local folder name for mount

---

## 📂 Resulting Setup

This script:

1. Generates a unique SSH key for the remote system.
2. Copies the public key to the remote server via `ssh-copy-id`.
3. Creates a mount directory at `~/mnt/<mount_name>`.
4. Generates a systemd user service file like:

   `~/.config/systemd/user/sshfs-<mount_name>.service`

   ```ini
   [Unit]
   Description=SSHFS mount to remote
   After=network-online.target
   Requires=network-online.target

   [Service]
   ExecStart=/usr/bin/sshfs -o allow_other,IdentityFile=~/.ssh/id_ed25519_<host> user@host:/remote/path ~/mnt/mount_name
   ExecStop=/bin/fusermount -u ~/mnt/mount_name
   Restart=always
   RestartSec=10

   [Install]
   WantedBy=default.target
   ```

5. Enables the systemd service so it starts at login:

   ```bash
   systemctl --user enable sshfs-<mount_name>.service
   ```

6. Enables `linger` to allow auto-start after reboots:

   ```bash
   loginctl enable-linger $USER
   ```

---

## 🔄 Managing the Mount

```bash
# Start the mount manually
systemctl --user start sshfs-<mount_name>.service

# Stop the mount
systemctl --user stop sshfs-<mount_name>.service

# View service status
systemctl --user status sshfs-<mount_name>.service
```

---

## ❓ Why Use Systemd?

- **User services** don’t require `sudo`.
- Clean **auto-start and auto-stop** behavior.
- No need to manually mount/unmount.

---

## 🛠 Troubleshooting

- If the mount fails, check logs with:

```bash
journalctl --user -xe
```

- Ensure your remote server allows SSH key logins.
- Verify that `ssh user@host` works without a password.

---

## 📄 License

MIT License – free to use, modify, and share.
