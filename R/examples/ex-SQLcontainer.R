\donttest{

## check sys prerequisites
checks <- check_sys_dependencies()
if (!all(checks)) {
  stop("System requirements not met. Make sure podman and ODBC drivers are installed.")
}

container <- SQLcontainer(
  container = "test_areskuel",
  user = "test_user"
)

container$create()
container$connect()
container$con

## create a test table "iris" with the iris data
container$test()

rsql <- container$sql("SELECT * FROM iris")
rsql

## create a new database
foo <- container$sql("CREATE DATABASE db_foo")
container$set_database("db_foo")
container$con

## check the history
container$sql_history

## close the connection
container$disconnect()

## delete the container (all data will be lost!)
container$delete()

}
