TEMPLATE = subdirs
SUBDIRS = \
    libpowermenutools \
    plugin \
    flashlight \
    daemon \
    gui \
    patch \
    $${NULL}

plugin.depends = libpowermenutools flashlight
daemon.depends = libpowermenutools plugin flashlight
gui.depends = daemon

OTHER_FILES = \
    rpm/powermenu2.spec \
    $${NULL}
