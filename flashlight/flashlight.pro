TARGET = powermenu2-flashlight
target.path = /usr/bin

QT += dbus

CONFIG += sailfishapp
PKGCONFIG += mlite5

dbus.files = dbus/org.coderus.powermenu.flashlight.service
dbus.path = /usr/share/dbus-1/services

LIBS += -L ../libpowermenutools -lpowermenutools

INSTALLS = target dbus

SOURCES += \
    src/dbuslistener.cpp \
    src/main.cpp

HEADERS += \
    src/dbuslistener.h
