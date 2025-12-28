## Sources from DESCRIPTION
#' @name areskuel-package
"_PACKAGE"

#' @rawNamespace importClassesFrom(odbc, "Microsoft SQL Server")
NULL

#' @importClassesFrom tibble tbl_df
NULL

#' @importFrom methods new
NULL

## Silence R CMD CHECK note on "not imported from..."
#' Keywords according to the SQL-92 standard
#' @export
SQL92Keywords <- function() {
  DBI::.SQL92Keywords
}
