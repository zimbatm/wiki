![alpacasay](img/alpacasay.png)

This website is my personal scratchpad. See [about](about.md) for more info on
the website.

## Posts

* [Benchmarking nixpkgs builds](benchmark-nixpkgs)
* [Recursive Nix experiment](experiment-recursive-nix)
* [Deploying Kubernetes apps with KubeNix](deploying-k8s-apps-with-kubenix)

## Current projects

* [nixpkgs-fmt](https://nix-community.github.io/nixpkgs-fmt)

## Past projects

* Planning [NixCon 2018](https://nixcon2018.org)

## Maintained projects

* [BuiltWithNix](BuiltWithNix.md)
* [Hostnames and usernames to reserve](https://zimbatm.github.io/hostnames-and-usernames-to-reserve/)
* [direnv](https://direnv.net) - per directory environment variables
* [docker-nixpkgs](https://github.com/nix-community/docker-nixpkgs) - docker images straight out of nixpkgs
* [github-deploy](https://github.com/zimbatm/github-deploy) - Track deployments on GitHub PRs
* [h](https://github.com/zimbatm/h) - faster shell navigation of projects
* [logmail](https://github.com/zimbatm/logmail) - sendmail to syslog
* [mdsh](https://github.com/zimbatm/mdsh) - markdown shell pre-processor
* [nixbox](https://github.com/nix-community/nixbox) - NixOS Vagrant boxes
* [shab](https://github.com/zimbatm/shab) - full template engine in 4 lines of bash
* [socketmaster](https://github.com/zimbatm/socketmaster) - zero downtime services restarts 
* [terraform-nixos](https://github.com/tweag/terraform-nixos) - Deploy NixOS with Terraform
* [more...](https://github.com/zimbatm?utf8=%E2%9C%93&tab=repositories&type=source)

## Journalling

{% for post in site.posts %}
* [{{ post.date | date: "%Y-%m-%d" }} - {{ post.title }}]({{ post.url | prepend: site.baseurl }})
{% endfor %}
