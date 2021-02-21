# Notes on Matrix

Matrix is a set of standards that implement chat. It has nice properties like
federation that allows it to be decentralized.

Another nice property is that Matrix actively supports bridging to other chat
platforms like Slack, Signal, WhatsApp, ...

My hope for [NumTide](NumTide.md) is that we can replace Slack with Matrix as
NumTide is an OSS company and it would work best in our ethos. It would also
make it easier or people to join conversations with us, assuming they have a
Matrix account.

## Critique

I really want Matrix to succeed. This criticism is meant as a form of
encouragement and inspiration to improve things.

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

Since the server is federated, I am quite certain that spam is going to become
a problem. Yet the server doesn't provide a solution out of the box. To be
faire there is a spam filter in the big YAML that can be configured but it's
yet another hoop to jump.

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

### Communities

Probably the most confusing aspect of Matrix. Communities have the notation `+<name>:<server>`. Eg: `+oss:numtide.com`.

A community is a landing page, and a list of rooms. Rooms can belong to multiple communities.

NOTE: apparently there is a communities v2 under work that might make things
better.

#### Limitations

The user creating a community gains admin. I didn't find a way to give admin to multiple people yet. Related issue: https://github.com/vector-im/element-web/issues/5240

Communities don't seem to be searchable?

## Howtos

Here are all the questions I had that I was able to answer myself.

### Backup and restore

I configured [restic](https://restic.net/) to create a hourly snapshot of the
state folder and copy it to Wasabi, a S3-compatible service.

#### Open issues

I don't know if the sqlite file changes are atomic or if there is a chance
they might get corrupted on restore.

### Re-activate a user that was deactivated by mistake

Somehow I managed to deactivate my own account. Don't ask :-p

```console
$ nix-shell -p sqlite --run 'sqlite3 /var/lib/matrix-synapse/homeserver.db'
sqlite> update users set deactivated=0 where name='@zimbatm:numtide.com';
```

After that, I am getting 'Incorrect username and/or password' when trying to
login. To generate a new hash, find the path to the matrix-synapse package.
Eg: `systemctl cat matrix-synapse`.

```console
$ /nix/store/pmcybj5phrcs3b0h2s2jgc1ykaqy2hfc-matrix-synapse-1.26.0/bin/hash_password
Password:
Confirm password:
$2b$12$lw336TQ8.XJVcFiQSaQfs.xGn668UisSx2u9XOaMsgdOIIUMBVA1W
```
^ not my real password, don't worry.

Then back in sqlite:
```console
$ nix-shell -p sqlite --run 'sqlite3 /var/lib/matrix-synapse/homeserver.db'
sqlite> UPDATE users SET password_hash='$2b$12$lw336TQ8.XJVcFiQSaQfs.xGn668UisSx2u9XOaMsgdOIIUMBVA1W' WHERE name='@zimbatm:numtide.com';
```

Ok that works now. The user has been kicked from all the rooms and need to
re-join them.

It would be great to have an admin UI instead of going through all of this.

### Adding GitHub notifications to a room.

https://github.com/maubot/github seems to be working quite well.

1. `/invite @github:maunium.net` in the target room.
2. `!github login` to give it access to the webhook config. Only needed the
   first time.
3. `!github webhook add <owner>/<repo>`
4. [Sponsor tulir](https://github.com/sponsors/tulir) to keep the bot running.

#### Open issues

The bot is super verbose and posts all comments on all issues. Is it possible to tweak that?

### Creating a truly public room

I don't understand the full implications of this so please take it with a
grain of salt.

Creating a public room is more difficult than anticipated so here is all the
steps I followed.

1. Rooms -> Create new room. Create the room
2. Select the rooms settings -> Security & Privacy.
  1. Select "Anyone who knows the room's link, including guests"
  2. Select "Anyone" on who can ready the history.

Finally, the matrix-synapse server also has to be configured with some extra
options:

```yaml
# If set to 'true', removes the need for authentication to access the server's
# public rooms directory through the client API, meaning that anyone can
# query the room directory. Defaults to 'false'.
allow_public_rooms_without_auth: true

# If set to 'true', allows any other homeserver to fetch the server's public
# rooms directory via federation. Defaults to 'false'.
allow_public_rooms_over_federation: true
```

One thing I noticed is that the users table now has a bunch of guests for
Shields.io. I suspect that one guest is created for each "visit" that
shields.io does, which is every time the badge is being generated. I assume
that those will get garbage-collected over time.

### Adding a badge to the repo

See the README.md of https://github.com/numtide/treefmt . It's using the great
shield.io service. See https://shields.io/category/chat

For the badge to display the number of users, the server needs to accept guest
users, and the room be fully public (see previous section).

Another surprising fact is that shields.io doesn't resolve the server using
the matrix delegation so you have to specify the full address using the
`server_fqdn` attribute. Eg: `server_fqdn=matrix.numtide.com` for the
`numtide.com` server.

Don't forget to contribute to the service so that they can keep it up and
running: https://opencollective.com/shields/contribute/

### Adding a new users

On NixOS, the administrative commands are not installed system-wide by default. And the configuration is stored in the /nix/store.
To find those out use:
```console
$ systemctl cat matrix-synapse
```

Then invoke something like the following. Note that matrix.numtide.com is where matrix is being hosted.
```console
$ /nix/store/pmcybj5phrcs3b0h2s2jgc1ykaqy2hfc-matrix-synapse-1.26.0/bin/register_new_matrix_user -c /nix/store/lwi1xq6ljznf9anjjchiajpxwqwdwcgf-homeserver.yaml https://matrix.numtide.com/
New user localpart [root]: zimbatm
Password: 
Confirm password: 
Make admin [no]: yes
Sending registration request...
Success!
$ 
```

### How much does it cost?

So far here is what it costs for me:

* 5 EUR / month: [Hetzner Cloud instance](https://www.hetzner.com/cloud)
* 5 USD / month: sponsor https://github.com/sponsors/tulir for the GitHub bot.
* 5 USD / month: backup
* TODO: Track time once it's finished

## Open questions

### How to setup a bridge between Slack and Matrix?

TODO: do some research. I know it's possible, but not in what form.


### Can a user backup and restore all their chats?

Email and IRC have this nice property that the user can relatively keep a local copy of all their interactions with other users. Is it possible to do that with Matrix?

### Can a user move between matrix servers?

What if a server disappears or kicks out a user. Can that user move their identity to another server? Having the identity detached from a domain seems quite vital to me.

### Is it possible to link element to the homeserver?

I don't want to host element-web and have to keep it up to date for now. https://app.element.io/ works but requires to select the homeserver every time. Is it possible to automate that bit?

Skimming through the code of https://github.com/vector-im/element-web/, it doesn't look like it.

## Critique

I really want Matrix to succeed so if I am being critical, please take it as a
form of encouragement and inspiration to improve things.

### Self-hosting

Ideally it would be possible to get your own instance in one-click. And have
maintenance be close to zero for small instances. I don't think we are quite
there yet. One pet-peeve of mine is that none of the guides document how to
backup and restore the server.

### No admin UI

Most of the configuration is done in a big YAML and there is no
administrative UI to manage users.

## Useful links

* Documentation sample: https://github.com/matrix-org/synapse/blob/develop/docs/sample_config.yaml
* Federation tester: https://federationtester.matrix.org/api/report?server_name=numtide.co
