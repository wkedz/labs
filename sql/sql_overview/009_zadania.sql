--Ile średnio kosztowała nagroda w konkursie
SELECT CAST(AVG(p.Cena) AS decimal(10,2)) AS SredniaCenaNagrody
FROM [KursSQL].[dbo].[KonkursyDlaKibicow] AS kdk
	INNER JOIN [KursSQL].[dbo].[Pamiatki] AS p
		ON p.IdPamiatki = kdk.NrNagrody

SELECT AVG(p.Cena)
FROM [KursSQL].[dbo].[KonkursyDlaKibicow] AS kdk
	INNER JOIN [KursSQL].[dbo].[Pamiatki] p
		ON kdk.NrNagrody = p.IdPamiatki

--Znajdź klientów, którzy kupili więcej niż jedną taką samą pamiątkę
SELECT k.Imie, k.Nazwisko, COUNT(*) AS LiczbaZakupow
FROM [KursSQL].[dbo].[Zakupy] AS z
	INNER JOIN [KursSQL].[dbo].[Kibice] AS k
		ON k.IdKibice = z.NrKlienta
GROUP BY k.Imie, k.Nazwisko
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

--Ile kobiety wydały na bilety?
SELECT SUM(kz.CenaBiletu) AS WydatkiNaBilety
FROM [KursSQL].[dbo].[Kibice] AS k
	INNER JOIN [KursSQL].[dbo].[KibicZawody] AS kz
		ON k.IdKibice = kz.Kibic
WHERE RIGHT(k.Imie, 1) = 'a'

--W której miejscowości odbyło się najwięcej zawodów?
SELECT TOP 1 m.Miejscowosc, COUNT(*) AS LiczbaZawodow
FROM [KursSQL].[dbo].[Zawody] AS z
	INNER JOIN [KursSQL].[dbo].[Miejsce] AS m
		ON m.IdMiejsce = z.Miejsce
GROUP BY m.Miejscowosc
ORDER BY COUNT(*) DESC

--Za ile sprzedaliśmy pamiątki w poszczególnych miesiącach 2019 roku?
SELECT SUM(Cena) AS SumaSprzedazy, MONTH(Data) AS Miesiac
FROM [KursSQL].[dbo].[Pamiatki] AS p
	INNER JOIN [KursSQL].[dbo].[Zakupy] AS z
		ON p.IdPamiatki = z.NrPamiatki
	INNER JOIN [KursSQL].[dbo].[Zawody] AS zaw
		ON zaw.IdZawody = z.IdZawodow
WHERE YEAR(Data) = 2019
GROUP BY MONTH(Data);

--Który zawodnik ma najlepszy rekord?
SELECT TOP 1 Imie, Nazwisko, Czas_s
FROM [KursSQL].[dbo].[Zawodnicy] AS z
	INNER JOIN [KursSQL].[dbo].[Rekord100m] AS r
		ON z.IdZawodnicy = r.NrZawodnika
ORDER BY Czas_s ASC;

--W którym miesiącu 2019 roku sprzedaliśmy najwięcej pamiątek?
SELECT TOP 1 MONTH(Data) AS Miesiac
FROM [KursSQL].[dbo].[Zakupy] AS z
	INNER JOIN [KursSQL].[dbo].[Zawody] AS zaw
		ON zaw.IdZawody = z.IdZawodow
WHERE YEAR(Data) = 2019
GROUP BY MONTH(Data)
ORDER BY COUNT(*) DESC;

--Częściej kobiety czy mężczyźni wygrywali w konkursach?
SELECT TOP 1 IIF(RIGHT(k.Imie, 1) ='a', 'Kobieta', 'Mężczyzna')
FROM [KursSQL].[dbo].[KonkursyDlaKibicow] AS kdk
	INNER JOIN [KursSQL].[dbo].[Kibice] AS k
		ON k.IdKibice = kdk.Zwyciezca
GROUP BY IIF(RIGHT(k.Imie, 1) ='a', 'Kobieta', 'Mężczyzna')
ORDER BY COUNT(*) DESC;

--Którzy zawodnicy dostali co najmniej 3 trofea w swojej głównej dyscyplinie?
SELECT *
FROM [KursSQL].[dbo].[Zawodnicy] AS z
	INNER JOIN [KursSQL].[dbo].[Trofea] AS t
		ON z.IdZawodnicy = t.NrZawodnika

SELECT NrZawodnika, COUNT(*) AS LiczbaTrofeow
FROM [KursSQL].[dbo].[Trofea] AS t
GROUP BY t.NrZawodnika
HAVING COUNT(*) >= 3
ORDER BY LiczbaTrofeow DESC;

SELECT z.Imie, z.Nazwisko
FROM [KursSQL].[dbo].[Zawodnicy] z
	INNER JOIN [KursSQL].[dbo].[Trofea] t
		ON z.IdZawodnicy = t.NrZawodnika
WHERE z.GlownaDyscyplina = t.NrDyscyplinySportowej
GROUP BY z.Imie, z.Nazwisko
HAVING COUNT(*) >= 3;

--Który zawodnik urodzony w XXI wieku ma najlepszy rekord na 100m?
SELECT TOP 1 z.Imie, z.Nazwisko, r.Czas_s
FROM [KursSQL].[dbo].[Zawodnicy] AS z
	INNER JOIN [KursSQL].[dbo].[Rekord100m] AS r
		ON z.IdZawodnicy = r.NrZawodnika
WHERE YEAR(z.DataUrodzenia) >= 2000
ORDER BY r.Czas_s ASC;

--Pokaż średnią cenę każdego typu pamiątek dostępnych wszędzie
SELECT tp.Nazwa, AVG(p.Cena) AS SredniaCena
FROM [KursSQL].[dbo].[Pamiatki] AS p
	INNER JOIN [KursSQL].[dbo].[TypyPamiatek] AS tp
		ON p.TypPamiatki = tp.IdTypyPamiatek
WHERE CzyDostepneWszedzie = 1
GROUP BY tp.Nazwa;

SELECT tp.Nazwa, AVG(Cena)
FROM [KursSQL].[dbo].[Pamiatki] p
	INNER JOIN [KursSQL].[dbo].[TypyPamiatek] tp
		ON p.TypPamiatki = tp.IdTypyPamiatek
WHERE CzyDostepneWszedzie = 1
GROUP BY tp.Nazwa

--Którzy zawodnicy zdobyli trofeum w drugim kwartale 2019 roku?
SELECT DISTINCT z.Imie, z.Nazwisko
FROM [KursSQL].[dbo].[Zawodnicy] z
	INNER JOIN [KursSQL].[dbo].[Trofea] t
		ON t.NrZawodnika = z.IdZawodnicy
	INNER JOIN [KursSQL].[dbo].[Zawody] za
		ON za.IdZawody = t.IdZawodow
WHERE MONTH(za.Data) BETWEEN 4 AND 6
	AND YEAR(za.Data) = 2019;

SELECT z.Imie, z.Nazwisko
FROM [KursSQL].[dbo].[Zawodnicy] z
	INNER JOIN [KursSQL].[dbo].[Trofea] t
		ON t.NrZawodnika = z.IdZawodnicy
	INNER JOIN [KursSQL].[dbo].[Zawody] za
		ON za.IdZawody = t.IdZawodow
WHERE MONTH(za.Data) BETWEEN 4 AND 6
	AND YEAR(za.Data) = 2019
GROUP BY z.Imie, z.Nazwisko;

--Która pamiątka była najchętniej kupowana podczas zawodów w Gdańsku?
SELECT TOP 1 p.Nazwa
FROM [KursSQL].[dbo].[Pamiatki] p
	INNER JOIN [KursSQL].[dbo].[Zakupy] z
		ON p.IdPamiatki = z.NrPamiatki
	INNER JOIN [KursSQL].[dbo].[Zawody] za
		ON za.IdZawody = z.IdZawodow
	INNER JOIN [KursSQL].[dbo].[Miejsce] m
		ON m.IdMiejsce = za.Miejsce
WHERE m.Miejscowosc = 'Gdańsk'
GROUP BY p.Nazwa
ORDER BY COUNT(*) DESC

--Ilu kibiców w wakacje zawitało do poszczególnych miast na zawody?
SELECT m.Miejscowosc, COUNT(*) AS LiczbaKibicow
FROM [KursSQL].[dbo].[Kibice] AS k
	INNER JOIN [KursSQL].[dbo].[KibicZawody] AS kz
		ON k.IdKibice = kz.Kibic
	INNER JOIN [KursSQL].[dbo].[Zawody] AS z
		ON z.IdZawody = kz.NrZawodow
	INNER JOIN [KursSQL].[dbo].[Miejsce] AS m
		ON m.IdMiejsce = z.Miejsce
WHERE MONTH(z.Data) IN (7,8)
GROUP BY m.Miejscowosc

--Ile trofeów z dowolnego rodzaju biegu zdobyto podczas zawodów sponsorowanych przez CPN?
	SELECT COUNT(*) AS LiczbaTrofeow
	FROM [KursSQL].[dbo].[Trofea] AS t
		INNER JOIN [KursSQL].[dbo].[Dyscyplina] AS d
			ON d.IdDyscyplina = t.NrDyscyplinySportowej
		INNER JOIN [KursSQL].[dbo].[Zawody] AS z
			ON z.IdZawody = t.IdZawodow
		INNER JOIN [KursSQL].[dbo].[Sponsoring] AS s
			ON s.Zawody = z.IdZawody
		INNER JOIN [KursSQL].[dbo].[Sponsorzy] AS sp
			ON s.IdSponsora = sp.IdSponsorzy
	WHERE d.Nazwa LIKE 'Bieg%'
		AND sp.Nazwa = 'CPN'

--Ile zarobiliśmy na biletach na poszczególnych zawodach?
SELECT z.Nazwa, SUM(kz.CenaBiletu) AS IleZarobilismy
FROM [KursSQL].[dbo].[Zawody] AS z
	INNER JOIN [KursSQL].[dbo].[KibicZawody] AS kz
		ON z.IdZawody = kz.NrZawodow
GROUP BY z.Nazwa

--Ile trofeów zostało zdobytych podczas poszczególnych zawodów w lipcu?
SELECT z.Nazwa, COUNT(*) AS LiczbaTrofeow
FROM [KursSQL].[dbo].[Trofea] AS t
	INNER JOIN [KursSQL].[dbo].[Zawody] AS z
		ON t.IdZawodow = z.IdZawody
WHERE MONTH(z.Data) = 7
GROUP BY z.Nazwa

--Pokaż numery pamiatek kupionych nie częściej niż 2 razy podczas jednych zawodów
SELECT DISTINCT p.Nazwa
FROM [KursSQL].[dbo].[Zakupy] AS z
	INNER JOIN [KursSQL].[dbo].[Pamiatki] AS p
		ON p.IdPamiatki = z.NrPamiatki
GROUP BY p.Nazwa, z.IdZawodow
HAVING COUNT(*) <= 2

--Którzy zawodnicy dostali trofeum w innej dyscyplinie niż swoja główna?
SELECT z.Imie, z.Nazwisko
FROM [KursSQL].[dbo].[Zawodnicy] AS z
	INNER JOIN [KursSQL].[dbo].[Trofea] AS t
		ON z.IdZawodnicy = t.NrZawodnika
WHERE z.GlownaDyscyplina <> t.NrDyscyplinySportowej
GROUP BY z.Imie, z.Nazwisko

--Ile zarobiliśmy na kibicach, 
--którzy choć raz coś wygrali i należą do jakiegokolwiek stowarzyszenia?
SELECT k.Imie, k.Nazwisko, SUM(kz.CenaBiletu) AS IleZarobilismy
FROM [KursSQL].[dbo].[Kibice] AS k
	INNER JOIN [KursSQL].[dbo].[KonkursyDlaKibicow] AS kdk
		ON kdk.Zwyciezca = k.IdKibice
	INNER JOIN [KursSQL].[dbo].[KibicZawody] AS kz
		ON k.IdKibice = kz.Kibic
WHERE k.NrStowarzyszenia IS NOT NULL
GROUP BY k.Imie, k.Nazwisko