TERMUX_PKG_HOMEPAGE=https://termux.dev/
TERMUX_PKG_DESCRIPTION="Basic system tools for Termux"
TERMUX_PKG_LICENSE="GPL-3.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.46.0+really1.45.0"
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/termux/termux-tools/archive/refs/tags/v1.45.0.tar.gz
TERMUX_PKG_SHA256=1ae29b1b875d95cc626dae323b45a2ace759969862d96094b2fa6d13bffe20d2
TERMUX_PKG_ESSENTIAL=true
#TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_UPDATE_TAG_TYPE="newest-tag"
TERMUX_PKG_BREAKS="termux-keyring (<< 1.9)"
TERMUX_PKG_CONFLICTS="procps (<< 3.3.15-2)"
TERMUX_PKG_SUGGESTS="termux-api"

TERMUX_PKG_DEPENDS="bzip2, coreutils, curl, dash, diffutils, findutils, gawk, grep, gzip, less, procps, psmisc, sed, tar, termux-am (>= 0.8.0), termux-am-socket (>= 1.5.0), termux-core, termux-exec, util-linux, xz-utils, dialog"
TERMUX_PKG_RECOMMENDS="ed, dos2unix, inetutils, net-tools, patch, unzip"

termux_step_pre_configure() {
	autoreconf -vfi
}

termux_step_post_make_install() {
	TERMUX_PKG_CONFFILES="$(cat "$TERMUX_PKG_BUILDDIR/conffiles")"
}

termux_step_create_debscripts() {
	cat <<- EOF > ./preinst
	$(cat "$TERMUX_PKG_BUILDDIR/preinst")
	EOF
}

termux_step_post_massage() {
    # Вызываем стандартную обработку
    termux_step_post_massage
    
    # Заменяем com.termux на новый package name во всех файлах
    sed -i "s/com.termux/${TERMUX_APP_PACKAGE}/g" ./bin/termux-fix-shebang
    sed -i "s/com.termux/${TERMUX_APP_PACKAGE}/g" ./bin/termux-info
    sed -i "s/com.termux/${TERMUX_APP_PACKAGE}/g" ./bin/termux-open
    sed -i "s/com.termux/${TERMUX_APP_PACKAGE}/g" ./bin/termux-open-url
    sed -i "s/com.termux/${TERMUX_APP_PACKAGE}/g" ./libexec/termux-api
    sed -i "s/com.termux/${TERMUX_APP_PACKAGE}/g" ./libexec/termux-api-client
    sed -i "s/com.termux/${TERMUX_APP_PACKAGE}/g" ./libexec/termux-am
    sed -i "s/com.termux/${TERMUX_APP_PACKAGE}/g" ./libexec/termux-commands
    
    # Рекурсивно во всех остальных файлах
    find . -type f -exec sed -i "s/com.termux/${TERMUX_APP_PACKAGE}/g" {} \;
    
    # ===== ДОБАВЛЯЕМ КАСТОМНЫЙ MOTD =====
    # Отключаем оригинальный скрипт вывода motd
    chmod -x ./libexec/termux-messages 2>/dev/null || true
    
    # Создаём свой motd
    cat > ./etc/motd << 'EOF'
Welcome to Termux!

Developer Fork: https://github.com/Hinderchik
Fork: https://github.com/Hinderchik/XunKal1-termux
Docs:       https://termux.dev/docs
Donate:     https://termux.dev/donate
Community:  https://termux.dev/community

Working with packages:

 - Search:  pkg search <query>
 - Install: pkg install <package>
 - Upgrade: pkg upgrade

Subscribing to additional repositories:

 - Root:    pkg install root-repo
 - X11:     pkg install x11-repo

For fixing any repository issues,
try 'termux-change-repo' command.

Report issues at https://termux.dev/issues
EOF
}