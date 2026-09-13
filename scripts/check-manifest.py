#!/usr/bin/env python3
"""Fail when a brew cask/formula name also appears in any nix packages list."""
import json
import sys
from pathlib import Path

manifest = json.loads(Path(__file__).resolve().parent.parent.joinpath("config.json").read_text())
layers = [manifest.get(k, {}) for k in ("common", "linux", "darwin")]

def brew_name(entry: str) -> str:
    return entry.split()[0].rsplit("/", 1)[-1]

def nix_name(entry: str) -> str:
    return entry.removeprefix("unstable.").rsplit(".", 1)[-1]

brew = {brew_name(e) for layer in layers for e in layer.get("casks", []) + layer.get("brews", [])}
nix = {nix_name(e) for layer in layers for e in layer.get("packages", [])}

conflicts = sorted(brew & nix)
if conflicts:
    sys.exit(f"config.json: owned by both brew and nix: {', '.join(conflicts)}")
print(f"manifest ok: {len(brew)} brew, {len(nix)} nix, no dual ownership")
