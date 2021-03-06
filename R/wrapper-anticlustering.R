
#' Anticlustering
#'
#' Create groups of elements (anticlusters) that are as similar as
#' possible to each other, by maximizing the heterogeneity within
#' groups. Implements anticlustering algorithms as described in
#' Papenberg and Klau (2020; <doi:10.1037/met0000301>).
#'
#' @param x The data input. Can be one of two structures: (1) A
#'     feature matrix where rows correspond to elements and columns
#'     correspond to variables (a single numeric variable can be
#'     passed as a vector). (2) An N x N matrix dissimilarity matrix;
#'     can be an object of class \code{dist} (e.g., returned by
#'     \code{\link{dist}} or \code{\link{as.dist}}) or a \code{matrix}
#'     where the entries of the upper and lower triangular matrix
#'     represent pairwise dissimilarities.
#' @param K How many anticlusters should be created. Alternatively: A
#'     vector of length \code{nrow(x)} describing how elements are
#'     assigned to anticlusters before the optimization starts.
#' @param objective The objective to be maximized. The option
#'     "diversity" (default; previously called "distance", which is
#'     still supported) maximizes the cluster editing objective
#'     function; the option "variance" maximizes the k-means objective
#'     function; "kplus" is an extension of k-means
#'     anticlustering. See Details.
#' @param method One of "exchange" (default) , "local-maximum", or
#'     "ilp".  See Details.
#' @param preclustering Boolean. Should a preclustering be conducted
#'     before anticlusters are created? Defaults to \code{FALSE}. See
#'     Details.
#' @param categories A vector, data.frame or matrix representing one
#'     or several categorical constraints. See Details.
#' @param repetitions The number of times a new exchange procedure is
#'     initiated when \code{method = "exchange"} or \code{method =
#'     "local-maximum"}.  In the end, the best objective found across
#'     the repetitions is returned. If this argument is not passed,
#'     only one repetitition is conducted.
#'
#' @return A vector of length N that assigns a group (i.e, a number
#'     between 1 and \code{K}) to each input element.
#'
#' @importFrom Matrix sparseMatrix
#' @importFrom stats as.dist dist
#'
#' @export
#'
#' @author
#' Martin Papenberg \email{martin.papenberg@@hhu.de}
#'
#' @details
#'
#' This function is used to solve anticlustering. That is, \code{K}
#' groups are created in such a way that all groups are as similar as
#' possible (this usually corresponds to creating groups with high
#' within-group heterogeneity). This is accomplished by maximizing
#' instead of minimizing a clustering objective function. The
#' maximization of three clustering objective functions is natively
#' supported, while other functions can also defined by the user:
#' 
#' \itemize{
#'   \item{cluster editing `diversity` objective, setting \code{objective = "diversity"} (default)}
#'   \item{k-means `variance` objective, setting \code{objective = "variance"}}
#'   \item{`kplus` anticlustering, an extension of k-means anticlustering}
#' }
#'
#' The k-means objective is the variance within groups---that is, the
#' sum of the squared distances between each element and its cluster
#' center (see \code{\link{variance_objective}}). K-means
#' anticlustering focuses on minimizing differences with regard to the
#' means of the input variables \code{x}; \code{objective = "kplus"}
#' anticlustering is an extension of this criterion that also tries to
#' minimize differences with regard to the standard deviations between
#' groups.
#' 
#' The cluster editing "diversity" objective is the sum of pairwise
#' distances within groups (see
#' \code{\link{diversity_objective}}). Anticluster editing is also
#' known as the »maximum diverse grouping problem« because it
#' maximizes group diversity as measured by the sum of pairwise
#' distances. Hence, anticlustering maximizes between-group similarity
#' by maximizing within-group heterogeneity. In previous versions of
#' this package, \code{method = "distance"} was used (and is still
#' supported) to request anticluster editing, but now \code{method =
#' "diversity"} is preferred because there are several clustering
#' objectives based on pairwise distances (e.g., see
#' \code{\link{dispersion_objective}}).
#'
#' If the data input \code{x} is a feature matrix (that is: each row
#' is a "case" and each column is a "variable") and the option
#' \code{objective = "diversity"} is used, the Euclidean distance is
#' computed as the basic unit of the anticluster editing objective. If
#' a different measure of dissimilarity is preferred, you may pass a
#' self-generated dissimiliarity matrix via the argument \code{x}.
#'
#' In the standard case, groups of equal size are generated. Adjust
#' the argument \code{K} to create groups of different size.
#'
#' \strong{Heuristic anticlustering}
#'
#' By default, a heuristic method is employed for anticlustering: the
#' exchange method (\code{method = "exchange"}). Building on an
#' initial assignment of elements to anticlusters, elements are
#' sequentially swapped between anticlusters in such a way that each
#' swap improves set similarity by the largest amount that is
#' possible. In the default case, elements are randomly assigned to
#' anticlusters before the exchange procedure starts; however, it is
#' also possible to explicitly specify the initial assignment using
#' the argument \code{K} (in this case, \code{K} has length
#' \code{nrow(x)}). The exchange procedure is repeated for each
#' element. Because each possible swap is investigated for each
#' element, the total number of exchanges grows quadratically with
#' input size, rendering the exchange method unsuitable for large N.
#' When using \code{method = "local-maximum"}, the exchange method is
#' repeated until an local maximum is reached. That means after the
#' exchange process has been conducted once for each data point, the
#' algorithm restarts with the first element and proceeds to conduct
#' exchanges until the objective cannot be improved.
#'
#' When setting \code{preclustering = TRUE}, only the \code{K - 1}
#' most similar elements serve as exchange partners, which can
#' dramatically speed up the optimization (more information on the
#' preclustering option is included below). This option is recommended
#' for larger N. For very large N, check out the function
#' \code{\link{fast_anticlustering}} that was specifically implemented
#' to process very large data sets.
#'
#' \strong{Exact anticlustering}
#'
#' An optimal anticluster editing objective can be found via integer
#' linear programming (the integer linear program implemented here can
#' be found in Papenberg & Klau, 2020, (8) - (12)). To this end, set
#' \code{method = "ilp"}. To obtain an optimal solution, the open
#' source GNU linear programming kit (available from
#' https://www.gnu.org/software/glpk/glpk.html) and the R package
#' \code{Rglpk} must be installed. The optimal solution is retrieved
#' by setting \code{objective = "diversity"}, \code{method = "ilp"}
#' and \code{preclustering = FALSE}. Use this combination of arguments
#' only for small problem sizes.
#'
#' To relax the optimality requirement, it is possible to set the
#' argument \code{preclustering = TRUE}. In this case, the anticluster
#' editing objective is still optimized using integer linear
#' programming, but a preprocessing forbids very similar elements to
#' be assigned to the same anticluster. The preclustering reduces the
#' size of the solution space, making the integer linear programming
#' approach applicable for larger problem instances. With
#' preclustering, optimality is no longer guaranteed, but the solution
#' is usually optimal or very close to optimal.
#'
#' The variance criterion cannot be optimized to optimality using
#' integer linear programming because the k-means objective function
#' is not linear. However, it is possible to employ the function
#' \code{\link{generate_partitions}} to obtain optimal solutions for
#' small problem instances.
#' 
#' \strong{Preclustering}
#' 
#' A useful heuristic for anticlustering is to form small groups of
#' very similar elements and assign these to different groups. This
#' logic is used as a preprocessing when setting \code{preclustering =
#' TRUE}. That is, before the anticlustering objective is optimized, a
#' cluster analysis identifies small groups of similar elements (pairs
#' if \code{K = 2}, triplets if \code{K = 3}, and so forth). The
#' optimization of the anticlustering objective is then conducted
#' under the constraint that these matched elements cannot be assigned
#' to the same group. When using the exchange algorithm, preclustering
#' is conducted using a call to \code{\link{matching}}. When using
#' \code{method = "ilp"}, the preclustering optimally finds groups of
#' minimum pairwise distance by solving the integer linear program
#' described in Papenberg and Klau (2020; (8) - (10), (12) - (13)).
#' 
#' \strong{Categorical constraints}
#'
#' The argument \code{categories} may induce categorical constraints.
#' The grouping variables indicated by \code{categories} will be
#' balanced out across anticlusters. Currently, this functionality is
#' only available in combination with the heuristic methods, but not
#' with the exact integer linear programming approach.
#' 
#' \strong{Optimize a custom objective function}
#' 
#' It is possible to pass a \code{function} to the argument
#' \code{objective}. See \code{\link{dispersion_objective}} for an
#' example. If \code{objective} is a function, the exchange method
#' assigns elements to anticlusters in such a way that the return
#' value of the custom function is maximized (hence, the function
#' should return larger values when the between-group similarity is
#' higher). The custom function has to take two arguments: the first
#' is the data argument, the second is the clustering assignment. That
#' is, the argument \code{x} will be passed down to the user-defined
#' function as first argument. \strong{However, only after}
#' \code{\link{as.matrix}} has been called on \code{x}. This implies
#' that in the function body, columns of the data set cannot be
#' accessed using \code{data.frame} operations such as
#' \code{$}. Objects of class \code{dist} will be converted to matrix
#' as well. 
#' 
#' 
#' @seealso
#'
#' \code{\link{fast_anticlustering}}
#'
#' \code{\link{variance_objective}}
#'
#' \code{\link{diversity_objective}}
#'
#'
#' @examples
#'
#' # Optimize the cluster editing (diversity) criterion
#' anticlusters <- anticlustering(
#'   schaper2019[, 3:6],
#'   K = 3,
#'   categories = schaper2019$room
#' )
#' # Compare feature means by anticluster
#' by(schaper2019[, 3:6], anticlusters, function(x) round(colMeans(x), 2))
#' # Compare standard deviations by anticluster
#' by(schaper2019[, 3:6], anticlusters, function(x) round(apply(x, 2, sd), 2))
#' # check that the "room" is balanced across anticlusters:
#' table(anticlusters, schaper2019$room)
#' 
#' # Use multiple starts of the algorithm to improve the objective and
#' # optimize the extended k-means criterion ("kplus")
#' anticlusters <- anticlustering(
#'   schaper2019[, 3:6],
#'   objective = "kplus",
#'   K = 3,
#'   categories = schaper2019$room,
#'   method = "local-maximum",
#'   repetitions = 2
#' )
#' # Compare means and standard deviations by anticluster
#' by(schaper2019[, 3:6], anticlusters, function(x) round(colMeans(x), 2))
#' by(schaper2019[, 3:6], anticlusters, function(x) round(apply(x, 2, sd), 2))
#'
#' 
#' ## Use preclustering and variance (k-means) criterion on large data set
#' N <- 1000
#' K = 2
#' lds <- data.frame(f1 = rnorm(N), f2 = rnorm(N))
#' ac <- anticlustering(
#'   lds, 
#'   K = K,
#'   objective = "variance",
#'   preclustering = TRUE
#' )
#' 
#' # The following is equivalent to setting `preclustering = TRUE`:
#' cl <- balanced_clustering(lds, K = N / K)
#' ac <- anticlustering(
#'   lds, 
#'   K = K,
#'   objective = "variance",
#'   categories = cl
#' )
#'
#' @references
#'
#' Grötschel, M., & Wakabayashi, Y. (1989). A cutting plane algorithm
#' for a clustering problem. Mathematical Programming, 45, 59-96.
#' 
#' Papenberg, M., & Klau, G. W. (2020). Using anticlustering to partition 
#' data sets into equivalent parts. Psychological Methods. Advance Online 
#' Publication. https://doi.org/10.1037/met0000301.
#'
#' Späth, H. (1986). Anticlustering: Maximizing the variance criterion.
#' Control and Cybernetics, 15, 213-218.
#'

anticlustering <- function(x, K, objective = "diversity", method = "exchange",
                           preclustering = FALSE, categories = NULL, 
                           repetitions = NULL) {

  x <- to_matrix(x)
  
  # extend data for k-means extension objective
  if (!inherits(objective, "function")) {
    validate_input(
      objective, "objective", 
      objmode = "character",
      input_set = c("distance", "diversity", "variance", "kplus"), 
      len = 1, not_na = TRUE
    )
    if (objective == "kplus") {
      x <- cbind(x, squared_from_mean(x))
      objective <- "variance"
    }
  }
  
  # In some cases, `anticlustering()` has to be called repeatedly - 
  # redirect to `repeat_anticlustering()` in this case, which then
  # again calls anticlustering with method "exchange" and 
  # repetitions = NULL
  if (method == "local-maximum" || argument_exists(repetitions)) {
    if (!argument_exists(repetitions)) {
      repetitions <- 1
    }
    return(repeat_anticlustering(x, K, objective, categories, preclustering, 
                                 method, repetitions))
  }
  
  ## Get data into required format
  input_validation_anticlustering(x, K, objective, method, preclustering, 
                                  categories, repetitions)

  ## Exact method using ILP
  if (method == "ilp") {
    return(exact_anticlustering(
      x,
      K,
      preclustering)
    )
  }
  
  # Preclustering and categorical constraints are both processed in the
  # variable `categories` after this step:
  categories <- get_categorical_constraints(x, K, preclustering, categories)
  
  if (class(objective) == "function") {
    # most generic exchange method, deals with any objective function
    return(exchange_method(x, K, objective, categories))
  }

  # Redirect to specialized fast exchange methods for diversity and 
  # variance objectives
  if (objective == "variance") {
    return(fast_anticlustering(x, K, Inf, categories))
  } else if (objective == "diversity" || objective == "distance") {
    return(fast_exchange_dist(x, K, categories))
  }
}

# Function that processes input and returns the data set that the
# optimization is conducted on as matrix (for exchange method)
# Returned matrix either represents distances or features.
to_matrix <- function(data) {
  if (!is_distance_matrix(data)) {
    data <- as.matrix(data)
    return(data)
  }
  as.matrix(as.dist(data))
}

# Determines if preclustering constraints or categorical constraints
# are present. Returns a grouping vector if one or both constraints 
# have been passed, or NULL if none is required
get_categorical_constraints <- function(data, K, preclustering, categories) {
  if (preclustering == TRUE) {
    N <- nrow(data)
    matches <- matching(data, p = K, match_within = categories, sort_output = FALSE)
    # deal with NA in matches
    return(replace_na_by_index(matches))
  }
  if (argument_exists(categories)) {
    return(merge_into_one_variable(categories))
  }
  NULL
}

replace_na_by_index <- function(matches) {
  na_matches <- is.na(matches)
  NAs <- sum(na_matches) 
  if (NAs == 0) {
    return(matches)
  }
  max_group <- max(matches, na.rm = TRUE)
  matches[na_matches] <- max_group + 1:NAs 
  matches
}

squared_from_mean <- function(data) {
  apply(data, 2, function(x) (x - mean(x))^2)
}
