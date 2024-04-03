library(DBI)
library(dbplyr)
library(duckdb) #We generally do not import it, as we use it a few times with :: notation
library(tidyverse)

# Databases are run by database management systems (DBMS for short), which come
# in three basic forms:
#   
# - Client-server DBMS run on a powerful central server, which you connect from
# your computer (the client). They are great for sharing data with multiple
# people in an organization. Popular client-server DBMS include PostgreSQL,
# MariaDB, SQL Server, and Oracle.

# - Cloud DBMS, like Snowflake, Amazon’s RedShift, and Google’s BigQuery, are
# similar to client-server DBMS, but they run in the cloud. This means they can
# easily handle extremely large datasets and can automatically provide more
# compute resources as needed.

# - In-process DBMS, like SQLite or duckdb, run entirely on your computer. They’re
# great for working with large datasets where you’re the primary user.





# SQL BASICS IN R ---------------------------------------------------------

## Connecting to Databases ------------------------------------------------

#You will always need a pair of packages: DBI (database interface), which allows
#to connect to a database, upload data, run SQL queries... + a package tailored
#to the DBMS you use, translating the generic DBI command for each DBMS. A common
#package to use if you cannot find one is odbc (not covered). 

#In this class, we wil focus on a simple in-process one: duckdb, that creates a
#temporary database that is deleted when you restart R. THE ONLY DIFFERENCE
#WILL BE ON HOW YOU CONNECT TO THE DATABASE! ALL ELSE IS REALLY SIMILAR!

### CONNECTION--------------------------------------------------------------
#We call the connection with :: as we will not use the packages much more
con <- DBI::dbConnect(
  #RMariaDB::MariaDB()          #MariaDB connection
  #RPostgres::Postgres()        #PostgreSQL connection
  duckdb::duckdb(),             #The DBMS specification in our case
  #dbdir = "duckdb"             #Where to save it: a duckdb directory in our project. 
)


## Adding Data -------------------------------------------------------------

#Writing Data from R
dbWriteTable(con, "starwars", dplyr::starwars)

#Writing Data from a csv (duckDB specific)
duckdb::duckdb_read_csv(con, "consoles", "Console_Data.csv")
duckdb::duckdb_read_csv(con, "games", "scrapped_data.csv")

#Checking data has been added correctly
dbListTables(con)

#Reading the tables
con %>%
  dbReadTable("consoles") %>%
  as_tibble()

con %>%
  dbReadTable("games") %>%
  as_tibble()

## SQL Queries -------------------------------------------------------------

#If you are good with SQL, you can use dbGetQuery

#We first define our SQL query in strings
sql <- "
  SELECT name, height, mass
  FROM starwars
  WHERE height > 100
"
#We then call it together with the connection and the table
dbGetQuery(con, sql) %>%
  as_tibble()


## R SQL Queries (dbplyr) --------------------------------------------------

# dbplyr is a dplyr backend, which means you keep writing dplyr code but the
# backend executes it differently. In this, dbplyr translates to SQL

#To use it, we must first create an object that represents a database table
starwars_db <- tbl(con, "starwars")

#And then, we are ready to use SQL without doing SQL!
query150 <- starwars_db %>%
  select(name, height, mass) %>%
  filter(height > 150)

#"Can you pass me the SQL query you did?" No problem!-> show_query() does the
#trick!
query150 %>% show_query()

## Getting Data Back to R Environment --------------------------------------

#In order to have a data frame, we use the function collect() on the dbplyr query
query150 %>% collect()


# BEYOND THE BASICS FOR SQL QUERYING --------------------------------------

#Let's treat these data tables as dbplyr database objects!
consoles_db <- tbl(con, "consoles")
games_db <- tbl(con, "games")
starwars_db <- tbl(con, "starwars")


#Let's say I would like to know all the console sales by Discontinuation.Year.,
#with that year ordered in descending order.
consoles_db %>%
  group_by(Discontinuation.Year) %>%
  summarise(Sales = sum(Units.sold..million., na.rm = TRUE)) %>%
  arrange(desc(Discontinuation.Year)) %>%
  show_query()

sql <- '
SELECT "Discontinuation.Year", SUM("Units.sold..million.") AS Sales
FROM consoles
GROUP BY "Discontinuation.Year"
ORDER BY "Discontinuation.Year" DESC
'

dbGetQuery(con, sql) %>%
  as_tibble()



#What if I want all the sales in games by Company that developed the consoles
#for Home Consoles, ordered by quantity sold

#Calling the data using R
consoles_db %>%
  inner_join(y = games_db, by = c("Console.Name" = "System.Full")) %>%
  filter(Type == "Home") %>%
  group_by(Company) %>%
  summarise(Sales = sum(Units.m., na.rm = TRUE)) %>%
  arrange(desc(Sales))

#Visualising the equivalent SQL code
consoles_db %>%
  inner_join(y = games_db, by = c("Console.Name" = "System.Full")) %>%
  filter(Type == "Home") %>%
  group_by(Company) %>%
  summarise(Sales = sum(Units.m., na.rm = TRUE)) %>%
  arrange(desc(Sales)) %>%
  show_query()

#Saving the data in our environment as a data frame using collect()
data <- consoles_db %>%
  inner_join(y = games_db, by = c("Console.Name" = "System.Full")) %>%
  filter(Type == "Home") %>%
  group_by(Company) %>%
  summarise(Sales = sum(Units.m., na.rm = TRUE)) %>%
  arrange(desc(Sales)) %>%
  collect()
