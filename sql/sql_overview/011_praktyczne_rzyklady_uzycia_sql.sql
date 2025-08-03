-- ZMIENNE
-- @ - moja lokalna zmienna
-- @@ - zmienna globalna

--Znajdź pamiątki kosztujące więcej niż średnia cena pamiątek
DECLARE @srednia decimal(10,2);

SELECT @srednia = AVG(Cena) -- zmienna jest dostepna w kontekscie, czyli w kwerendzie trzeba rowniez wykonac kod, ktory deklaruje zmienna
FROM [KursSQL].[dbo].[Pamiatki];

SELECT *
FROM [KursSQL].[dbo].[Pamiatki]
WHERE Cena > @srednia;

-- vs
SELECT *
FROM [KursSQL].[dbo].[Pamiatki]
WHERE Cena > (
    -- lepiej wykorzystac zmienna, poniewaz moze sie zdarzyc, ze silnik bedzie 
    -- wykonywal tego SELECTA dla każdego wiersza,
    -- a tak mamy juz ja obliczona w zmiennej.
    SELECT AVG(Cena) 
    FROM [KursSQL].[dbo].[Pamiatki]
    );


--Usuń wszystkie wsparcia CPNu
DECLARE @cpnId int;

SELECT @cpnId = IdSponsorzy
FROM [KursSQL].[dbo].[Sponsorzy]
WHERE Nazwa = 'CPN';

SELECT @cpnId;

DELETE FROM [KursSQL].[dbo].[Sponsoring]
WHERE IdSponsora = @cpnId;

-- IDENTYFIKATORY
--Dodaj Stowarzyszenie Miłośników Odpoczynku i dodaj nowego kibica należącego do niego
--Dodaj Stowarzyszenie Miłośników Odpoczynku i dodaj nowego kibica należącego do niego
INSERT INTO [KursSQL].[dbo].[Stowarzyszenia](Nazwa)
VALUES ('Stowarzyszenie Miłośników Odpoczynku')

DECLARE @idStowarzyszenia int
SELECT @idStowarzyszenia = SCOPE_IDENTITY() -- zwraca nam ostatnia wartosc klucza w kontekscie wykonania.

INSERT INTO [KursSQL].[dbo].[Kibice](Imie, Nazwisko, NrStowarzyszenia)
VALUES ('Jan', 'Odpoczywający', @idStowarzyszenia)

SELECT @@IDENTITY -- ostatnia wartosc wstawionego klucza
SELECT MAX(IdKibice) FROM [KursSQL].[dbo].[Kibice]

-- SKRYPTY
--Przygotuj skrypt pozwalający nam dodawać kibiców
DECLARE @imie varchar(max)
DECLARE @nazwisko varchar(max)

--DECLARE @imie varchar(max) = 'Jan'
--DECLARE @nazwisko varchar(max) 'Janowy'

----------------------------------------------------------------------------------
SELECT @imie = 'Jan'
SELECT @nazwisko = 'Janowy'
----------------------------------------------------------------------------------

INSERT INTO [KursSQL].[dbo].[Kibice](Imie, Nazwisko)
VALUES (@imie, @nazwisko)

--Poprzedni skrypt rozwiń o możliwość przypisania kibica do stowarzyszenia
DECLARE @imie varchar(max)
DECLARE @nazwisko varchar(max)
DECLARE @idStowarzyszenia int = NULL
DECLARE @nazwaStowarzyszenia varchar(max)

----------------------------------------------------------------------------------
SELECT @imie = 'Jan'
SELECT @nazwisko = 'Janowy'
SELECT @nazwaStowarzyszenia = 'Polski Związek Kibiców Sportowych'
----------------------------------------------------------------------------------

SELECT @idStowarzyszenia = IdStowarzyszenia
FROM [KursSQL].[dbo].[Stowarzyszenia]
WHERE Nazwa = @nazwaStowarzyszenia

INSERT INTO [KursSQL].[dbo].[Kibice](Imie, Nazwisko, NrStowarzyszenia)
VALUES (@imie, @nazwisko, @idStowarzyszenia)

SELECT *
FROM [KursSQL].[dbo].[Stowarzyszenia]

SELECT *
FROM [KursSQL].[dbo].[Kibice]

-- WYSZUKIWANIE LOSOWYCH WIERSZY
--Wylosuj nagrodę w konkursie Wielkie Losowanie i przypisz ją do Zuzanny Nowak
SELECT NEWID() -- 100% szan ze sie nie powtórzy
--UNIQUEIDENTIFIER

DECLARE @idNagrody int
SELECT TOP 1 @idNagrody = IdPamiatki
FROM [KursSQL].[dbo].[Pamiatki]
ORDER BY NEWID();

DECLARE @idKibica int
SELECT @idKibica = IdKibice
FROM [KursSQL].[dbo].[Kibice] 
WHERE Imie = 'Zuzanna' AND Nazwisko = 'Nowak'

INSERT INTO [KursSQL].[dbo].[KonkursyDlaKibicow](Nazwa, NrNagrody, Zwyciezca)
VALUES('Wielkie Losowanie', @idNagrody, @idKibica)

SELECT *
FROM [KursSQL].[dbo].[KonkursyDlaKibicow]

-- INSTRUKCJA WARUNKOWA
--Dodaj zakup losowej pamiątki podczas pierwszych zawodów dla Anny Nieistniejącej.
--Jeśli nie istnieje w bazie, wtedy ją dodaj

DECLARE @idAnny int
SELECT @idAnny = IdKibice
FROM [KursSQL].[dbo].[Kibice]
WHERE Imie = 'Anna' AND Nazwisko = 'Nieistniejąca'

IF @idAnny IS NULL
BEGIN
    INSERT INTO [KursSQL].[dbo].[Kibice](Imie, Nazwisko)
    VALUES('Anna', 'Nieistniejąca')

    SELECT @idAnny = SCOPE_IDENTITY()
END

DECLARE @idPamiatki int
SELECT @idPamiatki = IdPamiatki
FROM [KursSQL].[dbo].[Pamiatki]
ORDER BY NEWID()

INSERT INTO [KursSQL].[dbo].[Zakupy](IdZawodow, NrKlienta, NrPamiatki)
VALUES(1, @idAnny, @idPamiatki)

SELECT *
FROM [KursSQL].[dbo].[Zakupy] AS z
    INNER JOIN [KursSQL].[dbo].[Kibice] AS k
        ON k.IdKibice = z.NrKlienta
WHERE Nazwisko = 'Nieistniejąca'

--Jeśli nie istnieje Jan Nieistniejący wśród kibiców, to go dodaj
SELECT 1 FROM [KursSQL].[dbo].[Kibice] WHERE Imie = 'Jan' AND Nazwisko = 'Nieistniejący'

IF NOT EXISTS(SELECT 1 FROM [KursSQL].[dbo].[Kibice] WHERE Imie = 'Jan' AND Nazwisko = 'Nieistniejący')
    INSERT INTO [KursSQL].[dbo].[Kibice](Imie, Nazwisko)
    VALUES('Jan', 'Nieistniejący')
ELSE
    PRINT('Jan istnieje.')

-- TRANSAKCJE
--Usuń testowo wszystkie zakupy pamiątki nr 4
BEGIN TRAN
    DELETE FROM [KursSQL].[dbo].[Zakupy]
    WHERE NrPamiatki = 4

    SELECT *
    FROM [KursSQL].[dbo].[Zakupy]
    WHERE NrPamiatki = 4

ROLLBACK -- TO WYCOFA ZMIANY
-- COMMIT -- TO ZAPISZE ZMIANY

SELECT *
FROM [KursSQL].[dbo].[Zakupy]
WHERE NrPamiatki = 4

--Przypisz Jana Wróblewskiego do stowarzyszenia nr 1. 
--Skrypt nie powinien działać jeśli mamy więcej niż jedną taką osobę
BEGIN TRAN
    UPDATE [KursSQL].[dbo].[Kibice]
    SET NrStowarzyszenia = 1
    WHERE Imie = 'Jan' 
        AND Nazwisko = 'Wróblewski'

    IF @@ROWCOUNT > 1
        BEGIN
            ROLLBACK
            print('wycofano zmiany')
        END
    ELSE
        BEGIN
            COMMIT
            print('skrypt wykonany poprawnie')
        END

INSERT INTO [KursSQL].[dbo].[Kibice](Imie, Nazwisko)
VALUES('Jan', 'Wróblewski')

SELECT *
FROM [KursSQL].[dbo].[Kibice]
WHERE Imie = 'Jan' 
    AND Nazwisko = 'Wróblewski'

--Stwórz nową dyscyplinę i dodaj zawodnika, dla którego będzie ona główną dyscypliną
DECLARE @Imie varchar(max) = 'Jan'
DECLARE @Nazwisko varchar(max) = 'Nowy'
DECLARE @NowaDyscyplina varchar(max) = 'Nowa Dyscyplina'

INSERT INTO [KursSQL].[dbo].[Dyscyplina](Nazwa)
VALUES(@NowaDyscyplina);

-- Lepiej wykorzystać SCOPE_IDENTITY(), ponieważ w przypadku wielu wierszy INSERT,
-- zwróci nam ostatni wstawiony klucz, a @@IDENTITY może zwrócić inny klucz,
-- jeśli w bazie jest trigger, który wstawia coś
-- lub jeśli wstawiamy wiele wierszy, to może zwrócić pierwszy klucz.
-- SCOPE_IDENTITY() zwraca ostatni wstawiony klucz w bieżącym kontekście,
-- czyli w tym przypadku będzie to klucz nowo dodanej dyscypliny.
DECLARE @IdDyscypliny int = SCOPE_IDENTITY();

INSERT INTO [KursSQL].[dbo].[Zawodnicy]
VALUES(
    @Imie,
    @Nazwisko,
    CAST(GETDATE() AS date),
    @IdDyscypliny,
    '123456789'
    )

--Dodaj nowy sponsoring na 1000zł dla podanych z nazwy zawodów i wybranego z nazwy sponsora
--Skrypt ma działać tylko dla jednych zawodów
DECLARE @zawody varchar(max) = 'Mistrzostwa Powiatu Grajewskiego'
DECLARE @sponsor varchar(max) = 'CPN'
DECLARE @idSponsor int = NULL

SELECT @idSponsor = IdSponsorzy
FROM [KursSQL].[dbo].[Sponsorzy]
WHERE Nazwa = @sponsor

IF (SELECT 1 FROM [KursSQL].[dbo].[Zawody] WHERE Nazwa = @zawody) = 1
    AND @idSponsor IS NOT NULL
BEGIN
    DECLARE @idZawody int = (SELECT IdZawody FROM [KursSQL].[dbo].[Zawody] WHERE Nazwa = @zawody)
    INSERT INTO [KursSQL].[dbo].[Sponsoring](IdSponsora, Kwota, Zawody)
    VALUES(@idSponsor, 1000, @idZawody)
END

SELECT *
FROM [KursSQL].[dbo].[Sponsoring]

--Rozwiń poprzedni skrypt o dodanie sponsora, jeśli nie mamy go w bazie
BEGIN TRAN

DECLARE @zawody varchar(max) = 'Mistrzostwa Powiatu Grajewskiego'
DECLARE @sponsor varchar(max) = 'Firma Krzak'
DECLARE @idSponsor int = (SELECT IdSponsorzy FROM Sponsorzy WHERE Nazwa = @sponsor)

IF @idSponsor IS NULL
BEGIN
    INSERT INTO [KursSQL].[dbo].[Sponsorzy](Nazwa)
    VALUES(@sponsor)
    SELECT @idSponsor = SCOPE_IDENTITY()
END

INSERT INTO [KursSQL].[dbo].[Sponsoring](IdSponsora, Zawody, Kwota)
SELECT @idSponsor, IdZawody, 1000
FROM [KursSQL].[dbo].[Zawody]
WHERE Nazwa = @zawody

IF @@ROWCOUNT <> 1
    BEGIN
        ROLLBACK
        print('Zła ilość zawodów')
    END
ELSE
    BEGIN
        COMMIT
        PRINT('Dodano wpłatę sponsora')
    END
