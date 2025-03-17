#!/usr/bin/env bash

# Exposes a function called native_pkg_install() that provides a system-agnostic
# interface to using the native package manager.
# This works by defining a packages.sh file in the PACKAGES_DIR directory, and then
# a corresponding <distro>.sh file in the same PACKAGES_DIR directory. Further details
# are given therein.

source "$PACKAGES_DIR/packages.sh"
