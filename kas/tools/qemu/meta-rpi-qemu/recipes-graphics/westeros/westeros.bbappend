do_install:append:raspberrypi4 () {
    # so no shell syntax, exports or script sourcing allowed — KEY=VALUE only).
    if [ -f ${D}${sysconfdir}/default/westeros-env ]; then
        echo 'WESTEROS_DRM_CARD=/dev/dri/card0' >> ${D}${sysconfdir}/default/westeros-env
        echo 'LD_PRELOAD=/usr/lib/libwesteros_gl.so.0.0.0' >> ${D}${sysconfdir}/default/westeros-env
        echo 'WESTEROS_GL_USE_PREFERRED_MODE=1' >> ${D}${sysconfdir}/default/westeros-env
        echo 'WESTEROS_GL_GRAPHICS_MAX_SIZE=1280x720' >> ${D}${sysconfdir}/default/westeros-env
        echo 'RDKSHELL_SET_GRAPHICS_720=1' >> ${D}${sysconfdir}/default/westeros-env
        echo 'WESTEROS_GL_USER_PREFERRED_SIZE=1280x720' >> ${D}${sysconfdir}/default/westeros-env
    fi
}
