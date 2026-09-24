#!/usr/bin/env python3
"""Materialize a cluster: kustomize build + flux-operator build resourceset per RS.

Usage: render-resourcesets.py kubernetes/clusters/home > rendered.yaml
Non-RS objects (Namespaces, Secrets) pass through as-is; each ResourceSet
is rendered into its child Kustomizations.
"""
import subprocess
import sys
import tempfile

import yaml

cluster = sys.argv[1]
build = subprocess.run(
    ["kustomize", "build", "--load-restrictor", "LoadRestrictionsNone", cluster],
    capture_output=True, text=True, check=True,
)
for doc in yaml.safe_load_all(build.stdout):
    if not doc:
        continue
    if doc.get("kind") != "ResourceSet":
        print("---")
        print(yaml.dump(doc, sort_keys=False), end="")
        continue
    with tempfile.NamedTemporaryFile("w", suffix=".yaml") as f:
        yaml.dump(doc, f, sort_keys=False)
        f.flush()
        render = subprocess.run(
            ["flux-operator", "build", "resourceset", "-f", f.name],
            capture_output=True, text=True,
        )
    if render.returncode != 0:
        print(f"failed on {doc['metadata']['name']}: {render.stderr}", file=sys.stderr)
        sys.exit(1)
    print(render.stdout, end="")
