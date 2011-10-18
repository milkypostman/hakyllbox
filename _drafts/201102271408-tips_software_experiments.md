---
title: Tips for Software Experiments
posted: 2011-02-27 14:08:45
modified: 2011-02-27 15:16:01
created: 2011-02-27 15:01:34
---
The worst part of sitting down to write anything is feeling like there is so
much good advice out there and there is no way you could possibly contribute
something that hasn't been thought of and something valid.  Maybe more the
point is to document things you feel like you wish you had documented somewhere
so at the least you can look back and remember those things you said, for
better or for worse.  And most likely I'll look back at this post and think
about how terrible of a writer I was and what bad points I documented.
Anyways, here are a bunch of tips I am thinking of for coding experimental
research, specifically in computer science.  This doesn't apply for map-reduce
systems because I don't have one.

1. Granularity.  Write smaller programs, each which perform some small step in
   the overall experiement.  Don't write one behemoth of a program that does
   the entire experiment.  Write a bunch of small programs that write
   intermediate results to files.

1. Use files.  Take advantage of storage being relatively cheap.  Most likely
   your bottleneck in any experiment is going to be processing time.  Part of
   this is using filenames that mean something.  If you
   generated a set of `foo` using parameters `f=5` and `g=20` then probably
   `food_f5_g20.csv` is a good filename.  Also, `foo` isn't very good unless I
   know what the hell that means.  [Ext3](http://en.wikipedia.org/wiki/Ext3)
   has plenty (256) characters for each filename so make yourself useful and
   come up with a good prefix.
   
1. Be concious of data formats.  One of the worse things I do is make use of
   Python's [pickle](http://docs.python.org/library/pickle) module for saving
   intermeddiate data.  But it's also one of the best things I've done.  It's
   bad because the data I generate *requires* someone to know and use Python to
   use the data.  At the same time it makes reading and writing data a breeze
   because I don't have to worry about parsing different data types (converting strings to ints).  
   Python is
   pretty ubuquitous for scientific research so I feel OK doing this but I'm
   still pretty bad about predicting when data I'm generating is going to be used by someone else later.
   Regardless, it's fairly painless to write a quick format
   interchange program from Python to something like
   [JSON](http://docs.python.org/library/json.html?highlight=json#module-json)
   or [CSV](http://docs.python.org/library/csv).  If you can use CSV then you
   probably should.

1. Know your environment.  Specifically I mean "know UNIX," and more verbose I
   mean, "know the UNIX utilities."  There are plenty of powerful UNIX tools
   that can help sort / parse / digest text files and so just knowing what you
   can do is great.  Start with
   [`grep`](http://unixhelp.ed.ac.uk/CGI/man-cgi?grep) and
   [`cut`](http://unixhelp.ed.ac.uk/CGI/man-cgi?cut) if you're using CSV files.
   [`rsync`](http://www.manpagez.com/man/1/rsync/) is great for keeping
   multiple machines synced but takes some learning because the trailing
   forwardslahs (`/`) can screw things up big time (try: `-avzu` option flags
   with `--delete` when you need to remove extraneous files on a remote
   system).  [`screen`](http://www.gnu.org/software/screen/) or
   [`tmux`](http://tmux.sourceforge.net/) can be invaluable when working
   remotely and needing a persistent terminal.

1. Learn your shell.  When I deal with a lot files, it's very convenient to
   know how to write quick one-line shell commands that process a number of
   files quickly.  What's the use of knowing the utilities provided by UNIX if
   you can't put them together in an efficient way.

1. Don't over-engineer any experiment.  You're not writing code for the space
   shuttle, you're writing code that's most likely going to be run to get one
   set of results one time for one paper.  Besides the fact that after getting
   initial results you'll probably have to rethink the experiment all over.  It
   also keeps things simpler to read and debug, and quicker to write.  Plus
   you're more likely to share data than share code.
   There are exceptions to this rule when you do actually do something over and
   over again but that's a rarity.  A nice database layer can be useful.  If you find yourself
   doing something over and over again then a library of functions can be
   useful.  Classes can be really useful but I sometimes find they're too much.
   Like using [this
   guitar](http://www2.gibson.com/Products/Electric-Guitars/Firebird/Gibson-USA/Firebird-X.aspx)
   to play Nirvana covers.

1. If you do anything with random number generator, record the "seed".  I have
   run enough experiements that depend on random numbers that I've wanted to
   reproduce, I've finally learned that I need to record the seed used to
   generate the random numbers.
