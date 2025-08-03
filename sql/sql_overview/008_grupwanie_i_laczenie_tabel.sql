--Pokaż nazwę stowarzyszenia i liczbę kibiców do niego należących
SELECT s.Nazwa, COUNT(*) AS LiczbaKibicow
FROM [KursSQL].[dbo].[Kibice] AS k
    INNER JOIN [KursSQL].[dbo].[Stowarzyszenia] AS s
        ON k.NrStowarzyszenia = s.IdStowarzyszenia
GROUP BY s.Nazwa

--Ile razy została wygrana każda z nagród?
SELECT p.Nazwa, COUNT(*) AS LiczbaWygranych
FROM [KursSQL].[dbo].[Pamiatki] AS p
    INNER JOIN [KursSQL].[dbo].[KonkursyDlaKibicow] AS kdk
        ON p.IdPamiatki = kdk.NrNagrody
GROUP BY p.Nazwa

--Ile zarobiliśmy na każdym typie pamiątek?
SELECT tp.Nazwa, SUM(tp.Marza) AS Zysk
FROM [KursSQL].[dbo].[Zakupy] AS z
    INNER JOIN [KursSQL].[dbo].[Pamiatki] AS p	
        ON p.IdPamiatki = z.NrPamiatki
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] AS tp
        ON tp.IdTypyPamiatek = p.TypPamiatki
GROUP BY tp.Nazwa

--Za ile w sumie sprzedano pamiątki w każdym typie?
SELECT tp.Nazwa, SUM(p.Cena) AS SumaSprzedazy
FROM [KursSQL].[dbo].[Pamiatki] AS p
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] AS tp
        ON p.TypPamiatki = tp.IdTypyPamiatek
GROUP BY tp.Nazwa

--Ile każdy ze sponsorów wpłacił na zawody?
SELECT s.Nazwa, SUM(Kwota) AS SumaWplat
FROM [KursSQL].[dbo].[Sponsorzy] AS s
    INNER JOIN [KursSQL].[dbo].[Sponsoring] AS sp
        ON s.IdSponsorzy = sp.IdSponsora
GROUP BY s.Nazwa

--Ile mamy pamiątek poszczególnych typów?
SELECT tp.Nazwa, COUNT(*) AS LiczbaPamiatek
FROM [KursSQL].[dbo].[Pamiatki] AS p
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] AS tp
        ON p.TypPamiatki = tp.IdTypyPamiatek
GROUP BY tp.Nazwa

--Jaki jest średni rekord na 100m w każdej głównej dyscyplinie
SELECT d.Nazwa, AVG(r.Czas_s) AS SredniCzasRekordu
FROM [KursSQL].[dbo].[Zawodnicy] AS z
    INNER JOIN [KursSQL].[dbo].[Dyscyplina] d
        ON d.IdDyscyplina = z.GlownaDyscyplina
    INNER JOIN [KursSQL].[dbo].[Rekord100m] r
        ON r.NrZawodnika = z.IdZawodnicy
GROUP BY d.Nazwa

--Ile zawodów odbyło się w każdym z miast?
SELECT m.Miejscowosc, COUNT(*) AS LiczbaZawodow
FROM [KursSQL].[dbo].[Zawody] AS z
    INNER JOIN [KursSQL].[dbo].[Miejsce] m
        ON m.IdMiejsce = z.Miejsce
GROUP BY m.Miejscowosc

--Pokaż ile każdy z klientów kupił każdej z pamiątek
SELECT k.Imie, k.Nazwisko, p.Nazwa, COUNT(*) AS LiczbaZakupow
FROM [KursSQL].[dbo].[Zakupy] AS z
    INNER JOIN [KursSQL].[dbo].[Kibice] AS k
        ON z.NrKlienta = k.IdKibice
    INNER JOIN [KursSQL].[dbo].[Pamiatki] AS p
        ON p.IdPamiatki = z.NrPamiatki
GROUP BY k.Imie, k.Nazwisko, p.Nazwa

--Pokaż za jaką kwotę sprzedaliśmy każde z dostępnych wszędzie ubrań
SELECT p.Nazwa, SUM(p.Cena) AS SumaSprzedazy
FROM [KursSQL].[dbo].[Zakupy] AS z
    INNER JOIN [KursSQL].[dbo].[Pamiatki] AS p
        ON p.IdPamiatki = z.NrPamiatki
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] AS tp
        ON tp.IdTypyPamiatek = p.TypPamiatki
WHERE tp.Nazwa = 'Ubrania'
    AND p.CzyDostepneWszedzie = 1
GROUP BY p.Nazwa

--Ile kobiety i ile mężczyźni wydali na bilety?
SELECT IIF(RIGHT(k.Imie, 1) = 'a', 'Kobieta', 'Mężczyzna') AS Plec,
    SUM(kz.CenaBiletu) AS WydatkiNaBilety
FROM [KursSQL].[dbo].[Kibice] AS k
    INNER JOIN [KursSQL].[dbo].[KibicZawody] kz
        ON k.IdKibice = kz.Kibic
GROUP BY IIF(RIGHT(k.Imie, 1) = 'a', 'Kobieta', 'Mężczyzna')

--Ilu kibiców w każdym ze stowarzyszeń wygrało w konkursie? 
--Jeśli ktoś nie należy do żadnego stowarzyszenia wyświetl 'Brak stowrzyszenia'
SELECT ISNULL(s.Nazwa, 'Brak stowarzyszenia'),
    COUNT(*) AS LiczbaWygranych
FROM [KursSQL].[dbo].[Stowarzyszenia] AS s
    RIGHT JOIN [KursSQL].[dbo].[Kibice] AS k
        ON k.NrStowarzyszenia = s.IdStowarzyszenia
    INNER JOIN [KursSQL].[dbo].[KonkursyDlaKibicow] AS kdk
        ON kdk.Zwyciezca = k.IdKibice
GROUP BY ISNULL(s.Nazwa, 'Brak stowarzyszenia')

--Znajdź klientów, którzy kupili więcej niż jedną pamiątkę
SELECT k.Imie, k.Nazwisko
FROM [KursSQL].[dbo].[Zakupy] AS z
    INNER JOIN [KursSQL].[dbo].[Kibice] AS k
        ON k.IdKibice = z.NrKlienta
GROUP BY k.Imie, k.Nazwisko
HAVING COUNT(*) > 1

--Z której dyscypliny zdobyto najwięcej trofeów?
SELECT TOP 1 d.Nazwa
FROM [KursSQL].[dbo].[Trofea] AS t
    INNER JOIN [KursSQL].[dbo].[Dyscyplina] d
        ON d.IdDyscyplina = t.NrDyscyplinySportowej
GROUP BY d.Nazwa
ORDER BY COUNT(*) DESC

--Ile pamiątek sprzedaliśmy w poszczególnych miesiącach 2019 roku?
SELECT MONTH(Data) AS Miesiac, COUNT(*) AS SprzedanePamiatki
FROM [KursSQL].[dbo].[Zakupy] AS z
    INNER JOIN [KursSQL].[dbo].[Zawody] AS zw
        ON z.IdZawodow = zw.IdZawody
WHERE YEAR(Data) = 2019
GROUP BY MONTH(Data)

--Jaki był koszt zakupu każdego typu sprzedanych pamiątek?
SELECT tp.Nazwa, SUM(p.Cena - tp.Marza) AS Koszt
FROM [KursSQL].[dbo].[Zakupy] AS z
    INNER JOIN [KursSQL].[dbo].[Pamiatki] AS p	
        ON p.IdPamiatki = z.NrPamiatki
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] AS tp
        ON tp.IdTypyPamiatek = p.TypPamiatki
GROUP BY tp.Nazwa

--Ile każdego z trofeów zostało zdobytych w czerwcu 2019 roku
SELECT t.ZdobyteTrofeum, COUNT(*) AS LiczbaTrofeow
FROM [KursSQL].[dbo].[Zawody] AS z
    INNER JOIN [KursSQL].[dbo].[Trofea] AS t
        ON t.IdZawodow = z.IdZawody
WHERE MONTH(z.Data) = 6
    AND YEAR(z.Data) = 2019
GROUP BY t.ZdobyteTrofeum
