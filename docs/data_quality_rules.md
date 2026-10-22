# Prüfregeln – Details

Datenstand: **01.10.2026**. Geprüft werden 1.760 Terminänderungen und 3.200 Aufträge.

| # | Regel | Tabelle | Logik | Umsetzung | Treffer |
|---|---|---|---|---|---|
| 1 | Grund fehlt | Terminaenderungen | `Grund` ist leer | Power Query: `Grund_Error`; DAX: `[Grund fehlt]` | 45 |
| 2 | Kunde informiert ungültig | Terminaenderungen | Wert ist nicht `Ja` oder `Nein` | Power Query: `Kunde_Informiert_Error` mit `List.Contains`; Bereinigung in `Kunde_informiert_clean` | 40 |
| 3 | Verschiebung falsch | Terminaenderungen | `Verschiebung_Tage` ≠ `Neuer_Termin − Alter_Termin` | Power Query: `Mathcheck_Error`; neu berechnet in `Verschiebung_Tagen` | 40 |
| 4 | Datum unplausibel | Terminaenderungen | `Aenderungsdatum` > Datenstand **oder** `Neuer_Termin` < `Aenderungsdatum` | Power Query: `Gueltig` (0/1) | 80 |
| 5 | Dubletten | Terminaenderungen | gleiche `Aenderungs_ID` erscheint mehrfach | Index-Spalte + DAX-Spalte `Ist_Dublette`; die erste Zeile gilt als Original | 30 |
| 6 | Markt ungültig | Auftraege | `Markt` nicht in `Stammliste_Land` | Merge mit der Stammliste → `Check_Markt_Error`; Mapping in `Markt_Clean` | 45 |
| 7 | Absatzmittler fehlt | Auftraege | `Absatzmittler` ist leer | Power Query: `Missing Absatzmittler` | 20 |

## Warum markieren statt löschen?

Gelöschte Zeilen tauchen nirgends mehr auf. Damit lässt sich weder prüfen, ob eine Regel zu streng ist, noch an die erfassenden Stellen zurückmelden, welche Fehler auftreten.

Deshalb gilt:

- `Gueltig_final = 1`: Die Zeile fließt in die KPIs ein (Seitenfilter).
- `Gueltig_final = 0`: Die Zeile bleibt im Modell und erscheint auf der Seite **Datenqualität**.

```
Gueltig_final = IF ( Gueltig = 1 && Ist_Dublette = 0, 1, 0 )
```

Ausgeschlossen: 80 (Datum) + 30 (Dubletten) = **110**. Für die Analyse gültig sind damit **1.650** Änderungen.
