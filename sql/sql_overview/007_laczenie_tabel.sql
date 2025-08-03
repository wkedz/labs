-- Pokaż imię i nazwisko zawodnika, oraz nazwę głównej dyscypliny
SELECT *
FROM [KursSQL].[dbo].[Zawodnicy] AS Z;

SELECT *
FROM [KursSQL].[dbo].[Dyscyplina] AS D;

SELECT *
FROM [KursSQL].[dbo].[Zawodnicy] AS Z
    INNER JOIN [KursSQL].[dbo].[Dyscyplina] AS D
    ON Z.GlownaDyscyplina = D.IdDyscyplina;

-- Pokaż imię i nazwisko kibicek oraz nazwę stowarzyszenia, do którego należą
SELECT *
FROM [KursSQL].[dbo].[Kibice] AS K;

SELECT *
FROM [KursSQL].[dbo].[Stowarzyszenia] AS S;

SELECT K.Imie, K.Nazwisko, S.Nazwa
FROM [KursSQL].[dbo].[Kibice] AS K
    INNER JOIN [KursSQL].[dbo].[Stowarzyszenia] AS S
    ON K.NrStowarzyszenia = S.IdStowarzyszenia
WHERE RIGHT(Imie, 1) = 'a';

-- Jakiego typu jest najdroższa pamiątka?
SELECT TOP 1
    P.Nazwa, TP.Nazwa AS Typ, P.Cena
FROM [KursSQL].[dbo].[Pamiatki] AS P
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] AS TP
    ON P.TypPamiatki = TP.IdTypyPamiatek
ORDER BY P.Cena DESC;

-- Pokaż nazwę zawodów i miejsce, w którym się odbywały
SELECT z.Nazwa AS NazwaZawodow, m.Nazwa AS Mijesce
FROM [KursSQL].[dbo].[Zawody] AS z
    INNER JOIN [KursSQL].[dbo].[Miejsce] AS m
    ON z.Miejsce = m.IdMiejsce;

-- Pokaż zdobyte trofea i nazwę dyscypliny
SELECT t.ZdobyteTrofeum, d.Nazwa AS NazwaDyscypliny
FROM [KursSQL].[dbo].[Trofea] AS t
    INNER JOIN [KursSQL].[dbo].[Dyscyplina] AS d
    ON d.IdDyscyplina = t.NrDyscyplinySportowej;

-- Pokaż imię, nazwisko i czas rekordu na 100m zawodników z czasem poniżej 11s
SELECT z.Imie, z.Nazwisko, r.Czas_s
FROM [KursSQL].[dbo].[Zawodnicy] AS z
    INNER JOIN [KursSQL].[dbo].[Rekord100m] AS r
    ON z.IdZawodnicy = r.NrZawodnika
WHERE r.Czas_s < 11;

-- Pokaż imię i nazwisko kibiców, którzy zdobyli nagrodę i nie należą do żadnego stowarzyszenia
SELECT k.Imie, k.Nazwisko
FROM [KursSQL].[dbo].[Kibice] AS k
    INNER JOIN [KursSQL].[dbo].[KonkursyDlaKibicow] AS kdk
    ON k.IdKibice = kdk.Zwyciezca
WHERE k.NrStowarzyszenia IS NULL;

-- Pokaż średnią cenę pamiątek typu Zabawka
SELECT CAST(AVG(p.Cena) AS decimal(10,2)) AS SredniaCena
FROM [KursSQL].[dbo].[Pamiatki] AS p
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] AS tp
    ON tp.IdTypyPamiatek = p.TypPamiatki
WHERE tp.Nazwa = 'Zabawka';

-- Ile pamiątek kupiono podczas Mistrzostw Powiatu Grajewskiego?
SELECT *
FROM [KursSQL].[dbo].[Zakupy] AS z

SELECT COUNT(*) AS LiczbaPamiatek
FROM [KursSQL].[dbo].[Zawody] AS z
    INNER JOIN [KursSQL].[dbo].[Zakupy] AS zak
    ON z.IdZawody = zak.IdZawodow
WHERE z.Nazwa = 'Mistrzostwa Powiatu Grajewskiego';

-- Ile w sumie wpłacił sponsor CPN?
SELECT *
FROM [KursSQL].[dbo].[Sponsoring] AS s;

SELECT *
FROM [KursSQL].[dbo].[Sponsorzy] AS s;

SELECT s.IdSponsora, SUM(s.Kwota) AS SumaWplat
FROM [KursSQL].[dbo].[Sponsoring] AS s
    INNER JOIN [KursSQL].[dbo].[Sponsorzy] AS sp
    ON sp.IdSponsorzy = s.IdSponsora
WHERE sp.Nazwa = 'CPN'
GROUP BY s.IdSponsora;

-- Pokaż imiona i nazwiska wszystkich kibiców oraz nazwę stowarzyszenia do którego należą

SELECT TOP 5
    *
FROM [KursSQL].[dbo].[Kibice] AS k;

SELECT TOP 5
    *
FROM [KursSQL].[dbo].[Stowarzyszenia] AS s

SELECT *
FROM [KursSQL].[dbo].[Kibice] AS k
    JOIN [KursSQL].[dbo].[Stowarzyszenia] AS s
    ON k.NrStowarzyszenia = s.IdStowarzyszenia;

SELECT *
FROM [KursSQL].[dbo].[Kibice] AS k
    LEFT JOIN [KursSQL].[dbo].[Stowarzyszenia] AS s
    ON k.NrStowarzyszenia = s.IdStowarzyszenia;


SELECT *
FROM [KursSQL].[dbo].[Stowarzyszenia] AS s
    RIGHT JOIN [KursSQL].[dbo].[Kibice] AS k
    ON k.NrStowarzyszenia = s.IdStowarzyszenia;

-- Którego typu nie mamy żadnych pamiątek?
SELECT *
FROM [KursSQL].[dbo].[Pamiatki]

SELECT *
FROM [KursSQL].[dbo].[TypyPamiatek]

SELECT *
-- tp.IdTypyPamiatek AS Id, tp.Nazwa AS TypPamiatki
FROM [KursSQL].[dbo].[TypyPamiatek] AS tp
    LEFT JOIN [KursSQL].[dbo].[Pamiatki] AS p
    ON tp.IdTypyPamiatek = p.TypPamiatki
WHERE p.IdPamiatki IS NULL;
-- najlepiej brac indeksujacy id

-- Policz średnią cenę nigdy niekupionych pamiątek

SELECT *
FROM [KursSQL].[dbo].[Pamiatki]

SELECT *
FROM [KursSQL].[dbo].[Zakupy]


SELECT CAST(
        ISNULL(
            AVG(p.Cena), 0)
        AS decimal(10,2)
    ) As SredniaCena
FROM [KursSQL].[dbo].[Pamiatki] AS p
    LEFT JOIN [KursSQL].[dbo].[Zakupy] AS z
    ON p.IdPamiatki = z.NrPamiatki
WHERE p.IdPamiatki IS NULL;

-- Które pamiątki nie zostały nigdy wygrane?
SELECT *
FROM [KursSQL].[dbo].[Pamiatki]

SELECT *
FROM [KursSQL].[dbo].[KonkursyDlaKibicow]

SELECT p.Nazwa
FROM [KursSQL].[dbo].[Pamiatki] AS p
    LEFT JOIN [KursSQL].[dbo].[KonkursyDlaKibicow] AS k
    ON p.IdPamiatki = k.NrNagrody
WHERE k.IdKonkursyDlaKibicow IS NULL;

-- Które zawody w 2019 roku nie miały sponsora?
SELECT *
FROM [KursSQL].[dbo].[Zawody]

SELECT *
FROM [KursSQL].[dbo].[Sponsoring]

SELECT z.Nazwa
FROM [KursSQL].[dbo].[Zawody] AS z
    LEFT JOIN [KursSQL].[dbo].[Sponsoring] AS s
    ON z.IdZawody = s.Zawody
WHERE s.IdSponsoring IS NULL
    AND YEAR(z.Data) = 2019;

-- Jaka jest najtańsza nigdy nie wygrana pamiątka?
SELECT TOP 1 p.Nazwa, p.Cena
FROM [KursSQL].[dbo].[Pamiatki] AS p
    LEFT JOIN [KursSQL].[dbo].[KonkursyDlaKibicow] AS k
    ON p.IdPamiatki = k.NrNagrody 
WHERE k.IdKonkursyDlaKibicow IS NULL
ORDER BY p.Cena ASC;

-- Pokaż Nazwę pamiątki, nazwę typu i nazwę konkursu 
-- w jakim została wygrana każda z pamiątek
SELECT p.Nazwa,
       tp.Nazwa AS Typ,
       kdk.Nazwa AS Konkurs
FROM [KursSQL].[dbo].[TypyPamiatek] tp
    JOIN [KursSQL].[dbo].[Pamiatki] p
        ON tp.IdTypyPamiatek = p.TypPamiatki
    JOIN [KursSQL].[dbo].[KonkursyDlaKibicow] kdk
        ON p.IdPamiatki = kdk.NrNagrody;

-- Pokaż imię, nazwisko i nazwę stowarzyszenia wszystkich kibiców,
-- którzy wygrali coś w konkursie

SELECT *
FROM [KursSQL].[dbo].[Kibice]

SELECT *
FROM [KursSQL].[dbo].[Stowarzyszenia]

SELECT *
FROM [KursSQL].[dbo].[KonkursyDlaKibicow]

SELECT k.Imie, k.Nazwisko, s.Nazwa
FROM [KursSQL].[dbo].[Kibice] k 
    LEFT JOIN  [KursSQL].[dbo].[Stowarzyszenia] s
        ON s.IdStowarzyszenia = k.NrStowarzyszenia
    INNER JOIN [KursSQL].[dbo].[KonkursyDlaKibicow] kdk
        ON kdk.Zwyciezca  = k.IdKibice;


-- Policz ile zarobiliśmy na pamiątkach typu Ubrania
SELECT *
FROM [KursSQL].[dbo].[Pamiatki]
WHERE TypPamiatki = 2;

SELECT *
FROM [KursSQL].[dbo].[TypyPamiatek]
WHERE Nazwa = 'Ubrania';

SELECT *
FROM [KursSQL].[dbo].[Zakupy]

SELECT SUM(tp.Marza) AS SumaZarobkow
FROM [KursSQL].[dbo].[TypyPamiatek] tp
    INNER JOIN [KursSQL].[dbo].[Pamiatki] p
        ON tp.IdTypyPamiatek = p.TypPamiatki
    INNER JOIN [KursSQL].[dbo].[Zakupy] z
        ON p.IdPamiatki = z.NrPamiatki
WHERE tp.Nazwa = 'Ubrania';

-- Ile zarobiliśmy na sprzedaży latawców?
SELECT * 
FROM [KursSQL].[dbo].[TypyPamiatek] AS tp;

SELECT * 
FROM [KursSQL].[dbo].[Pamiatki] AS p;

SELECT SUM(p.Cena) AS KwotaSprzedazy, SUM(tp.Marza) AS Marza
FROM [KursSQL].[dbo].[Zakupy] AS z
    INNER JOIN [KursSQL].[dbo].[Pamiatki] AS p
        ON z.NrPamiatki = p.IdPamiatki
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] AS tp
        ON tp.IdTypyPamiatek = p.TypPamiatki
WHERE p.IdPamiatki = 4 ;

-- Za jaką kwotę sprzedaliśmy pamiątki w Grajewie?
SELECT * 
FROM [KursSQL].[dbo].[Pamiatki] AS p;

SELECT * 
FROM [KursSQL].[dbo].[Zawody] AS z;

SELECT * 
FROM [KursSQL].[dbo].[Zakupy] AS z;

SELECT SUM(p.Cena) AS SumaSprzedazy
FROM [KursSQL].[dbo].[Zawody] AS z
    INNER JOIN [KursSQL].[dbo].[Miejsce] AS m
        ON z.Miejsce = m.IdMiejsce
    INNER JOIN [KursSQL].[dbo].[Zakupy] AS za
        ON z.IdZawody = za.IdZawodow
    INNER JOIN [KursSQL].[dbo].[Pamiatki] AS p
        ON p.IdPamiatki = za.NrPamiatki
WHERE m.Miejscowosc = 'Grajewo'


-- Ile kosztował nas zakup i ile zarobiliśmy na ubraniach
SELECT SUM(p.Cena - tp.Marza) AS Koszty,
    SUM(tp.Marza) AS Zarobek
FROM [KursSQL].[dbo].[TypyPamiatek] tp
    INNER JOIN [KursSQL].[dbo].[Pamiatki] p
        ON p.TypPamiatki = tp.IdTypyPamiatek
    INNER JOIN [KursSQL].[dbo].[Zakupy] z
        ON z.NrPamiatki = p.IdPamiatki
WHERE tp.Nazwa = 'Ubrania'

-- Ile trofeów zdobyto w Gdańsku?
SELECT COUNT(*) AS LiczbaTrofeow
FROM [KursSQL].[dbo].[Trofea] t
    INNER JOIN [KursSQL].[dbo].[Zawody] z
        ON t.IdZawodow = z.IdZawody
    INNER JOIN [KursSQL].[dbo].[Miejsce] m
        ON m.IdMiejsce = z.Miejsce
WHERE m.Miejscowosc = 'Gdańsk'

-- Jaki jest średni rekord zawodników urodzonych w XX wieku, których główną dyscypliną jest bieg?
SELECT AVG(r.Czas_s) AS SredniCzasRekordu
FROM [KursSQL].[dbo].[Zawodnicy] z
    INNER JOIN [KursSQL].[dbo].[Dyscyplina] d
        ON d.IdDyscyplina = z.GlownaDyscyplina
    INNER JOIN [KursSQL].[dbo].[Rekord100m] r
        ON r.NrZawodnika = z.IdZawodnicy
WHERE d.Nazwa = 'Bieg'
    AND YEAR(z.DataUrodzenia) < 2000

-- Pełne zewnętrzne złączenie FULL JOIN
--Pokaż wszystkich kibiców, informacje o wygranych w konkursie 
--i wszystkie pamiątki (nawet jeśli nie zostały zdobyte)
SELECT *
FROM [KursSQL].[dbo].[Kibice] k
    LEFT JOIN [KursSQL].[dbo].[KonkursyDlaKibicow] kdk
        ON kdk.Zwyciezca = k.IdKibice
    FULL JOIN [KursSQL].[dbo].[Pamiatki] p
        ON p.IdPamiatki = kdk.NrNagrody

-- Złączenie krzyżowe, SELF JOIN i inne rodzaje złączeń
--Pokaż zawodników połączonych ze wszystkimi dyscyplinami
SELECT *
FROM [KursSQL].[dbo].[Zawodnicy] CROSS JOIN [KursSQL].[dbo].[Dyscyplina]
ORDER BY Zawodnicy.Imie;

-- TAK NIE UZYWAJ CROSS JOIN
SELECT *
FROM [KursSQL].[dbo].[Zawodnicy], [KursSQL].[dbo].[Dyscyplina]

-- TO JEST PRZYKLAD INNER JOINA,
-- ALE JAK USUNIESZ WHERE, TO ZROBI SIE CROSS JOIN
SELECT *
FROM [KursSQL].[dbo].[Zawodnicy] AS z, [KursSQL].[dbo].[Dyscyplina] AS d
WHERE z.GlownaDyscyplina = d.IdDyscyplina


--Za ile łącznie sprzedaliśmy wiatraczki?
SELECT SUM(Cena) AS SumaSprzedazy
FROM [KursSQL].[dbo].[Pamiatki] p
    INNER JOIN [KursSQL].[dbo].[Zakupy] z
        ON p.IdPamiatki = z.NrPamiatki
WHERE p.Nazwa = 'Wiatraczek'

--Pokaż nazwę, nazwę typu i cenę pamiątek dostępnych wszędzie
SELECT p.Nazwa, tp.Nazwa AS Typ, p.Cena
FROM [KursSQL].[dbo].[Pamiatki] p
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] tp
        ON p.TypPamiatki = tp.IdTypyPamiatek
WHERE CzyDostepneWszedzie = 1

--Pokaż nazwy pamiątek i ich typ, które nigdy nie zostały wygrane
SELECT p.Nazwa, tp.Nazwa AS Typ
FROM [KursSQL].[dbo].[Pamiatki] p
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] tp
        ON p.TypPamiatki = tp.IdTypyPamiatek
    LEFT JOIN [KursSQL].[dbo].[KonkursyDlaKibicow] k
        ON k.NrNagrody = p.IdPamiatki
WHERE k.IdKonkursyDlaKibicow IS NULL

--Pokaż imię i nazwisko najstarszego zawodnika, którego główną dyscypliną jest bieg
SELECT TOP 1 z.Imie, z.Nazwisko
FROM [KursSQL].[dbo].[Zawodnicy] z
    INNER JOIN [KursSQL].[dbo].[Dyscyplina] d
        ON z.GlownaDyscyplina = d.IdDyscyplina
WHERE d.Nazwa = 'Bieg'
ORDER BY DataUrodzenia

--Ile sprzedaliśmy zabawek?
SELECT COUNT(*) AS LiczbaPamiatek
FROM [KursSQL].[dbo].[TypyPamiatek] tp
    INNER JOIN [KursSQL].[dbo].[Pamiatki] p
        ON p.TypPamiatki = tp.IdTypyPamiatek
    INNER JOIN [KursSQL].[dbo].[Zakupy] z
        ON z.NrPamiatki = p.IdPamiatki
WHERE tp.Nazwa = 'Zabawka'

--Jakie wydarzenia odbyły się w Gdańsku?
SELECT z.Nazwa
FROM [KursSQL].[dbo].[Miejsce] m
    INNER JOIN [KursSQL].[dbo].[Zawody] z
        ON m.IdMiejsce = z.Miejsce
WHERE m.Miejscowosc = 'Gdańsk'

--Ile kosztowały nas wszystkie nagrody
SELECT SUM(p.Cena - tp.Marza) AS KosztyNagrod
FROM [KursSQL].[dbo].[Pamiatki] p
    INNER JOIN [KursSQL].[dbo].[KonkursyDlaKibicow] k
        ON k.NrNagrody = p.IdPamiatki
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] tp
        ON tp.IdTypyPamiatek = p.TypPamiatki

--Za jaką kwotę sprzedaliśmy ubrania w Gdańsku?
SELECT SUM(p.Cena) AS SumaSprzedazy
FROM [KursSQL].[dbo].[Zawody] z
    INNER JOIN [KursSQL].[dbo].[Miejsce] m
        ON z.Miejsce = m.IdMiejsce
    INNER JOIN [KursSQL].[dbo].[Zakupy] za
        ON z.IdZawody = za.IdZawodow
    INNER JOIN [KursSQL].[dbo].[Pamiatki] p
        ON p.IdPamiatki = za.NrPamiatki
    INNER JOIN [KursSQL].[dbo].[TypyPamiatek] tp
        ON tp.IdTypyPamiatek = p.TypPamiatki
WHERE m.Miejscowosc = 'Gdańsk'
    AND tp.Nazwa = 'Ubrania'

--Ile pamiątek sprzedaliśmy w Grajewie?
SELECT COUNT(*) AS LiczbaPamiatek
FROM [KursSQL].[dbo].[Zawody] z
    INNER JOIN [KursSQL].[dbo].[Miejsce] m
        ON z.Miejsce = m.IdMiejsce
    INNER JOIN [KursSQL].[dbo].[Zakupy] za
        ON z.IdZawody = za.IdZawodow
WHERE m.Miejscowosc = 'Grajewo'

--Ile złotych trofeów zdobyto w grajewie?
SELECT COUNT(*)
FROM [KursSQL].[dbo].[Trofea] t
    INNER JOIN [KursSQL].[dbo].[Zawody] z
        ON t.IdZawodow = z.IdZawody
    INNER JOIN [KursSQL].[dbo].[Miejsce] m
        ON m.IdMiejsce = z.Miejsce
WHERE m.Miejscowosc = 'Grajewo'
    AND ZdobyteTrofeum LIKE 'Złot%'
