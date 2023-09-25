# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as invidious with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

Invidious environment files are managed:
  file.managed:
    - names:
      - {{ invidious.lookup.paths.config_invidious }}:
        - source: {{ files_switch(
                        ["invidious.env", "invidious.env.j2"],
                        config=invidious,
                        lookup="invidious environment file is managed",
                        indent_width=10,
                     )
                  }}
      - {{ invidious.lookup.paths.config_postgres }}:
        - source: {{ files_switch(
                        ["postgres.env", "postgres.env.j2"],
                        config=invidious,
                        lookup="postgres environment file is managed",
                        indent_width=10,
                     )
                  }}
    - mode: '0640'
    - user: root
    - group: {{ invidious.lookup.user.name }}
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ invidious.lookup.user.name }}
    - require_in:
      - Invidious is installed
    - context:
        invidious: {{ invidious | json }}
