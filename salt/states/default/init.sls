{% from "macros/optional.sls" import optional_include with context %}

{{ optional_include(
  'private.' ~ sls
) }}
