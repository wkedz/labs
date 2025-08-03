-- Funkcje tekstowe
-- CONCAT - laczy stringi
-- + - laczy stringi, ale moze byc niebezpieczne, bo moze zamienic wszystko na liczby i zsumowac
-- SUBSTRING - zwraca czesc stringa
-- LEFT - zwraca czesc stringa od poczatku
-- RIGHT - zwraca czesc stringa od konca

-- Połącz imiona i nazwiska zawodnikow oddzielajac je spacja
-- + moze byc niebezpieczne, bo silnik bazy danych bedzie stie staral zamienic wszystko na liczbe, i zsumowac
SELECT Imie + ' ' + Nazwisko As ImieNazwisko -- warto dodac alias, poniewaz, beez tego pojawi sie No Column Name
FROM [KursSQL].[dbo].[Zawodnicy];

-- concat jest bezpieczniejsze, bo wszsytko zamienia na stringi i dodaje do siebie
SELECT CONCAT(Imie, ' ', Nazwisko) AS ImieNazwisko -- CONCAT jest bardziej wydajny niz +
FROM [KursSQL].[dbo].[Zawodnicy]

-- Pokaz imie i pierwsza litere imienia kazdego z zawodnikow (LEFT, RIGHT)
SELECT Imie, LEFT(Imie, 1) AS PierwszaLiteraImienia
FROM [KursSQL].[dbo].[Zawodnicy];

-- Znajdz wszsytkie kobiety wsrod kibicow
SELECT *
FROM [KursSQL].[dbo].[Kibice]
WHERE RIGHT(Imie, 1) = 'a'; -- szybsze niz LIKE

-- Pokaz imiona i nazwiska wszsytkich mezczyzn
SELECT Imie, Nazwisko
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE SUBSTRING(PESEL, 10, 1) IN ('1', '3', '5', '7', '9'); -- musza byc apostrofy, poniewaz SUBSTRING zwraca stringa

-- Znajdz najdlusze nazwisko wsrod zawodnikow
SELECT TOP 1 LEN(Nazwisko) AS DLUGOSC_NAZWISKA
FROM [KursSQL].[dbo].[Zawodnicy]
ORDER BY LEN(Nazwisko) DESC; -- LEN zwraca dlugosc string

-- Funkcje matematyczne
-- ROUND - zaokragla liczbe do okreslonej liczby miejsc po przecinku
-- MONTH - zwraca miesiac z daty
-- GETDATE - zwraca aktualna date i godzine

-- Pokaz informacje o biletach i dodac cene netto biletu
SELECT *, ROUND(CenaBiletu / 1.23, 2) AS CennaNetto
FROM [KursSQL].[dbo].[KibicZawody]
WHERE CenaBiletu > 0; -- nie ma potrzeby sortowania, bo nie ma kolumny do sortowania

-- Znajdz zawody, ktore odbyly sie w wakacje
SELECT *
FROM [KursSQL].[dbo].[Zawody]
WHERE MONTH(Data) IN (7, 8);

-- Ktora jest teraz godzina
SELECT GETDATE();

-- Funkcje konwersji i typy danych
-- CAST - konwertuje jeden typ danych na inny

-- Pokaz cene biletu w netto
SELECT *, CAST(CenaBiletu/1.23 AS decimal(10,2)) AS CenaNetto
FROM [KursSQL].[dbo].[KibicZawody];

-- Funkcje agregujace
-- AVG - zwraca srednia wartosc
-- COUNT - zwraca liczbe wierszy
-- MAX - zwraca maksymalna wartosc
-- MIN - zwraca minimalna wartosc
-- SUM - zwraca sume wartosci

-- Za jaka kwote sprzedalismy bilety
SELECT SUM(CenaBiletu) AS SumaSprzedazy
FROM [KursSQL].[dbo].[KibicZawody];

-- Policz srednia cene biletu pomijajac bezplaten bilety
SELECT AVG(CAST(CenaBiletu AS DECIMAL(10,2))) AS SredniaCenaBiletu
FROM [KursSQL].[dbo].[KibicZawody]
WHERE CenaBiletu > 0;

SELECT CAST(AVG(CAST(CenaBiletu AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS SredniaCenaBiletu
FROM [KursSQL].[dbo].[KibicZawody]
WHERE CenaBiletu > 0;

-- Znajdz zawodnika ktory jest najstarszy
SELECT MIN(DataUrodzenia) AS NajstarszyZawodnik
FROM [KursSQL].[dbo].[Zawodnicy];

-- Ile mamy kibicow w bazie
SELECT COUNT(*) AS LiczbaKibicow
FROM [KursSQL].[dbo].[Kibice];

-- Policz kibiwo nalezacych do stowarzyszenia
SELECT COUNT(*) AS LiczbaKibicowStowarzyszenia
FROM [KursSQL].[dbo].[Kibice]
WHERE NrStowarzyszenia IS NOT NULL;

SELECT COUNT(NrStowarzyszenia) AS LiczbaKibicowStowarzyszenia -- NIE LICZY NULL
FROM [KursSQL].[dbo].[Kibice];

-- Ile zawodów odbyło się w pierwszej połowie 2019 roku?
SELECT COUNT(Data) AS LiczbaZawodowPierwszaPolowa2019
FROM [KursSQL].[dbo].[Zawody]
WHERE MONTH(Data) IN (1,2,3,4,5,6) AND YEAR(Data) = 2019;;

SELECT COUNT(Data) AS LiczbaZawodowPierwszaPolowa2019
FROM [KursSQL].[dbo].[Zawody]
WHERE MONTH(Data) <= 6 AND YEAR(Data) = 2019;

SELECT COUNT(Data) AS LiczbaZawodowPierwszaPolowa2019
FROM [KursSQL].[dbo].[Zawody]
WHERE Data BETWEEN '2019-01-01' AND '2019-07-01';

SELECT COUNT(Data) AS LiczbaZawodowPierwszaPolowa2019
FROM [KursSQL].[dbo].[Zawody]
WHERE Data < '2019-07-01';

-- Ile jest kobiet wśród zawodników?
SELECT COUNT(*) AS LiczbaKobiet
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE RIGHT(Imie, 1) = 'a';

SELECT COUNT(*) AS LiczbaKobiet
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE SUBSTRING(PESEL, 10, 1) IN ('0', '2', '4', '6', '8'); -- PESEL dla kobiet ma parzysta cyfre na 10 pozycji

-- Wyświetl imiona, nazwiska i inicjały zawodników
SELECT Imie, Nazwisko, CONCAT(LEFT(Imie, 1), LEFT(Nazwisko,1)) AS Inicjaly
FROM [KursSQL].[dbo].[Zawodnicy];

SELECT Imie, Nazwisko, LEFT(Imie, 1) + LEFT(Nazwisko,1) AS Inicjaly
FROM [KursSQL].[dbo].[Zawodnicy];

-- Ilu kibiców nie jest zrzeszonych w stowarzyszeniu?
SELECT COUNT(*) AS LiczbaKibicowNiezrzeszonych
FROM [KursSQL].[dbo].[Kibice]
WHERE NrStowarzyszenia IS NULL;

SELECT COUNT(*) - COUNT(NrStowarzyszenia) AS LiczbaKibicowNiezrzeszonych
FROM [KursSQL].[dbo].[Kibice];

-- Ile zdobyto pucharów?
SELECT COUNT(*) AS LiczbaPucharow
FROM [KursSQL].[dbo].[Trofea]
WHERE ZdobyteTrofeum LIKE '%puchar%';