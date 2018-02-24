
{% macro file(path) -%}
default.track.file.{{ path }}:
  file.append:
    - name: {{ salt['track.etc_files']() }}
    - text: {{ path }}
    - makedirs: true
    - require_in:
      - default.track.cleanup
{%- endmacro %}
