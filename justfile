# Local builds via the bluebuild CLI (`just setup` installs a podman-based wrapper, no host packages needed)
image := "niri"
owner := "rhizoet"

default:
    @just --list

# Install the bluebuild CLI (runs it in a container)
setup:
    podman run --pull always --rm ghcr.io/blue-build/cli:latest-installer | bash

# Validate all recipes
validate:
    for r in recipes/recipe-*.yml; do bluebuild validate "$r"; done

# Build a recipe locally, e.g. `just build niri`
build recipe=image:
    bluebuild build recipes/recipe-{{recipe}}.yml

# Installer ISO from the published image (needs a pushed, public image), e.g. `just iso niri`
iso recipe=image:
    mkdir -p output
    bluebuild generate-iso --output-dir output --iso-name {{recipe}}.iso image ghcr.io/{{owner}}/{{recipe}}

# Installer ISO built locally from the recipe (builds the image first, no push needed)
# Runs rootful via sudo as documented by BlueBuild; the ISO is chowned back to you afterwards
iso-local recipe=image:
    mkdir -p output
    sudo bluebuild generate-iso --output-dir output --iso-name {{recipe}}.iso recipe recipes/recipe-{{recipe}}.yml
    sudo chown -R "$(id -u):$(id -g)" output
    @ls -lh output/{{recipe}}.iso

# One-time: create the signing key pair in a container (cosign.pub is committed, cosign.key becomes the SIGNING_SECRET secret)
keygen:
    podman run --rm -it --user root -v "$PWD":/work:Z -w /work ghcr.io/sigstore/cosign/cosign:latest generate-key-pair
