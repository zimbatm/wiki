# Notes on Matrix

Matrix is a set of standards that implement chat. It has nice properties like
federation that allows it to be decentralized.

Another nice property is that Matrix actively supports bridging to other chat
platforms like Slack, Signal, WhatsApp, ...

My hope for NumTide is that we can replace Slack with Matrix as NumTide is an
OSS company and it would work best in our ethos. It would also make it easier
or people to join conversations with us, assuming they have a Matrix account.

## Overview

Ideally it would be possible to get your own instance in one-click. And have
maintenance be close to zero for small instances. I don't think we are quite
there yet.

### Server administration

The main implementation is the
[synapse](https://github.com/matrix-org/synapse/) server. This is the only
implementation that handles all the protocols AFAIK.

The synapse server lacks an administrative interface to add/remove users, deal
with spam, ... A lot of these things are done either through the CLI, or by
tweaking a very large YAML file.

Backup and restore is not documented. A common theme among self-hosting. I
don't know why we keep pretending that servers will keep running
indefinitely.

Things like running bridges, bots, ... are all custom extra deployments.
Bridges tend to also have state which requires extra backup and restore
configuration.

Servers can have admins that have extra powers like creating new rooms and
communities (groups of rooms). Kick people out. It looks like users have to
have an account on the given server to become an admin. I was hoping that
since this is a federated systems, users could have their own server and
manage multiple federated systems with their single account.

### User interface(s)

The only client that implements the full set of UI extensions is the elements
client, which is also developed by the main Matix guys.

The UI is rather confusing. Admins can create "Communities", which is a set of
rooms. It's not clear how this can be used. It also looks like rooms cannot be
destroyed, which makes it hard to experiment.

## Things I want to do

### Deploy a Matrix server for numtide.com

It looks like it's running. I still have to configure backup and restore.

### Public rooms for OSS projects

It would be nice if there was a web widget on the website that people can use
to join the conversation, without having to register or anything. Then only
register if they want to create an identity.

### Setup a bridge between Slack and Matrix

TODO: do some research

## More thoughts

The best thing about email and IRC, is that users can backup chat histories.
At the moment it looks like Matrix clients are held hostage by the server and
would lose all their history if they get banned or the server shuts down.

Assuming that every user has their own domain and Matrix server, federation
needs to work really well. An has to handle spam really well. Right now, the
server is missing a lot of tooling to debug, accept/kick users and automate
spam filtering. There are some capabilities that are configurable in the fat
YAML file.

## Useful links

* Documentation sample: https://github.com/matrix-org/synapse/blob/develop/docs/sample_config.yaml
* Federation tester: https://federationtester.matrix.org/api/report?server_name=numtide.co
