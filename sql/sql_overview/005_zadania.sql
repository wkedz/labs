-- Jeśli wydrukowanie każdego biletu kosztowało 2zł
-- to jaki był koszt wydrukowania biletów
-- i ile zarobiliśmy na nich?
SELECT SUM(CenaBiletu) AS SumaZarobkow
, COUNT(*) AS LiczbaBiletow
, SUM(CenaBiletu) - COUNT(*) * 2 AS Zysk
FROM [KursSQL].[dbo].[KibicZawody];

-- Ile mamy kobiet w stowarzyszeniach?
SELECT COUNT(*) AS LiczbaKobietStowarzyszenia
FROM [KursSQL].[dbo].[Kibice]
WHERE RIGHT(Imie, 1) = 'a' AND NrStowarzyszenia IS NOT NULL;

-- Pokaż nazwy wydarzeń, które odbyły się w czerwcu
SELECT *
FROM [KursSQL].[dbo].[Zawody]
WHERE MONTH(Data) = 6;

-- Pokaż najmłodszą kobietę urodzoną w latach 90tych
SELECT TOP 1 *
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE SUBSTRING(PESEL, 10, 1) IN ('0','2','4','6','8')
    AND YEAR(DataUrodzenia) BETWEEN 1990 AND 1999
ORDER BY DataUrodzenia DESC;

-- Ile na bilety podczas pierwszych zawodów wydali kibice?
SELECT SUM(CenaBiletu) AS SumaBiletowPierwszychZawodow
FROM [KursSQL].[dbo].[KibicZawody]
WHERE NrZawodow = 1;

-- Ile kupiono biletów podczas pierwszych zawodów?
SELECT COUNT(*) AS IleBiletow
FROM [KursSQL].[dbo].[KibicZawody]
WHERE NrZawodow = 1;

-- Ile znaków ma najdłuższe imię i nazwisko zawodnika oddzielone spacją
SELECT MAX(LEN(Imie + ' ' + Nazwisko)) AS NajdluzszeImieNazwisko
FROM [KursSQL].[dbo].[Zawodnicy];

-- Który mamy dzisiaj rok?
SELECT YEAR(GETDATE()) AS RokDzisiaj;

-- Pokaż wszystkie olimpiady i zawody ogólnopolskie
-- (ogólnopolskie to te, które mają w nazwie 'zawody')
SELECT *
FROM [KursSQL].[dbo].[Zawody]
WHERE Nazwa Like '%limpiada%' OR Nazwa LIKE '%ogólnopolsk%';

-- Stwórz dla niestowarzyszonych kibicek identyfikator:
-- pierwsza litera imienia z kropką i nazwisko
SELECT CONCAT(LEFT(Imie, 1), '.', Nazwisko) AS Identyfikator
FROM [KursSQL].[dbo].[Kibice]
WHERE NrStowarzyszenia IS NULL
    AND RIGHT(Imie,1) = 'a';

SELECT LEFT(Imie, 1) + '.' + Nazwisko AS Identyfikator
FROM [KursSQL].[dbo].[Kibice]
WHERE NrStowarzyszenia IS NULL
    AND RIGHT(Imie,1) = 'a';

-- Pokaż imiona i nazwiska zawodników płci męskiej 
-- mających przynajmniej 25 lat (patrząc tylko na rok urodzenia)
-- dla których główną dyscypliną nie są biegi (biegi to dyscypliny 1,2,3)
SELECT Imie, Nazwisko
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE SUBSTRING(PESEL, 10, 1) IN ('1', '3', '5', '7', '9')
    AND YEAR(GETDATE()) - YEAR(DataUrodzenia) >= 25
    AND GlownaDyscyplina NOT IN (1, 2, 3);
