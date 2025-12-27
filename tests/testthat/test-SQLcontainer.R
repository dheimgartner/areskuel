skip_on_cran()

test_that("main", {
  pw <- "P@assword123!"
  container <- SQLcontainer(
    container = "test_rsql",
    user = "test",
    password = pw
  )
  tryCatch({
    container$create()
    expect_true(is.null(container$con))
    container$connect()
    expect_true(!is.null(container$con))
    container$test()
    rsql <- container$sql("SELECT * FROM iris")
    expect_true(is(rsql@data, "tbl_df"))
    container$disconnect()
    expect_true(is.null(container$con))
    expect_true(length(container$sql_history) == 1)
    container$stop()
  }, finally = container$delete())
})

test_that("can create and set new database and connect to it", {
  pw <- "P@assword123!"
  container <- SQLcontainer(
    container = "test_rsql",
    user = "test",
    password = pw
  )
  tryCatch({
    container$create()
    container$connect()
    container$test()
    rsql <- container$sql("CREATE DATABASE test_db")
    expect_no_error(container$set_database("test_db"))
    expect_true(container$database == "test_db")
    container$test()
    container$stop()
  }, finally = container$delete())
})
