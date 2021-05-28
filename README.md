# plasma-phone-components
## Introduction

UI components for Plasma Phone.
It provids Status-panel Quick-settings Lock-Screen and Home-Screen


## Dependencies:
* KDE Frameworks 5
* oFono
* libqofono
* ofono-phonesim
* CMake
* Qt5
* GStreamer
* GLIB2
* GObject
* ECM

## Building and Installing

```sh
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/path/to/prefix ..
make
make install # use sudo if necessary
```

Replace `/path/to/prefix` to your installation prefix.
Default is `/usr/local`.



##Usage
```
QT_QPA_PLATFORM=wayland dbus-run-session kwin_wayland --xwayland "plasmashell -p org.kde.plasma.phone"
```
## Links
* Home: www.jingos.com
* Project page: https://github.com/JingOS-team/jing-plasma-phone-components
* File issues: https://github.com/JingOS-team/jing-plasma-phone-components/issues
* Development channel:  www.jingos.com
