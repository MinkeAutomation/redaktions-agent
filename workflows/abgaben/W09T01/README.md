# Abgabestand W09T01 (EU AI Act Compliance), 17.11.2026

Diese 4 Exporte sind die Workflow-Dateien der Abgabe W09T01, so wie sie abgegeben wurden. Sie zeigen den Stand, an dem die KI-Kennzeichnung (Maßnahme C der [Compliance-Doku W09T01](../../../docs/w09t01-compliance-doku.md)) gebaut und gemessen wurde.

| Datei | Workflow | Version | n8n-versionId |
|---|---|---|---|
| `AGT-2606_W09T01_Redaktions-Agent_Hauptworkflow_2026-11-17_v22.json` | Hauptworkflow Redaktions-Agent | v22 | `2f925369` |
| `AGT-2606_W09T01_Redaktions-Agent_Text-Sub_2026-11-17_v08.json` | Werkzeug 3 Text schreiben | v08 | `9fe6db4c` |
| `AGT-2606_W09T01_Redaktions-Agent_Bilder-Sub_2026-11-17_v01.json` | Werkzeug 4 Bilder gestalten | Stand 17.11.2026 mit KI-Kennzeichnung (die Abgabedatei trägt `_v01` im Namen) | `4d00acc0` |
| `AGT-2606_W09T01_Redaktions-Agent_Einreich-Sub_2026-11-17_v02.json` | Werkzeug 5 Zur Freigabe einreichen | v02 | `458a5989` |

Wo die KI-Kennzeichnung im Code steht: `KI-Hinweis voranstellen` und `Agent-Antwort prüfen` im Hauptworkflow, `Paket prüfen` im Text-Sub (Hinweis am Ende beider Texte, Feld `ki_kennzeichnung`), `Render-Liste bauen` und `Bild kennzeichnen` im Bilder-Sub, `Beitrag bauen` im Einreich-Sub.

**Bereinigung.** Zugangskennungen (`CREDENTIAL_ID`), die Projektadresse der Datenbank (`SUPABASE_URL`), die Adresse der n8n-Instanz (`DEINE-N8N-INSTANZ`) und der Name eines Testkunden (`KUNDE_B`) sind schon in der abgegebenen Datei Platzhalter, das Feld `meta` ist leer, es gibt keine Pins. Gegenüber der abgegebenen Datei sind hier nur ersetzt: Workflow-, Tag-, Ordner- und Webhook-Kennungen der Instanz durch `WORKFLOW_ID_…`, `TAG_ID_…`, `FOLDER_ID_PROJEKTORDNER`, `ERROR_WORKFLOW_ID` und `WEBHOOK_ID` (im Hauptworkflow auch in der Sperrliste von `Agent-Antwort prüfen`), der Name des n8n-Ordners durch `Projektordner` und der Host des Render-Dienstes im Bilder-Sub durch `GOTENBERG_HOST`. Diese Ersetzungen gelten nur für den Export, die laufende Instanz bleibt unverändert; sonst sind Code, Notizen, Positionen und Verbindungen gleich. Zum Nachbauen dienen die Live-Exporte und die Anleitung in der [README](../../../README.md).

Spätere Stände: [Abgabestand W09T02](../W09T02/README.md), geltende Stände unter `workflows/`, alle Versionen in [versionen.md](../../../versionen.md).
