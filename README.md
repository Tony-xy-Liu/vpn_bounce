# VPN Bounce

## *vpn jumpserver in container for ssh so that rest of internet is not disrupted*

## [original article](https://medium.com/@manis.eren/ssh-to-intranet-through-a-jumphost-vpn-container-3d58c3af1761)

notes
- https://www.infradead.org/openconnect/connecting.html
- ControlMaster doesn't work in windows

sources
- [SSH Jumphosting to intranet through a VPN container](https://medium.com/@manis.eren/ssh-to-intranet-through-a-jumphost-vpn-container-3d58c3af1761)
- [alpine ssh server](https://github.com/danielguerra69/alpine-sshd)

## Setup

1. [Get docker](https://docs.docker.com/engine/install/ubuntu/) and [disable the sudo requiremnt for the docker CLI](https://docs.docker.com/engine/install/linux-postinstall/)

1. Clone this repo (you actually only need `./dev.sh` and the [container image](https://quay.io/repository/txyliu/vpn_bounce), but cloning the repo is more reproducible)
1. `mkdir ./ws/keys` and `mkdir ./ws/config`
1. `cd ./ws/keys` and make a new set of keys with `ssh-keygen -a 128 -t ed25519` and name it `bounce`. Go back to the root of the repo (`cd ../../`)
1. In your `~/.ssh/config` file (you can make an empty file and parent folders if they don't exist) add the following block:
    ```
    host vpn
        HostName localhost
        Port 2222
        User root
        IdentitiesOnly yes
        PreferredAuthentications publickey
        IdentityFile <this repo>/ws/keys/bounce
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
    ```
    and bounce ssh connections through it like so...
    ```
    host somewhere_else
        ...
        ProxyJump vpn
    ```
    You can rename "vpn" to something better. Here is [more documentation on the ssh config file](https://man.openbsd.org/ssh_config), I recommend setting the `ControlMaster` field if possible, and [a tutorial with examples](https://linuxize.com/post/using-the-ssh-config-file/). 
1. `cd ./ws/config && touch openconnect.sh` and edit it with the credentials to the vpn server. Here is an example for UBC (replace <password> and <cwl_username>):
    ```
    #!/bin/sh
    echo "<password>" | openconnect myvpn.ubc.ca --user=<cwl_username> --passwd-on-stdin
    ```
    Additional documentation for openconnect is here https://www.infradead.org/openconnect/index.html
1. Start the vpn container with `./dev.sh -r`, which will run a docker container. `ssh somewhere_else` will now bounce through the vpn via the container
