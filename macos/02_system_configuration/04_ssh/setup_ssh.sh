#!/usr/bin/env bash
# Generate an Ed25519 SSH key on macOS, load it into the
# ssh-agent with Keychain integration, append a Host * config block,
# and print the public key for copying to a server or GitHub.

set -euo pipefail
umask 077

KEY="$HOME/.ssh/id_ed25519"
CONFIG="$HOME/.ssh/config"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Exit if the key already exists OR config already references the key.
if [[ -f "$KEY" ]] || grep -qF -- "IdentityFile $KEY" "$CONFIG" 2>/dev/null; then
    echo "SSH key or config entry already exists. Nothing changed."
    exit 1
fi

ssh-keygen -t ed25519 -a 100 -C "" -f "$KEY"
ssh-add --apple-use-keychain "$KEY"

touch "$CONFIG"
chmod 600 "$CONFIG"

cat >> "$CONFIG" <<EOF

Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile $KEY
EOF

echo "Public key:"
cat "$KEY.pub"