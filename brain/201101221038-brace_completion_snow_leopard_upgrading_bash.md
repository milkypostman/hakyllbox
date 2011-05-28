---
title: Brace Completion in Snow Leopard (upgrading bash)
posted: 2011-01-22 10:38:32
modified: 2011-01-22 11:11:06
created: 2011-02-02 17:49:46
---

I've been working with a lot of files lately and they all are
numbered.  Thus far I've been relying on a lot of bash `for` loops to
get exactly the files I want, but I knew there *had* be a better way.
And there is... Refer to
[this question on Stack Overflow](http://superuser.com/questions/236484/list-files-numbered-in-a-specific-range).
Pretty great.

The only real problem is on Snow Leopard the default bash is
`3.2.48(1)`.  So something like `{1..10}` will expand properly to `1 2
3 4 5 6 7 8 9 10`, but the incremental and `0` padding options won't,
i.e., `{1..10..2}` and `{001..10}` won't work.  They **should** expand
to `1 3 5 7 9` and `001 002 003 004 005 006 007 008 009 010`
respectively.

One solution is to upgrade bash on Snow Leopard.  I am a believer in
[homebrew](https://github.com/mxcl/homebrew).  It's such a clean way
to manage things in OSX (meaning its easy to remove packages and get
back to base OSX if you ever want to, although Python seems like a
pain and 2.6 is good enough for me so I don't mess with that).

Anyways, here is what I did to upgrade my Bash on Snow Leopard.

1. `brew install bash`
    * (optional) `brew install bash-completion`
2. `sudo vim /etc/shells`
    * add `/usr/local/bin/bash` to the list
3. Update your account,
    1. Goto `Accounts Preference Pane`
    2. Unlock so you can make changes (by clicking the lock in the bottom left
       and entering your password assuming you're an admin)
    3. Control-Click your name and select `Advanced Options...`
    4. Under `Login Shell:` select `/usr/local/bin/bash` from the dropdown,
       *or* if it's not there just type it in.  It'll be fine.  Trust me I'm a
       doctor.
    5. Hit the `OK` (figuratively *hit* it, and by hit I mean click)

Now everything relating to brace expansion should work.
