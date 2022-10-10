# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as invidious with context %}

include:
  - {{ sls_config_clean }}

{%- if invidious.install.autoupdate_service %}

Podman autoupdate service is disabled for Invidious:
{%-   if invidious.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ invidious.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

Invidious is absent:
  compose.removed:
    - name: {{ invidious.lookup.paths.compose }}
    - volumes: {{ invidious.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if invidious.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ invidious.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if invidious.install.rootless %}
    - user: {{ invidious.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

Invidious compose file is absent:
  file.absent:
    - names:
      - {{ invidious.lookup.paths.compose }}
      - {{ invidious.lookup.paths.src }}
    - require:
      - Invidious is absent

Invidious user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ invidious.lookup.user.name }}
    - enable: false
    - onlyif:
      - fun: user.info
        name: {{ invidious.lookup.user.name }}
    - require:
      - Invidious is absent

Invidious user account is absent:
  user.absent:
    - name: {{ invidious.lookup.user.name }}
    - purge: {{ invidious.install.remove_all_data_for_sure }}
    - require:
      - Invidious is absent
    - retry:
        attempts: 5
        interval: 2

{%- if invidious.install.remove_all_data_for_sure %}

Invidious paths are absent:
  file.absent:
    - names:
      - {{ invidious.lookup.paths.base }}
    - require:
      - Invidious is absent
{%- endif %}
