# atomic-images

Custom Fedora Atomic images built with [BlueBuild](https://blue-build.org).

| Recipe | Image | Base |
| --- | --- | --- |
| `recipes/recipe-niri.yml` | `ghcr.io/rhizoet/niri` | `quay.io/fedora-ostree-desktops/base-atomic:44` |
| `recipes/recipe-kinoite.yml` | `ghcr.io/rhizoet/kinoite` | `quay.io/fedora-ostree-desktops/kinoite:44` |

## niri

[Niri](https://github.com/YaLTeR/niri) with [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
(DMS). Login via greetd + `dms-greeter`. No Waybar, Mako, Fuzzel or Swaylock: DMS provides bar, launcher,
notifications and lock screen. User configuration lives in `$HOME`, not in the image.

- RPM: niri, xwayland-satellite, dms, dms-greeter, dgop, matugen, cliphist, greetd, ghostty, nautilus, gnome-keyring,
  xdg-desktop-portal-gnome, micro, zsh, git, gcc, make, podman-docker
- Flatpak (Flathub, installed on first boot): Firefox, Celluloid (mpv + yt-dlp: video, audio, YouTube/livestream URLs),
  Loupe, Papers, File Roller, Text Editor, Calculator, Flatseal
- Homebrew with automatic update/upgrade timers
- removed: firefox (RPM), nano

Fedora 44 is pinned in the recipe; bump `image-version` manually once Fedora 45 is stable
(check that the COPR chroots exist).

## Updates

rpm-ostree stages new deployments in the background (`AutomaticUpdatePolicy=stage`); they apply on the next reboot.
Flatpaks and Homebrew update themselves.

## Install

```sh
rpm-ostree rebase ostree-unverified-registry:ghcr.io/rhizoet/niri:latest
systemctl reboot
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/rhizoet/niri:latest
systemctl reboot
```

After the first boot, `sysusers` has created the `greeter` user. Log in; Niri starts with the DMS default config from
`/etc/niri/` (a snapshot of what `dms setup` deploys, with Ghostty as terminal). It only applies while
`~/.config/niri/config.kdl` does not exist. Run `dms setup` (or apply your dotfiles) for a personal config, which also
enables DMS's dynamic theming of Niri.

## Maintainer

One-time setup:

1. `cosign generate-key-pair`; commit `cosign.pub` to the repo root and store `cosign.key` as the
   repository secret `SIGNING_SECRET`.
2. Set the ghcr.io packages to public.

CI (`.github/workflows/build.yml`) builds both recipes daily and on every push to `main`.

Local build / ISO via the containerized bluebuild CLI (see `justfile`):

```sh
just setup      # once: installs the bluebuild wrapper
just validate
just build niri
just iso niri        # installer ISO from the published image
just iso-local niri  # installer ISO built locally, no push needed
```

Renaming the GitHub repo changes nothing for the images: their names come from `name:` in the recipes.
