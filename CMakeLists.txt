cmake_minimum_required (VERSION 3.14 FATAL_ERROR)

project(plasma-phone-components)

set(QT_MIN_VERSION "5.15.0")
set(KF5_MIN_VERSION "5.78")

set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} ${CMAKE_SOURCE_DIR}/cmake)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMOptionalAddSubdirectory)
include(ECMInstallIcons)
include(ECMSetupVersion)
include(ECMMarkNonGuiExecutable)
include(ECMGenerateHeaders)
include(GenerateExportHeader)
include(FeatureSummary)

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED Core Qml Quick DBus)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    I18n
    KIO
    Plasma
    PlasmaQuick
    Service
    Notifications
    Config
    DBusAddons
    Wayland
)

ki18n_install(po)
find_package(KF5Wayland CONFIG)
set_package_properties(KF5Wayland PROPERTIES
                       TYPE REQUIRED
                       PURPOSE "Required for interacting with the compositor")

# torch
find_package(GStreamer 1.1.90 REQUIRED)
find_package(GLIB2 REQUIRED)
find_package(GObject REQUIRED)
find_package(KF5 REQUIRED COMPONENTS Package)

include(CheckIncludeFiles)

plasma_install_package(look-and-feel org.kde.plasma.phone look-and-feel)
plasma_install_package(shell org.kde.plasma.phone shells)

install( DIRECTORY kwinmultitasking/ DESTINATION ${DATA_INSTALL_DIR}/kwin/scripts/org.kde.phone.multitasking )
install( FILES kwinmultitasking/metadata.desktop DESTINATION ${SERVICES_INSTALL_DIR} RENAME kwin-script-org.kde.phone.multitasking.desktop )

install( DIRECTORY components/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/private/mobileshell )

install( DIRECTORY ./containments/panel/package/contents/ui/icons/quicksettings DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./look-and-feel/contents/lockscreen/imgs/airBubbles.svg  DESTINATION  /usr/share/icons/jing/  )
install(FILES ./look-and-feel/contents/lockscreen/imgs/lightning.svg  DESTINATION  /usr/share/icons/jing/  )
install(FILES ./look-and-feel/contents/lockscreen/imgs/lightningQuickly.svg  DESTINATION  /usr/share/icons/jing/  )
install(FILES ./look-and-feel/contents/lockscreen/imgs/unlock-screen.svg  DESTINATION  /usr/share/icons/jing/  )
install(FILES ./look-and-feel/contents/lockscreen/imgs/lock-screen.svg  DESTINATION  /usr/share/icons/jing/  )
install(FILES ./containments/panel/package/contents/ui/quicksettings/imgs/cleaningAll.svg  DESTINATION  /usr/share/icons/jing/  )
install(FILES ./containments/panel/package/contents/ui/quicksettings/imgs/close.svg  DESTINATION  /usr/share/icons/jing/  )
install(FILES ./containments/panel/package/contents/ui/icons/Bluetooth.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Wifi.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Battery_rect.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Battery_rect_white.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Battery_charge.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Battery_charge_white.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Headset.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Location.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Mute.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Rotate.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Udisk.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Vpn.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/AlarmClock.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Headset_white.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Location_white.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Mute_white.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Rotate_white.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Udisk_white.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Vpn_white.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/AlarmClock_white.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/wifi_disconnected.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/wifi_closed.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/wifi_volume_100.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/wifi_volume_75.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/wifi_volume_50.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/wifi_volume_25.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/network_wired.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/sim_disconnected.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/sim_volume_0.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/sim_volume_25.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/sim_volume_50.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/sim_volume_75.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/sim_volume_100.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/FlightMode.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Calculator.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Calendar.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Camera.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Clock.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Keyboard_Hide.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Keyboard_Show.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Poweroff.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Mute_enable.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/Mute_disable.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/FlightMode_enable.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/AutoBrightness_enable.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/AutoBrightness_disable.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/quick_charging.svg DESTINATION /usr/share/icons/jing/jing/settings/ )
install(FILES ./containments/panel/package/contents/ui/icons/quick_charging_white.svg DESTINATION /usr/share/icons/jing/jing/settings/ )


add_subdirectory(bin)
add_subdirectory(applets)
add_subdirectory(containments)
add_subdirectory(sounds)
#add_subdirectory(touchscreentest)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
