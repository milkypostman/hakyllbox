---
title: Gaussian KDE Smoothed Histograms with MatPlotLib
author: Donald Ephraim Curtis
tags: python, data, matplotlib, pandas, smooth
---

Using [pandas][pandas] I've been doing some data analysis and simple data exploration; most recently I wanted to build a curve for test score distributions. Since I do like the way plots using [ggplot2][ggplot2] look---yes that whole package is better but I <3 [Python][python]---I took an opportunity to try out [some code posted by Bicubic][matplotlib-ggplot] to style my [MatPlotLib][matplotlib] plots.

While doing all this I figured out how to use Gaussian [Kernel Density Estimation][kde] to make my histograms smooth. A [question on Stack Overflow][so-density] provided the bulk of the code and instructions on how to adjust the `covariance_factor` of the `gaussian_kde` class provided by the [scipy][scipy] stats module.

![`covariance_factor = .5`](/imgs/gaussian_kde_5.png) 

![`covariance_factor = .25`](/imgs/gaussian_kde_25.png) 

## Pitfalls

One thing to note is that the `gaussian_kde` function requires floating point numbers. 

Code to generate the graphs is:

    import matplotlib.pyplot as plt
    import numpy as np
    from scipy.stats import gaussian_kde
    

    # bogus data
    data = [1.5]*7 + [2.5]*2 + [3.5]*8 + [4.5]*3 + [5.5]*1 + [6.5]*8

    # generated a density class
    density = gaussian_kde(data)

    # set the covariance_factor, lower means more detail
    density.covariance_factor = lambda : .25
    density._compute_covariance()


    # generate a fake range of x values
    xs = np.arange(0,24,.1)

    # fill y values using density class
    ys = density(xs)
    

    # ggaxes is a wrapper around rstyle
    ax = ggaxes(plt.figure(figsize=(10,8)))
    
    l = ax.plot(xs, ys, antialiased=True, linewidth=2, color="#A81450")
    l = ax.fill_between(xs, ys, alpha=.5, zorder=5, antialiased=True, color="#E01B6A")
    
    Series(data).hist(ax=ax, normed=1, bins=8, color='grey', antialiased=True)
    ax.set_xlim(0,8)
    
    plt.savefig("gaussian_kde_25.png")


The code above requires the following function:

    from rstyle import rstyle
    
    def ggaxes(fig=None):
        if fig is None: fig = plt.figure()
        ax = fig.add_subplot(111)
        rstyle(ax)
        return ax
        
`rstyle` is the function to style [matplotlib][matplotlib] like [ggplot2][ggplot2] (originally located [here][matplotlib-ggplot]) which I keep in the file `rstyle.py` somewhere in my `PYTHONPATH`:

    from pylab import *
    
    def rstyle(ax):
        """Styles an axes to appear like ggplot2
        Must be called after all plot and axis manipulation operations have been carried out (needs to know final tick spacing)
        """
        #set the style of the major and minor grid lines, filled blocks
        ax.grid(True, 'major', color='w', linestyle='-', linewidth=1.4)
        ax.grid(True, 'minor', color='0.92', linestyle='-', linewidth=0.7)
        ax.patch.set_facecolor('0.85')
        ax.set_axisbelow(True)
    
        #set minor tick spacing to 1/2 of the major ticks
        ax.xaxis.set_minor_locator(MultipleLocator( (plt.xticks()[0][1]-plt.xticks()[0][0]) / 2.0 ))
        ax.yaxis.set_minor_locator(MultipleLocator( (plt.yticks()[0][1]-plt.yticks()[0][0]) / 2.0 ))
    
        #remove axis border
        for child in ax.get_children():
            if isinstance(child, matplotlib.spines.Spine):
                child.set_alpha(0)
    
        #restyle the tick lines
        for line in ax.get_xticklines() + ax.get_yticklines():
            line.set_markersize(5)
            line.set_color("gray")
            line.set_markeredgewidth(1.4)
    
        #remove the minor tick lines
        for line in ax.xaxis.get_ticklines(minor=True) + ax.yaxis.get_ticklines(minor=True):
            line.set_markersize(0)
    
        #only show bottom left ticks, pointing out of axis
        rcParams['xtick.direction'] = 'out'
        rcParams['ytick.direction'] = 'out'
        ax.xaxis.set_ticks_position('bottom')
        ax.yaxis.set_ticks_position('left')
    
    
        if ax.legend_ <> None:
            lg = ax.legend_
            lg.get_frame().set_linewidth(0)
            lg.get_frame().set_alpha(0.5)
    
    
    def rhist(ax, data, **keywords):
        """Creates a histogram with default style parameters to look like ggplot2
        Is equivalent to calling ax.hist and accepts the same keyword parameters.
        If style parameters are explicitly defined, they will not be overwritten
        """
    
        defaults = {
                    'facecolor' : '0.3',
                    'edgecolor' : '0.28',
                    'linewidth' : '1',
                    'bins' : 100
                    }
    
        for k, v in defaults.items():
            if k not in keywords: keywords[k] = v
    
        return ax.hist(data, **keywords)
    
    
    def rbox(ax, data, **keywords):
        """Creates a ggplot2 style boxplot, is eqivalent to calling ax.boxplot with the following additions:
    
        Keyword arguments:
        colors -- array-like collection of colours for box fills
        names -- array-like collection of box names which are passed on as tick labels
    
        """
    
        hasColors = 'colors' in keywords
        if hasColors:
            colors = keywords['colors']
            keywords.pop('colors')
    
        if 'names' in keywords:
            ax.tickNames = plt.setp(ax, xticklabels=keywords['names'] )
            keywords.pop('names')
    
        bp = ax.boxplot(data, **keywords)
        pylab.setp(bp['boxes'], color='black')
        pylab.setp(bp['whiskers'], color='black', linestyle = 'solid')
        pylab.setp(bp['fliers'], color='black', alpha = 0.9, marker= 'o', markersize = 3)
        pylab.setp(bp['medians'], color='black')
    
        numBoxes = len(data)
        for i in range(numBoxes):
            box = bp['boxes'][i]
            boxX = []
            boxY = []
            for j in range(5):
              boxX.append(box.get_xdata()[j])
              boxY.append(box.get_ydata()[j])
            boxCoords = zip(boxX,boxY)
    
            if hasColors:
                boxPolygon = Polygon(boxCoords, facecolor = colors[i % len(colors)])
            else:
                boxPolygon = Polygon(boxCoords, facecolor = '0.95')
    
            ax.add_patch(boxPolygon)
        return bp

[scipy]: http://www.scipy.org
[kde]: http://en.wikipedia.org/wiki/Kernel_density_estimation
[matplotlib]: http://matplotlib.org
[python]: http://python.org
[messy-mind]: http://messymind.net/
[ggplot2]: http://ggplot2.org
[so-density]: http://stackoverflow.com/questions/4150171/how-to-create-a-density-plot-in-matplotlib
[matplotlib-ggplot]: http://messymind.net/2012/07/making-matplotlib-look-like-ggplot/
[pandas]: http://pandas.pydata.org
[pandas-viz]: http://pandas.pydata.org/pandas-docs/stable/visualization.html
