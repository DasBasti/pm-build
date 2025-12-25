#!/bin/false

test_image_does_not_include_wpa_supplicant() {
    expect "wpa_supplicant is not included in the image. It collides with iwd"
    ! grep "wpa-supplicant" "$DEPLOY_DIR/images/$MACHINE/"*.manifest
}
