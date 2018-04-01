{% import "macros/pkg.sls" as pkg with context %}

{% call pkg.all_installed(pillar) %}
  - pacman-tools
  - util-linux
{% endcall %}

{{ sls }}.pkgfile.update:
  cmd.run:
    - name: pkgfile --update
    - onchanges:
      - pkg: {{ sls }}.pkg.pacman-tools