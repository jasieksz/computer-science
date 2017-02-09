DROP DATABASE sznajd_a
CREATE DATABASE sznajd_a

DROP TABLE IF EXISTS uczestnicywarsztatow CASCADE;
DROP TABLE IF EXISTS uczestnicydnia CASCADE;
DROP TABLE IF EXISTS oplaty CASCADE;
DROP TABLE IF EXISTS rezerwacjewarsztatow CASCADE;
DROP TABLE IF EXISTS uczestnicy CASCADE;
DROP TABLE IF EXISTS rezerwacjedni CASCADE;
DROP TABLE IF EXISTS cennik CASCADE;
DROP TABLE IF EXISTS warsztaty CASCADE;
DROP TABLE IF EXISTS dzienkonferencji CASCADE;
DROP TABLE IF EXISTS firmykonferencji CASCADE;
DROP TABLE IF EXISTS konferencje CASCADE;
DROP TABLE IF EXISTS firmy CASCADE;

CREATE TABLE public.firmy
(
    idfirmy SERIAL PRIMARY KEY NOT NULL,
    nazwa VARCHAR(64) UNIQUE NOT NULL,
    telefon VARCHAR(16) CHECK (telefon NOT LIKE '%[^0-9]%'),
    email VARCHAR(32) UNIQUE NOT NULL ,
    nip VARCHAR(10) CHECK (nip NOT LIKE '%[^0-9]%'),
    haslo VARCHAR(32) NOT NULL,
    kraj VARCHAR(32) CHECK (kraj !~ '[^A-Z a-zążółćśęźńĄŻÓŁĆŚĘŹŃ-]'),
    miasto VARCHAR(32) CHECK (miasto !~ '[^A-Z a-zążółćśęźńĄŻÓŁĆŚĘŹŃ-]'),
    ulica VARCHAR(32)
);

CREATE TABLE public.konferencje
(
    idkonferencji SERIAL PRIMARY KEY NOT NULL,
    nazwa VARCHAR(64) UNIQUE NOT NULL,
    datastart DATE NOT NULL,
    datakoniec DATE NOT NULL CHECK (konferencje.datakoniec >= konferencje.datastart),
    kraj VARCHAR(32) CHECK (kraj !~ '[^A-Z a-zążółćśęźńĄŻÓŁĆŚĘŹŃ-]'),
    miasto VARCHAR(32) CHECK (miasto !~ '[^A-Z a-zążółćśęźńĄŻÓŁĆŚĘŹŃ-]'),
    ulica VARCHAR(32),
    anulowane BOOLEAN
);


CREATE TABLE public.warsztaty
(
    idwarsztatu SERIAL PRIMARY KEY NOT NULL,
    idkonferencji INTEGER NOT NULL,
    iddnia INTEGER NOT NULL,
    nazwa VARCHAR(32) NOT NULL,
    godzinastart TIME,
    godzinakoniec TIME CHECK (warsztaty.godzinastart < warsztaty.godzinakoniec),
    cena MONEY NOT NULL CHECK (warsztaty.cena >= 0.00::MONEY),
    iloscmiejsc INTEGER NOT NULL CHECK (warsztaty.iloscmiejsc > 0),
    anulowany BOOLEAN
);

CREATE TABLE uczestnicy
(
    iduczestnika SERIAL PRIMARY KEY NOT NULL,
    imie VARCHAR(32),
    nazwisko VARCHAR(32),
    email VARCHAR(32) UNIQUE NOT NULL ,
    telefon VARCHAR(16) CHECK (telefon NOT LIKE '%[^0-9]%'),
    haslo VARCHAR(16) NOT NULL
);

CREATE  TABLE public.dzienkonferencji(
  iddnikonferencji SERIAL NOT NULL PRIMARY KEY,
  idkonferencji INTEGER NOT NULL REFERENCES konferencje (idkonferencji),
  data DATE NOT NULL,
  iloscmiejsc INTEGER CHECK (dzienkonferencji.iloscmiejsc >= 0),
  cena MONEY CHECK (dzienkonferencji.cena>=0.00::MONEY)
);

CREATE TABLE public.firmykonferencji (
  idfirmykonferncji SERIAL NOT NULL PRIMARY KEY ,
  idkonferencji INTEGER NOT NULL REFERENCES konferencje (idkonferencji),
  idfirmy INTEGER NOT NULL REFERENCES firmy (idfirmy),
  CONSTRAINT no_duplicate UNIQUE (idkonferencji,idfirmy)
);

CREATE TABLE public.rezerwacjedni (
  idrezerwacjedni SERIAL NOT NULL PRIMARY KEY,
  idfirmykonferencji INTEGER NOT NULL REFERENCES firmykonferencji (idfirmykonferncji),
  iddnikonferencji INTEGER NOT NULL REFERENCES dzienkonferencji (iddnikonferencji),
  datarezerwacji DATE NOT NULL,
  iloscmiejsc INTEGER NOT NULL,
  dataanulowania DATE
);

CREATE TABLE public.uczestnicydnia (
  iduczestnicydnia SERIAL NOT NULL PRIMARY KEY,
  iduczestnika INTEGER NOT NULL REFERENCES uczestnicy (iduczestnika),
  idrezerwacjedni INTEGER NOT NULL REFERENCES rezerwacjedni (idrezerwacjedni),
  typ VARCHAR(16),
  numerlegitymacji INTEGER CHECK (uczestnicydnia.numerlegitymacji >= 0),
  CONSTRAINT uczestnicydnia_no_duplicate UNIQUE (iduczestnika, idrezerwacjedni)
);

CREATE TABLE public.rezerwacjewarsztatow (
  idrezerwacjewarsztatow SERIAL NOT NULL PRIMARY KEY,
  idwarsztatu INTEGER NOT NULL REFERENCES warsztaty (idwarsztatu),
  idrezerwacjedni INTEGER NOT NULL REFERENCES rezerwacjedni (idrezerwacjedni),
  iloscmiejsc INTEGER NOT NULL CHECK (rezerwacjewarsztatow.iloscmiejsc > 0),
  dataanulowania DATE
);

CREATE TABLE public.oplaty (
  idoplaty SERIAL NOT NULL PRIMARY KEY,
  idrezerwacjedni INTEGER NOT NULL REFERENCES rezerwacjedni (idrezerwacjedni),
  kwota MONEY CHECK (kwota >= 0.00::MONEY)
);

CREATE TABLE public.cennik (
  idceny SERIAL NOT NULL PRIMARY KEY,
  iddnikonferencji INTEGER NOT NULL REFERENCES dzienkonferencji (iddnikonferencji),
  dataplatnosci DATE,
  modyfikator REAL
);

CREATE TABLE uczestnicywarsztatow
(
    iduczestnicywarsztatow SERIAL PRIMARY KEY NOT NULL,
    idrezerwacjewarsztatow INTEGER NOT NULL REFERENCES rezerwacjewarsztatow (idrezerwacjewarsztatow),
    iduczestnicydnia INTEGER NOT NULL  REFERENCES uczestnicydnia (iduczestnicydnia),
    CONSTRAINT uczestnicywarsztatow_no_duplicate UNIQUE (idrezerwacjewarsztatow, iduczestnicydnia)
);
--------------------------------------------------------- WIDOKI ---------------------------------------------------------

CREATE VIEW public.ZaplanowaneKonferencje AS
  SELECT idkonferencji, nazwa, datastart FROM konferencje
  WHERE konferencje.datastart > CURRENT_DATE;


CREATE VIEW public.NiepolaconeRezerwacjeKonferencji AS
  SELECT rezerwacjedni.idrezerwacjedni AS "Id Rezerwacji" FROM rezerwacjedni
  LEFT OUTER JOIN oplaty ON rezerwacjedni.idrezerwacjedni = oplaty.idrezerwacjedni
  WHERE (idoplaty IS NULL) OR (dataanulowania IS NOT NULL);


CREATE VIEW public.ZaplanowaneWarsztaty AS
  SELECT warsztaty.nazwa, warsztaty.iddnia, warsztaty.godzinakoniec, warsztaty.cena,
    warsztaty.iloscmiejsc -(SELECT SUM(rezerwacjewarsztatow.iloscmiejsc) FROM rezerwacjewarsztatow
                            WHERE (rezerwacjewarsztatow.idwarsztatu = warsztaty.idwarsztatu)
                            AND rezerwacjewarsztatow.dataanulowania IS NULL) AS "Dostępne miejsca"
FROM warsztaty
INNER JOIN dzienkonferencji ON warsztaty.iddnia = dzienkonferencji.iddnikonferencji
WHERE dzienkonferencji.data > CURRENT_DATE;


CREATE VIEW public.AktywnoscUczestnikow AS
  SELECT iduczestnika, SUM(iduczestnicydnia) AS "Aktywność" FROM uczestnicydnia
  GROUP BY iduczestnika
  ORDER BY SUM(iduczestnicydnia) DESC;


CREATE VIEW public.AktywnoscFirm AS
  SELECT idfirmy, COUNT(idfirmykonferncji) AS "Aktywność" FROM firmykonferencji
  INNER JOIN rezerwacjedni ON firmykonferencji.idfirmykonferncji = rezerwacjedni.idfirmykonferencji
  GROUP BY idfirmy, dataanulowania
  HAVING (dataanulowania IS NULL)
  ORDER BY COUNT(idfirmykonferncji) DESC;

------------------------------------------- TRIGERY ----------------------------------------

CREATE TRIGGER tr_sprawdz_godziny_warsztatow
AFTER INSERT OR UPDATE ON warsztaty
FOR EACH ROW EXECUTE PROCEDURE sprawdz_godziny_warsztatu();

CREATE TRIGGER tr_anuluj_warsztaty
AFTER UPDATE ON rezerwacjedni
FOR ROW EXECUTE PROCEDURE anuluj_rezerwacje_warsztatu();

---------------------------------- FUNCKEJ -------------------------------------------
CREATE OR REPLACE FUNCTION Dodaj_Cennik(
  Konferencja character varying,
  Dzien date,
  DataPlatnosci date,
  Cena MONEY
) returns void as $$
  DECLARE Id_Konferencji INTEGER;
  DECLARE Id_Dnia_Konferencji INTEGER;
  BEGIN
    INSERT INTO cennik
    VALUES(DEFAULT, Znajdz_Dzien_Konferencji(Konferencja, Dzien), DataPlatnosci, Cena);
  END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Dodaj_Dzien_Konferencji(
  Konferencja character varying,
  Data date,
  Cena MONEY,
  miejsca integer
) returns void as $$
  BEGIN
    INSERT INTO dzienkonferencji VALUES(DEFAULT, Znajdz_Konferencje(Konferencja), Data, Cena, Miejsca);
  END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Dodaj_Firme(
  Firma character varying,
  Telefon character varying,
  Email character varying,
  NIP character varying,
  Haslo character varying,
  Kraj character varying,
  Miasto character varying,
  Ulica character varying
) returns void as $$
  BEGIN
    INSERT INTO firmy VALUES(DEFAULT, Firma, Telefon, Email, NIP, Haslo, Kraj, Miasto, Ulica);
  END
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Dodaj_Firme_Konferencji(
  Konferencja character varying,
  Firma character varying
  ) returns void as $$
  DECLARE Id_Konferencji INTEGER;
  DECLARE Id_Firmy INTEGER;
  BEGIN
    ID_Konferencji := Znajdz_Konferencje(Konferencja);
    Id_Firmy := Znajdz_Firme(Firma);
    INSERT INTO firmykonferencji
    VALUES(DEFAULT, Id_Konferencji, Id_Firmy);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Dodaj_Konferencje(
  Konferencja character varying,
  datastart date,
  datakoniec date,
  kraj character varying,
  miasto character varying,
  ulica character varying
  )
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
  INSERT INTO konferencje VALUES(DEFAULT, Konferencja, DataStart, DataKoniec, Kraj, Miasto, Ulica, false);
END; $function$;

CREATE OR REPLACE FUNCTION Dodaj_Oplate(
  Firma       character varying,
  Konferencja character varying,
  Dzien       date,
  Kwota       money
) RETURNS VOID AS $$
  DECLARE Id_Rezerwacji_Dnia INTEGER;
  BEGIN
    Id_Rezerwacji_Dnia=Znajdz_Rezerwacje_Dnia(Firma, Konferencja, Dzien);
    INSERT INTO oplaty
    VALUES(DEFAULT, Id_Rezerwacji_Dnia, Kwota);
  END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Dodaj_Rezerwacje_Dni(
  Firma character varying,
  Konferencja character varying,
  Dzien date,
  data_rezerwacji date,
  IloscMiejsc integer
) returns void as $$
  DECLARE Id_Dnia_Konferencji Integer;
  DECLARE Id_Firmy_Konferencji Integer;
  BEGIN
    ID_Dnia_Konferencji := Znajdz_Dzien_Konferencji(Konferencja, Dzien);
    Id_Firmy_Konferencji := Znajdz_Firme_Konferencji(Firma, Konferencja);
    INSERT INTO rezerwacjedni
    VALUES(DEFAULT, Id_Firmy_Konferencji, Id_Dnia_Konferencji, data_rezerwacji, IloscMiejsc, NULL);
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Dodaj_Rezerwacje_Warsztatu(
  Warsztat character varying,
  Konferencja character varying,
  Dzien date,
  Firma character varying,
  Ilosc_Miejsc INTEGER
) returns void as $$
  BEGIN
    INSERT INTO rezerwacjewarsztatow
    VALUES(DEFAULT, Znajdz_Warsztat(Warsztat, Konferencja, Dzien),
      Znajdz_Rezerwacje_Dnia(Firma, Konferencja, Dzien), Ilosc_Miejsc, NULL);
  END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Dodaj_Uczestnika(
    Imie character varying,
    Nazwisko character varying,
    Email character varying,
    Telefon character varying,
    Haslo character varying
) returns void as $$
  BEGIN
    INSERT INTO uczestnicy VALUES(DEFAULT, Imie, Nazwisko, Email, Telefon, Haslo);
  END;
$$ LANGUAGE plpgsql;;

CREATE OR REPLACE FUNCTION dodaj_uczestnika_dnia (user_email character varying, konferencja character varying, dzien date, firma character varying, typ character varying, numer_legitymacji integer) RETURNS void
 LANGUAGE plpgsql
AS $$
  DECLARE Id_Rezerwacji_Dnia  INTEGER;
  DECLARE ID_Konferencji      INTEGER;
  DECLARE Id_Dnia_Konferencji INTEGER;
  DECLARE Id_Uczestnika INTEGER;
  BEGIN
    Id_Dnia_Konferencji := Znajdz_Dzien_Konferencji(Konferencja, Dzien);
    Id_Rezerwacji_Dnia := Znajdz_Rezerwacje_Dnia(Firma, Konferencja, Dzien);
    Id_Uczestnika := znajdz_uczestnika(user_email);
    INSERT INTO uczestnicydnia
    VALUES(DEFAULT, Id_Uczestnika, Id_Rezerwacji_Dnia, Typ, Numer_Legitymacji);
  END;
$$;

CREATE OR REPLACE FUNCTION Dodaj_Uczestnika_Warsztatu(
    Firma         character varying,
    Warsztat      character varying,
    Konferencja   character varying,
    Dzien         date,
    Id_Uczestnika Integer

    ) RETURNS VOID AS $$
    DECLARE Id_Rezerwacji_Warsztatu INTEGER;
    DECLARE Id_Uczestnika_Dnia INTEGER;
    BEGIN
    Id_Rezerwacji_Warsztatu := Znajdz_Rezerwacje_Warsztatu(Firma, Warsztat, Konferencja, Dzien);
    Id_Uczestnika_Dnia      := Znajdz_Uczestnika_Dnia(Id_Uczestnika, Konferencja, Dzien, Firma);
    INSERT INTO uczestnicywarsztatow
    VALUES(DEFAULT, Id_Rezerwacji_Warsztatu, Id_Uczestnika_Dnia);
    END;
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Dodaj_Warsztat(
  Warsztat      character varying,
  Konferencja   character varying,
  Dzien         date,
  Godzinastart  TIME,
  Godzinakoniec TIME,
  Cena          MONEY,
  IloscMiejsc   integer
) returns void as $$
  DECLARE Id_Konferencji      INTEGER;
  DECLARE Id_Dnia_Konferencji INTEGER;
  BEGIN
  INSERT INTO warsztaty
  VALUES(DEFAULT, Znajdz_Dzien_Konferencji(Konferencja, Dzien),
    Godzinastart, Godzinakoniec, Cena, IloscMiejsc, FALSE, Warsztat);
  END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Znajdz_Konferencje(Konferencja character varying)
returns Integer as $$
  DECLARE ID_Konferencji INTEGER;
  BEGIN
    ID_Konferencji := (
      SELECT idkonferencji FROM konferencje WHERE Konferencja=konferencje.nazwa
    );
    IF Id_Konferencji IS NULL THEN
      RAISE 'Nie ma takiej konferencji';
    ELSE return Id_Konferencji;
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Znajdz_Dzien_Konferencji(Konferencja character varying, Dzien date)
returns Integer as $$
  DECLARE Id_Dnia_Konferencji INTEGER;
  BEGIN
    ID_Dnia_Konferencji := (
      SELECT iddnikonferencji FROM dzienkonferencji WHERE dzienkonferencji.data = dzien AND idkonferencji = Znajdz_Konferencje(Konferencja)
    );
    IF Id_Dnia_Konferencji IS NULL THEN
      RAISE 'Nie ma takiego dnia konferencji';
    ELSE return Id_Dnia_Konferencji;
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION  Znajdz_Firme(Firma character varying)
returns Integer as $$
  DECLARE Id_Firmy INTEGER;
  BEGIN
    IF Firma IS NULL THEN
      Id_Firmy := (SELECT idfirmy FROM firmy WHERE Nazwa='INDIVIDUAL');
    ELSE
      Id_Firmy := (SELECT idfirmy FROM firmy WHERE Nazwa=firma       );
    END IF;
    IF Id_Firmy IS NULL THEN
      RAISE 'Nie ma takiej firmy';
    ELSE return Id_Firmy;
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Znajdz_Firme_Konferencji(Firma character varying, Konferencja character varying)
returns Integer as $$
  DECLARE Id_Firmy_Konferencji Integer;
  BEGIN
    Id_Firmy_Konferencji := (
      SELECT idfirmykonferncji FROM firmykonferencji
      WHERE idfirmy=Znajdz_Firme(Firma) AND idkonferencji=Znajdz_Konferencje(Konferencja)
      );
    IF Id_Firmy_Konferencji IS NULL THEN
      RAISE 'Ta firma nie jest zarejestrowana na tej konferencji';
    ELSE
      return Id_Firmy_Konferencji;
    END IF;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Znajdz_Rezerwacje_Dnia(
  Firma       character varying,
  Konferencja character varying,
  Dzien       date
)
  returns   Integer as $$
  DECLARE Id_Rezerwacji_Dnia Integer;
  DECLARE Id_Dnia_Konferencji Integer;
  DECLARE Id_Firmy_Konferencji Integer;
  BEGIN
    Id_Dnia_Konferencji   := Znajdz_Dzien_Konferencji(Konferencja, Dzien);
    Id_Firmy_Konferencji  := Znajdz_Firme_Konferencji(Firma, Konferencja);
    Id_Rezerwacji_Dnia    := (
      SELECT  idrezerwacjedni FROM rezerwacjedni
      WHERE   iddnikonferencji=Id_Dnia_Konferencji
      AND     idfirmykonferencji=Id_Firmy_Konferencji
      );
    IF Id_Rezerwacji_Dnia IS NULL THEN
      RAISE 'Dana firma nie ma rezerwacji na tej konferencji tego dnia';
    ELSE
      return Id_Rezerwacji_Dnia;
    END IF;
  END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Znajdz_Rezerwacje_Warsztatu(
  Firma       character varying,
  Warsztat    character varying,
  Konferencja character varying,
  Dzien       date
  )
  returns     INTEGER
  as $$
  DECLARE Id_Rezerwacji_Warsztatu INTEGER;
  BEGIN
    Id_Rezerwacji_Warsztatu := (
        SELECT idrezerwacjewarsztatow FROM rezerwacjewarsztatow
        WHERE idwarsztatu=Znajdz_Warsztat(Warsztat, Konferencja, Dzien)
        AND idrezerwacjedni=Znajdz_Rezerwacje_Dnia(Firma, Konferencja, Dzien)
      );
    IF Id_Rezerwacji_Warsztatu IS NULL THEN
      RAISE 'Nie ma takiej rezerwacji warsztatu';
    ELSE
      return Id_Rezerwacji_Warsztatu;
    END IF;
  END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Znajdz_Uczestnika_Dnia(
  Id_Uczestnika Integer,
  Konferencja   character varying,
  Dzien         date,
  Firma         character varying
) returns       Integer
  as $$
  DECLARE Id_Uczestnika_Dnia Integer;
  BEGIN
    Id_Uczestnika_Dnia := (
      SELECT  iduczestnicydnia FROM uczestnicydnia
      WHERE   iduczestnika=Id_Uczestnika
      AND     idrezerwacjedni=Znajdz_Rezerwacje_Dnia(Firma, Konferencja, Dzien)
      );
    IF Id_Uczestnika_Dnia IS NULL THEN
      RAISE 'Nie ma takiego uczestnika tego dnia';
    ELSE return Id_Uczestnika_Dnia;
    END IF;
  END;
  $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Znajdz_Warsztat(
  Warsztat    character varying,
  Konferencja character varying,
  Dzien       date
) returns     Integer as $$
  DECLARE Id_Warsztatu Integer;
  BEGIN
    Id_Warsztatu := (
      SELECT idwarsztatu FROM warsztaty
      WHERE iddnia=Znajdz_Dzien_Konferencji(Konferencja, Dzien)
      AND warsztaty.nazwa=Warsztat
      );
    IF Id_Warsztatu IS NULL THEN
      RAISE 'Nie ma takiego warsztatu';
    ELSE
      return Id_Warsztatu;
    END IF;
  END;
  $$ LANGUAGE plpgsql;

  CREATE FUNCTION anuluj_rezerwacje_dnia (idrezewacjidnia INTEGER) RETURNS void
  LANGUAGE plpgsql
AS $$
  BEGIN
    UPDATE rezerwacjedni SET dataanulowania = CURRENT_DATE;
  END;
$$;

CREATE OR REPLACE FUNCTION uczestnicy_dnia_konferencji (iddniakonferencji INTEGER)
RETURNS TABLE ("id uczestnika" INTEGER, "imie" VARCHAR(50), "nazwisko" VARCHAR(50))
LANGUAGE plpgsql
AS $$
  BEGIN
  RETURN QUERY
  SELECT uczestnicy.iduczestnika, imie, nazwisko FROM uczestnicy
  INNER JOIN uczestnicydnia ON uczestnicy.iduczestnika=uczestnicydnia.iduczestnika
  INNER JOIN rezerwacjedni ON uczestnicydnia.idrezerwacjedni = rezerwacjedni.idrezerwacjedni
  INNER JOIN dzienkonferencji ON rezerwacjedni.iddnikonferencji = dzienkonferencji.iddniakonferencji
  WHERE dzienkonferencji.iddniakonferencji = uczestnicy_dnia_konferencji.iddniakonferencji
  ORDER BY uczestnicy.iduczestnika;
  END;
$$;


CREATE OR REPLACE FUNCTION uczestnicy_warsztatu (idwarsztatu INTEGER)
RETURNS TABLE ("id uczestnika" INTEGER, "imie" VARCHAR(50), "nazwisko" VARCHAR(50))
LANGUAGE plpgsql
AS $$
  BEGIN
  RETURN QUERY
  SELECT uczestnicy.iduczestnika, imie, nazwisko FROM uczestnicy
  INNER JOIN uczestnicydnia ON uczestnicy.iduczestnika=uczestnicydnia.iduczestnika
  INNER JOIN uczestnicywarsztatow ON uczestnicydnia.iduczestnicydnia = uczestnicywarsztatow.iduczestnicydnia
  INNER JOIN rezerwacjewarsztatow ON uczestnicywarsztatow.idrezerwacjewarsztatow = rezerwacjewarsztatow.idrezerwacjewarsztatow
  INNER JOIN warsztaty ON rezerwacjewarsztatow.idwarsztatu = warsztaty.idwarsztatu
  WHERE warsztaty.idwarsztatu = uczestnicy_warsztatu.idwarsztatu
  ORDER BY uczestnicy.iduczestnika;
  END;
$$;

CREATE OR REPLACE FUNCTION wolne_miejsca_dnia(id_dnia INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
  DECLARE wszystkiemiejsca INTEGER;
  DECLARE zajetemiejsca INTEGER;
  DECLARE wolnemiejsca INTEGER;
  BEGIN
    wszystkiemiejsca := (SELECT iloscmiejsc FROM dzienkonferencji
                         WHERE iddniakonferencji = id_dnia);
    zajetemiejsca := (SELECT sum(iloscmiejsc) FROM rezerwacjedni
                      WHERE (iddnikonferencji = id_dnia AND dataanulowania IS NULL));
    wolnemiejsca := (wszystkiemiejsca - zajetemiejsca);
    RETURN wolnemiejsca;
  END;
$$;

CREATE OR REPLACE FUNCTION wolne_miejsca_warsztatu(id_warsztatu INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
  DECLARE wszystkiemiejsca INTEGER;
  DECLARE zajetemiejsca INTEGER;
  DECLARE wolnemiejsca INTEGER;
  BEGIN
    wszystkiemiejsca := (SELECT iloscmiejsc FROM warsztaty
                         WHERE idwarsztatu = id_warsztatu);
    zajetemiejsca := (SELECT sum(iloscmiejsc) FROM rezerwacjewarsztatow
                      WHERE (idwarsztatu = id_warsztatu AND rezerwacjewarsztatow.dataanulowania IS NULL));
    wolnemiejsca := (wszystkiemiejsca - zajetemiejsca);
    RETURN wolnemiejsca;
  END;
$$;


CREATE OR REPLACE FUNCTION sprawdz_zgodnosc_rezerwacji(id_rezerwacjidnia INTEGER)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
  DECLARE czy_oplacona INTEGER;
  DECLARE miejsca_zarezerwowane INTEGER;
  DECLARE uczestnicy_rezerwacji INTEGER;
  BEGIN
    czy_oplacona := (SELECT idoplaty FROM oplaty
                     WHERE idrezerwacjedni=id_rezerwacjidnia);
    IF czy_oplacona IS NULL THEN
      RAISE 'Rezerwacja jeszcze nie oplacona';
      RETURN FALSE;
    END IF;
    miejsca_zarezerwowane := (SELECT iloscmiejsc FROM rezerwacjedni
                              WHERE idrezerwacjedni = id_rezerwacjidnia);
    uczestnicy_rezerwacji := (SELECT COUNT(iduczestnicydnia) FROM uczestnicydnia
                              HAVING idrezerwacjedni = id_rezerwacjidnia);
    IF miejsca_zarezerwowane != uczestnicy_rezerwacji THEN
      RAISE 'Nie wczyscy się jeszcze zapisali';
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END;
$$;

CREATE OR REPLACE FUNCTION dodaj_rezerwacje_warsztatu (warsztat character varying, konferencja character varying, dzien date, firma character varying, ilosc_miejsc integer) RETURNS void
	LANGUAGE plpgsql
AS $$
  DECLARE wolne_miejsca INTEGER;
  DECLARE id_warsztatu INTEGER;
  BEGIN
    id_warsztatu := Znajdz_Warsztat(Warsztat, Konferencja, Dzien);
    wolne_miejsca := wolne_miejsca_warsztatu(id_warsztatu);
    IF wolne_miejsca < ilosc_miejsc THEN
      RAISE 'Nie ma tyle miejsc';
    ELSE
      INSERT INTO rezerwacjewarsztatow
      VALUES(DEFAULT, id_warsztatu, Znajdz_Rezerwacje_Dnia(Firma, Konferencja, Dzien), Ilosc_Miejsc, NULL);
    END IF;
  END;
$$;


CREATE OR REPLACE FUNCTION dodaj_rezerwacje_dni (firma character varying, konferencja character varying, dzien date, data_rezerwacji date, ilosc_miejsc integer) RETURNS void
	LANGUAGE plpgsql
AS $$
  DECLARE Id_Dnia_Konferencji Integer;
  DECLARE Id_Firmy_Konferencji Integer;
  DECLARE wolne_miejsca INTEGER;
  BEGIN
    ID_Dnia_Konferencji := Znajdz_Dzien_Konferencji(Konferencja, Dzien);
    Id_Firmy_Konferencji := Znajdz_Firme_Konferencji(Firma, Konferencja);
    wolne_miejsca := wolne_miejsca_dnia(Id_Dnia_Konferencji);
    IF wolne_miejsca < ilosc_miejsc THEN
      RAISE 'Nie ma już wolnych miejsc';
    ELSE
      INSERT INTO rezerwacjedni
      VALUES(DEFAULT, Id_Firmy_Konferencji, Id_Dnia_Konferencji, data_rezerwacji, IloscMiejsc, NULL);
    END IF;
  END;
$$;

CREATE OR REPLACE FUNCTION znajdz_uczestnika_dnia (id_uczestnika integer, konferencja character varying, dzien date, firma character varying) RETURNS integer
 LANGUAGE plpgsql
AS $$
  DECLARE Id_Uczestnika_Dnia Integer;
  BEGIN
    Id_Uczestnika_Dnia := (
      SELECT  iduczestnicydnia FROM uczestnicydnia
      WHERE   iduczestnika=Id_Uczestnika
      AND     idrezerwacjedni=Znajdz_Rezerwacje_Dnia(Firma, Konferencja, Dzien)
      );
    IF Id_Uczestnika_Dnia IS NULL THEN
      RAISE 'Nie ma takiego uczestnika tego dnia';
    ELSE return Id_Uczestnika_Dnia;
    END IF;
  END;
$$;
