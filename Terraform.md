I have been working with [Terraform](https://terraform.io) for more than a year now and have gained a number of experiences. Here are some notes around it.
# Design patterns
There are a couple of notes on designing Terraform modules.
## Resource-prefixing
Cloud resources often require their name to be unique in the scope of the account (ie: Google Cloud instances), or globally (ie: S3 buckets). When composing Terraform modules, we therefor want to ensure that the resources declared in that module don't clash with other instances of that same module.

A common strategy to work around that issue is to request a "name" or "prefix" input variable, and then use that to prefix all of the inner resources.

Eg:
```tf
variable "name" {}

resource "google_compute_instance" "default" {         
  name = "${var.name}-default"
  # ...
}
```

Like that, when that module is instantiated multiple times, a different "name" argument can be passed.

This also makes modules more composable as the "name" attribute can be passed to sub-modules:
```tf
variable "name" {}

module "other_module" {
  source = "..."
  name = "${var.name}-other-module"
}
```
NOTE(1): try to only pass `[a-z]` and dashes to the name as many resources have some further limitations on valid values.
NOTE(2): some resources also have a length limitation on their names, so nesting too deep or passing really long names should be considered carefully.
## Tag all of the things
The big cloud providers often provider a facility to tag/label their resources. This should be encouraged. The value is not immediately apparent. It will become handy to figure out what exploded the AWS billing, to enforce AWS Config security and just to keep track of which resource belongs to which project in general.

When designing a shared module, add a `tags` argument, and then use that value to tag all of the inner-resources.
```tf
variable "name" {}
variable "tags" {
  type = map(string)
  default = {}
}

resource "aws_s3_bucket" "store" {
  bucket = "${var.name}-store
  acl    = "private"
  tags = merge(var.tags, {
    Name        = "${var.name} Store"
  })
}

```
## Composition through parameter injection instead of sub-modules
When composing Terraform modules, it is best to keep the hierarchy as flat as possible. For reasons that will be described below.

Instead of nesting modules, initialize all the modules in the root modules and plug them together by passing their outputs back into the other module inputs:
```tf
module "a" {
  // ...
}

module "b" {
  // ...
  some_var = module.a.some_var
}
```

This leads to more code as the parameters are being passed around. But I think it's worth it, based on my own experience.

If I try to formulate the reasons, I would say that the main one is code agility. Because Terraform resources are usually state, it's quite difficult to move them around. By having all the modules in the top-level it becomes easier to swap out module A without having to rewrite B. Which also leads to more flexible and re-usable code.

The resource-prefixing as described in the other section is also easier to handle when hitting size constraints on the resource names.

## Never declare providers in shared modules
The main reason is that when the provider is removed, Terraform will fail to run a plan, because all the resources in the module are tied to a provider that doesn't exist anymore. This is the type of lesson that you will only learn once it's too late.

Instead, initialize all the providers in the root module, and then pass them explicitly around. See https://www.terraform.io/docs/configuration/modules.html#providers
As in the previous chapter, the solution requires more code, but it's worth it.

Another reason I learned from @draganm is that each provider definition spawns a new binary of said provider. In a scenario where 50 modules, 50 providers would be running in memory.

# TODO
* Talk about the Terraform state bootstrapping problem.

# Glossary

* Root module: a top-level Terraform module. That module holds the state and typically contains a `terraform { backend }` configuration.
* Shared module: a Terraform module that is designed to be instantiated by other Terraform modules.