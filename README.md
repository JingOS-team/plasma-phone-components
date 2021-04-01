plasma-phone-components
=======================

UI components for Plasma Phone

Test on a development machine
=======================

Dependencies:
* KDE Frameworks 5 setup (plasma-framework and its dependencies)
* oFono https://git.kernel.org/cgit/network/ofono/ofono.git
* libqofono https://git.merproject.org/mer-core/libqofono
* ofono-phonesim https://git.kernel.org/cgit/network/ofono/phonesim.git/

If you want to test some part specific to telephony, set up ofono-phonesim according to https://docs.plasma-mobile.org/Ofono.html

To start the phone homescreen in a window, run:
```
QT_QPA_PLATFORM=wayland dbus-run-session kwin_wayland --xwayland "plasmashell -p org.kde.plasma.phone"
```


# Jing-plasma-phone-components

Jing-plasma-phone-components is based on plasma-phone-components , a beautifully designed launcher that conforms to the JingOS style and has a compatible `pad / desktop`  experience.


## Links
* Home: www.jingos.com
* Project page: https://github.com/JingOS-team/jing-plasma-phone-components
* File issues: https://github.com/JingOS-team/jing-plasma-phone-components/issues
* Development channel:  www.jingos.com
