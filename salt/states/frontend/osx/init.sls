{% import "macros/dotfiles.sls" as dotfiles with context %}
{% import "macros/primary.sls" as primary with context %}

include:
  - .karabiner
  - .sublime
  - .skhd
  - .yabai

{{ dotfiles.link_static() }}
