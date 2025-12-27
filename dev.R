devtools::load_all()

check_sys_dependencies()

container <- SQLcontainer(
  container = "rsql",
  user = "dani"
)

container$path

# container$pull_image()
container$delete()
container$create()
# container$delete()

container$stop()
container$start()

container$con
container$server
container$database
container$port
container$password

container$connect()
container$con
container$disconnect()
container$con

container$connect()
container$test()
rsql <- container$sql("SELECT * FROM iris")
rsql@data
container$sql("CREATE DATABASE db_foo")
container$set_database("db_foo")
container$test()
container$con

container$disconnect()
container$sql_history
