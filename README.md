
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RSQL

<!-- badges: start -->

<!-- badges: end -->

The goal of `RSQL` is to easily set up, manage and interact with
`podman` containers that run `Microsoft SQL Server` (and possibly other
containerized DBMS in the future).

## Prerequisites

You need to install `podman` and the `ODBC` drivers. The main
functionality is implemented in the bash shell script in
`inst/scripts/mssqlcontainer.sh`. That being said, it should be clear
that `RSQL` is for Linux-users…

- `podman` installation:
  <https://podman.io/docs/installation#installing-on-linux>
- `ODBC` drivers:
  <https://learn.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver17&tabs=alpine18-install%2Calpine17-install%2Cdebian8-install%2Credhat7-13-install%2Crhel7-offline>

## Installation

Install from CRAN:

``` r
install.packages("RSQL")
```

You can install the development version of `RSQL` like so:

``` r
devtools::install_github("dheimgartner/RSQL")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(RSQL)

## check sys prerequisites
checks <- check_sys_dependencies()
if (!all(as.logical(checks))) {
  stop("System requirements not met. Make sure podman and ODBC drivers are installed.")
}

container <- SQLcontainer(
  container = "rsql",
  user = "test"
)

container$create()
container$connect()
container$con
#> <OdbcConnection> dbo@rsql
#>   Database: master
#>   Microsoft SQL Server Version: 14.00.3038

## create a test table "iris" with the iris data
container$test()
#> Creating `iris` table...

rsql <- container$sql("SELECT * FROM iris")
rsql
#> An object of class "RSQL"
#> Slot "server":
#> [1] "localhost"
#> 
#> Slot "database":
#> [1] "master"
#> 
#> Slot "sql":
#> [1] "SELECT * FROM iris"
#> 
#> Slot "data":
#> # A tibble: 150 × 5
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>           <dbl>       <dbl>        <dbl>       <dbl> <chr>  
#>  1          5.1         3.5          1.4         0.2 setosa 
#>  2          4.9         3            1.4         0.2 setosa 
#>  3          4.7         3.2          1.3         0.2 setosa 
#>  4          4.6         3.1          1.5         0.2 setosa 
#>  5          5           3.6          1.4         0.2 setosa 
#>  6          5.4         3.9          1.7         0.4 setosa 
#>  7          4.6         3.4          1.4         0.3 setosa 
#>  8          5           3.4          1.5         0.2 setosa 
#>  9          4.4         2.9          1.4         0.2 setosa 
#> 10          4.9         3.1          1.5         0.1 setosa 
#> # ℹ 140 more rows

## create a new database
foo <- container$sql("CREATE DATABASE db_foo")
container$set_database("db_foo")
container$con
#> <OdbcConnection> dbo@rsql
#>   Database: db_foo
#>   Microsoft SQL Server Version: 14.00.3038

## check the history
container$sql_history
#> [[1]]
#> An object of class "SQLhistory"
#> Slot "server":
#> [1] "localhost"
#> 
#> Slot "database":
#> [1] "master"
#> 
#> Slot "sql":
#> [1] "SELECT * FROM iris"
#> 
#> 
#> [[2]]
#> An object of class "SQLhistory"
#> Slot "server":
#> [1] "localhost"
#> 
#> Slot "database":
#> [1] "master"
#> 
#> Slot "sql":
#> [1] "CREATE DATABASE db_foo"

## close the connection
container$disconnect()

## delete the container (all data will be lost!)
container$delete()
```
