// Power Query (M) – Tabelle Auftraege
// Quelle: data/Liefertermin_Prototyp_Daten.xlsx (Pfad anpassen)
let
    Source = Excel.Workbook(File.Contents("C:\Pfad\zu\Liefertermin_Prototyp_Daten.xlsx"), null, true),
    Auftraege_Table = Source{[Item="Auftraege",Kind="Table"]}[Data],
    #"Changed Type" = Table.TransformColumnTypes(Auftraege_Table,{{"Auftragsnr", type text}, {"Auftragsdatum", type date}, {"Modell", type text}, {"Werk", type text}, {"Markt", type text}, {"Absatzmittler", type text}, {"Kundentyp", type text}, {"Erster_Liefertermin", type date}, {"Aktueller_Liefertermin", type date}, {"Tatsaechlicher_Liefertermin", type date}, {"Status", type text}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type", "Missing Absatzmittler", each if [Absatzmittler] = null then "Error" else "Correct"),
    #"Duplicated Column" = Table.DuplicateColumn(#"Added Custom", "Markt", "Markt - Copy"),
    #"Reordered Columns" = Table.ReorderColumns(#"Duplicated Column",{"Auftragsnr", "Auftragsdatum", "Modell", "Werk", "Markt", "Markt - Copy", "Absatzmittler", "Kundentyp", "Erster_Liefertermin", "Aktueller_Liefertermin", "Tatsaechlicher_Liefertermin", "Status", "Missing Absatzmittler"}),
    #"Renamed Columns" = Table.RenameColumns(#"Reordered Columns",{{"Markt - Copy", "Markt - Original"}}),
    #"Merged Queries" = Table.NestedJoin(#"Renamed Columns", {"Markt"}, Stammliste_Land, {"Column1"}, "Stammliste_Land", JoinKind.LeftOuter),
    #"Renamed Columns1" = Table.RenameColumns(#"Merged Queries",{{"Stammliste_Land", "Markt_Stamm"}}),
    #"Added Custom1" = Table.AddColumn(#"Renamed Columns1", "Check_Markt_Error", each if Table.IsEmpty([Markt_Stamm]) then "error" else "AllesGut"),
    #"Filtered Rows" = Table.SelectRows(#"Added Custom1", each true),
    #"Added Custom2" = Table.AddColumn(#"Filtered Rows", "Abweichung_Tage", each Duration.Days([Tatsaechlicher_Liefertermin] - [Erster_Liefertermin])),
    #"Added Custom3" = Table.AddColumn(#"Added Custom2", "Markt_Clean", each if [Check_Markt_Error] = "error" then let m = Text.Proper(Text.Trim([Markt])) in
if m = "Germany" or m = "De" then "Deutschland"
else if m = "France" then "Frankreich"
else if m = "Grossbritannien" then "Großbritannien"
else if m = "Spain" then "Spanien"
else if m = "Italy" then "Italien"
else if m = "Cn" then "China"
else m
else [Markt_Stamm]{0}[Column1])
in
    #"Added Custom3"
