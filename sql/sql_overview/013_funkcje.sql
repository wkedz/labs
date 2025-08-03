-- Nalzey rozwazyc uzycie funkcji, poniewaz zostanie ona uruchoniona dla kazdego wywolania
-- moz warto obliczyc raz, i wykorzystac ta wartosc w zmiennej.

-- Funkcje warto uzyc, dla wierszy dla ktorych i tak musimy wykonac jakies obliczenia.
-- Wtedy, dobrze jest zamknac te obliczenia w funkcji, aby nie powtarzac kodu.
--Stwórz funkcję zamiany kwoty brutto na netto
GO
DROP FUNCTION IF EXISTS dbo.netto;

GO
CREATE FUNCTION dbo.netto(@kwota decimal(10,2))
	RETURNS decimal(10,2)
BEGIN
    DECLARE @wynik decimal(10,2)
    SELECT @wynik = @kwota / 1.23
    RETURN @wynik
END
GO
SELECT dbo.netto(123)

GO
--Stwórz funkcję zwracającą najlepszy rekord na 100m
DROP FUNCTION IF EXISTS dbo.rekord;

GO
CREATE FUNCTION dbo.rekord()
RETURNS decimal(10,2)
BEGIN
    DECLARE @wynik decimal(10,2)

    SELECT @wynik = MIN(Czas_s)
    FROM [KursSQL].[dbo].[Rekord100m]

    RETURN @wynik
END

GO
SELECT dbo.rekord()

--Wykorzystując funkcję z poprzedniego ćwiczenia 
--Policz ile każdemu zawodnikowi brakuje do rekordu
--i posortuj od rekordów najbliższym najlepszemu wynikowi
SELECT z.Imie, z.Nazwisko, r.Czas_s - dbo.rekord() AS Rekord
FROM [KursSQL].[dbo].[Zawodnicy] AS z
    INNER JOIN [KursSQL].[dbo].[Rekord100m] AS r
        ON z.IdZawodnicy = r.NrZawodnika
ORDER BY Rekord

-- Lepsze rozwiaznie
GO
DECLARE @rekord DECIMAL(10,2) = dbo.rekord()

SELECT z.Imie, z.Nazwisko, r.Czas_s - @rekord AS Rekord
FROM [KursSQL].[dbo].[Zawodnicy] AS z
    INNER JOIN [KursSQL].[dbo].[Rekord100m] AS r
        ON z.IdZawodnicy = r.NrZawodnika
ORDER BY Rekord

--Stwórz funkcję liczącą VAT od podanej kwoty (odejmując cenę brutto od netto)
GO
CREATE FUNCTION dbo.kwotaVAT(@kwota decimal(10,2))
RETURNS decimal(10,2)
BEGIN
	DECLARE @wynik decimal(10,2)
	DECLARE @netto decimal(10,2)

	SELECT @netto = @kwota / 1.23

	SELECT @wynik = @kwota - @netto

	RETURN @wynik
END

--Wykorzystaj funkcję w widoku informującym o kupionych biletach

--Stwórz widok, który zawiera informacje o kupionych biletach:
--nazwę zawodów, cenę biletu, liczbę biletów sprzedanych w tej cenie,
--kwotę brutto i netto (-23% VATu), jaką kibice zapłacili za bilety
--informację o kwocie podatku VAT 23%
GO
CREATE VIEW Bilety
AS
SELECT z.Nazwa, 
	kz.CenaBiletu, 
	COUNT(*) AS LiczbaBiletow,
	CAST(SUM(CenaBiletu) as decimal(10,2)) AS Brutto,
	CAST(SUM(CenaBiletu) / 1.23 as decimal(10,2)) AS Netto,
	dbo.kwotaVAT(SUM(CenaBiletu)) AS VAT
	--CAST(SUM(CenaBiletu) as decimal(10,2)) - CAST(SUM(CenaBiletu) / 1.23 as decimal(10,2)) AS VAT
FROM [KursSQL].[dbo].[Zawody] AS z
	INNER JOIN [KursSQL].[dbo].[KibicZawody] AS kz
		ON kz.NrZawodow = z.IdZawody
GROUP BY kz.CenaBiletu, z.Nazwa

GO
SELECT *
FROM Bilety

--Wyświetl informację o sumie kosztów każdej sprzedanej pamiątki netto i kwocie VAT
--koszt = cena sprzedaży - marża
--wykorzystaj utworzone wcześniej funkcje
GO
SELECT p.Nazwa,
	dbo.netto(SUM(p.Cena - tp.Marza)) AS KosztNetto,
	dbo.kwotaVAT(SUM(p.Cena - tp.Marza)) AS KwotaVAT
FROM [KursSQL].[dbo].[Zakupy] AS z
	INNER JOIN [KursSQL].[dbo].[Pamiatki] AS p	
		ON z.NrPamiatki = p.IdPamiatki
	INNER JOIN [KursSQL].[dbo].[TypyPamiatek] AS tp
		ON tp.IdTypyPamiatek = p.TypPamiatki
GROUP BY p.Nazwa

--Stwórz funkcję wyświetlającą płeć na podstawie PESELu
GO
CREATE FUNCTION dbo.plec(@PESEL varchar(max))
RETURNS varchar(max)
BEGIN
	DECLARE @wynik varchar(max) = 'mężczyzna'
	
	IF @PESEL LIKE '%[02468]_'
		SELECT @wynik = 'kobieta'

	RETURN @wynik
END

--Wykorzystaj funkcję i policz ile mamy kobiet i mężczyzn wśród zawodników
GO
SELECT dbo.plec(PESEL) AS Plec, COUNT(*) AS LiczbaZawodnikow
FROM [KursSQL].[dbo].[Zawodnicy]
GROUP BY dbo.plec(PESEL)
