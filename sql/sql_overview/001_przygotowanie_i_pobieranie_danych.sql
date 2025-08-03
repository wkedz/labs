-- Pokaż wszystkich zawodników
 
SELECT *
FROM [KursSQL].[dbo].[Zawodnicy];

-- Pokaż imiona i nazwiska zawodników
 
SELECT Imie, Nazwisko
FROM [KursSQL].[dbo].[Zawodnicy];

-- Pokaż 3 zawodników

SELECT TOP 3 *
FROM [KursSQL].[dbo].[Zawodnicy];
 
-- Pokaż imiona i nazwiska dwóch kibiców
 
SELECT TOP 2 Imie, Nazwisko
FROM [KursSQL].[dbo].[Kibice];

-- Pokaż unikalne imiona kibicow
 
SELECT DISTINCT Imie AS UnikalneImiona
FROM [KursSQL].[dbo].[Kibice];

-- Wyświetl nazwy miejsc, w których odbywają się zawody
 
SELECT DISTINCT Nazwa
FROM [KursSQL].[dbo].[Miejsce];

-- Pokaż jakie rodzaje trofeów można zdobyć
 
SELECT DISTINCT ZdobyteTrofeum
FROM [KursSQL].[dbo].[Trofea];

-- Wyświetl 5 kibiców
 
-- Pokaz 5 zawodnikow
-- TOP zwraca losowe wiersze tylko dla MS SQL Server
-- W innych bazach danych uzywamy LIMIT
-- trzeba dodac SORT

SELECT TOP 5 Imie, Nazwisko
FROM [KursSQL].[dbo].[Kibice];

-- Pokaż nazwy dyscyplin

SELECT DISTINCT Nazwa
FROM [KursSQL].[dbo].[Dyscyplina];

-- Pokaż 3 nazwy trofeów

SELECT DISTINCT TOP 3 ZdobyteTrofeum
FROM [KursSQL].[dbo].[Trofea];
