#!/usr/bin/env bash
#
# Renders the Kubernetes manifest as YAML
set -euo pipefail

domain=${KUBE_INGRESS_BASE_DOMAIN:-myorg.net}

app=${CI_ENVIRONMENT_SLUG:-myorg}
hostname=${app}.${domain}
imageTag=${CI_COMMIT_SHA:-$(git rev-parse HEAD)}

# JSON is valid yaml
toYAML() { cat; }

if type -p ruby &>/dev/null ; then
toYAML() {
  ruby -ryaml -rjson -e 'puts YAML.dump(JSON.load(ARGF))'
}
fi

nix-instantiate "$(dirname "$0")/default.nix" \
  --eval --strict --json \
  --argstr app "$app" \
  --argstr hostname "$hostname" \
  --argstr imageTag "$imageTag" \
  | toYAML
