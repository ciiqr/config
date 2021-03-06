{% import "macros/optional.sls" as optional with context %}
{% set platform = __salt__['grains.get']('platform', '') %}
{% set os_family = __salt__['grains.get']('os_family', '') %}
{% set os = __salt__['grains.get']('os', '') %}
{% set roles = __salt__['grains.get']('roles', []) %}

{% call optional.pillar_stacks() %}
  {% if platform %}
  - default/{{ platform }}
  - private/default/{{ platform }}
  {% endif %}

  - default/{{ os_family }}
  - private/default/{{ os_family }}

  {% if os != os_family -%}
  - default/{{ os }}
  - private/default/{{ os }}
  {%- endif %}

  {%- for role in roles %}
  - default/{{ role }}
  - private/default/{{ role }}
  {%- endfor %}

  - default/{{ minion_id }}
  - private/default/{{ minion_id }}

  {% if platform %}
  - {{ platform }}
  - private/{{ platform }}
  {% endif %}

  - {{ os_family }}
  - private/{{ os_family }}

  {% if os != os_family -%}
  - {{ os }}
  - private/{{ os }}
  {%- endif %}

  {%- for role in roles %}
  - {{ role }}
  - private/{{ role }}
  {%- endfor %}

  - {{ minion_id }}
  - private/{{ minion_id }}
{%- endcall %}
