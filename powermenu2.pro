TEMPLATE = subdirs
SUBDIRS = \
    libpowermenutools \
    plugin \
    flashlight \
    daemon \
    gui \
    patch \
    $${NULL}

plugin.depends = libpowermenutools
daemon.depends = libpowermenutools plugin
gui.depends = daemon

OTHER_FILES = \
    rpm/powermenu2.spec \
    $${NULL}
