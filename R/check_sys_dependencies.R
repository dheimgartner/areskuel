check_podman <- function() {
  if (Sys.which("podman") == "") {
    warning(
      "Podman is required but not found.\n",
      "Install from: https://podman.io/",
      call. = FALSE
    )
    return(FALSE)
  }
  return(TRUE)
}

check_odbc <- function() {
  drivers <- odbc::odbcListDrivers()
  if (!any(grepl("SQL Server", drivers$name))) {
    warning(
      "No SQL Server ODBC driver found.\n",
      "Install Microsoft ODBC Driver for SQL Server.",
      call. = FALSE
    )
    return(FALSE)
  }
  return(TRUE)
}

#' Checks if system dependencies ara available
#'
#' @returns Named list containing boolean values
#' @export
check_sys_dependencies <- function() {
  funcs <- list(podman = check_podman, odbc_driver = check_odbc)
  checks <- sapply(funcs, function(x) x())
  checks
}
