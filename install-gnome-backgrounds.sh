#!/bin/bash

readonly ROOT_UID=0
readonly MAX_DELAY=20 # max delay for user to enter root password

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ "$UID" -eq "$ROOT_UID" ]]; then
  BACKGROUND_DIR="/usr/share/backgrounds"
  PROPERTIES_DIR="/usr/share/gnome-background-properties"
else
  BACKGROUND_DIR="$HOME/.local/share/backgrounds"
  PROPERTIES_DIR="$HOME/.local/share/gnome-background-properties"
fi

THEME_VARIANTS=('WhiteSur' 'Monterey' 'Ventura' 'Sonoma')
SCREEN_VARIANTS=('1080p' '2k' '4k')

#COLORS
CDEF=" \033[0m"                               # default color
CCIN=" \033[0;36m"                            # info color
CGSC=" \033[0;32m"                            # success color
CRER=" \033[0;31m"                            # error color
CWAR=" \033[0;33m"                            # waring color
b_CDEF=" \033[1;37m"                          # bold default color
b_CCIN=" \033[1;36m"                          # bold info color
b_CGSC=" \033[1;32m"                          # bold success color
b_CRER=" \033[1;31m"                          # bold error color
b_CWAR=" \033[1;33m"                          # bold warning color

# echo like ...  with  flag type  and display message  colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;    # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;    # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;    # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;    # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

usage() {
  cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -t, --theme VARIANT     Specify theme variant(s) [whitesur|monterey|ventura|sonoma] (Default: All variants)s)
  -s, --screen VARIANT    Specify screen variant [1080p|2k|4k] (Default: 4k)
  -u, --uninstall         Uninstall wallpappers
  -h, --help              Show help

INSTALLATION EXAMPLES:
Install WhiteSur version on 4k display:
  $0 -t whitesur -s 4k
EOF
}

install() {
  local theme="$1"
  local screen="$2"

  prompt -i "\n * Install ${theme} ${screen} version in ${BACKGROUND_DIR}... "
  [[ -d ${BACKGROUND_DIR}/${theme} ]] && rm -rf ${BACKGROUND_DIR}/${theme}
  [[ -f ${PROPERTIES_DIR}/${theme}.xml ]] && rm -rf ${PROPERTIES_DIR}/${theme}.xml
  mkdir -p ${BACKGROUND_DIR}/${theme}

  if [[ "${theme}" == 'Ventura' || "${theme}" == 'Sonoma' ]]; then
    cp -a --no-preserve=ownership ${REPO_DIR}/4k/${theme}{'-dark','-light'}.jpg ${BACKGROUND_DIR}/${theme}
  else
    cp -a --no-preserve=ownership ${REPO_DIR}/${screen}/${theme}{'','-morning','-light'}.jpg ${BACKGROUND_DIR}/${theme}
  fi

  cp -a --no-preserve=ownership ${REPO_DIR}/xml-files/timed-xml-files/${theme}-timed.xml ${BACKGROUND_DIR}/${theme}
  cp -a --no-preserve=ownership ${REPO_DIR}/xml-files/gnome-background-properties/${theme}.xml ${PROPERTIES_DIR}

  sed -i "s/@BACKGROUNDDIR@/$(printf '%s\n' "${BACKGROUND_DIR}" | sed 's/[\/&]/\\&/g')/g" "${BACKGROUND_DIR}/${theme}/${theme}-timed.xml"
  sed -i "s/@BACKGROUNDDIR@/$(printf '%s\n' "${BACKGROUND_DIR}" | sed 's/[\/&]/\\&/g')/g" "${PROPERTIES_DIR}/${theme}.xml"
}

uninstall() {
  local theme="$1"
  prompt -i "\n * Uninstall ${theme}... "
  [[ -d ${BACKGROUND_DIR}/${theme} ]] && rm -rf ${BACKGROUND_DIR}/${theme}
  [[ -f ${PROPERTIES_DIR}/${theme}.xml ]] && rm -rf ${PROPERTIES_DIR}/${theme}.xml
}

uninstall_nord() {
  [[ -d ${BACKGROUND_DIR}/Wallpaper-nord ]] && rm -rf ${BACKGROUND_DIR}/${BACKGROUND_DIR}/Wallpaper-nord
  [[ -f ${PROPERTIES_DIR}/Mojave.xml ]] && rm -rf ${PROPERTIES_DIR}/Mojave.xml
}

install_nord_wallpaper() {
  prompt -w "Install Nord version in ${BACKGROUND_DIR}... \n"
  mkdir -p ${BACKGROUND_DIR}/Wallpaper-nord
  cp -a --no-preserve=ownership ${REPO_DIR}/Wallpaper-nord/{'Mojave-nord','WhiteSur-nord'}{'-dark','-light'}.png ${BACKGROUND_DIR}/Wallpaper-nord
  cp -a --no-preserve=ownership ${REPO_DIR}/xml-files/gnome-background-properties/Mojave-nord.xml ${PROPERTIES_DIR}
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -u|--uninstall)
      uninstall='true'
      shift
      ;;
    -t|--theme)
      shift
      for theme in "$@"; do
        case "$theme" in
          whitesur)
            themes+=("${THEME_VARIANTS[0]}")
            shift 1
            ;;
          monterey)
            themes+=("${THEME_VARIANTS[1]}")
            shift 1
            ;;
          ventura)
            themes+=("${THEME_VARIANTS[2]}")
            shift 1
            ;;
          sonoma)
            themes+=("${THEME_VARIANTS[3]}")
            shift 1
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized theme variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--screen)
      shift
      for screen in "$@"; do
        case "$screen" in
          1080p)
            screens+=("${SCREEN_VARIANTS[0]}")
            shift 1
            ;;
          2k)
            screens+=("${SCREEN_VARIANTS[1]}")
            shift 1
            ;;
          4k)
            screens+=("${SCREEN_VARIANTS[2]}")
            shift 1
            ;;
          -*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized screen variant '$1'."
            prompt -i "Try '$0 --help' for more information."
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
      prompt -e "ERROR: Unrecognized installation option '$1'."
      prompt -i "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[@]}")
fi

if [[ "${#screens[@]}" -eq 0 ]] ; then
  screens=("${SCREEN_VARIANTS[@]}")
fi

install_wallpaper() {
  echo
  for theme in "${themes[@]}"; do
    for screen in "${screens[@]}"; do
      install "$theme" "$screen"
    done
  done
  echo
}

uninstall_wallpaper() {
  echo
  for theme in "${themes[@]}"; do
    uninstall "$theme"
  done
  echo
}

if [[ "${uninstall}" != 'true' ]]; then
  install_wallpaper && install_nord_wallpaper
else
  uninstall_wallpaper && uninstall_nord
fi

prompt -s "Finished!"
