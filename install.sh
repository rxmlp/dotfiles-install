#!/usr/bin/env bash
set -euo pipefail


if [ ! -f /etc/os-release ]; then
    echo "/etc/os-release not found. Unable to determine."
    exit 1  # Exit if os-release missing
fi

. /etc/os-release
if [ "$ID" = "arch" ] || echo "$ID_LIKE" | grep -qw "arch"; then
    echo "This system is Arch Linux or Arch-based."
else
    echo "This system is NOT Arch Linux nor Arch-based."
    exit 1  # Exit if not Arch(-based)
fi

if ping -c 1 github.com > /dev/null 2>&1; then
    echo "Internet is accessible"
else
    echo "No internet access/or github is blocked (DNS?)"
    exit 1
fi

TEMP=$(mktemp -d --suffix=_xyrd-dots)

cd $TEMP

# Determine what to use for super priveledges
if command -v sudo >/dev/null 2>&1; then
    SUPER="sudo"
elif command -v doas >/dev/null 2>&1; then
    SUPER="doas"
else
    echo "Neither sudo nor doas is installed"
    exit 1
fi

# List of required packages
REQUIRED_PKGS=("git" "base" "base-devel" "starship")

# Determine which packages are missing
MISSING_PKGS=()
for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
        MISSING_PKGS+=("$pkg")
    fi
done

# If any packages are missing, install them
if [ "${#MISSING_PKGS[@]}" -gt 0 ]; then
    echo "Installing missing package(s): ${MISSING_PKGS[*]}"
    $SUPER pacman -Sy --needed --noconfirm "${MISSING_PKGS[@]}"
else
    echo "All required packages ('git' and 'base') are already installed."
fi


# Adding Chaotic-Aur
$SUPER pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
$SUPER pacman-key --lsign-key 3056513887B78AEB

$SUPER pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
$SUPER pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

PACMAN_CONF="/etc/pacman.conf"
REPO_BLOCK="[chaotic-aur]"
INCLUDE_LINE="Include = /etc/pacman.d/chaotic-mirrorlist"

if ! grep -qF "$REPO_BLOCK" "$PACMAN_CONF"; then
    echo "Adding Chaotic-AUR repository to $PACMAN_CONF"
    $SUPER sh -c "echo -e '\n$REPO_BLOCK\n$INCLUDE_LINE' >> $PACMAN_CONF"
else
    echo "Chaotic-AUR repository already present in $PACMAN_CONF"
fi
$SUPER pacman -Syu --noconfirm


CONFIG_DIR="$HOME/.dotfiles"
TARGET_DIR="$HOME/.config"
BACKUP_DIR="$TARGET_DIR/backup"
DIRS=(
  fastfetch helix kitty matugen rofi swappy xdg-desktop-portal ghostty hypr mako qt6ct superfile waybar
)

# Clone your dotfiles repo to CONFIG_DIR, backing up if it already exists
if [ -d "$CONFIG_DIR" ]; then
    echo "$CONFIG_DIR already exists, making .bak and cloning fresh"
    rm -rf "$CONFIG_DIR.bak"
    mv "$CONFIG_DIR" "$CONFIG_DIR.bak"
fi

git clone https://github.com/rxmlp/dotfiles.git "$CONFIG_DIR"


mkdir -p "$TARGET_DIR"
mkdir -p "$BACKUP_DIR"

for d in "${DIRS[@]}"; do
    SRC="$CONFIG_DIR/config/$d"
    DEST="$TARGET_DIR/$d"
    if [ -e "$SRC" ]; then  # -e covers files and dirs
        # If the destination exists (dir, file, or symlink), move it to backup
        if [ -e "$DEST" ] || [ -L "$DEST" ]; then
            echo "Backing up existing $DEST to $BACKUP_DIR/"
            if [ -e "$BACKUP_DIR/$d" ] || [ -L "$BACKUP_DIR/$d" ]; then
                mv "$DEST" "$BACKUP_DIR/${d}_$(date +%s)"
            fi
        fi
        ln -s "$SRC" "$DEST"
        echo "Linked $SRC -> $DEST"
    else
        echo "Source $SRC does not exist, skipping."
    fi
done


    if [ -d "$HOME/.zshrc" ]; then
        echo "$HOME/.zshrc already exists, making .bak and cloning fresh"
        mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
    fi
    ln -s $CONFIG_DIR/.zshrc ~/.zshrc
    if [ -d "$HOME/.antigen" ]; then
        echo "$HOME/.antigen already exists, making .bak and cloning fresh"
        mv "$HOME/.antigen" "$HOME/.antigen.bak"
    fi
    ln -s $CONFIG_DIR/.antigen ~/.antigen
    if [ -d "$HOME/.nanorc" ]; then
        echo "$HOME/.nanorc already exists, making .bak and cloning fresh"
        mv "$HOME/.nanorc" "$HOME/.nanorc.bak"
    fi
    ln -s $CONFIG_DIR/.nanorc ~/.nanorc

$SUPER pacman -Sy --noconfirm yay
yay -S --noconfirm matugen-bin better-control-git


# Temporary working directory for building the dummy package
BUILD_DIR=$(mktemp -d --suffix=_xyrd-PKGBUILD)

# Download the PKGBUILD for xyrd-dots
curl -L -o "$BUILD_DIR/PKGBUILD" "https://raw.githubusercontent.com/rxmlp/dotfiles-install/refs/heads/main/PKGBUILD"

# Change to the build directory
cd "$BUILD_DIR"

# Build and install the dummy package (this requires base-devel installed)
makepkg -si --noconfirm

# Clean up the build directory
rm -rf "$BUILD_DIR"