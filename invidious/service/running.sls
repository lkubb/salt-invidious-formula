# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as invidious with context %}

include:
  - {{ sls_config_file }}

Invidious service is enabled:
  compose.enabled:
    - name: {{ invidious.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if invidious.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ invidious.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
    - require:
      - Invidious is installed
{%- if invidious.install.rootless %}
    - user: {{ invidious.lookup.user.name }}
{%- endif %}

Invidious service is running:
  compose.running:
    - name: {{ invidious.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if invidious.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ invidious.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if invidious.install.rootless %}
    - user: {{ invidious.lookup.user.name }}
{%- endif %}
    - watch:
      - Invidious is installed
