-- posortuj alfabetycznie po nazwisku zawodników
-- rosnaco
-- ORDER BY JEST BARDZO NIE WYDAJNY
SELECT *
FROM [KursSQL].[dbo].[Zawodnicy]
ORDER BY Nazwisko ASC;

-- malejaco
SELECT *
FROM [KursSQL].[dbo].[Zawodnicy]
ORDER BY Nazwisko DESC;

-- Uporzadkuj bilety po cenie malejaca pomijajac bezplatne bilety
SELECT *
FROM [KursSQL].[dbo].[KibicZawody]
WHERE CenaBiletu > 0
ORDER BY CenaBiletu DESC;

-- Uporzadkuj rosnaco zawody wedlug miejsac i daty
SELECT *
FROM [KursSQL].[dbo].[Zawody]
ORDER BY Miejsce ASC, Data ASC;

-- Pokaz najdrozszy biler
SELECT TOP 1 CenaBiletu
FROM [KursSQL].[dbo].[KibicZawody]
ORDER BY CenaBiletu DESC;

-- Znajdz trzech najstarszych zawodników
SELECT TOP 3 *
FROM [KursSQL].[dbo].[Zawodnicy]
ORDER BY DataUrodzenia ASC;

-- Pokaż zawody od najnowszego do najstarszego
SELECT *
FROM [KursSQL].[dbo].[Zawody]
ORDER BY Data DESC;

-- Posortuj alfabetycznie wszystkie możliwe do zdobycia puchary
SELECT DISTINCT ZdobyteTrofeum
FROM [KursSQL].[dbo].[Trofea]
WHERE ZdobyteTrofeum LIKE '%puchar%'
ORDER BY ZdobyteTrofeum ASC;

-- Pokaż pierwszą parę biegaczy zgodnie z alfabetem (biegi to dyscypliny 1,2,3)
SELECT TOP 2 *
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE GlownaDyscyplina IN (1, 2, 3) 
ORDER BY Nazwisko ASC;

-- Pokaż najmłodszą kobietę
SELECT TOP 1 *
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE PESEL LIKE '%[02468]_'
ORDER BY DataUrodzenia DESC;

-- Posortuj alfabetycznie wg nazwy zawody z drugiego kwartału 2019 roku
SELECT *
FROM [KursSQL].[dbo].[Zawody]
WHERE Data BETWEEN '2019-04-01' AND '2019-06-30'
ORDER BY Nazwa ASC;