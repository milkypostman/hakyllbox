---
title: Installing Pymacs + Rope on Emacs 24
author: Donald Curtis
tags: emacs
---

Getting Rope installed on Emacs is a bit weird, but much easier than it used to be.

## using virtualenv

My setup starts with a directory `~/.virtualenv/default` which is my base virtual environment I use for Python.  I prefer not to mess with the system packages on OS X simply because sometimes overwriting system packages can interfere with the OS---or so I've heard.

*I don't use `virtualenvwrapper` because it was doggin' my shell startup time.*

In my [init.el](https://github.com/milkypostman/dotemacs/blob/master/init.el) I simply make sure to put my virtualenv bin directory in the path, `python` in that directory takes care of the rest,

    (push "~/.virtualenvs/default/bin" exec-path)
    (setenv "PATH"
            (concat
             "~/.virtualenvs/default/bin" ":"
             (getenv "PATH")
             ))


## Installing the Python files/packages

Install `rope` and `ropemacs`:

    pip install rope ropemacs
    
Then install `Pymacs`:

    pip install -e "git+https://github.com/pinard/Pymacs.git#egg=Pymacs"
    cd $VIRTUAL_ENV/src/pymacs
    make
    
The last two steps here are needed because of the odd build system `Pymacs` has.  You could use `easy_install` on a checkout of `Pymacs` but you would still need to enter the directory and type `make` as `python setup.py install` does not seem to properly build and install the `Pymacs.py` file.

You can test the installation by changing to a directory that does *not* contain `Pymacs` and running,

    python -c 'import Pymacs'
    
No errors no problems.


## Installing the Emacs files/packages

### Pymacs

For this part I simply cloned the `Pymacs` repo into the `elisp` directory under `.emacs.d`:

    cd ~/.emacs.d
    mkdir elisp
    cd elisp
    git clone https://github.com/pinard/Pymacs.git

### auto-complete

I install [auto-complete](http://cx4a.org/software/auto-complete/) from [MELPA](http://melpa.milkbox.net) using `package.el` via `package-list-packages` or you can do it directly,

    (package-install 'auto-complete)
    


## Configuration

Once everything is installed, this is what I use in my `init.el` file.  **Not for the faint of heart.**  My `init.el` is like a [Rube Goldberg](https://en.wikipedia.org/wiki/Rube_Goldberg) machine in that I rely heavily on autoloads from `package.el` and I don't load anything until its needed.  I've include a macro I use just to make things look cleaner in my `init.el` file.

    (defmacro after (mode &rest body)
      `(eval-after-load ,mode
         '(progn ,@body)))

    (after 'auto-complete
           (add-to-list 'ac-dictionary-directories "~/.emacs.d/dict")
           (setq ac-use-menu-map t)
           (define-key ac-menu-map "\C-n" 'ac-next)
           (define-key ac-menu-map "\C-p" 'ac-previous))
    
    (after 'auto-complete-config
           (ac-config-default)
           (when (file-exists-p (expand-file-name "/Users/dcurtis/.emacs.d/elisp/Pymacs"))
             (ac-ropemacs-initialize)
             (ac-ropemacs-setup)))
    
    (after 'auto-complete-autoloads
           (autoload 'auto-complete-mode "auto-complete" "enable auto-complete-mode" t nil)
           (add-hook 'python-mode-hook
                     (lambda ()
                       (require 'auto-complete-config)
                       (add-to-list 'ac-sources 'ac-source-ropemacs)
                       (auto-complete-mode))))
    
The first two blocks happen when stuff actually goes down (`auto-complete` is actually loaded).  Ignore those for now.

The first thing that will *maybe* get loaded automatically by `package.el` is `auto-complete-autoloads.el` and in my configuration I setup `python-mode-hook` for *auto-complete*.  Thus *auto-complete* is only setup for `python-mode` if the `auto-complete` package is actually installed.

Now back to the initial two blocks.  When I enter `python-mode` then `auto-complete-config.el` will get require'd, `ac-source-ropemacs` will get added to `ac-sources`, and `auto-complete-mode` will get enabled.  A side effect of requiring `auto-complete-config` is that `auto-complete` will get loaded---it's require'd by `auto-complete-config`---and thus my *auto-complete* bindings will get set from the first block.  Then after `auto-complete-config` is loaded, `ac-config-default` will get called.  And finally, if the `Pymacs` directory exists under `~/.emacs.d/elisp/` then I'll initialize `ropemacs`.  

Now, you can enable `rope` without `auto-complete` but I don't.  It's *untested* but I think it would be something like,

    (autoload 'pymacs-apply "pymacs")
    (autoload 'pymacs-call "pymacs")
    (autoload 'pymacs-eval "pymacs" nil t)
    (autoload 'pymacs-exec "pymacs" nil t)
    (autoload 'pymacs-load "pymacs" nil t)
    (pymacs-load "ropemacs" "rope-")
    
But if you look in the `auto-complete-config.el` you can see they take care of all of this for you.  I haven't played with `rope` enough to know that I need it right now.  I'm not sure I really even care about `auto-complete`, I just wanted to see if I could get this working easily and it seems to be OK now.


[My `.emacs.d` configuration](https://github.com/milkypostman/dotemacs)
