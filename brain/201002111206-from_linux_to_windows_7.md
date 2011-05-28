---
title: From Linux to Windows 7
posted: 2010-02-11 12:06:23
modified: 2011-02-02 17:32:30
created: 2011-02-02 17:49:46
---
__I've done it maybe...__

I am currently waiting patiently for Apple to release their new MacBook Pro line using a new i5 or i7 processor and then it's my intent to snatch one up as my new permanent computer.  Check.

Well, besides liking most Apple software and software created for OSX I have grown especially fond of iTunes, mainly because I want to sync my iPhone everynight and snatch the newest podcasts i'm subscribed to.  OK, I could do this in Linux but if you've ever used any of that stuff, it's reverse engineered and it's not real reliable.  Besides, iTunes is a pretty great music manager.

Regardless, I decided that until that time comes I want to see where Windows is at and how well I can adapt to it from my Linux lifestyle.  For about the last 10+ years I've used Linux 99% of my time and it's been great.  Love command lines, love compilers, love the software (for the most part, I'm looking at you browsers and flash!).  But it's just not as refined...

Well, let me tell you something.  Windows software (at least the free stuff) is not that refined either.  It's pretty good, and much better than what it was.  I'm going to outline some major things that I need to do and how I'm handling it in Windows 7.

#### Terminal
Windows now includes "Power Shell" which is a glorified terminal.  By default they did a good job of creating commands that relate to UNIX/Linux style commands (ls, cd, rm, etc.).  The downfall of this is that they are aliases to .NET commands!  Basically what PowerShell boils down to is a .NET command interface.  Kinda like how you'd run _python_ and get a Python shell.  It works so far.

On a side-note.  There are environment variables but they are a bit harder to define.  You have to edit the environment variables for a user and when you start a new shell they will have updated.  There are probably easier ways to do this (I know you can do _setx_) but using the GUI seems to work pretty easily and a little quicker than trying to type out the settings.  If you screw it up there isn't as easy of a way to correct it.

Also, there is an idea of a .bashrc (shell startup file) but it's not very convenient.  I don't remember the link offhand and you have to enable script running for unsigned scripts.

#### SSH
Thank you [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/).  I installed Pageant, Putty, and Plink.  Plink lets me ssh in the PowerShell but that doesn't work too well because PowerShell doesn't handle the color escapes from bash.  But it works well enough.  Pageant handles my private key authentication.  I have it run at startup (simple shortcut in the startup folder) and mainly use Putty to connect remotely and forward my SSH key.  Works very solid.  Somewhat is annoying to have to use another program for this, and not be able to do it from the command line.

#### Editor ([VIM](http://vim.org))
I used vim in Linux and there is a nice build for Windows.  Installs nicely.  Overall it works good.  I was able to get all my settings ported over quickly (after figuring out where they go: $HOME/_vimrc).  One nice thing is you can update the shell environment variables and then vim and gvim can be used from the powershell just like in Linux and all seems fairly kosher.

#### Version Control
GIT has a [windows client](http://code.google.com/p/msysgit/) that has been working for me.  It's command line only and It seems a janky as it wouldn't let me use putty as the ssh backend but it has a compiled version of OpenSSH client that it falls back on.  I believe it might have something to do with my using a color terminal on the host that has my git repositories.

Subversion has always had a program that integrates with Explorer nicely called [TortoiseSVN](http://tortoisesvn.tigris.org/) that works great.  I am tempted to move away from GIT.  I _believe_ that even Mecurial and Bazaar have Windows clients, not sure though.

#### Python
Python was a bit trickier.  I downloaded the 64-bit version and it worked pretty well except that some libraries (numpy) require some compilation.  The problem is that by default Windows 7 doesn't come with a compiler.  There are two solutions.

1. Download Microsoft Visual Studio Express Edition _and_ Microsoft SDK for Windows.
2. Download third-party pre-compiled versions of the libraries.

I did (1) initially and found out that by default VS Express Edition doesn't include a 64-bit compiler, you have to download the Windows SDK to get that.  Well, I eventually just decided on downloading the third-party compilations from [here](http://www.lfd.uci.edu/~gohlke/pythonlibs/) thanks to Christoph Gohlke.  He did the heavy lifting of building these packages.

As a side note, there does seem to be a package for distutils which allows you to use 'easy_install' to install Python packages.  The package includes the 64-bit build but uses a 32-bit installer which looks at a bad registry entry to find the location of Python.  I fixed this by duplicating one registry entry (I'll have to update this later to say where) and it installed and runs fine.

#### MySQL
Install is easy, but default table type is InnoDB which is different from Linux which was defaulting to MyISAM.  I ended up having to run a PowerShell as an administrator and then editing the my.ini file which lives in the MySQL install directory (somewhere under _C:\\Program Files\\_).  This just caused some problems with Django because I imported some old tables and then built some new ones and the constraints didn't want to work because of differences in table types.

#### [Django](http://www.djangoproject.com/)
There is a package which I _didn't_ use called "Instant Django" so you may wanna check that out.  For this one I actually used _distutils_ and just ran

``python C:\\python26\\Scripts\\easy_install.py install django``

and that took care of everything.  If you've setup Django on Linux before it can be tricky but it's not any trickier on Windows.

That's about all I've run into right now.  Seems are working and I'm fairly happy.  Not because I think Linux is bad or Windows is good.  It's just different and a decently exciting experience.  Web browsing seems faster and a bit more stable.  So far so good.
