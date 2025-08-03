-- W grupowanie w SELECT, można użyć tylko funkcji agregujacych, i/lub grupowany element.

--Ile zdobyto każdego z rodzajów trofeum?
SELECT ZdobyteTrofeum, COUNT(*) AS IloscZdobytych
FROM [KursSQL].[dbo].[Trofea]
GROUP BY ZdobyteTrofeum
ORDER BY IloscZdobytych DESC;

SELECT DISTINCT ZdobyteTrofeum
FROM [KursSQL].[dbo].[Trofea]
WHERE ZdobyteTrofeum IS NOT NULL;

--Ilu jest kibiców w każdym ze stowarzyszeń?
-- NrStowarzyszenia moze zostac uzyte w tym poniewaz jest w GROUP BY
SELECT COUNT(*) AS LiczbaCzlonkow, NrStowarzyszenia
FROM [KursSQL].[dbo].[Kibice]
WHERE NrStowarzyszenia IS NOT NULL
GROUP BY NrStowarzyszenia;

-- SELECT  COUNT(Imie), Nazwisko -- error - to nie moze zostac uzyte, bo nie jest w funkcji 
-- aggregujace
-- FROM [KursSQL].[dbo].[Kibice]

--Ile w danym roku urodziło się zawodników?
SELECT COUNT(*) AS LiczbaZawodnikow, YEAR(DataUrodzenia) AS RokUrodzenia
FROM [KursSQL].[dbo].[Zawodnicy]
GROUP BY DataUrodzenia;

-- Ile sprzedano biletów w każdej cenie
SELECT CenaBiletu, COUNT(*) AS LiczbaBiletow, SUM(CenaBiletu) AS SumaSprzedazy
FROM [KursSQL].[dbo].[KibicZawody]
GROUP BY CenaBiletu;

-- Pokaż numer nagrody i ile razy została wygrana
SELECT NrNagrody, SUM(Zwyciezca) AS LiczbaWygranych
FROM [KursSQL].[dbo].[KonkursyDlaKibicow]
GROUP BY NrNagrody;

-- Za ile w sumie sprzedano pamiątki w każdym typie?
SELECT TypPamiatki, SUM(Cena) AS SumaSprzedazy
FROM [KursSQL].[dbo].[Pamiatki]
GROUP BY TypPamiatki;

-- Ile każdy ze sponsorów wpłacił na zawody?
SELECT IdSponsora, SUM(Kwota) AS SumaWplat
FROM [KursSQL].[dbo].[Sponsoring]
WHERE Kwota > 0
GROUP BY IdSponsora;

-- Ile było wpłat sponsorowanych za każdą z kwot?
SELECT Kwota, COUNT(*) AS LiczbaWplat
FROM [KursSQL].[dbo].[Sponsoring]
WHERE Kwota > 0
GROUP BY Kwota;

-- Pokaż ile każdy z klientów kupił każdej z pamiątek
SELECT *
FROM [KursSQL].[dbo].[Zakupy]
ORDER BY NrKlienta;

SELECT NrKlienta, COUNT(*) AS LiczbaZakupow
FROM [KursSQL].[dbo].[Zakupy]
GROUP BY NrKlienta
ORDER BY NrKlienta;

SELECT NrKlienta, NrPamiatki, COUNT(*) AS LiczbaZakupow
FROM [KursSQL].[dbo].[Zakupy]
GROUP BY NrKlienta, NrPamiatki
ORDER BY NrKlienta;

-- Ile odbyło się zawodów każdego roku i miesiąca?
SELECT COUNT(*) AS LiczbaZawodow,
    YEAR(Data) AS Rok,
    MONTH(Data) AS Miesiac
FROM [KursSQL].[dbo].[Zawody]
GROUP BY YEAR(Data), MONTH(Data);

-- Pokaż imię, nazwisko i płeć każdego z zawodników
SELECT Imie, Nazwisko, PESEL
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE RIGHT(Imie, 1) = 'a';

SELECT Imie, Nazwisko, PESEL
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE SUBSTRING(PESEL, 10, 1) IN  ('0', '2', '4', '6', '8');

SELECT Imie,
    Nazwisko,
    CASE
            WHEN SUBSTRING(PESEL, 10, 1) IN  ('0', '2', '4', '6', '8') THEN 'Kobieta'
            ELSE 'Mężczyzna'
        END AS Plec
FROM [KursSQL].[dbo].[Zawodnicy]
ORDER BY Plec;

-- Ile mamy kobiet i mężczyzn wśród zawodników?
SELECT CASE
            WHEN SUBSTRING(PESEL, 10, 1) IN  ('0', '2', '4', '6', '8') THEN 'Kobieta'
            ELSE 'Mężczyzna'
       END AS Plec,
    COUNT(*) AS LiczbaZawodnikow
FROM [KursSQL].[dbo].[Zawodnicy]
GROUP BY CASE
            WHEN SUBSTRING(PESEL, 10, 1) IN  ('0', '2', '4', '6', '8') THEN 'Kobieta'
            ELSE 'Mężczyzna'
       END;

-- Ile sprzedano biletów w grupach cenowych do 100zł, 100zł-200zł i ponad 200zł
SELECT CASE
            WHEN CenaBiletu < 100 THEN 'do 100zł'
            WHEN CenaBiletu <= 200 THEN '100zł-200zł'
            ELSE 'powyżej 200zł'
       END AS GrupaCenowa,
    COUNT(*) AS LiczbaBiletow,
    SUM(CenaBiletu) AS SumaSprzedazy
FROM [KursSQL].[dbo].[KibicZawody]
GROUP BY CASE
            WHEN CenaBiletu < 100 THEN 'do 100zł'
            WHEN CenaBiletu BETWEEN 100 AND 200 THEN '100zł-200zł'
            ELSE 'powyżej 200zł'
       END
ORDER BY GrupaCenowa;


-- Znajdź klientów, którzy kupili więcej niż jedną pamiątkę
SELECT NrKlienta, COUNT(*) AS LiczbaZakupow
FROM [KursSQL].[dbo].[Zakupy]
GROUP BY NrKlienta
HAVING COUNT(*) > 1;

-- Pokaż lata, w których urodziła się więcej niż jeden zawodniczka
SELECT YEAR(DataUrodzenia) AS RokUrodzenia
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE PESEL LIKE '%[02468]_';

SELECT
    COUNT(*) AS LiczbaZawodniczek,
    YEAR(DataUrodzenia) AS RokUrodzenia
FROM
    [KursSQL].[dbo].[Zawodnicy]
WHERE 
    PESEL LIKE '%[02468]_'
GROUP BY 
    YEAR(DataUrodzenia)
HAVING 
    COUNT(*) > 1;

-- Pokaż najrzadziej zdobywane złote trofeum, ale zdobyte przynajmniej 5 razy
SELECT TOP 1
    ZdobyteTrofeum
FROM [KursSQL].[dbo].[Trofea]
WHERE ZdobyteTrofeum LIKE 'Zlot%'
GROUP BY ZdobyteTrofeum
HAVING COUNT(*) >= 5
ORDER BY COUNT(*) ASC;

-- Ile zdobyto każdego z rodzajów trofeum?
SELECT ZdobyteTrofeum, COUNT(*) AS IloscZdobytych
FROM [KursSQL].[dbo].[Trofea]
GROUP BY ZdobyteTrofeum;

-- Pokaż lata, w których urodził się tylko 1 zawodnik
SELECT YEAR(DataUrodzenia) AS RokUrodzenia, COUNT(*) AS LiczbaZawodnikow
FROM [KursSQL].[dbo].[Zawodnicy]
GROUP BY YEAR(DataUrodzenia)
HAVING COUNT(*) = 1;

-- Ilu zawodników urodziło się w latach 80tych, a ilu w 90tych?
SELECT x.Okres, COUNT(*) AS LiczbaZawodnikow
FROM (
    SELECT CASE WHEN YEAR(DataUrodzenia) BETWEEN 1980 AND 1989 THEN 'Lata 80te'
                WHEN YEAR(DataUrodzenia) BETWEEN 1990 AND 1999 THEN 'Lata 90te'
        END AS Okres
    FROM [KursSQL].[dbo].[Zawodnicy]
) AS x
WHERE x.Okres IS NOT NULL
GROUP BY Okres;

SELECT CASE WHEN YEAR(DataUrodzenia) BETWEEN 1980 AND 1989 THEN 'Lata 80te'
            WHEN YEAR(DataUrodzenia) BETWEEN 1990 AND 1999 THEN 'Lata 90te'
       END AS Okres, COUNT(*) AS LiczbaZawodnikow
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE YEAR(DataUrodzenia) BETWEEN 1980 AND 1999
GROUP BY 
      CASE
        WHEN YEAR(DataUrodzenia) BETWEEN 1980 AND 1989 THEN 'Lata 80te'
        WHEN YEAR(DataUrodzenia) BETWEEN 1990 AND 1999 THEN 'Lata 90te'
      END;

SELECT CASE WHEN YEAR(DataUrodzenia) BETWEEN 1980 AND 1989 THEN 'Lata 80te'
            WHEN YEAR(DataUrodzenia) BETWEEN 1990 AND 1999 THEN 'Lata 90te'
       END AS Okres, COUNT(*) AS LiczbaZawodnikow
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE CASE
        WHEN YEAR(DataUrodzenia) BETWEEN 1980 AND 1989 THEN 'Lata 80te'
        WHEN YEAR(DataUrodzenia) BETWEEN 1990 AND 1999 THEN 'Lata 90te'
      END IS NOT NULL
GROUP BY 
      CASE
        WHEN YEAR(DataUrodzenia) BETWEEN 1980 AND 1989 THEN 'Lata 80te'
        WHEN YEAR(DataUrodzenia) BETWEEN 1990 AND 1999 THEN 'Lata 90te'
      END;

-- Pokaż numer zawodów, średnią kwotę wsparcia (w pełnych złotówkach) oraz liczbę wspierających sponsorów
SELECT Zawody,
    COUNT(IdSponsora) AS LiczbaSponsorow,
    CAST(AVG(Kwota) AS decimal(10,2)) AS SredniaKwotaWsparcia
FROM [KursSQL].[dbo].[Sponsoring]
GROUP BY Zawody;

-- Ile mamy pamiątek w każdym z typów oraz jaka jest średnia cena w każdym z typów?
SELECT TypPamiatki,
    COUNT(*) AS LiczbaPamiatek,
    CAST(AVG(Cena) AS decimal(10,2)) AS SredniaCena
FROM [KursSQL].[dbo].[Pamiatki]
GROUP BY TypPamiatki;

-- Pokaż numer pamiatki i liczbę kupionych sztuk
SELECT NrPamiatki, COUNT(*) AS LiczbaZakupow
FROM [KursSQL].[dbo].[Zakupy]
GROUP BY NrPamiatki;

-- Znajdź klientów, którzy kupili więcej niż jedną taką samą pamiątkę
SELECT NrKlienta, NrPamiatki, COUNT(*) AS LiczbaRoznychPamiatek
FROM [KursSQL].[dbo].[Zakupy]
GROUP BY NrKlienta, NrPamiatki
HAVING COUNT(*) > 1
ORDER BY NrKlienta;

SELECT *
FROM [KursSQL].[dbo].[Zakupy]
ORDER BY NrKlienta;

SELECT *
FROM [KursSQL].[dbo].[Zakupy]
WHERE NrKlienta = 2
ORDER BY NrKlienta;

SELECT NrKlienta, NrPamiatki, COUNT(*)
FROM [KursSQL].[dbo].[Zakupy]
WHERE NrKlienta = 2
GROUP BY NrKlienta, NrPamiatki
HAVING COUNT(*) > 1;


-- Pokaż ile zostało zdobytych złotych i srebrnych trofeów
SELECT *
FROM [KursSQL].[dbo].[Trofea];

SELECT CASE
            WHEN ZdobyteTrofeum LIKE 'Zlot%' THEN 'zloty'
            WHEN ZdobyteTrofeum LIKE 'Srebr%' THEN 'srebrny'
        END AS Typ,
    COUNT(*) AS Zdobyte
FROM [KursSQL].[dbo].[Trofea]
WHERE ZdobyteTrofeum LIKE 'Zlot%' OR ZdobyteTrofeum LIKE 'Srebr%'
GROUP BY CASE
            WHEN ZdobyteTrofeum LIKE 'Zlot%' THEN 'zloty'
            WHEN ZdobyteTrofeum LIKE 'Srebr%' THEN 'srebrny'
        END;

SELECT Trofea.Typ, COUNT(*) AS Zdobyte
FROM (SELECT CASE
            WHEN ZdobyteTrofeum LIKE 'Zlot%' THEN 'zloty'
            WHEN ZdobyteTrofeum LIKE 'Srebr%' THEN 'srebrny'
        END AS Typ
    FROM [KursSQL].[dbo].[Trofea] ) AS Trofea
WHERE Trofea.Typ IS NOT NULL
GROUP BY Trofea.Typ;

-- Pokaż numery pamiatek kupionych przynajmniej 5 razy podczas jednych zawodów
SELECT *
FROM [KursSQL].[dbo].[Zakupy]
ORDER BY NrPamiatki;

SELECT DISTINCT NrPamiatki
FROM [KursSQL].[dbo].[Zakupy]
GROUP BY NrPamiatki, IdZawodow
HAVING COUNT(*) >= 5
ORDER BY NrPamiatki;

-- Pokaż lata urodzenia zawodników urodzonych w styczniu XX wieku
SELECT YEAR(DataUrodzenia) AS RokUrodzenia
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE YEAR(DataUrodzenia) < 2000 AND MONTH(DataUrodzenia) = 1
GROUP BY YEAR(DataUrodzenia);

SELECT DISTINCT YEAR(DataUrodzenia) AS RokUrodzenia
FROM [KursSQL].[dbo].[Zawodnicy]
WHERE YEAR(DataUrodzenia) < 2000 AND MONTH(DataUrodzenia) = 1

-- Pokaż średnią cenę pamiątek dostępnych i niedostępnych wszędzie.
-- Zamień 1 i 0 na TAK/NIE
SELECT *
FROM [KursSQL].[dbo].[Pamiatki];

SELECT Pam.Dostepnosc, CAST(AVG(Pam.Cena) AS decimal(10,2)) AS SredniaCena, COUNT(*) AS LiczbaPamiatek
FROM (
    SELECT Cena,
        CzyDostepneWszedzie,
        CASE CzyDostepneWszedzie
               WHEN 1 THEN 'TAK'
               WHEN 0 THEN 'NIE'
           END AS Dostepnosc
    FROM [KursSQL].[dbo].[Pamiatki]
) AS Pam
GROUP BY Pam.Dostepnosc;