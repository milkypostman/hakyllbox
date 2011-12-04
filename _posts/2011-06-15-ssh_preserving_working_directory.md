---
title: SSH Preserving Working Directory
author: Donald Ephraim Curtis
tags: linux, ssh, bash
---

if you want to ssh somewhere and preserve the directory here is a
useful snippet...

    cdssh () {
        if [ -n ${1} ]; then
            CWD=$(pwd|sed "s#$HOME#~#")
            ssh -t $1 -- "cd ${CWD} ; bash -l"
        fi
    }

the reason for the `cwd` is to handle where the home directory on the
remote system is in a different directory than the localhost.  some
systems (osx) use `/users/<username/` as the home which doesn't play
nicely with many other system.

