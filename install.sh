#!/bin/bash
#set -ueo pipefail
#set -x

REPO_DIR=$(cd $(dirname $0) && pwd)
SRC_DIR=${REPO_DIR}/src

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

THEME_NAME=Mojave
COLOR_VARIANTS=('-light' '-dark')
OPACITY_VARIANTS=('' '-solid')
ALT_VARIANTS=('' '-alt')
SMALL_VARIANTS=('' '-small')
ICON_VARIANTS=('' '-normal' '-gnome' '-ubuntu' '-arch' '-manjaro' '-fedora' '-debian')

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-o, --opacity VARIANTS" "Specify theme opacity variant(s) [standard|solid] (Default: All variants)"
  printf "  %-25s%s\n" "-c, --color VARIANTS" "Specify theme color variant(s) [light|dark] (Default: All variants)"
  printf "  %-25s%s\n" "-a, --alt VARIANTS" "Specify theme titilebutton variant(s) [standard|alt] (Default: All variants)"
  printf "  %-25s%s\n" "-s, --small VARIANTS" "Specify titilebutton size variant(s) [standard|small] (Default: standard variant)"
  printf "  %-25s%s\n" "-i, --icon VARIANTS" "Specify activities icon variant(s) for gnome-shell [standard|normal|gnome|ubuntu|arch|manjaro|fedora|debian] (Default: standard variant)"
  printf "  %-25s%s\n" "-g, --gdm" "Install GDM theme"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local opacity=${4}
  local alt=${5}
  local small=${6}
  local icon=${7}

  [[ ${color} == '-light' ]] && local ELSE_LIGHT=${color}
  [[ ${color} == '-dark' ]] && local ELSE_DARK=${color}

  local THEME_DIR=${dest}/${name}${color}${opacity}${alt}

  [[ -d ${THEME_DIR} ]] && rm -rf ${THEME_DIR}

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                              ${THEME_DIR}
  ln -sf ${REPO_DIR}/COPYING                                                            ${THEME_DIR}

  echo "[Desktop Entry]" >>                                                             ${THEME_DIR}/index.theme
  echo "Type=X-GNOME-Metatheme" >>                                                      ${THEME_DIR}/index.theme
  echo "Name=${name}${color}${opacity}${alt}" >>                                        ${THEME_DIR}/index.theme
  echo "Comment=An Stylish Gtk+ theme based on Elegant Design" >>                       ${THEME_DIR}/index.theme
  echo "Encoding=UTF-8" >>                                                              ${THEME_DIR}/index.theme
  echo "" >>                                                                            ${THEME_DIR}/index.theme
  echo "[X-GNOME-Metatheme]" >>                                                         ${THEME_DIR}/index.theme
  echo "GtkTheme=${name}${color}${opacity}${alt}" >>                                    ${THEME_DIR}/index.theme
  echo "MetacityTheme=${name}${color}${opacity}${alt}" >>                               ${THEME_DIR}/index.theme
  echo "IconTheme=la-capitaine-icon-theme" >>                                           ${THEME_DIR}/index.theme
  echo "CursorTheme=Adwaita" >>                                                         ${THEME_DIR}/index.theme
  echo "ButtonLayout=close,minimize,maximize:menu" >>                                   ${THEME_DIR}/index.theme

  mkdir -p                                                                              ${THEME_DIR}/gnome-shell
  ln -sf ${SRC_DIR}/gnome-shell/{extensions,message-indicator-symbolic.svg,pad-osd.css} ${THEME_DIR}/gnome-shell
  ln -sf ${SRC_DIR}/gnome-shell/gnome-shell${color}${opacity}.css                       ${THEME_DIR}/gnome-shell/gnome-shell.css
  ln -sf ${SRC_DIR}/gnome-shell/common-assets                                           ${THEME_DIR}/gnome-shell/assets
  ln -sf ${SRC_DIR}/gnome-shell/assets${color}/*.svg                                    ${THEME_DIR}/gnome-shell/assets
  ln -sf ${SRC_DIR}/gnome-shell/assets${color}/activities/activities${icon}.svg         ${THEME_DIR}/gnome-shell/assets/activities.svg
  cd ${THEME_DIR}/gnome-shell
  ln -s assets/no-events.svg no-events.svg
  ln -s assets/process-working.svg process-working.svg
  ln -s assets/no-notifications.svg no-notifications.svg

  mkdir -p                                                                              ${THEME_DIR}/gtk-2.0
  ln -sf ${SRC_DIR}/gtk-2.0/gtkrc${color}                                               ${THEME_DIR}/gtk-2.0/gtkrc
  ln -sf ${SRC_DIR}/gtk-2.0/assets${color}                                              ${THEME_DIR}/gtk-2.0/assets
  ln -sf ${SRC_DIR}/gtk-2.0/common/*.rc                                                 ${THEME_DIR}/gtk-2.0
  ln -sf ${SRC_DIR}/gtk-2.0/menubar-toolbar${color}.rc                                  ${THEME_DIR}/gtk-2.0/menubar-toolbar.rc

  mkdir -p                                                                              ${THEME_DIR}/gtk-3.0
  ln -sf ${SRC_DIR}/gtk-3.0/assets                                                      ${THEME_DIR}/gtk-3.0
  ln -sf ${SRC_DIR}/gtk-3.0/windows-assets/titlebutton${alt}${small}                    ${THEME_DIR}/gtk-3.0/windows-assets
  ln -sf ${SRC_DIR}/gtk-3.0/thumbnail${color}.png                                       ${THEME_DIR}/gtk-3.0/thumbnail.png
  ln -sf ${SRC_DIR}/gtk-3.0/gtk${color}${opacity}${alt}${small}.css                     ${THEME_DIR}/gtk-3.0/gtk.css
  [[ ${color} != '-dark' ]] && \
  ln -sf ${SRC_DIR}/gtk-3.0/gtk-dark${opacity}${alt}${small}.css                        ${THEME_DIR}/gtk-3.0/gtk-dark.css

  mkdir -p                                                                              ${THEME_DIR}/metacity-1
  ln -sf ${SRC_DIR}/metacity-1/metacity-theme${color}.xml                               ${THEME_DIR}/metacity-1/metacity-theme-1.xml
  ln -sf ${SRC_DIR}/metacity-1/metacity-theme-3.xml                                     ${THEME_DIR}/metacity-1
  ln -sf ${SRC_DIR}/metacity-1/assets/*.png                                             ${THEME_DIR}/metacity-1
  ln -sf ${SRC_DIR}/metacity-1/thumbnail${color}.png                                    ${THEME_DIR}/metacity-1/thumbnail.png
  cd ${THEME_DIR}/metacity-1 && ln -s metacity-theme-1.xml metacity-theme-2.xml

  mkdir -p                                                                              ${THEME_DIR}/xfwm4
  ln -sf ${SRC_DIR}/xfwm4/assets${color}/*.png                                          ${THEME_DIR}/xfwm4
  ln -sf ${SRC_DIR}/xfwm4/themerc${color}                                               ${THEME_DIR}/xfwm4/themerc

  mkdir -p                                                                              ${THEME_DIR}/cinnamon
  ln -sf ${SRC_DIR}/cinnamon/cinnamon${color}.css                                       ${THEME_DIR}/cinnamon/cinnamon.css
  ln -sf ${SRC_DIR}/cinnamon/common-assets                                              ${THEME_DIR}/cinnamon/assets
  ln -sf ${SRC_DIR}/cinnamon/assets${color}/*.svg                                       ${THEME_DIR}/cinnamon/assets
  ln -sf ${SRC_DIR}/cinnamon/thumbnail${color}.png                                      ${THEME_DIR}/cinnamon/thumbnail.png

  mkdir -p                                                                              ${THEME_DIR}/plank
  ln -sf ${SRC_DIR}/plank/${name}${color}/*.theme                                       ${THEME_DIR}/plank
}

# Bakup and install files related to GDM theme
install_gdm() {
  local THEME_DIR="$1/$2$3$4$5"
  local GS_THEME_FILE="/usr/share/gnome-shell/gnome-shell-theme.gresource"
  local SHELL_THEME_FOLDER="/usr/share/gnome-shell/theme"
  local ETC_THEME_FOLDER="/etc/alternatives"
  local ETC_THEME_FILE="/etc/alternatives/gdm3.css"
  local UBUNTU_THEME_FILE="/usr/share/gnome-shell/theme/ubuntu.css"
  local UBUNTU_NEW_THEME_FILE="/usr/share/gnome-shell/theme/gnome-shell.css"

  if [[ -f "$GS_THEME_FILE" ]] && command -v glib-compile-resources >/dev/null ; then
    echo "Installing '$GS_THEME_FILE'..."
    cp -an "$GS_THEME_FILE" "$GS_THEME_FILE.bak"
    glib-compile-resources \
      --sourcedir="$THEME_DIR/gnome-shell" \
      --target="$GS_THEME_FILE" \
      "${SRC_DIR}/gnome-shell/gnome-shell-theme.gresource.xml"
  else
    echo
    echo "ERROR: Failed to install '$GS_THEME_FILE'"
    exit 1
  fi

  if [[ -f "$UBUNTU_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    echo "Installing '$UBUNTU_THEME_FILE'..."
    cp -an "$UBUNTU_THEME_FILE" "$UBUNTU_THEME_FILE.bak"
    rm -rf "$GS_THEME_FILE"
    mv "$GS_THEME_FILE.bak" "$GS_THEME_FILE"
    cp -af "$THEME_DIR/gnome-shell/gnome-shell.css" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$ETC_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    echo "Installing Ubuntu gnome-shell theme..."
    cp -an "$ETC_THEME_FILE" "$ETC_THEME_FILE.bak"
    rm -rf "$ETC_THEME_FILE" "$GS_THEME_FILE"
    mv "$GS_THEME_FILE.bak" "$GS_THEME_FILE"
    [[ -d $SHELL_THEME_FOLDER/Mojave ]] && rm -rf $SHELL_THEME_FOLDER/Mojave
    cp -ur "$THEME_DIR/gnome-shell" "$SHELL_THEME_FOLDER/Mojave"
    cd "$ETC_THEME_FOLDER"
    ln -s "$SHELL_THEME_FOLDER/Mojave/gnome-shell.css" gdm3.css
  fi
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "ERROR: Destination directory does not exist."
        exit 1
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -g|--gdm)
      gdm='true'
      shift 1
      ;;
    -o|--opacity)
      shift
      for opacity in "${@}"; do
        case "${opacity}" in
          standard)
            opacitys+=("${OPACITY_VARIANTS[0]}")
            shift
            ;;
          solid)
            opacitys+=("${OPACITY_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized opacity variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      shift
      for color in "${@}"; do
        case "${color}" in
          light)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -a|--alt)
      shift
      for alt in "${@}"; do
        case "${alt}" in
          standard)
            alts+=("${ALT_VARIANTS[0]}")
            shift
            ;;
          alt)
            alts+=("${ALT_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized alt variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--small)
      shift
      for alt in "${@}"; do
        case "${alt}" in
          standard)
            smalls+=("${SMALL_VARIANTS[0]}")
            shift
            ;;
          small)
            smalls+=("${SMALL_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized alt variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -i|--icon)
      shift
      for icon in "${@}"; do
        case "${icon}" in
          standard)
            icons+=("${ICON_VARIANTS[0]}")
            shift
            ;;
          normal)
            icons+=("${ICON_VARIANTS[1]}")
            shift
            ;;
          gnome)
            icons+=("${ICON_VARIANTS[2]}")
            shift
            ;;
          ubuntu)
            icons+=("${ICON_VARIANTS[3]}")
            shift
            ;;
          arch)
            icons+=("${ICON_VARIANTS[4]}")
            shift
            ;;
          manjaro)
            icons+=("${ICON_VARIANTS[5]}")
            shift
            ;;
          fedora)
            icons+=("${ICON_VARIANTS[6]}")
            shift
            ;;
          debian)
            icons+=("${ICON_VARIANTS[7]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized alt variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

for opacity in "${opacitys[@]:-${OPACITY_VARIANTS[@]}}"; do
  for color in "${colors[@]:-${COLOR_VARIANTS[@]}}"; do
    for alt in "${alts[@]:-${ALT_VARIANTS[@]}}"; do
      for small in "${smalls[@]:-${SMALL_VARIANTS[0]}}"; do
        for icon in "${icons[@]:-${ICON_VARIANTS[0]}}"; do
          install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${alt}" "${small}" "${icon}"
        done
      done
    done
  done
done

if [[ "${gdm:-}" == 'true' ]]; then
  install_gdm "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${alt}" "${small}"
fi

echo
echo Done.
