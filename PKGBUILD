# Maintainer: Your Name <your.email@example.com>

pkgname=xyrd-dots
pkgver=1.0.0
pkgrel=1
PACMAN_AUTH=(doas)   
pkgdesc="Meta-package for xyrd-dots dependencies"
arch=('any')
url="https://github.com/rxmlp/dotfiles"
license=('MIT')
depends=(
    # Hypr
    hyprland
    hypridle
    hyprlock
    hyprsunset
    hyprlang
    hyprutils
    hyprpaper
    hyprcursor
    hyprpicker
    hyprgraphics
    hyprpolkitagent
    hyprland-qtutils
    hyprland-protocols
    hyprland-qt-support
    hyprwayland-scanner
    xdg-desktop-portal-hyprland
    aquamarine

    # tools
    opendoas
    git
    base
    ninja
    gcc
    cmake
    meson
    make
    glaze
    re2
    cpio
    socat

    # XCB and Wayland dependencies
    libxcb
    xcb-proto
    xcb-util
    xcb-util-keysyms
    libxfixes
    libx11
    libxcomposite
    libxrender
    libxcursor
    pixman
    wayland-protocols
    xcb-util-wm
    xorg-xwayland
    libinput
    libliftoff
    libdisplay-info
    xcb-util-errors
    xdg-desktop-portal-gtk
    fd
    ffmpegthumbnailer
    imagemagick
    tomlplusplus
    qt6ct
    wf-recorder
    wl-clipboard
    xorg-xhost
    mpvpaper

    # Utilities
    matugen-bin
    helix
    zsh
    mako
    ghostty
    kitty
    rofi-wayland
    grimblast-git
    swappy
    waybar
    fzf
    greetd
    btop
    nvtop
    eza
    clipman
    fastfetch
    pcmanfm-qt

    # Newly added from your list
    better-control-git
    bluez
    bluez-tools
    bluez-utils
    networkmanager
    noto-fonts-emoji
    papirus-icon-theme
    ttf-jetbrains-mono-nerd
)
optdepends=(
    'doas-sudo-shim: For sudo compatibility with doas'
    'timeshift: For system snapshots'
    'timeshift-autosnap: For automatic snapshots'
    'codium: For Visual Studio Code alternative'
    'gnome-disk-utility: For disk management GUI'
)
conflicts=()
provides=()
replaces=()

package() {
    # This function is intentionally empty since this is a meta-package
    :
}   
