qt5_add_dbus_interfaces(DBUS_SRCS dbus/org.kde.KWin.Screenshot.xml
                                  dbus/org.kde.KScreen.xml)

set(phonepanel_SRCS
    phonepanel.cpp
    mediamanager.cpp
    hotkeysmanager.cpp
    ${DBUS_SRCS}
)

find_package(Threads)
add_library(plasma_applet_phonepanel MODULE ${phonepanel_SRCS})

kcoreaddons_desktop_to_json(plasma_applet_phonepanel package/metadata.desktop)

target_link_libraries(plasma_applet_phonepanel
			KF5::Solid
                      Qt5::Gui
                      Qt5::DBus
                      KF5::Plasma
                      Qt5::Qml
                      KF5::Plasma
                      KF5::I18n
                      KF5::ConfigCore
    		      KF5::ConfigGui
    		      KF5::CoreAddons
    		      KF5::Notifications
    		      KF5::DBusAddons
		      KF5::WaylandClient
		      KF5::KIOCore
		      KF5::KIOGui
                      ${GSTREAMER_LIBRARIES} GLIB2::GLIB2 ${GOBJECT_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})

target_include_directories(plasma_applet_phonepanel PRIVATE "${GSTREAMER_INCLUDE_DIR}" "${KDE_INSTALL_INCLUDEDIR}/Solid" "${KDE_INSTALL_INCLUDEDIR}/KDELibs4Support")

install(TARGETS plasma_applet_phonepanel DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)

#install(FILES plasma-phonepanel-default.desktop DESTINATION ${SERVICES_INSTALL_DIR})

plasma_install_package(package org.kde.phone.panel)

