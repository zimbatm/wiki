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

        spec.imagePullSecrets."gitlab-registry" = { };
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
      accessModes = [ "ReadWriteOnce" ];
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
