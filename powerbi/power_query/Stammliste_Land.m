// Power Query (M) – Tabelle Stammliste_Land
// Quelle: data/Liefertermin_Prototyp_Daten.xlsx (Pfad anpassen)
let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WckktLSlOzshJzEtRitWJVnIrSszLLkrNTM4Acz1LEnMyU/PA7OCCxDwY2y8zNSW1CKQrFcx3L8o/PD+pKLMkMQ+uJiA/B8pyzElPLYIJhxzeU5SdmglmO2dk5iWCWWGOrkqxsQA=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Column1 = _t]),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Column1", type text}})
in
    #"Changed Type"
