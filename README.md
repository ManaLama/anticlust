anticlust
=========

`anticlust` is an `R` package for »anticlustering«, a method to
partition a set of elements into subsets in such a way that the subsets
are as similar as possible. The package `anticlust` was originally
developed to assign items to experimental conditions in experimental
psychology, but it can be applied whenever a user requires that a given
set of elements has to be partitioned into similar subsets. The package
is still under active developement; expect changes and improvements
before it will be submitted to CRAN. Check out the [NEWS
file](https://m-py.github.io/anticlust/NEWS.html) for recent changes.

Installation
------------

    library("remotes") # if not available: install.packages("remotes")
    install_github("m-Py/anticlust")

How do I learn about anticlustering
-----------------------------------

This page contains some basic information on anticlustering. More
information is available via the following sources:

1.  There is a preprint available (»Using anticlustering to partition a
    stimulus pool into equivalent parts«) describing the theoretical
    background of anticlustering and the `anticlust` package in detail.
    It can be retrieved from <https://psyarxiv.com/3razc/>

2.  I am working on some vignettes on typical usages of the `anticlust`
    for stimulus selection in psychological research. A work-in-progress
    can be found
    [here](https://m-py.github.io/anticlust/stimulus-selection.html).

3.  Use the R help. The main function of the package is
    `anticlustering()` and the help page of the function
    (`?anticlustering`) is useful to learn more about anticlustering. It
    provides explanations of all function parameters and how they relate
    to the theoretical background of anticlustering.

A quick start
-------------

In this initial example, I use the main function `anticlustering()` to
create three similar sets of plants using the classical iris data set:

    # load the package via
    library("anticlust")

    anticlusters <- anticlustering(
      iris[, -5],
      K = 3,
      objective = "variance",
      method = "exchange"
    )

    ## The output is a vector that assigns a group (i.e, a number 
    ## between 1 and K) to each input element:
    anticlusters
    #>   [1] 1 1 2 3 2 2 1 3 1 3 1 2 3 2 1 3 1 3 3 1 2 3 1 3 3 2 2 2 2 2 3 2 3 2 1
    #>  [36] 3 2 2 1 2 1 3 2 1 1 1 3 1 3 3 3 1 1 2 3 3 1 3 1 2 3 3 1 2 2 1 1 2 2 3
    #>  [71] 1 1 3 3 2 1 3 3 1 3 1 2 1 2 1 2 3 1 1 3 2 1 2 1 1 2 1 2 3 3 3 2 2 3 3
    #> [106] 2 1 1 2 1 3 2 2 3 2 2 1 3 1 1 1 2 1 3 2 3 1 3 3 2 1 2 3 2 3 3 1 2 2 1
    #> [141] 2 2 1 3 3 3 2 2 1 3

    ## Each group has the same number of items:
    table(anticlusters)
    #> anticlusters
    #>  1  2  3 
    #> 50 50 50

    ## Compare the feature means by anticluster:
    by(iris[, -5], anticlusters, function(x) round(colMeans(x), 2))
    #> anticlusters: 1
    #> Sepal.Length  Sepal.Width Petal.Length  Petal.Width 
    #>         5.84         3.06         3.76         1.20 
    #> -------------------------------------------------------- 
    #> anticlusters: 2
    #> Sepal.Length  Sepal.Width Petal.Length  Petal.Width 
    #>         5.84         3.06         3.76         1.20 
    #> -------------------------------------------------------- 
    #> anticlusters: 3
    #> Sepal.Length  Sepal.Width Petal.Length  Petal.Width 
    #>         5.84         3.06         3.76         1.20

As illustrated in the example, we can use the function
`anticlustering()` to create similar sets of elements. The function
takes as input a data table describing the elements that should be
assigned to sets. In the data table, each row represents an element, for
example a person, word or a photo. Each column is a numeric variable
describing one of the elements’ features. The table may be an R `matrix`
or `data.frame`; a single feature can also be passed as a `vector`. The
number of groups is specified through the argument `K`.

To quantify set similarity, `anticlust` may employ one of two measures
that have been developed in the context of cluster analysis:

-   the k-means “variance” objective
-   the cluster editing “distance” objective

The k-means objective is given by the sum of the squared distances
between cluster centers and individual data points. The cluster editing
objective is the sum of pairwise distances within each anticluster. The
following plot illustrates both objectives for 15 elements that have
been assigned to three sets. Each element is described by two numeric
features, displayed as the *x* and *y* axis:

<img src="inst/objectives_updated.png" width="100%" style="display: block; margin: auto;" />

The lines connecting the dots illustrate the distances that enter the
objective functions. For anticluster editing (“distance objective”),
lines are drawn between pairs of elements within the same anticluster,
because the objective is the sum of the pairwise distances between
elements in the same cluster. For k-means anticlustering (“variance
objective”), lines are drawn between each element and the cluster
centroid, because the objective is the sum of the squared distances
between cluster centers and elements.

Minimizing either the distance or the variance objective creates three
distinct clusters of elements (as shown in the upper plots), whereas
maximization leads to a strong overlap of the three sets, i.e., three
anticlusters (as shown in the lower plots). For anticlustering, the
distance objective maximizes the average similarity between elements in
different sets, whereas the variance objective tends to maximize the
similarity of the cluster centers (i.e., the feature means).

To vary the objective function in the `anticlust` package, we can change
the parameter `objective`. To use anticluster editing, use
`objective = "distance"` (this is also the default). To maximize the
k-means variance objective, set `objective = "variance"`.

Categorical constraints
-----------------------

Sometimes, it is required that sets are not only similar with regard to
some numeric variables, but we also want to ensure that each set
contains an equal number of elements of a certain category. Coming back
to the initial iris data set, we may want to require that each set has a
balanced number of plants of the three iris species. To this end, we can
use the argument `categories` as follows:

    anticlusters <- anticlustering(
      iris[, -5],
      K = 3,
      objective = "variance",
      method = "exchange",
      categories = iris[, 5]
    )

    ## The species are as balanced as possible across anticlusters:
    table(anticlusters, iris[, 5])
    #>             
    #> anticlusters setosa versicolor virginica
    #>            1     17         17        16
    #>            2     17         16        17
    #>            3     16         17        17

Questions and suggestions
-------------------------

If you have any question on the `anticlust` package or any suggestions
(which are greatly appreciated), I encourage you to contact me via email
(<a href="mailto:martin.papenberg@hhu.de" class="email">martin.papenberg@hhu.de</a>)
or [Twitter](https://twitter.com/MPapenberg), or to open an issue on
this Github repository.

Reference
---------

Papenberg, M., & Klau, G. W. (2019, October 30). Using anticlustering to
partition a stimulus pool into equivalent parts.
<https://doi.org/10.31234/osf.io/3razc>
