# vim: ft=sls

{#-
    Stops the invidious, postgres container services
    and disables them at boot time.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as invidious with context %}

invidious service is dead:
  compose.dead:
    - name: {{ invidious.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if invidious.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ invidious.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if invidious.install.rootless %}
    - user: {{ invidious.lookup.user.name }}
{%- endif %}

invidious service is disabled:
  compose.disabled:
    - name: {{ invidious.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if invidious.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ invidious.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if invidious.install.rootless %}
    - user: {{ invidious.lookup.user.name }}
{%- endif %}
