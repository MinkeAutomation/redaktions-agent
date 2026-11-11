# Redaktions-Agent K2

Projekt 2 im Kurs KI-Automatisierung (AGT-2606): Ein Agent in n8n plant Social-Media-Posts (Instagram und LinkedIn) für einen Kunden, prüft das Thema gegen Markenrichtlinien und frühere Posts, holt bei Bedarf belegte Fakten, schreibt das Text-Paket, baut die Bilder im Branding des Kunden und reicht alles zur Freigabe durch einen Menschen ein. Nach der Freigabe in Telegram wird der Beitrag in Nextcloud abgelegt.

## In 5 Minuten

1. Den Ablauf und die Stände liest du in [CHANGELOG.md](CHANGELOG.md): je Version des Systemprompts was geändert wurde, Ergebnis, nächste Idee, Status und die zugehörige Agent-Konfiguration.
2. Die 5 Werkzeuge und der Hauptworkflow liegen als Export in [workflows/](workflows/). Die Liste aller Versionen mit n8n-Versions-ID steht in [versionen.md](versionen.md). Dieses Repo beginnt mit dem Stand vom 11.11.2026 (Hauptworkflow v16) als erstem Commit; die Commit-Spalte in `versionen.md` verweist auf den Verlauf eines privaten Archiv-Repos, nicht auf dieses Repo.
3. Der geltende Systemprompt liegt als Markdown-Datei in [prompts/](prompts/) (Muster `YYYYMMDD_System-Prompt-Redaktions-Agent_V<Nummer>.md`), die älteren Fassungen V1 und V3, die zeichengleiche Live-Fassung von V2 (`..._V2_vor-V3.md`) und die Testkopie-Prompts in [archiv/prompts/](archiv/prompts/).
4. Die Tests, auch der Vergleich von Prompt v1 gegen v2, stehen in [docs/test-tabelle.md](docs/test-tabelle.md).
5. Die Tabelle für den Paket-Speicher und die Lese-Views stehen in [sql/](sql/).
6. Ziel, Scope und die Architekturentscheidung (Single-Agent) stehen in [docs/projekt-charter.md](docs/projekt-charter.md).

## Was der Agent tut

| Werkzeug | Aufgabe | Workflow |
|---|---|---|
| 1 Markenwissen abfragen | liest Markenrichtlinien und frühere Posts des Kunden (nur lesen) | `sub-markenwissen-abfragen.json` |
| 2 Thema recherchieren | holt belegte Fakten mit Quelle (Perplexity Sonar), höchstens 1 Aufruf je Auftrag und 1 Wiederholung | `sub-thema-recherchieren.json` |
| 3 Text schreiben | schreibt das Paket (Folien, Instagram-Text, LinkedIn-Post, Hashtags), prüft es und speichert es unter einer `paket_id` | `sub-text-schreiben.json` |
| 4 Bilder gestalten | Foto von Pixabay, sonst KI-Bild, gerendert mit Gotenberg, abgelegt in Supabase Storage (ohne Layout 4) | `sub-bilder-gestalten.json` |
| 5 Zur Freigabe einreichen | speichert den Beitrag mit Status `wartet_auf_freigabe`, höchstens 1 je Auftrag | `sub-zur-freigabe-einreichen.json` |

Der Agent reicht nur die `paket_id` weiter, das Paket selbst liegt in der Tabelle `k2_pakete`. Freigabe (Telegram, 2 Knöpfe), Ablage (Nextcloud) und die Bestätigung mit Link zum Kundenordner (Telegram) laufen im Hauptworkflow `redaktions-agent.json`, weil Warten auf einen Menschen nicht in einen Sub gehört. Eine Prüfung der Antwort des Agenten (Guardrail Ebene 3) steht vor der Freigabe.

## Stand (11.11.2026)

- Alle 5 Werkzeuge gebaut, veröffentlicht und angebunden. Getestet mit dem Testkunden `test-p2` im n8n-Chat, der Hauptworkflow bleibt unveröffentlicht.
- Agent-Modell: Nemotron 3.5 Super free (Gratis). Der Endpunkt von Nemotron 3 Ultra free war am 11.11.2026 zeitweise ausgefallen.
- Systemprompt: v2 live; v1 und v3 archiviert. Vergleich v1 gegen v2 mit 10 Anfragen in der [Test-Tabelle](docs/test-tabelle.md).
- Grenzen: Zahlenprüfung im Text-Werkzeug erkennt nicht alle Zahlwörter (ein Viertel, halb, null, Ordnungszahlen); Bildwahl nur über Schlagwörter; Wortmarke statt Logo-Datei; die Freigabe braucht einen Klick in Telegram.
- Die Exporte in [workflows/](workflows/) sind für die Veröffentlichung bereinigt: Credential-IDs, Workflow-IDs (auch die Verweise der Werkzeug-Knoten), Tag- und Ordner-Kennungen, Adresse der Datenbank, Adresse der n8n-Instanz, Fehler-Workflow, Webhook-IDs und Hosts des Bild-Dienstes sind durch Platzhalter ersetzt, interne Verweise in Code-Kommentaren entfernt. Die Funktion ist gleich, der Export weicht deshalb im Text von der laufenden Instanz ab.

## Umgebung

n8n (eigene Instanz), Supabase (Postgres und Storage), OpenRouter, Pixabay, Cloudflare Workers AI, Gotenberg, Telegram, Nextcloud. Zugangsdaten stehen nur in den n8n-Credentials.

## Importhinweise

Die Exporte lassen sich nicht ohne Anpassung einspielen. Vorgehen:

1. Datenbank vorbereiten (Supabase):
   - Tabellen `k1_kunden`, `k1_posts` und `k1_einstellungen` aus Projekt 1 (Beiträge, Kunden, Einstellungen).
   - Erweiterung von `k1_posts` um die Spalte `erzeugt_von` (Werte `p1_workflow` und `p2_agent`, kommt aus Projekt 2) und die Views `k2_v_markenwissen` und `k2_v_fruehere_posts`, beides in `sql/p2_k2_views_v01.sql` (Reihenfolge: erst die Spalte, dann die Views).
   - Tabelle `k2_pakete` aus `sql/p2_k2_pakete_v01.sql` (Paket-Speicher).
   - Einstellungsschlüssel in `k1_einstellungen`: `telegram_chat_id`, `telegram_freigabe_nutzer_id`, `cloudflare_account_id`.
   - Storage-Bucket `k1-medien` für die Bilder.
   - Testkunde `test-p2` in `k1_kunden` mit erfundenen Daten (Ton, Zielgruppe, No-Gos, Call to Action).
2. Platzhalter ersetzen. Die Platzhalter für Workflow-IDs ersetzt du erst in Schritt 3, weil die neuen IDs erst nach dem Import der Werkzeuge bekannt sind. Der Import in eine fremde Instanz ist bisher nicht nachgespielt, die Hinweise beschreiben den erwarteten Weg.
   - `CREDENTIAL_ID`: steht für 6 verschiedene Zugänge. Nach dem Import wählst du je Knoten den eigenen Zugang aus, der angezeigte Name sagt, welcher gemeint ist (OpenRouter, Supabase, Telegram, Pixabay, Cloudflare Workers AI).
   - `https://SUPABASE_URL` (13 Stellen): Adresse der eigenen Supabase-Datenbank.
   - `https://DEINE-N8N-INSTANZ`: kommt nur in den Notizen (Sticky Notes) vor. Dort die Adresse der eigenen n8n-Instanz eintragen oder die Notiz so lassen, sie hat keine Funktion.
   - Sperrliste der Ausgabe-Prüfung, eigener Schritt: Im Code-Knoten „Agent-Antwort prüfen“ in `redaktions-agent.json` steht der Platzhalter `DEINE-N8N-INSTANZ` ohne `https://` in einem regulären Ausdruck (`/DEINE-N8N-INSTANZ/i`). Ihn durch den eigenen Hostnamen ersetzen, ohne `https://`, mit Punkten als `\.` geschrieben. Am einfachsten nach dem Import im n8n-Editor, dort mit einfachem Backslash, zum Beispiel `/n8n\.example\.org/i`. Wer schon vorher im Dateitext der JSON-Datei ersetzt, muss den Backslash doppelt schreiben (`/n8n\\.example\\.org/i`), sonst ist die Datei kein gültiges JSON mehr. Der Austausch von `https://DEINE-N8N-INSTANZ` aus dem Punkt davor erreicht diese Stelle nicht. Bleibt der Platzhalter stehen, sperrt die Prüfung die echte Adresse nicht, wenn der Agent sie in einer Antwort an den Menschen nennt. In `test-redaktions-agent-1-werkzeug.json` steht dieselbe Zeile.
   - `ERROR_WORKFLOW_ID`: eigener Fehler-Workflow oder die Zeile entfernen.
   - `WEBHOOK_ID`: steht in 6 Knoten (Chat-Eingang und 5 Telegram-Knoten) im Feld `webhookId`, gemeint ist je Knoten eine eigene Kennung des Webhooks in der eigenen Instanz. n8n vergibt sie beim Anlegen des Knotens selbst. Vor dem Import das Feld `webhookId` in diesen Knoten entfernen oder je Knoten eine eigene, neue Kennung (UUID) eintragen, nicht überall denselben Wert stehen lassen.
   - `GOTENBERG_HOST`: Adresse des eigenen Gotenberg-Dienstes, Port 3000. Port 3999 ist ein Testschalter für einen absichtlichen Ausfall.
3. Workflow-IDs eintragen, Reihenfolge einhalten. Die Exporte enthalten statt der echten n8n-Workflow-IDs die Platzhalter aus der Tabelle unten. Jeder Platzhalter steht in allen Dateien für dasselbe Ziel.
   1. Die 5 Werkzeuge (`sub-markenwissen-abfragen`, `sub-thema-recherchieren`, `sub-text-schreiben`, `sub-bilder-gestalten`, `sub-zur-freigabe-einreichen`) importieren (n8n: Workflow, Aus Datei importieren) und veröffentlichen. n8n vergibt dabei eine neue ID (bei einem anderen Importweg das Feld `id` am Ende der Datei vorher entfernen).
   2. Die neue ID jedes Werkzeugs notieren (Adressleiste, `/workflow/<ID>`).
   3. In `redaktions-agent.json` im Texteditor mit Suchen und Ersetzen (alle Treffer) jeden Platzhalter der Werkzeuge durch die neue ID ersetzen. Das erfasst die 5 Werkzeug-Knoten (Feld `workflowId`) und, soweit dort genannt (Werkzeug 1 und 2), die Sperrliste im Code-Knoten „Agent-Antwort prüfen“, die IDs als Muster führt.
   4. `WORKFLOW_ID_NEXTCLOUD_ABLAGE` durch die ID deines eigenen Ablage-Workflows ersetzen (Knoten „In Nextcloud ablegen“; der Ablage-Workflow stammt aus Projekt 1 und liegt nicht im Repo).
   5. Dann `redaktions-agent.json` importieren. Die Platzhalter `WORKFLOW_ID_REDAKTIONS_AGENT` und `WORKFLOW_ID_PROJEKT_1` stehen in `redaktions-agent.json` nur im Feld `id` und in der Sperrliste der Ausgabe-Prüfung; sie müssen nicht ersetzt werden. Wer die Sperrliste scharf halten will, trägt nach dem Import die neue ID des Hauptworkflows dort ein.

   | Platzhalter | Ziel |
   |---|---|
   | `WORKFLOW_ID_SUB_MARKENWISSEN` | Werkzeug 1, `sub-markenwissen-abfragen.json` |
   | `WORKFLOW_ID_SUB_RECHERCHE` | Werkzeug 2, `sub-thema-recherchieren.json` |
   | `WORKFLOW_ID_SUB_TEXT` | Werkzeug 3, `sub-text-schreiben.json` |
   | `WORKFLOW_ID_SUB_BILDER` | Werkzeug 4, `sub-bilder-gestalten.json` |
   | `WORKFLOW_ID_SUB_EINREICHEN` | Werkzeug 5, `sub-zur-freigabe-einreichen.json` |
   | `WORKFLOW_ID_NEXTCLOUD_ABLAGE` | Ablage-Workflow aus Projekt 1 (nicht im Repo) |
   | `WORKFLOW_ID_REDAKTIONS_AGENT` | der Hauptworkflow selbst (`redaktions-agent.json`) |
   | `WORKFLOW_ID_PROJEKT_1` | Hauptworkflow von Projekt 1, kommt nur in der Sperrliste vor |
   | `TAG_ID_…` und `FOLDER_ID_PROJEKTORDNER` | Kennungen von Tags und Ordner der Ursprungsinstanz; nicht nötig, Tags legst du nach Bedarf selbst an |
   | `WORKFLOW_ID_TEST_…` | die Testkopien `test-*.json`; nicht nötig |

   Die Dateien in `konfiguration/` sind Auszüge der Agent-Konfiguration zur Dokumentation und werden nicht importiert.
4. Die Dateien `test-*.json` sind Testkopien und nicht nötig.

Die LICENSE erlaubt das Lesen der Inhalte zur Bewertung im Kurs und zum Lernen. Die Importhinweise dienen dem Nachvollziehen dieser Arbeit; darüber hinaus gilt die LICENSE unverändert.
