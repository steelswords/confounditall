# Confounditall - A Config Manager

Confounditall (Or simply confoundit or confound) is a shell script framework
to manage your configuration between machines. That means both files and
programs!

## Background

Managing dotfiles in itself isn't too bad, until you try to keep them in sync
across several machines. Then it becomes a horrendous chore.
For instance, since 2019 I've had at least a personal laptop (or two or three), a
personal desktop, a work computer, and several less-used Linux machines, be it
servers, Raspberry Pis, whathaveyou.

I gave Nix an honest go for about three months prior to writing this. But the
added complexity of Nix wasn't getting me the flexibility or the reliability I
needed. I found myself sometimes just *struggling* with the language and the
system, just in order to get something working between the schtuff I had
installed natively and the programs I installed through home-manager.

"Why am I fighting this system so hard to give me what I want? I just want my
dotfiles to be symlinked to my configs repo and certain programs to be installed
to recent, stable versions. I don't need to bork my whole system occasionally
because of libc conflicts for that!"

And thus, ConfoundItAll was born.

# Usage

The typical usage Confound expects is:
- You have a repo of dotfiles, configs, whatever.
- You add Confound to that dotfiles repo as a submodule
- You add a directory of scripts that imperatively set up your system
- You add a confound.conf file that declares where the Confound submodule is and
  where your setup steps directory is
- Write a script in your dotfiles repo that calls the `setup.sh` script in the
  Confound subdirectory, passing the `confound.conf` file you created earlier.

That's it!

This is perhaps better illustrated with an annotated script:

```bash
#!/usr/bin/env bash

# Standard bash script boilerplate I include in just about every script
set -u -e -o pipefail
trap "echo 'An error occurred! Quitting mid-script!'" ERR


# Exporting some environment variables that will be used in your user steps
# See "Configuring," below for a catalogue of environment variables and their
# usage in Confound.
# USER_CONFIG_REPO_DIR represents the directory your top-level configs repo is
in.
export USER_CONFIG_REPO_DIR="$( realpath . )"

# We call confound's setup.sh script with the confound.conf configuration file
# as the first argument. Confound takes care of the rest!
./confounditall/setup.sh confound.conf
```

And an example `confound.conf` file:
```bash
CONFOUND_DIR="$(realpath confounditall)"
USER_STEPS_DIR="confound.d"
```

# Configuration

Confound is governed by a few config values and one environment variable

## Configuration Values: What Goes in confound.conf?

| Parameter Name | Description | Default Value |
|----------------|-------------|---------------|
| CONFOUND_DIR | The directory for the confounditall repo/submodule | The repo from which Confound's `setup.sh` is called. |
| PACKAGES_DIR | The directory for distro support. See "Support for Multiple Distros", below. | `$CONFOUND_DIR/distros` |
| USER_STEPS_DIR | The directory where your setup steps are located. | `$USER_CONFIG_REPO_DIR/user-steps.d` |
| SECRETS_FILE | A sops secrets file. See "Secrets with sops, below". |`$USER_CONFIG_REPO_DIR/secrets/secrets.json` |
| USER_CONFIG_REPO_DIR | The directory that holds your config files and user steps. | *unset* |

## USER_CONFIG_REPO_DIR
I recommend you export this as an environment variable instead of putting
it in your `confound.conf` file.

# Support for Multiple Distros

TODO

Also TODO: This is broken at the moment.

# Bash Functions Provided by Confound

TODO: Document

## `confound_package_update_upgrade`

This is a the distro-agnostic, Confound way of doing an `apt update && apt upgrade`
or a `pacman -Syu`.

**Arguments:** none.

## `confound_package_install`

This installs a package through the distro's package manager.

**Arguments:**
- `$1`: The Confound package name. This is usually, but not necessarily, the same
    as Ubuntu's names for packages. This is translated to a distro-specific
    equivalent if such is defined in the `distro_packages` array. (See "Support
    for Multiple Distros, above"). If `$1` is NOT in the `distro_packages` array
    for the detected distro, `$1` is passed as the native package name to the
    distro package manager.

## `confound_ln`
## `confound_get_secret`

# Securely storing secrets with Sops
Confound uses [sops](https://github.com/getsops/sops) for secret management. Sops
is nice because when set up properly, it automagically keeps your secrets in a
JSON or YAML (or other) file, with just the secret parts encrypted. That means
you have a secrets file that's easy for git and diff to work with, but all your
secrets remain encrypted.

TODO: Document setup.

The default place for your secrets file is in `$USER_CONFIG_REPO_DIR/secrets/secrets.json`.
You can place it elsewhere if you also define and export a `SECRETS_FILE` variable
with the location of your secrets file before sourcing Confound.
