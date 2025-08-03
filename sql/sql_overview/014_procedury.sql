--Stwórz procedurę, która znajdzie zawodnika po Nazwisku
GO
CREATE PROCEDURE ZnajdzZawodnika
    @nazwisko varchar(max)
AS
BEGIN
    SELECT *
    FROM [KursSQL].[dbo].[Zawodnicy]
    WHERE Nazwisko = @nazwisko
END;

--Rozwiń poprzednią procedurę o szukanie po imieniu lub nazwisku
--oba parametry powinny być opcjonalne
GO
ALTER PROCEDURE ZnajdzZawodnika
    @imie varchar(max) = null,
    @nazwisko varchar(max) = null
AS
BEGIN
    SELECT *
    FROM [KursSQL].[dbo].[Zawodnicy]
    WHERE (@imie IS NULL OR Imie = @imie)
        AND (@nazwisko IS NULL OR Nazwisko = @nazwisko)
END

EXEC ZnajdzZawodnika
EXEC ZnajdzZawodnika @imie = 'Kaja'
EXEC ZnajdzZawodnika @nazwisko = 'Wiśniewska'
EXEC ZnajdzZawodnika 
    @imie = 'Janusz',
    @nazwisko = 'Baran'

--Stwórz procedurę, która przypisze podanemu kibicowi wylosowaną nagrodę w podanym konkursie
GO
CREATE PROCEDURE WygranaWKonkursie
    @nazwaKonkursu varchar(max),
    @imieZwyciezcy varchar(max),
    @nazwiskoZwyciezcy varchar(max)
AS
BEGIN
    DECLARE @idNagrody int

    SELECT 
        TOP 1 @idNagrody = IdPamiatki
    FROM 
        [KursSQL].[dbo].[Pamiatki]
    ORDER BY
         NEWID()

    DECLARE @idKibica int
    SELECT @idKibica = IdKibice
    FROM [KursSQL].[dbo].[Kibice] 
    WHERE Imie = @imieZwyciezcy 
        AND Nazwisko = @nazwiskoZwyciezcy

    INSERT INTO [KursSQL].[dbo].[KonkursyDlaKibicow](Nazwa, NrNagrody, Zwyciezca)
    VALUES(@nazwaKonkursu, @idNagrody, @idKibica)
END

SELECT *
FROM [KursSQL].[dbo].[KonkursyDlaKibicow]

--Zabezpiecz poprzednią procedurę przed podaniem nieistniejącego kibica
GO
ALTER PROCEDURE WygranaWKonkursie
    @nazwaKonkursu varchar(max),
    @imieZwyciezcy varchar(max),
    @nazwiskoZwyciezcy varchar(max)
AS
BEGIN
    DECLARE @idNagrody int

    SELECT TOP 1 @idNagrody = IdPamiatki
    FROM [KursSQL].[dbo].[Pamiatki]
    ORDER BY NEWID()

    DECLARE @idKibica int
    SELECT @idKibica = IdKibice
    FROM Kibice 
    WHERE Imie = @imieZwyciezcy AND Nazwisko = @nazwiskoZwyciezcy

    IF @idKibica IS NOT NULL
        INSERT INTO [KursSQL].[dbo].[KonkursyDlaKibicow](Nazwa, NrNagrody, Zwyciezca)
        VALUES(@nazwaKonkursu, @idNagrody, @idKibica)
    ELSE
        SELECT 'Nie znaleziono takiego kibica'
END

GO
--Rozwiń poprzednią procedurę:
--Jeśli podamy nieistniejącego kibica, wtedy dodaje go do bazy danych
--Można podać nazwę stowarzyszenia dla nowo dodawanego kibica
--Ewentualne nowe stowarzyszenie dodajemy tylko w momencie, gdy dodajemy kibica
--Jeśli stowarzyszenie nie istnieje, wtedy należy je dodać
ALTER PROCEDURE WygranaWKonkursie
    @nazwaKonkursu varchar(max),
    @imieZwyciezcy varchar(max),
    @nazwiskoZwyciezcy varchar(max),
    @nazwaStowarzyszenia varchar(max) = NULL
AS
BEGIN
    DECLARE @idNagrody int

    SELECT TOP 1 @idNagrody = IdPamiatki
    FROM [KursSQL].[dbo].[Pamiatki]
    ORDER BY NEWID()

    DECLARE @idStowarzyszenia int

    DECLARE @idKibica int
    SELECT @idKibica = IdKibice
    FROM [KursSQL].[dbo].[Kibice] 
    WHERE Imie = @imieZwyciezcy AND Nazwisko = @nazwiskoZwyciezcy

    IF @idKibica IS NULL
    BEGIN
        SELECT @idStowarzyszenia = IdStowarzyszenia
        FROM [KursSQL].[dbo].[Stowarzyszenia]
        WHERE Nazwa = @nazwaStowarzyszenia

        IF @idStowarzyszenia IS NULL
        BEGIN
            INSERT INTO [KursSQL].[dbo].[Stowarzyszenia](Nazwa)
            VALUES(@nazwaStowarzyszenia)

            SELECT @idStowarzyszenia = SCOPE_IDENTITY()
        END

        INSERT INTO [KursSQL].[dbo].[Kibice](Imie, Nazwisko, NrStowarzyszenia)
        VALUES(@imieZwyciezcy, @nazwiskoZwyciezcy, @idStowarzyszenia)

        SELECT @idKibica = SCOPE_IDENTITY()
    END

    INSERT INTO [KursSQL].[dbo].[KonkursyDlaKibicow](Nazwa, NrNagrody, Zwyciezca)
    VALUES(@nazwaKonkursu, @idNagrody, @idKibica)
END

--Stwórz procedurę wyświetlającą sprzedaż biletów podczas wszystkich zawodów 
--dla podanego miesiąca i roku
--sprzedaż, czyli: liczba sprzedanych biletów, suma kwoty, suma kwoty pomniejszona o 23% VAT (netto)
GO
CREATE PROCEDURE SrzedazBiletow
    @miesiac int,
    @rok int
AS
BEGIN
    SELECT z.Nazwa,
        COUNT(*) AS LiczbaBiletow,
        SUM(kz.CenaBiletu) AS BiletyBrutto,
        CAST(SUM(kz.CenaBiletu) / 1.23 AS decimal(10,2)) AS BiletyNetto
    FROM [KursSQL].[dbo].[KibicZawody] AS kz
        INNER JOIN [KursSQL].[dbo].[Zawody] AS z
            ON kz.NrZawodow = z.IdZawody
    WHERE YEAR(z.Data) = @rok
        AND MONTH(z.Data) = @miesiac
    GROUP BY z.Nazwa
END

--Stwórz procedurę zdobywania trofeum. 
--Pamiętaj, że może zdobyć je zawodnik, 
--który nie istnieje w naszej bazie danych, wtedy należy zwrócić odpowiedni komunikat
--dyscyplinę i zawody podajemy z nazwy
--jeśli dyscyplina lub zawody nie istnieją, wtedy zwracamy odpowiedni komunikat
GO
CREATE PROCEDURE ZdobycieTrofeum
    @nazwaTrofeum varchar(max),
    @imieZawodnika varchar(max),
    @nazwiskoZawodnika varchar(max),
    @nazwaDyscypliny varchar(max),
    @nazwaZawodow varchar(max)
AS
BEGIN
    DECLARE @idDyscypliny int
    SELECT @idDyscypliny = IdDyscyplina
    FROM [KursSQL].[dbo].[Dyscyplina]
    WHERE Nazwa = @nazwaDyscypliny

    DECLARE @idZawodow int
    SELECT @idZawodow = IdZawody
    FROM [KursSQL].[dbo].[Zawody]
    WHERE Nazwa = @nazwaZawodow

    DECLARE @idZawodnika int
    SELECT @idZawodnika = IdZawodnicy
    FROM [KursSQL].[dbo].[Zawodnicy]
    WHERE Imie = @imieZawodnika AND Nazwisko = @nazwiskoZawodnika

    IF @idDyscypliny IS NULL
        PRINT('Brak dyscypliny o podanej nazwie')

    IF @idZawodow IS NULL
        PRINT('Brak zawodów o podanej nazwie')

    IF @idZawodnika IS NULL
        PRINT('Brak zawodnika o podanym imieniu i nazwisku')

    IF @idDyscypliny IS NOT NULL 
        AND @idZawodow IS NOT NULL
        AND @idZawodnika IS NOT NULL
    BEGIN
        INSERT INTO [KursSQL].[dbo].[Trofea](IdZawodow, NrDyscyplinySportowej, NrZawodnika, ZdobyteTrofeum)
        VALUES(@idZawodow, @idDyscypliny, @idZawodnika, @nazwaTrofeum)
    END
END
