# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as invidious with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Invidious user account is present:
  user.present:
{%- for param, val in invidious.lookup.user.items() %}
{%-   if val is not none and param != "groups" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ invidious.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false

Invidious user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ invidious.lookup.user.name }}
    - enable: {{ invidious.install.rootless }}
    - require:
      - user: {{ invidious.lookup.user.name }}

Invidious paths are present:
  file.directory:
    - names:
      - {{ invidious.lookup.paths.base }}
      - {{ invidious.lookup.paths.src }}
    - user: {{ invidious.lookup.user.name }}
    - group: {{ invidious.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ invidious.lookup.user.name }}

{%- if invidious.install.podman_api %}

Invidious podman API is enabled:
  compose.systemd_service_enabled:
    - name: podman.socket
    - user: {{ invidious.lookup.user.name }}
    - require:
      - Invidious user session is initialized at boot

Invidious podman API is available:
  compose.systemd_service_running:
    - name: podman.socket
    - user: {{ invidious.lookup.user.name }}
    - require:
      - Invidious user session is initialized at boot
{%- endif %}

# The Postgres container requires the database init files from the repo.
# git.cloned would suffice mostly, but it cannot clone into an existing dir
# https://github.com/saltstack/salt/issues/55926
Invidious repository is cloned:
  git.latest:
    - name: {{ invidious.lookup.repo }}
    - target: {{ invidious.lookup.paths.src }}
    - user: {{ invidious.lookup.user.name }}
    - force_clone: true

Invidious compose file is managed:
  file.managed:
    - name: {{ invidious.lookup.paths.compose }}
    - source: {{ files_switch(["docker-compose.yml", "docker-compose.yml.j2"],
                              lookup="Invidious compose file is present"
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ invidious.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - makedirs: true
    - context:
        invidious: {{ invidious | json }}
    - require:
      - Invidious repository is cloned

Invidious is installed:
  compose.installed:
    - name: {{ invidious.lookup.paths.compose }}
{%- for param, val in invidious.lookup.compose.items() %}
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- for param, val in invidious.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - watch:
      - file: {{ invidious.lookup.paths.compose }}
{%- if invidious.install.rootless %}
    - user: {{ invidious.lookup.user.name }}
    - require:
      - user: {{ invidious.lookup.user.name }}
{%- endif %}

{%- if invidious.install.autoupdate_service is not none %}

Podman autoupdate service is managed for Invidious:
{%-   if invidious.install.rootless %}
  compose.systemd_service_{{ "enabled" if invidious.install.autoupdate_service else "disabled" }}:
    - user: {{ invidious.lookup.user.name }}
{%-   else %}
  service.{{ "enabled" if invidious.install.autoupdate_service else "disabled" }}:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}
