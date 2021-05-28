find -name \*.cpp -o -name \*.h -o -name \*.qml | sort | xargs xgettext  -o myapp.po \
--c++ --kde \
--from-code=UTF-8 \
-kjTr:1 -kjTrc:1c,2 -kjTrd:2 -kjTrp:1,2  -kjTrcp:1c,2,3 \
-ki18n:1 -ki18nc:1c,2 -ki18np:1,2 -ki18ncp:1c,2,3 \
-kki18n:1 -kki18nc:1c,2 -kki18np:1,2 -kki18ncp:1c,2,3 \
-kI18N_NOOP:1 -kI18NC_NOOP:1c,2 \
-kxi18n:1 -kxi18nc:1c,2 -kxi18np:1,2 -kxi18ncp:1c,2,3 \
-kkxi18n:1 -kkxi18nc:1c,2 -kkxi18np:1,2 -kkxi18ncp:1c,2,3

