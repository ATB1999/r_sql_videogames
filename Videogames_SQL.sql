-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

#First StarWars Example on the script
SELECT "name", height, mass
FROM starwars
WHERE (height > 150.0)

#Let's say I would like to know all the console sales by Discontinuation.Year.,
#with that year ordered in descending order.
SELECT "Discontinuation.Year", SUM("Units.sold..million.") AS Sales
FROM consoles
GROUP BY "Discontinuation.Year"
ORDER BY "Discontinuation.Year" DESC

#What if I want all the sales in games by Company that developed the consoles
#for Home Consoles, ordered by quantity sold
SELECT Company, SUM("Units.m.") AS Sales
FROM (
  SELECT q01.*
  FROM (
    SELECT
      consoles.*,
      "Game.Name",
      "Units.m.",
      Publisher,
      Developer,
      Image_URL,
      "Release.Date"
    FROM consoles
    INNER JOIN games
      ON (consoles."Console.Name" = games."System.Full")
  ) q01
  WHERE ("Type" = 'Home')
) q01
GROUP BY Company
ORDER BY Sales DESC
