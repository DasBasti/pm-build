#!/bin/false

source "$SCRIPT_DIR/.framework/colors.sh"

# Log functions that respect verbose flag
log_info() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${COLOR_BLUE}$@${COLOR_RESET}"
    fi
}

log_warning() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${COLOR_YELLOW}$@${COLOR_RESET}"
    fi
}

log_error() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${COLOR_RED}$@${COLOR_RESET}"
    fi
}

log_console() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${COLOR_RESET}$@"
    fi
}

log_success() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${COLOR_GREEN}$@${COLOR_RESET}"
    fi
}
