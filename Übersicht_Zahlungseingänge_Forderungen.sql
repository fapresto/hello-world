/* =============================================================================================
-- -------------------------------------------------------------------
-- Create: 2019/08/26
-- Autor: Diederichs
-- Zweck: Abgleich Forderungen aus compASS und Zahlungseingänge aus MPS
-- tLsb_FP: enthält die Angaben zu einer Forderungen
-- tLsb_FR: Personendaten, Bescheidsummen, Kopf der BG
-- tPers:  Personendaten
-- -------------------------------------------------------------------
--*/
SELECT fr.tNuAnmeldeName LSB_SB
, fr.tNuZust Team
, fr.FRX_PERSID
, fp.FPX_AKTENZ
-- Kommentar 1
-- Kommentar 2
-- Kommentar 4
, fp.FPX_SOLL_1
, fp.FPX_SOLL_N
, fp.FPX_SOLLAEND
, fp.FPX_STUND_1
--, fp.FPX_IST_1
, fp.FPX_RUECKST
--, fp.FPX_STUNDAB, fp.FPX_GUELTAB, fp.FPX_BISJMT
, fp.FPX_KASSENZ
, i.[Pers_ ID] PersID_MPS
--, i.Betrag Einzahlung 
, CAST(i.Betrag AS float) Einzahlung
, i.Name Einzahlender, i.Adresse, i.PLZ
, i.[Buchungsdatum bei Erfassung]
, i.[Buchungstext 1] , i.[Buchungstext 2], i.[Buchungstext 3] Kassenzeichen_LSB, i.Erfassungsdatum

  FROM [ps_dat].[dbo].[tLsb_FP] fp --FÜHRENDE TABELLE!
  LEFT JOIN [mps].[dbo].[Saarpfalz-Kreis$Geb_Ist-Erfassung] i
    ON fp.FPX_KASSENZ = i.[Buchungstext 3] collate Latin1_General_100_CI_AS
  INNER JOIN ( 
  -- ---------------------------------------------------------------------
  -- Untermenge mit benötigten Angaben bilden (PersID, zust. LSB-SB, Team)
  -- ---------------------------------------------------------------------
	Select distinct f.FRX_PERSID, f.FRX_AKTENZ, tnu.tNuAnmeldeName, tnu.tNuZust --, fa.FAX_SACHBEAR, tnu.tNuAnmeldeName 
	from [ps_dat].[dbo].[tLsb_FR] f
	INNER JOIN ([ps_dat].[dbo].[tLsb_FA] fa
				LEFT JOIN [ps_dat].[dbo].[tNutzerAdmin] tnu
				ON fa.FAX_SACHBEAR = tnu.tNuAbk
	) 
	ON f.FRX_AKTENZ = fa.FAX_AKTENZ
	-- nur Kopf der BG ziehen
	where f.FRX_NRPERSON = 1 and f.FRX_PERSID <> ''
  ) fr
    ON fp.FPX_AKTENZ = fr.FRX_AKTENZ 
    
    --where i.Betrag is not null 
order by LSB_SB, fr.FRX_PERSID, fp.FPX_KASSENZ

  