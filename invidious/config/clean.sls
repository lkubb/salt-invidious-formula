# vim: ft=sls

{#-
    Removes the configuration of the invidious, postgres containers
    and has a dependency on `invidious.service.clean`_.

    This does not lead to the containers/services being rebuilt
    and thus differs from the usual behavior.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as invidious with context %}

include:
  - {{ sls_service_clean }}

Invidious environment files are absent:
  file.absent:
    - names:
      - {{ invidious.lookup.paths.config_invidious }}
      - {{ invidious.lookup.paths.config_postgres }}
      - {{ invidious.lookup.paths.base | path_join(".saltcache.yml") }}
    - require:
      - sls: {{ sls_service_clean }}
