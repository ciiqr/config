{% import "macros/primary.sls" as primary with context %}

{% macro link_static() -%}
  {%- for configPath in [grains['configDir'] ~ '/salt/states/', grains['privateConfigDir'] ~ '/salt/states/private/'] -%}
    {%- set path = configPath ~ slspath ~ '/home' -%}
    {%- set files = salt['file.find'](path, type='f') -%}
    {%- for file in files -%}
      {%- set relative_file = salt['utils.relpath'](file, path) -%}
      {%- set user_relative_file = primary.home() ~ '/' ~ relative_file %}

{{ sls }}.~/{{ relative_file }}:
  file.symlink:
    - name: {{ user_relative_file }}
    - target: {{ file }}
    - user: {{ primary.user() }}
    {% if not grains['platform'] == 'windows' %}
    - group: {{ primary.group() }}
    {% endif %}
    - makedirs: true
    - force: true

    {% endfor -%}
  {%- endfor -%}
{%- endmacro %}