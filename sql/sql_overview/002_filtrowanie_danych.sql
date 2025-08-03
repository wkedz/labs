-- Znajdz wszystkie Dagmary
SELECT * 
FROM [KursSQL].[dbo].[Kibice]
WHERE Imie = 'Dagmara';

-- Znajdz bilety, ktore kosztowaly przynajmniej 100 zl
SELECT *
FROM [KursSQL].[dbo].[KibicZawody]
WHERE CenaBiletu >= 100;

-- Znajdz wszsytkich zawodnikow, poza Faustyna
SELECT *
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE Imie <> 'Faustyna'; -- mozna !=, ale stosujemy <>

-- Znajdz kibicow, ktorzy nie nalezy do zadnego stowarzyszenia
SELECT * 
FROM [KursSQL].[dbo].[Kibice]
WHERE NrStowarzyszenia IS NULL; 

-- Znajdz kibicow o imieiu Olga, i Dagmara
SELECT *
FROM [KursSQL].[dbo].[Kibice]
WHERE Imie IN ('Olga', 'Dagmara');

-- Znajdz zawodniko poza Faustyna, Lidia, i Januszem
SELECT *
FROM [KursSQL].[dbo].[Kibice]
WHERE Imie NOT IN ('Faustyna', 'Lidia', 'Janusz');

-- Znajdz zawodu, ktore odbyly sie 18 maja 2019
SELECT *
FROM [KursSQL].[dbo].[Zawody]
WHERE DATA = '2019-05-18'; -- musza byc apostrofy, w przeciwnym razie zrobi z tego operacje odejmowania 2019 - 05 - 18

-- Żeby sprawdzi, jaki mamy format daty mozna zamienic miejscami miesiac dziem np, 2019-18-05 i tutaj sie wywali.
SELECT *
FROM [KursSQL].[dbo].[Zawody]
WHERE DATA = '2019-18-5'; -- musza byc apostrofy, w przeciwnym razie zrobi z tego operacje odejmowania 2019 - 05 - 18 (system amerykanski)

-- Started executing query at Line 37
-- Msg 242, Level 16, State 3, Line 1
-- The conversion of a varchar data type to a datetime data type resulted in an out-of-range value.

-- Znajdz zawody, ktore odbykly sie w wakacje
SELECT *
FROM [KursSQL].[dbo].[Zawody]
WHERE DATA BETWEEN '2019-07-01' AND '2019-08-31';

-- Znajdz bilety z zawodow nr 1 kosztujacych maksymalnie 50 zl
SELECT *
FROM [KursSQL].[dbo].[KibicZawody]
WHERE NrZawodow = 1 AND CenaBiletu <= 50;

-- Znajdz Olgi i Dagmary
SELECT *
FROM [KursSQL].[dbo].[Kibice]
WHERE Imie = 'Olga' OR Imie = 'Dagmara'; 

-- Znajdz zawody ktore odbywy sie w wakacje
SELECT *
FROM [KursSQL].[dbo].[Zawody]
WHERE DATA >= '2019-07-01' AND DATA <= '2019-08-31';

-- Znajdz wszsytkie zdobyte zlote trofea (LIKE)
-- RACZEJ NIE UZYWAJ LIKE, BO JEST TO NIEOPTYMALNE
SELECT *
FROM [KursSQL].[dbo].[Trofea]
WHERE ZdobyteTrofeum LIKE '%złot%';

-- Znajdz wszystkie zawodniczki (koncza sie na a)
SELECT *
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE Imie LIKE '%a';

SELECT *
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE PESEL LIKE '%[02468]_'; -- 10 znak w PESEL musi byc cyfra parzysta, _ ostani dowolny znak
-- rozbicie 
-- % - dowolne cos
-- [02468] - cyfra parzysta
-- _ - dowolny znak

-- %%%%%%%%%[_
-- ___________

-- Pokaż bilety, które kosztuja j 100zł
SELECT *
FROM [KursSQL].[dbo].[KibicZawody]
WHERE CenaBiletu = 100;

-- Kiedy urodzila sie zawodniczka Kaja
SELECT DataUrodzenia
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE Imie = 'Kaja';

-- Jakie mozna zdobyc puchary
SELECT DISTINCT ZdobyteTrofeum
FROM [KursSQL].[dbo].[Trofea]
WHERE ZdobyteTrofeum LIKE '%puchar%';

-- Pokaz nazwy miejsc, gdzie odbyly sie zawody w Grajewie
SELECT Nazwa
FROM [KursSQL].[dbo].[Miejsce]
WHERE Miejscowosc = 'Grajewo';

-- Znajdź kibiców, którzy nie należą do żadnego sotwarzyszenia
SELECT *
FROM [KursSQL].[dbo].[Kibice]
WHERE NrStowarzyszenia IS NULL AND Imie NOT LIKE '%a';

-- Pokaż zawodników urodzonych w latach 90tych
SELECT * 
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE DataUrodzenia BETWEEN '1990-01-01' AND '1999-12-31';

-- Znajdz wszystkich mężczyzn wsrod zawodnikow
SELECT *
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE Pesel NOT LIKE '%[13579]_';

-- Pokaz wszystkie zdobyte grajewskie puchary
SELECT *
FROM [KursSQL].[dbo].[Trofea]
WHERE ZdobyteTrofeum LIKE '%puchar%' AND ZdobyteTrofeum LIKE '%grajew%';

-- Pokaz zawody, ktore odbyly sie w pierwszej polowie 2019 roku
SELECT *
FROM [KursSQL].[dbo].[Zawody]
WHERE Data >= '2019-01-01' 
    AND Data <= '2019-06-30';