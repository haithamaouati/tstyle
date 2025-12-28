#!/data/data/com.termux/files/usr/bin/bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati

# ANSI Colors
nc="$(printf '\e[0m')"
bold="$(printf '\e[1m')"
underline="$(printf '\e[4m')"
bold_green="$(printf '\e[1;32m')"
bold_red="$(printf '\e[1;31m')"
bold_yellow="$(printf '\e[1;33m')"

# API
readonly NERDFONTSAPI='https://api.github.com/repos/ryanoasis/nerd-fonts'
readonly NERDFONTSREPO='https://github.com/ryanoasis/nerd-fonts'
NEW_RELEASE_AVAILABLE='false'
KEEP_FONT_ARCHIVES='false'
INCLUDE_INSTALLED_FONTS='false'
UPDATE_INSTALLED_FONTS='false'
DISPLAY_INSTALLED_FONTS='false'
DISPLAY_ALL_FONTS='false'

# Directories
TERMUX_DIR="$HOME/.termux"
COLORS_DIR="$HOME/.termux/colors"
FONTS_DIR="$HOME/.termux/fonts"
readonly DOWN_DIR="$TERMUX_DIR/cache"
readonly NF_DIR="$DOWN_DIR"
readonly FONT_RELEASES_DIR="$NF_DIR/releases"
readonly RELEASE_FILE="$NF_DIR/release.txt"
readonly ALL_FONTS_FILE="$NF_DIR/all_fonts.txt"
readonly FONT_DIR="$FONTS_DIR"

# ASCII Banner
banner () {
    clear
    echo -e "${bold_green}"
    cat <<"EOF"
 __            __             ___
/\ \__        /\ \__         /\_ \
\ \ ,_\   ____\ \ ,_\  __  __\//\ \      __
 \ \ \/  /',__\\ \ \/ /\ \/\ \ \ \ \   /'__`\
  \ \ \_/\__, `\\ \ \_\ \ \_\ \ \_\ \_/\  __/
   \ \__\/\____/ \ \__\\/`____ \/\____\ \____\
    \/__/\/___/   \/__/ `/___/> \/____/\/____/
                           /\___/
                           \/__/
EOF
    echo -e "\ntstyle${nc} — Stylish Termux color-schemes & fonts.\n"
    echo -e " Author: Haitham Aouati"
    echo -e " GitHub: ${underline}github.com/haithamaouati${nc}"
}

# Script Termination
exit_on_signal_SIGINT () {
    { printf "\n\n%s\n" "${bold_red}[!]${nc} Script interrupted." 2>&1; echo; reset_color; }
    exit 0
}

exit_on_signal_SIGTERM () {
    { printf "\n\n%s\n" "${bold_red}[!]${nc} Script terminated." 2>&1; echo; reset_color; }
    exit 0
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

# Reset terminal colors
reset_color() {
        tput sgr0
        tput op
    return
}

# Available color-schemes & fonts
check_files () {
    if [[ "$1" = colors ]]; then
        colors=($(ls $COLORS_DIR))
        echo ${#colors[@]}
    elif [[ "$1" = fonts ]]; then
        fonts=($(ls $FONTS_DIR))
        echo ${#fonts[@]}
    fi
    return
}

total_colors=$(check_files colors)
total_fonts=$(check_files fonts)

# Reload Settings
reload_settings () {
    case "${TERMUX__USER_ID:-}" in ''|*[!0-9]*|0[0-9]*) TERMUX__USER_ID=0;; esac
    echo "${bold}[*]${nc} Reloading Settings..."
    am broadcast --user "$TERMUX__USER_ID" -a "com.termux.app.reload_style" "com.termux" > /dev/null
    { echo "${bold_green}[✓]${nc} Applied Successfully."; echo; }
    return
}

# Apply color-schemes
apply_colors () {
    local count=1
    color_schemes=($(ls $COLORS_DIR))
    for colors in "${color_schemes[@]}"; do
        echo ${bold_green}"[$count]${nc} ${colors%.*}"
        count=$(($count+1))
    done

    { echo; read -p "Select Color Scheme (1 to $total_colors): " answer; echo; }

    if [[ (-n "$answer") && ("$answer" -le $total_colors) ]]; then
        scheme=${color_schemes[(( answer - 1 ))]}
        echo -e "${bold}[*]${nc} Applying Color Scheme..."
        ln -sf $COLORS_DIR/$scheme $TERMUX_DIR/colors.properties
        { reload_settings; reset_color; return; }
    else
        echo -n "${bold_red}[!]${nc} Back to menu."
        { echo; break; }
    fi
    return
}

# Apply fonts
apply_fonts () {
    local count=1
    fonts_list=($(ls $FONTS_DIR))
    for fonts in "${fonts_list[@]}"; do
        echo ${bold_green}"[$count]${nc} ${fonts%.*}"
        count=$(($count+1))
    done

    { echo; read -p "Select font (1 to $total_fonts): " answer; echo; }

    if [[ (-n "$answer") && ("$answer" -le $total_fonts) ]]; then
        font_ttf=${fonts_list[(( answer - 1 ))]}
        echo "${bold}[*]${nc} Applying Fonts..."
        ln -sf $FONTS_DIR/$font_ttf $TERMUX_DIR/font.ttf
        { reload_settings; reset_color; return; }
    else
        echo -n "${bold_red}[!]${nc} Back to menu."
        { reset_color; echo; break; }
    fi
    return
}

# Random style
random_style () {
    echo "${bold}[*]${nc} Setting Random Style..."
    random_scheme=$(ls $COLORS_DIR | shuf -n 1)
    ln -sf $COLORS_DIR/$random_scheme $TERMUX_DIR/colors.properties
    { reload_settings; reset_color; return; }
}

# Main menu
until [[ "$REPLY" = "0" ]]; do
        active_color=`readlink $TERMUX_DIR/colors.properties`
        active_font=`readlink $TERMUX_DIR/font.ttf`
    banner
    echo "
${bold}Current color:${bold_yellow} ${active_color%.*}${nc}
${bold}Current font:${bold_yellow} ${active_font%.*}${nc}

${bold_green}[1]${nc} Colors ($total_colors)
${bold_green}[2]${nc} Fonts ($total_fonts)
${bold_green}[3]${nc} Random
${bold_red}[0]${nc} Quit
"

    { read -p "Select Option: "; echo; }

    if [[ "$REPLY" =~ ^[0-3]$ ]]; then
        if [[ "$REPLY" = "1" ]]; then
            apply_colors
        elif [[ "$REPLY" = "2" ]]; then
            apply_fonts
        elif [[ "$REPLY" = "3" ]]; then
            random_style
        fi
    else
        echo -n "${bold_red}[!]${nc} Invalid Option, Try Again."
    fi
done
{ echo "${bold_red}See you later!"; echo; reset_color; exit 0; }
