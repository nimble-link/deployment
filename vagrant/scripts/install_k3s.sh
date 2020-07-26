#!/bin/bash

set -euo pipefail

echo "=== Install k3s ==="

curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s -

echo "=== Successfully install k3s ==="
