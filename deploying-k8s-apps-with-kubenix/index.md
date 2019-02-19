---
title: Deploying Kubernetes apps with KubeNix
date: 2019-02-20
---

Tired of writing YAML templating (:wink: Helm) and like Nix?

Give [KubeNix](https://github.com/xtruder/kubenix) a try.

The documentation behind it is still quite sparse but the tech behind is
great. What is does is:

* load the official swagger API spec
* generates Nix modules options from it
* take your module configuration
* generate valid Kubernetes resource definitions in JSON

This gives greater confidence in the generated output than Helm that just
bangs strings together. And all the power of a real language is available.

## Working example

Here is a simple deployments with one service, and ingress and a PVC described
in Nix. Everything is defined as a single file but it could easily be split
into multiple files.

[$ configuration.nix](configuration.nix)
```nix
# This file describes all the resources that we want to deploy
{ app
, hostname
, imageTag
}:
let
  registry = "registry.gitlab.com/myorg/myproject";
  labels = {
    app = app;
  };
  serverPort = 65432;
  claimName = "${app}-server-data";
  pullSecretName = "${app}-gitlab-registry";
in
{
  kubernetes.version = "1.11";

  kubernetes.resources.deployments."${app}-server" = {
    metadata.labels = labels;
    spec = {
      replicas = 1;
      strategy.type = "Recreate";
      selector.matchLabels = labels;
      template = {
        metadata.labels = labels;
        spec.volumes."server-data".persistentVolumeClaim.claimName = claimName;

        spec.imagePullSecrets."gitlab-registry" = {};
        spec.containers.server = {
          name = "${app}-server";
          image = "${registry}/server:${imageTag}";
          imagePullPolicy = "IfNotPresent";
          env.FOO = { value = "BAR"; };
          ports."${toString serverPort}" = { name = "http"; };
          resources.requests.cpu = "100m";
          livenessProbe = {
            httpGet = {
              path = "/ping";
              port = "http";
            };
          };
          readinessProbe = {
            httpGet = {
              path = "/ping";
              port = "http";
            };
          };
          volumeMounts."/data" = { name = "server-data"; };
        };
      };
    };
  };

  kubernetes.resources.persistentVolumeClaims."${claimName}" = {
    metadata.labels = labels;
    spec = {
      resources.requests.storage = "5Gi";
      # ReadWriteOnce – the volume can be mounted as read-write by a single node
      accessModes = ["ReadWriteOnce"];
    };
  };

  kubernetes.resources.services."${app}-server" = {
    metadata.labels = labels;
    spec.selector = labels;
    spec.ports."80" = {
      name = "http";
      targetPort = serverPort;
    };
  };

  kubernetes.resources.ingresses."${app}-ingress" = {
    metadata.labels = labels;
    metadata.annotations = {
      "ingress.kubernetes.io/ssl-redirect" = "true";
      "kubernetes.io/tls-acme" = "true";
      "kubernetes.io/ingress.class" = "nginx";
    };
    spec.tls = [
      {
        hosts = [ hostname ];
        secretName = "${app}-tls";
      }
    ];
    spec.rules = [
      {
        host = hostname;
        http.paths = [
          {
            path = "/";
            backend = {
              serviceName = "${app}-server";
              servicePort = 80;
            };
          }
        ];
      }
    ];
  };
}
```

This takes the configuration and passes it through kubenix:

[$ default.nix](default.nix)
```nix
{ app
, hostname
, imageTag
}@args:
let
  kubenix-src = builtins.fetchTarball {
    url = "https://github.com/xtruder/kubenix/archive/9acf125f74b9ce7d65b77f33294e65f275b5bc31.tar.gz";
    sha256 = "06z55z4zg8shim3zgkz7j7zkhb9cwm2da9wwh5sf3is7isgyh471";
  };
  kubenix = import kubenix-src {};

  configuration = import ./configuration.nix args;

  manifest = kubenix.buildResources {
    inherit configuration;
    writeJSON = false;
  };
in
  manifest
```

And finally, a wrapper script for convenience to tie everything together:

[$ render.sh](render.sh)
```sh
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
```

And this is how the output looks like. This is now something that can be
passed straight to `kubectl apply`:

`$ ./render.sh`
```yaml
---
apiVersion: v1
items:
- apiVersion: apps/v1beta2
  kind: Deployment
  metadata:
    labels:
      app: myorg
      kubenix/build: 2e1b2ab155a59aa591f9a851cdef5a97b6f5158f
    name: myorg-server
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: myorg
    strategy:
      type: Recreate
    template:
      metadata:
        labels:
          app: myorg
      spec:
        containers:
        - env:
          - name: FOO
            value: BAR
          image: registry.gitlab.com/myorg/myproject/server:cf94dbc1736d7cf0c7272d10fe351d2893eef367
          imagePullPolicy: IfNotPresent
          livenessProbe:
            httpGet:
              path: "/ping"
              port: http
          name: myorg-server
          ports:
          - containerPort: 65432
            name: http
          readinessProbe:
            httpGet:
              path: "/ping"
              port: http
          resources:
            requests:
              cpu: 100m
          volumeMounts:
          - mountPath: "/data"
            name: server-data
        imagePullSecrets:
        - name: gitlab-registry
        volumes:
        - name: server-data
          persistentVolumeClaim:
            claimName: myorg-server-data
- apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      ingress.kubernetes.io/ssl-redirect: 'true'
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: 'true'
    labels:
      app: myorg
      kubenix/build: 2e1b2ab155a59aa591f9a851cdef5a97b6f5158f
    name: myorg-ingress
  spec:
    rules:
    - host: myorg.myorg.net
      http:
        paths:
        - backend:
            serviceName: myorg-server
            servicePort: 80
          path: "/"
    tls:
    - hosts:
      - myorg.myorg.net
      secretName: myorg-tls
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    labels:
      app: myorg
      kubenix/build: 2e1b2ab155a59aa591f9a851cdef5a97b6f5158f
    name: myorg-server-data
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: 5Gi
- apiVersion: v1
  kind: Service
  metadata:
    labels:
      app: myorg
      kubenix/build: 2e1b2ab155a59aa591f9a851cdef5a97b6f5158f
    name: myorg-server
  spec:
    ports:
    - name: http
      port: 80
      targetPort: 65432
    selector:
      app: myorg
kind: List
labels:
  kubenix/build: 2e1b2ab155a59aa591f9a851cdef5a97b6f5158f
```

## Conclusion

The example is a bit raw but hopefully gives you an idea of what KubeNix can
do.
