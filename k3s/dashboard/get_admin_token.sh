#!/bin/bash

set -euo pipefail

kubectl -n kubernetes-dashboard \
  describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
