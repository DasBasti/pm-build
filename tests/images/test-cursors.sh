#!/bin/false


test_cursor_theme_installed() {
    expect "that a cursor theme is installed in the image"

    # Search the image for cursor theme directories (*/usr/share/icons/*/cursors)
    matches=$(find $DEPLOY_DIR/images/$MACHINE/ -type d -path "*/usr/share/icons/*/cursors" 2>/dev/null)
    [ -n "${matches}" ] || { log_error "No cursor theme directories found in image"; fail; }

    pass
}
