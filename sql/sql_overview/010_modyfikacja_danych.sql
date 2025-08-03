--Dodaj siebie jako zawodnika
INSERT INTO [KursSQL].[dbo].[Zawodnicy]
VALUES ('Jan', 'Kowalski', '1990-01-01', 1, '12345678901');

SELECT *
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE Nazwisko = 'Kowalski';

--Dodaj siebie i swojego znajomego jako kibiców nienależących do żadnego stowarzyszenia
INSERT INTO [KursSQL].[dbo].[Kibice](Imie, Nazwisko)
VALUES ('Jan', 'Snieg'),
    ('Jan', 'Znajomy');

SELECT *
FROM [KursSQL].[dbo].[Kibice]
WHERE Nazwisko IN ('Snieg', 'Znajomy');

--Dodaj kopię Maskotki z ceną o 10% wyższą (z dokładnością do 10 groszy)
INSERT INTO [KursSQL].[dbo].[Pamiatki](Nazwa, Cena, TypPamiatki, CzyDostepneWszedzie)
(
    SELECT Nazwa, ROUND(Cena * 1.1, 1), TypPamiatki, CzyDostepneWszedzie
    FROM [KursSQL].[dbo].[Pamiatki]
    WHERE Nazwa = 'Maskotka'
);

SELECT * FROM [KursSQL].[dbo].[Pamiatki] WHERE Nazwa = 'Maskotka';

--Policz ile zarobiliśmy na każdym typie pamiątek. Wynik zapisz w nowej tabeli Zarobek
SELECT tp.Nazwa, SUM(Marza) AS Zarobek
INTO [KursSQL].[dbo].[Zarobek]
FROM [KursSQL].[dbo].[TypyPamiatek] tp
    INNER JOIN [KursSQL].[dbo].[Pamiatki] p
        ON p.TypPamiatki = tp.IdTypyPamiatek
    INNER JOIN [KursSQL].[dbo].[Zakupy] z
        ON z.NrPamiatki = p.IdPamiatki
GROUP BY tp.Nazwa;

SELECT * FROM [KursSQL].[dbo].[Zarobek];

--Ustaw cenę Latawca na 23zł
UPDATE [KursSQL].[dbo].[Pamiatki]
SET Cena = 23
WHERE Nazwa = 'Latawiec';

--Podnieś ceny pamiątek o 10% (z zaokrągleniem do 10 groszy)
UPDATE [KursSQL].[dbo].[Pamiatki]
SET Cena = Cena + CAST(Cena * 0.1 AS decimal(10,1));

--Zaktualizuj rekord Zuzannie Kwiatkowskiej na 10.93s
UPDATE r
SET Czas_s = 10.93
FROM [KursSQL].[dbo].[Rekord100m] AS r
    INNER JOIN [KursSQL].[dbo].[Zawodnicy] AS z
        ON z.IdZawodnicy = r.NrZawodnika
WHERE Imie = 'Zuzanna' AND Nazwisko = 'Kwiatkowska';

SELECT *
FROM [KursSQL].[dbo].[Zawodnicy] AS z
    INNER JOIN [KursSQL].[dbo].[Rekord100m] AS r
        ON z.IdZawodnicy = r.NrZawodnika
WHERE Imie = 'Zuzanna' AND Nazwisko = 'Kwiatkowska';

--Usuń siebie z tabeli z kibicami
SELECT *
FROM [KursSQL].[dbo].[Kibice]
WHERE Imie = 'Jan' AND Nazwisko = 'Snieg';

DELETE FROM [KursSQL].[dbo].[Kibice]
WHERE Imie = 'Jan' AND Nazwisko = 'Snieg';

--Wyczyść tabelę z rekordami
DELETE FROM [KursSQL].[dbo].[Rekord100m]; -- Zapamietuje klucze, wiec inkrementacja zaczyna sie od ostatniego id
TRUNCATE TABLE Rekord100m;  -- Calkowice usuwa tabele, a id zaczyna sie od 1. Jest znacznie szybsze, ale nie mozna podawac warunkow.

INSERT INTO [KursSQL].[dbo].[Rekord100m](NrZawodnika, Czas_s)
VALUES (1, 1);

SELECT *
FROM [KursSQL].[dbo].[Rekord100m];

--Usuń wszystkie zakupy z czerwca 2019 poza 12 czerwca
SELECT *
FROM [KursSQL].[dbo].[Zakupy] AS z
     INNER JOIN [KursSQL].[dbo].[Zawody] AS za
            ON za.IdZawody = z.IdZawodow
WHERE YEAR(za.Data) = 2019
    AND MONTH(za.Data) = 6 
    AND DAY(za.Data) != 12;

DELETE z
FROM [KursSQL].[dbo].[Zakupy] AS z
     INNER JOIN [KursSQL].[dbo].[Zawody] AS za
            ON za.IdZawody = z.IdZawodow
WHERE YEAR(za.Data) = 2019
    AND MONTH(za.Data) = 6 
    AND DAY(za.Data) != 12;


--Dodaj nowe zawody, które odbędą się dzisiaj na Stadionie Lekkoatletycznym w Lublinie
SELECT *
FROM [KursSQL].[dbo].[Zawody];

SELECT *
FROM [KursSQL].[dbo].[Miejsce];

SELECT *
FROM [KursSQL].[dbo].[Miejsce]
WHERE Nazwa = 'Stadion Lekkoatletyczny'
    AND Miejscowosc = 'Lublin';

INSERT INTO [KursSQL].[dbo].[Zawody](Nazwa, Miejsce, Data)
VALUES (
    'Nowe Zawody',
    (SELECT IdMiejsce FROM [KursSQL].[dbo].[Miejsce] WHERE Miejscowosc = 'Lublin'),
    CAST(GETDATE() AS date)
);

INSERT INTO [KursSQL].[dbo].[Zawody](Nazwa, Miejsce, Data)
VALUES ('Nowe zawody', 2, CAST(GETDATE() AS date))

--Podnieś marżę o 1zł na każdym produkcie
SELECT *
FROM [KursSQL].[dbo].[TypyPamiatek];

UPDATE tp
SET Marza = Marza + 1
FROM [KursSQL].[dbo].[TypyPamiatek] AS tp;

--Zmień nazwisko Janowi Znajomemu na Nieznajomy
SELECT Imie, Nazwisko
FROM [KursSQL].[dbo].[Kibice]
WHERE Imie = 'Jan' AND Nazwisko = 'Znajomy';

UPDATE k
SET Nazwisko = 'Nieznajomy'
FROM [KursSQL].[dbo].[Kibice] AS k
WHERE Imie = 'Jan' AND Nazwisko = 'Znajomy';

UPDATE [KursSQL].[dbo].[Kibice]
SET Nazwisko = 'Nieznajomy'
WHERE Imie = 'Jan' 
    AND Nazwisko = 'Znajomy';

--Dodaj nową pamiątkę. Ma być dostępna wszędzie i być typu, który jeszcze nie był wykorzystywany
SELECT tp.IdTypyPamiatek
FROM [KursSQL].[dbo].[Pamiatki] AS p
    RIGHT JOIN [KursSQL].[dbo].[TypyPamiatek] tp
        ON tp.IdTypyPamiatek = p.TypPamiatki
WHERE p.IdPamiatki IS NULL

INSERT INTO [KursSQL].[dbo].[Pamiatki](Nazwa, Cena, TypPamiatki, CzyDostepneWszedzie)
VALUES ('Nowa Pamiątka', 10.00,
        (
            SELECT tp.IdTypyPamiatek
            FROM [KursSQL].[dbo].[Pamiatki] AS p
                RIGHT JOIN [KursSQL].[dbo].[TypyPamiatek] tp
                    ON tp.IdTypyPamiatek = p.TypPamiatki
            WHERE p.IdPamiatki IS NULL
        ),
        1);

--Usuń wszystkie wsparcia CPNu
SELECT *
FROM [KursSQL].[dbo].[Sponsorzy]
WHERE Nazwa = 'CPN'

DELETE FROM [KursSQL].[dbo].[Sponsoring]
WHERE IdSponsora = 3;

DELETE FROM [KursSQL].[dbo].[Sponsoring]
WHERE IdSponsora = (
    SELECT IdSponsora 
    FROM [KursSQL].[dbo].[Sponsorzy] 
    WHERE Nazwa = 'CPN'
);