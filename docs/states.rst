Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``invidious``
^^^^^^^^^^^^^
*Meta-state*.

This installs the invidious, postgres containers,
manages their configuration and starts their services.


``invidious.package``
^^^^^^^^^^^^^^^^^^^^^
Installs the invidious, postgres containers only.
This includes creating systemd service units.


``invidious.config``
^^^^^^^^^^^^^^^^^^^^
Manages the configuration of the invidious, postgres containers.
Has a dependency on `invidious.package`_.


``invidious.service``
^^^^^^^^^^^^^^^^^^^^^
Starts the invidious, postgres container services
and enables them at boot time.
Has a dependency on `invidious.config`_.


``invidious.clean``
^^^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``invidious`` meta-state
in reverse order, i.e. stops the invidious, postgres services,
removes their configuration and then removes their containers.


``invidious.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the invidious, postgres containers
and the corresponding user account and service units.
Has a depency on `invidious.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``invidious.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the invidious, postgres containers
and has a dependency on `invidious.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``invidious.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the invidious, postgres container services
and disables them at boot time.


