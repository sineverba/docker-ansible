#!/usr/bin/env python3
import sys

import yaml


def main():
    interfaces = sys.argv[1].split(",")
    netplan_files = sys.argv[2:]

    any_changed = False
    for path in netplan_files:
        with open(path) as f:
            config = yaml.safe_load(f) or {}

        ethernets = (config.get("network") or {}).get("ethernets") or {}
        changed = False
        for iface in interfaces:
            entry = ethernets.get(iface)
            if entry is None:
                continue
            if entry.get("optional") is not True:
                entry["optional"] = True
                changed = True

        if changed:
            with open(path, "w") as f:
                yaml.safe_dump(config, f, default_flow_style=False, sort_keys=False)
            print(f"changed:{path}")
            any_changed = True

    if not any_changed:
        print("ok")


if __name__ == "__main__":
    main()
