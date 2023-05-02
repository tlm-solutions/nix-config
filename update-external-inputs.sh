#!/bin/sh

# Updates all the non-tlms inputs. Can be run against release (or
# whatever have you) without being afraid of pulling in a broken
# master of a service

nix flake lock \
    --update-input nixpkgs \
    --update-input naersk \
    --update-input microvm \
    --update-input sops-nix \
    --update-input flake-utils
