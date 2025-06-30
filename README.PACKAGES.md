# Package Installation

## Goals
The goals here are to make things as simple and clean as possible.

To that end, system packages are preferred **whenever possible**. Distros do a
reasonably good job of maintaining packages and keeping them working with the rest
of the system *most of the time*.

## Motivation
However, what I find the most frustrating is packages often break the longer you
depend on them. In rolling-release distros, this is usually because a package
updates its API in some breaking way and suddenly your configs don't work, or
some other program's integration doesn't work.
In fixed release distros, the problem is often the opposite: There isn't a new
enough version of package xyz for what you need, and you're stuck several versions
behind.

The end result is the same, though. You're left with a broken package, and the
only thing to do is upgrade your distro (difficult and fraught), pin the too-new
version (fraught), or build it from source (fraught mostly from an automation
perspective, and less so than the alternatives).

# Design

The primary function to install packages is `confound_package_install`. It takes
as its arguments the Confound Package Name and, as an optional second argument,
a minimum version (TODO: Also support maximum versions)

TODO: REVAMP THIS

WHY NOT JUST ADD A CUSTOM STEP INSTEAD OF OVERRIDING THINGS?





















`counfound_package_install` first looks in the `distro_packages` associative
array supplied by the `distros/<distroname>/packages.sh` file. If the Confound
Package Name has an entry, and that entry is not prefixed by `$CONFOUND_CUSTOM_PACKAGE_PREFIX` (by default `_confound_custom_`), it is installed by passing it to the distro's
package manager.

Most of the code for this is found in `resources.d/03-package-manager.sh`

If, however, the Confound Package Name does map to `$CONFOUND_CUSTOM_PACKAGE_PREFIX`
