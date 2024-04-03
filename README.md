# Using SQL through R #

This repository has the code used for the example of using R to do SQL querying, replicating analogous profuction environments through duckdb in-process database
management system (DBMS). An article with the example explained can be found on [Medium](), intending to show a tool for people that is a newcomer or that has 
issues with SQL but know R a way to make the most out of SQL.

![image](https://github.com/ATB1999/r_sql_videogames/assets/112544311/8f109071-a7f7-4251-9514-3e3849ec4afb)

We focus on two .csv data sets found in [Kaggle](https://www.kaggle.com/datasets/lucasgalanti/home-consoles-and-gaming-sales?resource=download&select=scrapped_data.csv) about gaming consoles and games, using a simple SQL query and a one a bit more complex involving an inner join,
by means of using R DBI, dbplyr, duckdb and tidyverse libraries for doing the SQL process without the need to even know SQL; and with the ultimae objective of being
agnostic to SQL to perform data analysis wih the data exctracted.

![image](https://github.com/ATB1999/r_sql_videogames/assets/112544311/8603a0e6-5c23-45a0-a0b4-8bf34e1e2f9c)
