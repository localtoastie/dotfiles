# Nix home-manager config

Home-manager configuration for my machines, built as a Nix flake. One shared
base, plus layers for the OS and for each host.

| Host             | System         | Layers                                     |
| ---------------- | -------------- | ------------------------------------------ |
| `thundercracker` | x86_64-linux   | common, linux, redhat, host                |
| `shockwave`      | x86_64-linux   | common, linux, redhat, host (work machine) |
| `skywarp`        | aarch64-darwin | commented out in `flake.nix`               |

## Layout

```
nix/
├── flake.nix            # inputs and one homeConfigurations entry per host
├── justfile             # everyday commands (see below)
├── home/
│   ├── common.nix       # every machine: CLI tools, shell, git, prompt
│   ├── linux.nix        # Linux only: GUI apps via nixGL, ssh agent config
│   └── redhat.nix       # Red Hat family only: podman
├── hosts/
│   └── <hostname>/
│       ├── default.nix      # host module, loaded automatically for the directory
│       ├── aws-config.tpl   # ~/.aws/config template with 1Password references
│       ├── ssh-key.pub      # public half of the host's 1Password ssh key
│       └── zsh-functions/   # optional host-only zsh functions
├── zsh-functions/       # zsh functions for every machine
├── git/                 # commit template and git helper scripts
└── starship/            # prompt config
```

Each host entry in `flake.nix` lists its layers:

```nix
"victor@shockwave" = mkHome {
  system = "x86_64-linux";
  username = "victor";
  extraModules = [ ./home/linux.nix ./home/redhat.nix ./hosts/shockwave ];
};
```

## How the layers combine

Every module sets options and the module system combines them:

- Lists and attribute sets merge. `home.packages`, `programs.zsh.shellAliases`
  and `programs.ssh.settings` from a host are added to the shared ones.
- Single values conflict. If two modules set the same string option (or the
  same key inside an attribute set) to different values, evaluation fails
  with "conflicting definitions". Wrap the value that should win in
  `lib.mkForce`.

## Everyday commands

Run these from `nix/`. They pick the config from `whoami` and `hostname -s`.

| Command            | What it does                                            |
| ------------------ | ------------------------------------------------------- |
| `just switch`      | Build and activate this host's config                   |
| `just build`       | Build without activating, to check it                   |
| `just aws-config`  | Render `~/.aws/config` from 1Password (see below)        |
| `just news`        | Show unread home-manager news                           |
| `just generations` | List home-manager generations                           |
| `just clean`       | Garbage-collect old generations and store paths         |

To check a host's config evaluates without building or downloading anything
(useful when you are not on that host):

```sh
nix eval --raw '.#homeConfigurations."victor@shockwave".activationPackage.drvPath'
```

The flake only sees files git knows about. After adding a file, `git add` it
or Nix reports it as missing.

## Setting up a new machine

1. Install Nix with flakes enabled.
2. Clone this repo and `cd nix`.
3. Make sure the host has an entry in `flake.nix` and a `hosts/<hostname>/`
   directory (see the next section).
4. First switch, before home-manager or just are installed:
   ```sh
   nix run home-manager/master -- switch --flake .#$(whoami)@$(hostname -s)
   ```
   Existing files that home-manager takes over, such as `~/.ssh/config`, are
   renamed with a `.hm-backup` suffix rather than deleted.
5. Sign in to the 1Password desktop app and turn on Settings → Developer →
   "Use the SSH agent".
6. Sign in the CLI (`eval $(op signin)`), then run `just aws-config`.

## Adding a host

1. Create `hosts/<hostname>/default.nix`. The smallest useful version:
   ```nix
   { ... }:

   {
     xdg.configFile."1Password/ssh/agent.toml".text = ''
       [[ssh-keys]]
       vault = "Personal"
     '';
   }
   ```
2. Add an entry to `homeConfigurations` in `flake.nix` with the layers it
   needs. The key must be `<username>@<short hostname>` for `just` to find it.
3. Add `aws-config.tpl` and `ssh-key.pub` if the host uses AWS or GitHub.
   Copy an existing host's `default.nix` for the ssh and git signing blocks.

## Per-host customization

All of these go in `hosts/<hostname>/default.nix`.

- **Packages:** add to `home.packages`.
- **Aliases:** add to `programs.zsh.shellAliases`. They are zsh only; set
  `programs.bash.shellAliases` too for bash.
- **Zsh functions:** put one function per file in `hosts/<hostname>/zsh-functions/`
  and mark it executable. The host module links the directory to
  `~/.config/zsh/functions-<hostname>` and adds it to `fpath` with
  `lib.mkOrder 490`, which must stay below the `mkOrder 500` autoload loop
  in `common.nix` or the functions will not load.
- **Git email:** shockwave uses `programs.git.includes` with `gitdir:`
  conditions so only repos under the listed directories commit with the work
  email. Everything else keeps the email from `common.nix`.

## Secrets

Anything Nix evaluates ends up in `/nix/store`, which every user on the machine
can read. Secret values therefore never go through Nix; they stay in 1Password
and are filled in on the machine.

### AWS config

`~/.aws/config` is not managed by home-manager. Each host has an
`aws-config.tpl` with the real values replaced by 1Password references:

```ini
sso_account_id = {{ op://Work/aws-sso/dev-account-id }}
```

`just aws-config` runs `op inject` to write the rendered file with `0600`
permissions. It refuses to run if `op` is not signed in, or if `~/.aws/config`
is still a home-manager symlink (run `just switch` first). Run it again after
changing a template; `just switch` does not touch the AWS config.

### SSH keys

Private keys live in 1Password and are served by its SSH agent. They are never
written to disk.

- `home/linux.nix` writes `~/.ssh/config` with `IdentityAgent
  ~/.1password/agent.sock` for all hosts, and an `Include ~/.ssh/config.local`
  at the top for per-machine hosts that should not be committed.
- Each host's `agent.toml` limits the agent to one vault, so work and personal
  keys stay on their own machines.
- `ssh-key.pub` is the public key. It is linked into `~/.ssh/` and used with
  `IdentitiesOnly yes` for `github.com`, so ssh offers only that key.
- Git signs every commit and tag with the same key through 1Password's
  `op-ssh-sign`. For GitHub to show commits as Verified, add the public key to
  GitHub a second time with key type "Signing Key".

To list the keys the agent offers:

```sh
SSH_AUTH_SOCK=~/.1password/agent.sock ssh-add -L
```

The 1Password app must be running and unlocked for ssh, git over ssh and
commit signing to work. Over a remote ssh session into the machine, use agent
forwarding from the machine you are on.

## Linux notes

These machines are not NixOS, so GUI apps installed by Nix need OpenGL
wrappers. `home/linux.nix` sets up nixGL and wraps Ghostty with
`config.lib.nixGL.wrap`; do the same for other GPU-using apps.
