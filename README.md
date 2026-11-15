# dotfiles

My machine setup. The configuration itself is a Nix home-manager flake; see
[nix/README.md](nix/README.md) for how it is organised, the everyday commands
and how secrets are handled.

This page covers preparing a fresh machine before the first home-manager
switch.

## 1. Install Nix

Use the Determinate Systems installer. It enables flakes by default and
includes an uninstaller (`/nix/nix-installer uninstall`).

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a new shell afterwards so `nix` is on your `PATH`, then check it:

```sh
nix --version
```

## 2. Install just, git and zsh (Linux)

These come from the system package manager rather than Nix: git is needed to
clone this repo, zsh has to be a system shell to be a login shell, and just
runs the commands in `nix/justfile`.

Fedora:

```sh
sudo dnf install just git zsh
```

RHEL, Rocky or Alma (just comes from EPEL):

```sh
sudo dnf install epel-release
sudo dnf install just git zsh
```

Debian, Ubuntu or Pop!_OS:

```sh
sudo apt install just git zsh
```

## 3. Set the hostname

`just` picks the config named `<username>@<short hostname>` from
`nix/flake.nix`, so the hostname must match a host there (for example
`shockwave` or `thundercracker`).

```sh
sudo hostnamectl set-hostname shockwave
hostname -s    # should print the new name
```

Open a new terminal so the shell picks up the change.

## 4. Make zsh the default shell

Use the system zsh, not the one home-manager installs. The system one is listed
in `/etc/shells` and keeps working even if the Nix profile breaks.

```sh
grep zsh /etc/shells          # confirm it is listed
chsh -s "$(command -v zsh)"
```

Log out and back in for it to take effect, then check:

```sh
echo $SHELL
```

## 5. Clone and switch

```sh
git clone <this repo> ~/git/localtoastie/dotfiles
cd ~/git/localtoastie/dotfiles/nix
nix run home-manager/master -- switch --flake .#$(whoami)@$(hostname -s)
```

After the first switch, use `just switch`. Then follow the 1Password and AWS
steps in [nix/README.md](nix/README.md#setting-up-a-new-machine).

## Known issues

### COSMIC greeter

None recorded yet.

<!--
Copy this for each issue:

#### Short description of the problem

- Ticket: https://github.com/pop-os/cosmic-greeter/issues/NNN
- Affects: hosts / versions where it happens
- Symptoms: what you see
- Workaround: steps that get around it
- Status: open / fixed in <version>
-->
