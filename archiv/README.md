# Archiv

Hier liegen die abgelösten Stände des Redaktions-Agenten: ältere Fassungen der Workflows, Systemprompts und Agent-Konfigurationen. Der geltende Stand liegt unter festem Dateinamen außerhalb dieses Ordners (`workflows/`, `prompts/`, `konfiguration/`). Welche Version welchen Status hat, steht in der Spalte Status von [versionen.md](../versionen.md) (Live, In Test, Archiviert, Verworfen); die Spalte Archivdatei verlinkt jede Datei.

## Aufbau

| Ordner | Inhalt | Dateien |
|---|---|---|
| `workflows/redaktions-agent/` | Hauptworkflow v01 bis v15 (v16 ist Live in `workflows/`) | 20 |
| `workflows/sub-markenwissen-abfragen/` | Werkzeug 1, v01 bis v03 (v03.1 ist Live) | 5 |
| `workflows/sub-thema-recherchieren/` | Werkzeug 2, v01 bis v03 (v03.1 ist Live) | 7 |
| `workflows/sub-text-schreiben/` | Werkzeug 3, v00 bis v06.1 (v07 ist Live) | 15 |
| `workflows/test-redaktions-agent-1-werkzeug/` | ältere Stände der Testkopie mit 1 Werkzeug, v00 bis v03 (v04 liegt in `workflows/test/`) | 4 |
| `workflows/test-text-schreiben-lesefehler/` | ältere Stände der Testkopie zum Lesefehler von Werkzeug 3, v00 bis v02 (v03 liegt in `workflows/test/`) | 3 |
| `prompts/` | Systemprompts V1 und V3, die Fassung von V2 mit vollen n8n-Ausdrücken, Prompt der Testkopie | 4 |
| `konfiguration/` | Agent-Konfiguration V3 (verworfen) | 1 |

Die Werkzeuge 4 und 5 und die Testkopien Jina Reader und Markenwissen-Lesefehler haben nur 1 Stand, er liegt in `workflows/` beziehungsweise `workflows/test/`. Die Agent-Konfiguration V1 liegt weiter in `konfiguration/`, weil die Abgabe vom 11.11.2026 dorthin verweist; ihr Status ist Archiviert.

## Dateinamen

`JJJJMMTT_<Gegenstand>_vNN.json` für Workflows (Datum und Versionsnummer wie in `versionen.md`, `<Gegenstand>` ist der Dateiname des Live-Stands). Prompts und Konfigurationen tragen `_V<Nummer>` im Namen, wie im [CHANGELOG](../CHANGELOG.md). Die Dateien mit dem Zusatz `_export-zusatzfelder` sind der Export vom 09.11.2026 23:03, der zusätzlich description, staticData und parentFolder enthält; es ist keine eigene Version, die Workflows blieben unverändert.

## Bereinigt und nicht ohne Anpassung lauffähig

Jede Archivdatei ist wie die heutigen Exporte bereinigt: Credential-IDs, Workflow-IDs, Tag- und Ordner-Kennungen, Webhook-IDs, Adresse der Datenbank, Adresse der n8n-Instanz und der Host des Bild-Dienstes sind durch Platzhalter ersetzt, interne Verweise in Code-Kommentaren und Notizen sind entfernt. Die Funktion ist gleich. Die Dateien sind deshalb zum Nachlesen und Vergleichen gedacht, nicht zum Import; für den Import gelten die Hinweise im [README](../README.md) und die Live-Dateien in `workflows/`. In die JSON-Dateien ist kein Status geschrieben, der Status steht nur in `versionen.md` und in der ersten Zeile der Markdown-Dateien.

## Status

| Status | Bedeutung hier |
|---|---|
| Archiviert | abgelöst, durch eine spätere Version ersetzt |
| Verworfen | getestet, nicht übernommen: Systemprompt V3 (Hauptworkflow v06, Testkopie v02) und die Agent-Konfiguration V3; live bleibt V2 |
