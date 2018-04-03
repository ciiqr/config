
packages:
  # Arch
  yaourt: yaourt
  pacman-tools:
    - pkgfile
    - pkgtools
  util-linux: util-linux

services:
  man-db: man-db.timer
  updatedb: updatedb.timer

base:
  packages:
    kernel:
      - linux
      - linux-headers
    # TODO: do I want to purge normal kernel?
    # kernel:
    #   - linux-lts
    #   - linux-lts-headers
    coreutils: coreutils
    awk: gawk
    libcap: libcap
    man:
      - man-db
      - man-pages
    info: texinfo
    wget: wget
    nfs: nfs-utils
    woof: woof
    htop: htop
    whois: whois
    ssh: openssh
    sshfs: sshfs
    nano: nano
    p7zip: p7zip
    rsync: rsync
    mlocate: mlocate
    incron: incron
    lsof: lsof
    nmap: nmap
    screen: screen
    units: units
    unrar: unrar
    zip:
      - zip
      - unzip
    traceroute: traceroute
    fdupes: fdupes
    jq: jq
    colordiff: colordiff
    cwdiff: cwdiff
    openssl: openssl
    lshw: lshw
    hwinfo: hwinfo
    lm-sensors: lm_sensors
    ntp: ntp
    haveged: haveged
    smartmontools: smartmontools
    zsh:
      - zsh
      - zsh-completions
      - zsh-syntax-highlighting
      - zshdb
    bash:
      - bash
      - bash-completion
    terminfo:
      - rxvt-unicode-terminfo
    git: git
  services:
    haveged: haveged
    smartmontools: smartd

development:
  packages:
    git: git
    cloc: cloc
    pkg-config: pkg-config
    sloccount: sloccount
    pssh: pssh
    shellcheck: shellcheck
    swift:
      - swift-bin
      - tailor
    # swift-perfect-dependencies:
    #   - openssl
    #   - libssl-dev
    #   - uuid-dev
    python:
      - python
      - python2
    bpython:
      - bpython
      - bpython2
    # pip:
    #   - python-pip
    #   - python3-pip
    # python-dev:
    #   - python-dev
    #   - python3-dev
    python-setuptools:
      - python-setuptools
      - python2-setuptools
    virtualenv:
      - python-virtualenv
      - python2-virtualenv
    nim:
      - nim
      - nimble
    mono:
      - mono
      - nuget
      # TODO: consider mono-tools
    # mono-libraries:
    #   -   .0-cil
    #   - libwebkit1.1-cil
    #   - libdbus2.0-cil
    #   - libdbus-glib2.0-cil
    cpp:
      - clang
      - llvm
      - lldb
      - ninja
    valgrind: valgrind
    strace: strace
    vagrant: vagrant
    virtualbox: virtualbox
    vagrant-nfs: nfs-utils
    meld: meld
    qtcreator: qtcreator
    monodevelop: monodevelop-stable
    kcachegrind: kcachegrind
    xephyr: xorg-server-xephyr
    hub: hub

frontend:
  packages:
    # xorg: xorg
    xterm: xterm
    rxvt: rxvt-unicode
    awesome:
      - awesome
      - vicious
    compton: compton
    lxdm: lxdm
    network-manager:
      - networkmanager
      - nm-connection-editor
      - network-manager-applet
      - networkmanager-openconnect
      - networkmanager-openvpn
      - networkmanager-pptp
    redshift:
      - redshift
      - gtk3
      - python-gobject
      - python-xdg
    lxappearance: lxappearance
    # numix-blue-gtk-theme: numix-blue-gtk-theme
    # oxygen-cursor-theme:
    #   - oxygen-cursor-theme
    #   - oxygen-cursor-theme-extra
    # linux-dark-icons: linux-dark-icons
    baobab: baobab
    sublime: sublime-text-dev
    spotify: spotify
    google-chrome: google-chrome
    firefox:
      - firefox
      - firefox-developer-edition
    deluge:
      - deluge
      - python2-notify
      - pygtk
      - librsvg
    keepass:
      - keepass
      - keepassx2
      - kpcli
    gpicview: gpicview
    fbreader: fbreader
    evince: evince
    vlc: vlc
    libreoffice:
      - libreoffice-fresh
      - gtk3
    samba: cifs-utils
    # dropbox:
    #   - nautilus-dropbox
    #   - python-gpgme
    # fonts:
    #   - fonts-dejavu
    #   - fonts-liberation
    #   - ttf-mscorefonts-installer
    #   - fonts-roboto
    #   - fonts-symbola
    #   - xfonts-terminus
    # pulseaudio:
    #   - pulseaudio
    #   - pulseaudio-utils
    #   - pavucontrol
    xdg-open:
      - xdg-utils
      - perl-file-mimeinfo
    #   - gvfs-bin
    # xorg-tools:
    #   - feh
    #   - xdotool
    #   - wmctrl
    #   - suckless-tools
    #   - xbindkeys
    #   - xcalib
    #   - xkbset
    #   - xkeycaps
    #   - xsel
    #   - x11-utils
    libinput:
      - libinput
      - xf86-input-libinput
    scrot: scrot
    imagemagick: imagemagick
    speedcrunch: speedcrunch
    spacefm:
      - spacefm
      - udisks2
    gparted: gparted
    gksu: gksu
    gcolor2: gcolor2
    baobab: baobab
    ntfs: ntfs-3g
    zenity: zenity
    youtube-dl: youtube-dl
    gucharmap: gucharmap
    leafpad: leafpad
    nethogs: nethogs
    iftop: iftop
    iotop: iotop
    pinta: pinta
    inotify: inotify-tools
    hardinfo: hardinfo
    powertop: powertop
    libnotify: libnotify
    bleachbit: bleachbit
    seahorse: seahorse

server:
  packages:
    ssh-server: openssh
    ddclient:
      - ddclient
      - perl-json-any
  services:
    ssh-server: sshd
    ddclient: ddclient

server-data:
  packages:
    acl: acl
    deluge-server: deluge
    samba-server: samba
    nfs-server: nfs-utils
    minidlna: minidlna
  services:
    deluge-server: deluged
    deluge-web-server: deluged-web

# TODO: decide how I'm going to handle aur packages
