// Power Query (M) – Tabelle Terminaenderungen
// Quelle: data/Liefertermin_Prototyp_Daten.xlsx (Pfad anpassen)
let
    Source = Excel.Workbook(File.Contents("C:\Pfad\zu\Liefertermin_Prototyp_Daten.xlsx"), null, true),
    Terminaenderungen_Table = Source{[Item="Terminaenderungen",Kind="Table"]}[Data],
    #"Changed Type" = Table.TransformColumnTypes(Terminaenderungen_Table,{{"Aenderungs_ID", type text}, {"Auftragsnr", type text}, {"Aenderungsdatum", Int64.Type}, {"Alter_Termin", Int64.Type}, {"Neuer_Termin", Int64.Type}, {"Verschiebung_Tage", Int64.Type}, {"Grund", type text}, {"Kunde_informiert", type text}, {"Erfasst_ueber", type text}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type", "Mathcheck_Error", each let
    ExpectedDays = Value.Subtract([Neuer_Termin], [Alter_Termin]),
    Result =
        if [Verschiebung_Tage] = ExpectedDays
        then "Yes"
        else "Error"
in
    Result),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "Custom", each if [Grund] = null then "Error" else "Alles Gut"),
    #"Renamed Columns" = Table.RenameColumns(#"Added Custom1",{{"Custom", "Grund_Error"}}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Renamed Columns",{{"Kunde_informiert", type text}, {"Aenderungsdatum", type date}, {"Alter_Termin", type date}, {"Neuer_Termin", type date}}),
    #"Duplicated Column" = Table.DuplicateColumn(#"Changed Type1", "Grund_Error", "Grund_Error - Copy"),
    #"Removed Columns" = Table.RemoveColumns(#"Duplicated Column",{"Grund_Error - Copy"}),
    #"Added Custom2" = Table.AddColumn(#"Removed Columns", "Kunde_Informiert_Error", each if List.Contains({"Ja","Nein"}, [Kunde_informiert]) then "Alles Gut" else "Error"),
    #"Filtered Rows" = Table.SelectRows(#"Added Custom2", each true),
    #"Added Custom3" = Table.AddColumn(#"Filtered Rows", "Aenderungdatum_Error", each if [Aenderungsdatum]>[Neuer_Termin] then "Error" else "Alles Gut"),
    #"Added Custom4" = Table.AddColumn(#"Added Custom3", "Verschiebungen", each [Neuer_Termin]-[Alter_Termin]),
    #"Changed Type3" = Table.TransformColumnTypes(#"Added Custom4",{{"Verschiebungen", Int64.Type}}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Changed Type3",{{"Verschiebungen", Int64.Type}}),
    #"Renamed Columns1" = Table.RenameColumns(#"Changed Type2",{{"Verschiebungen", "Verschiebung_Tagen"}}),
    #"Added Custom5" = Table.AddColumn(#"Renamed Columns1", "Gueltig", each if [Aenderungsdatum] > #date(2026, 10, 1) or [Neuer_Termin] < [Aenderungsdatum] then 0 else 1),
    #"Added Index" = Table.AddIndexColumn(#"Added Custom5", "Index", 1, 1, Int64.Type),
    #"Added Custom6" = Table.AddColumn(#"Added Index", "Grund_Clean", each if [Grund_Error]="Error" then "Fehlende Informationen" else [Grund]),
    #"Added Custom7" = Table.AddColumn(#"Added Custom6", "Kunde_informiert_clean", each if List.Contains({"Ja","yes","j"}, [Kunde_informiert]) then "Ja" else if List.Contains({"Nein","no"}, [Kunde_informiert]) then "Nein" else "Unbekannt")
in
    #"Added Custom7"
