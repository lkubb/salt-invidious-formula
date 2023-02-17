# vim: ft=sls

{#-
    Starts the invidious, postgres container services
    and enables them at boot time.
    Has a dependency on `invidious.config`_.
#}

include:
  - .running
