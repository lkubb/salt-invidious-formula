# vim: ft=sls

{#-
    Removes the invidious, postgres containers
    and the corresponding user account and service units.
    Has a depency on `invidious.config.clean`_.
    If ``remove_all_data_for_sure`` was set, also removes all data.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
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

{%- if invidious.install.podman_api %}

Invidious podman API is unavailable:
  compose.systemd_service_dead:
    - name: podman
    - user: {{ invidious.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ invidious.lookup.user.name }}

Invidious podman API is disabled:
  compose.systemd_service_disabled:
    - name: podman
    - user: {{ invidious.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ invidious.lookup.user.name }}
{%- endif %}

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
