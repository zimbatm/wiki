# Linux needs a Keyring program

A keyring is a process that is started on user-session login and contains all
of the secret keys of the users. It is responsible for securing those keys and
control access to those to a limited set of processes.

The keyring should be running outside of the user's accessible memory to avoid
tampering from other programs running in that same space.

## Desired capabilities

* System-level and user-level capabilities
* Memory protection
* Unlocked by user login
* GPG signing and encryption
* SSH agent
* CA certificates
* Some sort if IPC/DBus protocol
* Per program private key space
* Backup / restore functionality
* Support for hardware keys
* Connection to Vault or other stores
* Allow to trigger service restarts on key change

## Current state of things

Both Windows and MacOS have a keyring process available. MacOS goes even
further by baking some of the functionalities of that keyring with a system
chip to prevent any sorts of memory attacks.

## Gnome Keyring

Gnome provides a keyring. Unfortunately it is broken in many ways:

* SSH keys only support the RSA encryption which is vulnerable to quantum
  attacks.
* No support for GPG keys

## KWallet

KDE has it's own keyring as well.

It seems to be tied to KDE and thus not usable by other desktop environents.

TODO: add more details


## Firefox / Google Chrome

Both support KWallet and Gnome Keyring. In the event that those are missing
they will fallback on plain text files!

## Network Manager

Supports both KWallet and Gnome Keyring. System-wide network configurations
are stored as plain text.


## Hardware keys

Another option is to depend on hardware keys. Those typically have limited
storage.

## keyring.sh

The daemon hands over a read-only memory region that contains the secret.

Handles:
* certificate chains
* SSH agent
* GPG agent
* K/V passwords
* delegated auth to other daemons

Integrates with:
* YubiKey
* macOS Keyring
* Windows Keyring
* 

### Get socket (username, hostname:port)

Initiates the socket with auth on the target and hands it over to the client.

SSH_AUTH_SOCK

### Get password (username, hostname:port)



### Set password (username, hostname:port, password)


### Protocols

https://developer.gnome.org/gnome-keyring/stable/gnome-keyring-Simple-Password-Storage.html

https://www.vaultproject.io/api/

https://api.kde.org/frameworks/kwallet/html/index.html

https://developer.apple.com/documentation/security/keychain_services

