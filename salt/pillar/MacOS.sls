
base:
  zsh_etc_path: /etc
  packages:
    wget: wget
    # TODO: nfs
    woof: woof
    htop: htop
    whois: whois
    ssh: openssh
    sshfs:
      - caskroom/cask/osxfuse
      - sshfs
    nano: nano
    p7zip: p7zip
    rsync: rsync
    lsof: lsof
    nmap: nmap
    screen: screen
    units: gnu-units
    unrar: unrar
    zip: zip
    traceroute: tcptraceroute
    fdupes: fdupes
    jq: jq
    colordiff: colordiff
    # TODO: ntp
    smartmontools: smartmontools
    zsh:
      - zsh
      - zsh-completions
      - zsh-syntax-highlighting
      - zsh-autosuggestions
      - zshdb
    git: git

frontend:
  packages:
    baobab: baobab
    sublime: caskroom/cask/sublime-text
    spotify: caskroom/cask/spotify
    # TODO: redshift - or use built in Night Shift (that would require some dumb things to enable from here, redshift would just require enabling the service)
    google-chrome: caskroom/cask/google-chrome
    firefox: caskroom/cask/firefox-developer-edition
    deluge: caskroom/cask/deluge
    keepass:
      - caskroom/cask/keepassx
      - kpcli
    fbreader: caskroom/cask/fbreader
    dropbox: caskroom/cask/dropbox
    imagemagick: imagemagick
    speedcrunch: caskroom/cask/speedcrunch
    ntfs: ntfs-3g
    zenity: zenity
    youtube-dl: youtube-dl
    gucharmap: gucharmap
    nethogs: nethogs
    iftop: iftop
    libnotify: libnotify

development:
  packages:
    git: git
    cloc: cloc
    pkg-config: pkg-config
    sloccount: sloccount
    shellcheck: shellcheck
    python:
      - python
      - python@2
    # TODO: bpython
    nim: nim
    mono: mono
    cpp:
      - clang-format
      - llvm
      - ninja
    virtualbox: caskroom/cask/virtualbox
    meld: caskroom/cask/meld
