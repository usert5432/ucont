ucont - Micro Application Containers
====================================

`ucont` is a collection of bash scripts to create, manage and run lightweight
application containers. It draws inspiration from the Singularity application
containers but aims to be less complex and have a minimum number of
dependencies.

`ucont` comes with a number of templates to bootstrap Debian based containers
with debootstrap and Archlinux containers with pacstrap. The created containers
can be made available for everyone by superuser with `ucont-mount` command.
Once ucont container is mounted every user can execute commands in the
container environment with `ucont-exec`.

Installation
------------

`ucont` can be installed with ``make`` by

::

    make install

You can control installation paths via ``PREFIX``, ``BINDIR``, ``SYSCONFDIR``,
``LOCALSTATEDIR`` variables (see also ``./make/install-paths.mk``).

Additionally, `ucont` comes with a chroot wrapper to allow users to chroot
into containers without administrative privileges. For the chroot wrapper to
work it needs to be either a SUID application or have a CAP_SYS_CHROOT
capability. You can control whether the wrapper uses suid or capabilities
mechanisms by setting ``USE_SUID`` or ``USE_CAPS`` variables to ``true`` during
installation.

Documentation
-------------

Please refer to the `ucont` manpages ``ucont(1)`` for the detailed
documentation. Below are a few examples of `ucont` usage.

Examples
^^^^^^^^

Let's create a new container ``office-container.sqfs`` that holds office suite
applications using configuration ``examples/office.conf`` that comes with
`ucont` package:

::

    (root) $ ucont create -f sqfs examples/office.conf office-container.sqfs

In order to allow users run applications in this container we need to mount
it. The command below will mount ``office-container.sqfs`` with label
``office``

::

    (root) $ ucont mount office office-container.sqfs

Now, anyone can execute commands in the container environment. For example,

::

    (user) $ ucont exec office libreoffice

will chroot into container ``office`` and execute ``libreoffice`` command
inside.

