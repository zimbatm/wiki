---
date: 2021-02-19T15:46
---

# Kubernetes is a lie

A small collection of rants and observations about Kubernetes :)

## Connascence

> Connascence (/kəˈneɪsəns/) is a software quality metric invented by Meilir
> Page-Jones to allow reasoning about the complexity caused by dependency
> relationships in object-oriented design much like coupling did for
> structured design. In software engineering, two components are connascent if
> a change in one would require the other to be modified in order to maintain
> the overall correctness of the system. In addition to allowing
> categorization of dependency relationships, connascence also provides a
> system for comparing different types of dependency. Such comparisons between
> potential designs can often hint at ways to improve the quality of the
> software.
source: [Wikipedia](https://en.wikipedia.org/wiki/Connascence)

The resources described in k8s often have a strong relationship between
each-other. But are loosely combined in the YAML code. A classic example is
a Service matching on Pod labels. Cert-manager provisioning a Secret
resource and the pod has to make sure to mount the same name.

You have a collection of resources that are connected to each-other, but their
relationship is not obvious.

The side-effect of that is that:

1. Inevitably YAML gets replaced by some sort of templating language to try
   and enforce those invariants. But this is not enough.
2. Because the resources are eventually available it's hard to know if a
   deployment succeeded or not.
3. As a devops person, something that should be boring is now very intense;
   remember that this and this resource has been patched and depends on XYZ.

## The abstraction is a lie

Kubernetes pretends that it abstracts away the platform. This is a lie.

Pretty much every deployment will rely on metadata annotations. These are
little snippets of extra config that is platform-specific.

It's even in the official documentation:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: minimal-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: Prefix
        backend:
          service:
            name: test
            port:
              number: 80
```
[source](https://kubernetes.io/docs/concepts/services-networking/ingress/)

## Complexity explosion

A platform truly fails when it is not able to curtail complexity.

If you deploy k8s, pretty soon your DevOps people will want to deploy Istio,
Knative, monitoring in a second cluster, ... The platform has reached a
critical mass of complexity that generates its own complexity.

## Low observability

Everybody who starts with kubernetes is hit with this issue: a pod didn't
start. How can I track the issue? The answer should be: connect to and read
the logs.

The pod might fail because of an ImagePullBackOff, which only appears in the
events, not in the pod logs.
