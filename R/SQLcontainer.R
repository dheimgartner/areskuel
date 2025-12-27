#' An S4 class to represent the SQL query return value
#'
#' @slot server The server connnected to at the time of the query execution.
#' @slot database The database connected to at the time of the query execution.
#' @slot sql The SQL query.
#' @slot data The resulting data.
#'
#' @name RSQL
#' @export
RSQL <- setClass("RSQL", slots = c(
  server = "character",
  database = "character",
  sql = "character",
  data = "tbl_df"
))

#' An S4 class to represent the SQL query history
#'
#' @slot server The server connnected to at the time of the query execution.
#' @slot database The database connected to at the time of the query execution.
#' @slot sql The SQL query.
#'
#' @name SQLhistory
#' @export
SQLhistory <- setClass("SQLhistory", slots = c(
  server = "character",
  database = "character",
  sql = "character"
))

setClassUnion("MSSQL#NULL", c("Microsoft SQL Server", "NULL"))

#' The main reference class to manage and interact with the podman container
#'
#' ...and in paricular it's SQL server!
#'
#' @field path The path to the `mssqlcontainer.sh` executable.
#' @field container The name of the container. Defaults to `"rsql"`.
#' @field user The SQL user. Defaults to `"ursql"`.
#' @field con The DB connection.
#' @field server The server to connect to. Defaults to `"localhost"`.
#' @field database The database to connect to. Defaults to `"master"`.
#' @field port The port number. Defaults to `"1433"`.
#' @field sql_history A list of `"SQLhistory"` elements [SQLhistory].
#' @field password The associated password for the user. Defaults to `"P@assword123!"`.
#'  Needs to conform with MSSQL's password policy!
#' @field driver The `odbc`-driver to use. Defaults to `"ODBC Driver 18 for SQL Server"`.
#'
#' @seealso The methods documentation and `SQLcontainer$help()`
#' @name SQLcontainer
#'
#' @example R/examples/ex-SQLcontainer.R
#' @rawNamespace export(SQLcontainer)
SQLcontainer <- setRefClass(
  "SQLcontainer",
  fields = c(
    path = "character",
    container = "character",
    user = "character",
    con = "MSSQL#NULL",
    server = "character",
    database = "character",
    port = "character",
    sql_history = "list",
    password = "character",
    driver = "character"
  )
)

SQLcontainer$methods(
  initialize = function(container = "rsql", user = "ursql", password = "P@ssword123!",
                        server = "localhost", database = "master", port = "1433",
                        driver = "ODBC Driver 18 for SQL Server") {
    path <<- system.file("scripts", "mssqlcontainer.sh", package = "RSQL")
    container <<- container
    user <<- user
    con <<- NULL
    server <<- server
    database <<- database
    port <<- port
    password <<- password
    driver <<- driver
  }
)

SQLcontainer$methods(
  exec = function(...) {
    dots <- list(...)
    args <- do.call(paste, dots)
    cmd <- paste(path, args)
    system(cmd)
  }
)

#' Pull the docker image
#' @name SQLcontainer$pull_image
SQLcontainer$methods(
  pull_image = function() {
    exec("pull_image")
  }
)

#' Create the podman container
#' @name SQLcontainer$create
SQLcontainer$methods(
  create = function() {
    exec("create", container, user, password)
  }
)

#' Delete the podman container
#' @name SQLcontainer$delete
SQLcontainer$methods(
  delete = function() {
    exec("delete", container)
  }
)

#' Start the podman container
#' @name SQLcontainer$start
SQLcontainer$methods(
  start = function() {
    exec("start", container)
  }
)

#' Stop the podman container
#' @name SQLcontainer$stop
SQLcontainer$methods(
  stop = function() {
    exec("stop", container)
  }
)

#' Connect to the MSSQL instance
#' @name SQLcontainer$connect
SQLcontainer$methods(
  connect = function() {
    con <<- DBI::dbConnect(
      odbc::odbc(),
      Driver = driver,
      Server = server,
      Database = database,
      Port = port,
      UID = user,
      PWD = password,
      TrustServerCertificate = "yes"
    )
  }
)

#' Close the connection to the MSSQL instance
#' @name SQLcontainer$disconnect
SQLcontainer$methods(
  disconnect = function() {
    if (is.null(con)) {
      message("Already disconnected...")
      return()
    }
    DBI::dbDisconnect(con)
    con <<- NULL
  }
)

#' Set the MSSQL server to connect to
#' @name SQLcontainer$set_server
#' @param server The server to connect to.
SQLcontainer$methods(
  set_server = function(server) {
    server <<- server
    database <<- "master"
    disconnect()
    connect()
  }
)

#' Set the MSSQL database to connect to
#' @name SQLcontainer$set_database
#' @param database The database to connect to.
SQLcontainer$methods(
  set_database = function(database) {
    database <<- database
    disconnect()
    connect()
  }
)

#' Execute an SQL query
#' @name SQLcontainer$sql
#' @param sql Query string.
SQLcontainer$methods(
  sql = function(sql) {
    dat <- DBI::dbGetQuery(con, sql)
    hist <- SQLhistory(server = server, database = database, sql = sql)
    sql_history <<- append(sql_history, hist)
    RSQL(
      server = server,
      database = database,
      sql = sql,
      data = tibble::tibble(dat)
    )
  }
)

#' Create a table containing the iris data
#' @name SQLcontainer$test
SQLcontainer$methods(
  test = function() {
    cat("Creating `iris` table...\n")
    DBI::dbWriteTable(con, "iris", iris)
  }
)
