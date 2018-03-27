
base:
  zsh_etc_path: /etc
  locate_conf_path: /etc/locate.rc
  packages:
    coreutils: coreutils
    awk: gawk
    wget: wget
    # TODO: nfs
    woof: woof
    htop: htop
    whois: whois
    ssh:
      - openssh
      - ssh-copy-id
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
    openssl: openssl@1.1
    # TODO: ntp
    smartmontools: smartmontools
    zsh:
      - zsh
      - zsh-completions
      - zsh-syntax-highlighting
      - zsh-autosuggestions
      - zshdb
    bash:
      - bash
      - bash-completion@2
      - brew-cask-completion
      - launchctl-completion
      - packer-completion
      - vagrant-completion
      - aptly-completion
      - ruby-completion
      - open-completion
      - pip-completion
      - mix-completion
      - gem-completion
      - kitchen-completion
      - bashdb
    git: git

frontend:
  packages:
    baobab: baobab
    sublime: caskroom/cask/sublime-text
    spotify: caskroom/cask/spotify
    yakyak: caskroom/cask/yakyak
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
  terraform:
    hash: sha256=3f05acdf0a9e04ba7e3bda18521feb0b310462dcce62c454854a40519b1695ed
  packer:
    hash: sha256=bc9345fbd3b55fc4d7003b4df97089001ce755a36b6ba347e514b20393a01cf0
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
    vagrant: caskroom/cask/vagrant
    virtualbox: caskroom/cask/virtualbox
    meld: caskroom/cask/meld
