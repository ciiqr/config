{% import "macros/primary.sls" as primary with context %}

{% if 'git.checkout' in salt %}

{{ sls }}.latest:
  git.latest:
    - name: https://github.com/robbyrussell/oh-my-zsh.git
    - target: {{ primary.home() }}/.cache/config/oh-my-zsh
    - user: {{ primary.user() }}

{{ sls }}.omz:
  file.copy:
    - name: {{ primary.home() }}/.oh-my-zsh
    - source: {{ primary.home() }}/.cache/config/oh-my-zsh
    - makedirs: true
    - preserve: true
    - subdir: true
    - require:
      - {{ sls }}.latest

{{ sls }}.perms:
  file.directory:
    - name: {{ primary.home() }}/.oh-my-zsh
    - user: {{ primary.user() }}
    - group: {{ primary.group() }}
    - dir_mode: 700
    - file_mode: 600
    - recurse:
      - user
      - group
      - mode
    - require:
      - {{ sls }}.latest

{% endif %}
