set(homescreen_SRCS
    wallpapermanager.cpp
    homescreen.cpp
    applicationlistmodel.cpp
    basemodel.cpp
    listmodelmanager.cpp
    launcheritem.cpp
)

add_library(plasma_containment_phone_homescreen MODULE ${homescreen_SRCS})

kcoreaddons_desktop_to_json(plasma_containment_phone_homescreen package/metadata.desktop)

target_link_libraries(plasma_containment_phone_homescreen
                      Qt5::Gui
                      KF5::Plasma
                      Qt5::Qml
                      Qt5::Quick
                      KF5::I18n
                      KF5::Service
                      KF5::KIOGui
                      KF5::Notifications
                      KF5::WaylandClient
                      KF5::Solid
                      KF5::ConfigCore
                      KF5::ConfigGui
                      KF5::KIOCore
                      KF5::KIOWidgets
                      KF5::KIOFileWidgets
)


install(TARGETS plasma_containment_phone_homescreen DESTINATION ${KDE_INSTALL_PLUGINDIR}/plasma/applets)
install(FILES service/systeminfodump DESTINATION  /usr/bin/ )
install(FILES service/systeminfo.service DESTINATION  /usr/lib/systemd/system/ )

plasma_install_package(package org.kde.phone.homescreen)

