-- Do czego służą widoki?
--ograniczenie dostępu do danych
--możliwość "zmiany" struktury tabeli
--ukrycie złożoności danych

--Utwórz widok zawierający informacje o zawodnikach
--(imię, nazwisko, płeć, datę urodzenia, nazwę głównej dyscypliny i rekord na 100m)
CREATE VIEW V_Zawodnicy
AS
SELECT Imie,
    Nazwisko,
    CASE WHEN PESEL LIKE '%[02468]_' 
        THEN 'Kobieta' 
        ELSE 'Mężczyzna' END AS Plec,
    DataUrodzenia,
    d.Nazwa AS GlownaDyscyplina,
    r.Czas_s AS RekordNa100m_s
FROM [KursSQL].[dbo].[Zawodnicy] AS z
    INNER JOIN [KursSQL].[dbo].[Dyscyplina] AS d
        ON d.IdDyscyplina = z.GlownaDyscyplina
    INNER JOIN [KursSQL].[dbo].[Rekord100m] AS r
        ON r.NrZawodnika = z.IdZawodnicy
    
--Wykorzystując widok z poprzedniego ćwiczenia
--Policz ile mężczyzn i ile kobiet reprezentuje poszczególne dyscypliny
SELECT Plec, GlownaDyscyplina, COUNT(*) AS LiczbaZawodnikow
FROM V_Zawodnicy
GROUP BY Plec, GlownaDyscyplina

--Wykorzystując widok z pierwszego ćwiczenia
--Znajdź najlepszy rekord na 100m dla każdej z płci, 
--tylko dla zawodników, dla których główną dyscypliną jest dowolny rodzaj biegu
SELECT Plec, MIN(RekordNa100m_s) AS Rekord
FROM V_Zawodnicy
WHERE GlownaDyscyplina LIKE 'Bieg%'
GROUP BY Plec

--Stwórz widok, który zawiera informacje o kupionych biletach:
--nazwę zawodów, cenę biletu, liczbę biletów sprzedanych w tej cenie,
--kwotę brutto i netto (-23% VATu), jaką kibice zapłacili za bilety
CREATE VIEW Bilety
AS
SELECT z.Nazwa,
    kz.CenaBiletu,
    COUNT(*) AS LiczbaBiletow,
    kz.CenaBiletu * COUNT(*) AS KwotaBrutto,
    CAST((kz.CenaBiletu * COUNT(*)) / 1.23 AS decimal(10,2)) AS KwotaNetto
FROM [KursSQL].[dbo].[KibicZawody] AS kz
    INNER JOIN [KursSQL].[dbo].[Zawody] AS z
        ON z.IdZawody = kz.NrZawodow
GROUP BY z.Nazwa, kz.CenaBiletu

SELECT *
FROM Bilety

--Na podstawie widoku z poprzedniego ćwiczenia
--Znajdź 3 rodzaje biletów, których sprzedaliśmy najwięcej
--rodzaj biletu - bilet na wybraną kwotę podczas konkretnych zawodów
SELECT TOP 3 *
FROM Bilety
ORDER BY LiczbaBiletow DESC

--Zmodyfikuj widok, dodając do niego informację o kwocie podatku VAT 23%
ALTER VIEW Bilety
AS
SELECT z.Nazwa,
    kz.CenaBiletu,
    COUNT(*) AS LiczbaBiletow,
    kz.CenaBiletu * COUNT(*) AS KwotaBrutto,
    CAST((kz.CenaBiletu * COUNT(*)) / 1.23 AS decimal(10,2)) AS KwotaNetto,
    kz.CenaBiletu * COUNT(*) - CAST((kz.CenaBiletu * COUNT(*)) / 1.23 AS decimal(10,2)) AS kwotaVAT
FROM [KursSQL].[dbo].[KibicZawody] AS kz
    INNER JOIN [KursSQL].[dbo].[Zawody] AS z
        ON z.IdZawody = kz.NrZawodow
GROUP BY z.Nazwa, kz.CenaBiletu

--Stwórz widok z pełnymi informacjami o sprzedaży pamiątek:
--nazwa pamiątki i typu, cena, cena netto (-23% VAT), marża, data sprzedaży, 
--nazwa i id zawodów, id miejsca
CREATE VIEW Sprzedaz
AS
SELECT p.Nazwa,
    tp.Nazwa AS Typ,
    p.Cena,
    CAST(p.Cena / 1.23 as decimal(10,2)) AS CenaNetto,
    CAST(tp.Marza as decimal(10,2)) AS Marza,
    z.Data AS DataSprzedazy,
    z.Nazwa AS NazwaZawodow,
    z.IdZawody,
    z.Miejsce AS IdMiejsca
FROM [KursSQL].[dbo].[Zawody] AS z
    INNER JOIN [KursSQL].[dbo].[Zakupy] AS za
        ON z.IdZawody = za.IdZawodow
    INNER JOIN [KursSQL].[dbo].[Pamiatki] AS p
        ON p.IdPamiatki = za.NrPamiatki
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] AS tp
        ON tp.IdTypyPamiatek = p.TypPamiatki

SELECT *
FROM Sprzedaz

--Ile pamiątek sprzedaliśmy w każdym z miejsc w Grajewie?
SELECT m.Nazwa, COUNT(*) AS LiczbaPamiatek
FROM Sprzedaz s
    INNER JOIN [KursSQL].[dbo].[Miejsce] m
        ON s.IdMiejsca = m.IdMiejsce
WHERE m.Miejscowosc = 'Grajewo'
GROUP BY m.Nazwa

--Ile pamiątek danego typu sprzedaliśmy na każdym z wydarzeń?
--(Posortuj po typie rosnąco i liczbie sprzedanych pamiątek malejąco)
SELECT Typ, NazwaZawodow, COUNT(*) AS LiczbaPamiatek
FROM Sprzedaz
GROUP BY Typ, NazwaZawodow
ORDER BY Typ, LiczbaPamiatek DESC