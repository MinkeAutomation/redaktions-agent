# Redaktions-Agent

Projekt 2 im Kurs KI-Automatisierung (AGT-2606): Ein Agent in n8n plant Social-Media-Posts (Instagram und LinkedIn) für einen Kunden, prüft das Thema gegen Markenrichtlinien und frühere Posts, holt bei Bedarf belegte Fakten, schreibt das Text-Paket, baut die Bilder im Branding des Kunden und reicht alles zur Freigabe durch einen Menschen ein. Nach der Freigabe in Telegram wird der Beitrag in Nextcloud abgelegt.

## Stand (12.11.2026)

Status heißt hier Live (geltender Stand), In Test (Testkopie, wird nicht Live), Archiviert (abgelöst, Datei unter `archiv/`) oder Verworfen (getestet, nicht übernommen). Der Status je Version steht in [versionen.md](versionen.md), die Datei zu jeder Version in der Spalte Archivdatei.

| Bestandteil | Version | Status | Datei |
|---|---|---|---|
| Hauptworkflow Redaktions-Agent | v19.2 | Live (in n8n nicht veröffentlicht) | [workflows/redaktions-agent.json](workflows/redaktions-agent.json) |
| Werkzeug 1 Markenwissen abfragen | v03.3 | Live | [workflows/sub-markenwissen-abfragen.json](workflows/sub-markenwissen-abfragen.json) |
| Werkzeug 2 Thema recherchieren | v03.2 | Live | [workflows/sub-thema-recherchieren.json](workflows/sub-thema-recherchieren.json) |
| Werkzeug 3 Text schreiben | v07.1 | Live | [workflows/sub-text-schreiben.json](workflows/sub-text-schreiben.json) |
| Werkzeug 4 Bilder gestalten | v01.2 | Live | [workflows/sub-bilder-gestalten.json](workflows/sub-bilder-gestalten.json) |
| Werkzeug 5 Zur Freigabe einreichen | v01.2 | Live | [workflows/sub-zur-freigabe-einreichen.json](workflows/sub-zur-freigabe-einreichen.json) |
| Systemprompt | V4 | Live | [prompts/20261112_System-Prompt-Redaktions-Agent_V4.md](prompts/20261112_System-Prompt-Redaktions-Agent_V4.md) |
| Systemprompt | V2 | Archiviert (abgelöst von V4) | [archiv/prompts/20261110_System-Prompt-Redaktions-Agent_V2.md](archiv/prompts/20261110_System-Prompt-Redaktions-Agent_V2.md) |
| Systemprompt | V1 | Archiviert | [archiv/prompts/20261109_System-Prompt-Redaktions-Agent_V1.md](archiv/prompts/20261109_System-Prompt-Redaktions-Agent_V1.md) |
| Systemprompt | V3 | Verworfen (V2 blieb live, inzwischen von V4 abgelöst) | [archiv/prompts/20261110_System-Prompt-Redaktions-Agent_V3.md](archiv/prompts/20261110_System-Prompt-Redaktions-Agent_V3.md) |
| Agent-Konfiguration | V2 | Stand 11.11.2026 (der Auszug zu V4 liegt noch nicht vor) | [konfiguration/20261111_Redaktions-Agent_V2_Agent-Konfiguration.json](konfiguration/20261111_Redaktions-Agent_V2_Agent-Konfiguration.json) |
| Agent-Konfiguration | V1 | Archiviert (bleibt in `konfiguration/`, die Abgabe verweist dorthin) | [konfiguration/20261109_Redaktions-Agent_V1_Agent-Konfiguration.json](konfiguration/20261109_Redaktions-Agent_V1_Agent-Konfiguration.json) |
| Agent-Konfiguration | V3 | Verworfen (zunächst blieb V2 live, inzwischen V4) | [archiv/konfiguration/20261110_Redaktions-Agent_V3_Agent-Konfiguration.json](archiv/konfiguration/20261110_Redaktions-Agent_V3_Agent-Konfiguration.json) |
| Testkopie Redaktions-Agent mit 1 Werkzeug | v04 | In Test (Testkopie, wird nicht Live) | [workflows/test/test-redaktions-agent-1-werkzeug.json](workflows/test/test-redaktions-agent-1-werkzeug.json) |
| Testkopie Text schreiben, Lesefehler | v03 | In Test (Testkopie, wird nicht Live) | [workflows/test/test-text-schreiben-lesefehler.json](workflows/test/test-text-schreiben-lesefehler.json) |
| Testkopie Markenwissen, Lesefehler | 1 Stand | In Test (Testkopie, wird nicht Live) | [workflows/test/test-markenwissen-lesefehler.json](workflows/test/test-markenwissen-lesefehler.json) |
| Testkopie Jina Reader | v01 | In Test (Testkopie, wird nicht Live) | [workflows/test/test-jina-reader.json](workflows/test/test-jina-reader.json) |
| Tabelle Paket-Speicher `k2_pakete` | v01 | Live | [sql/p2_k2_pakete_v01.sql](sql/p2_k2_pakete_v01.sql) |
| Lese-Views und Spalte `erzeugt_von` | v01 | Live | [sql/p2_k2_views_v01.sql](sql/p2_k2_views_v01.sql) |

- Alle 5 Werkzeuge gebaut, veröffentlicht und angebunden. Getestet mit dem Testkunden `test-p2` im n8n-Chat, der Hauptworkflow bleibt unveröffentlicht.
- Agent-Modell: Nemotron 3.5 Super free (Gratis), seit v19 (13.11.2026: v19.2) mit 4.000 Ausgabe-Tokens. Der Endpunkt von Nemotron 3 Ultra free war am 11.11.2026 zeitweise ausgefallen.
- Systemprompt: V4 live (12.11.2026, Guardrails); V1 und V2 archiviert, V3 verworfen. Vergleich V1 gegen V2 mit 10 Anfragen in der [Test-Tabelle](docs/test-tabelle.md). Der Vergleich V2 gegen V4 steht aus.
- Guardrails (12.11.2026, Hauptworkflow v17 bis v19, gebaut für den Chat-Eingang): Eingangsprüfung vor dem Agenten (schwärzen, Jailbreak, Themenbindung) und Ausgangsprüfung vor der Freigabe (Schlüssel, Links, Personendaten, Anstößiges, mit Sperre). 9 Kernfälle in 12 Testzeilen (13 Ausführungen): 7 bestanden, 4 nicht bestanden (A1b, A6, P2 in 2 Anläufen), 1 Fehler (A3 am Eingang), siehe [Tag 4](docs/w08t04.html). Offen bis Ende Woche 9: Laufzeile, Eingänge Formular und Telegram, Prüfung der Recherche-Texte, Veröffentlichung, 11 weitere Fälle.
- Grenzen: Zahlenprüfung im Text-Werkzeug erkennt nicht alle Zahlwörter (ein Viertel, halb, null, Ordnungszahlen); Bildwahl nur über Schlagwörter; Wortmarke statt Logo-Datei; die Freigabe braucht einen Klick in Telegram.
- Die Exporte in [workflows/](workflows/) und die älteren Stände in [archiv/workflows/](archiv/workflows/) sind für die Veröffentlichung bereinigt: Credential-IDs, Workflow-IDs (auch die Verweise der Werkzeug-Knoten), Tag- und Ordner-Kennungen, Adresse der Datenbank, Adresse der n8n-Instanz, Fehler-Workflow, Webhook-IDs und Hosts des Bild-Dienstes sind durch Platzhalter ersetzt, interne Verweise in Code-Kommentaren entfernt. Der Name eines Testkunden ist in den Exporten durch `KUNDE_B` ersetzt, live in n8n steht der Originalwert. Die Funktion ist gleich, der Export weicht deshalb im Text von der laufenden Instanz ab.

## In 5 Minuten

1. Den Ablauf und die Stände liest du in [CHANGELOG.md](CHANGELOG.md): je Version des Systemprompts was geändert wurde, Ergebnis, nächste Idee, Status und die zugehörige Agent-Konfiguration.
2. Die 5 Werkzeuge und der Hauptworkflow liegen als Export in [workflows/](workflows/), die Testkopien in [workflows/test/](workflows/test/), jede ältere Version in [archiv/](archiv/README.md). Die Liste aller Versionen mit Status, Archivdatei und n8n-Versions-ID steht in [versionen.md](versionen.md), was es je Version an Plan, Test und Doku gibt in [docs/versionsmatrix.md](docs/versionsmatrix.md). Dieses Repo beginnt mit dem Stand vom 11.11.2026 (Hauptworkflow v16) als erstem Commit; die Commit-Spalte in `versionen.md` verweist auf den Verlauf eines privaten Archiv-Repos, nicht auf dieses Repo.
3. Der geltende Systemprompt liegt als Markdown-Datei in [prompts/](prompts/) (Muster `YYYYMMDD_System-Prompt-Redaktions-Agent_V<Nummer>.md`), die älteren Fassungen V1, V2 und V3 (verworfen), die zeichengleiche Live-Fassung von V2 (`..._V2_vor-V3.md`) und die Testkopie-Prompts in [archiv/prompts/](archiv/prompts/).
4. Die Tests, auch der Vergleich von Prompt v1 gegen v2, stehen in [docs/test-tabelle.md](docs/test-tabelle.md).
5. Die Tabelle für den Paket-Speicher und die Lese-Views stehen in [sql/](sql/).
6. Ziel, Scope und die Architekturentscheidung (Single-Agent) stehen in [docs/projekt-charter.md](docs/projekt-charter.md).
7. Welche Zugänge und Adressen du zum Nachbauen brauchst, listet [.env.example](.env.example) (nur Namen, keine Werte).

## Dokumentation

Die Projektdokumentation liegt als Webseite im Ordner [docs/](docs/):

- [Wochen-Doku und Projektdokumentation](docs/index.html): Use Case, Architektur, Stand je Werkzeug, Prompt-Versionen, Ergebnis V1 gegen V2, Freigabe, Compliance, offene Punkte
- [Tag 1 (09.11.2026)](docs/w08t01.html): Use Case, Datenmodell, Systemprompt V1, Werkzeug 1 und 2
- [Tag 2 (10.11.2026)](docs/w08t02.html): Fehlerweg, Ausgabe-Prüfung, Werkzeug 3, Testreihe mit 1 Werkzeug
- [Tag 3 (11.11.2026)](docs/w08t03.html): Werkzeug 4 und 5, Freigabe und Ablage, Vergleich V1 gegen V2
- [Tag 4 (12.11.2026)](docs/w08t04.html): Guardrails an Eingang und Ausgang, Erlaubt und verboten, Übersicht nach den 3 Ebenen, Systemprompt V4, Planbild des Endstands, 9 Kernfälle in 12 Testzeilen (13 Ausführungen); die Testtabelle mit Eingabe und Antwort im Wortlaut steht in [docs/test-tabelle-w08t04.md](docs/test-tabelle-w08t04.md)

Dazu gehören:

- [Projekt-Charter mit Architekturentscheidung](docs/projekt-charter.md) (Ziel, Scope, Single-Agent gegen Multi-Agent) und das [Architekturbild](docs/bilder/architektur-redaktions-agent.svg)
- [Projekt-Charter als Webseite](https://minkeautomation.github.io/redaktions-agent/charter.html): derselbe Inhalt wie die Markdown-Fassung, mit Navigation zur Wochen-Doku
- [Versionsmatrix](docs/versionsmatrix.md): je Version Plan, Testtabelle, Tages-Doku und Export, Lücken mit Grund
- [Test-Tabelle](docs/test-tabelle.md): Werkzeug-Tests, Vergleich V1 gegen V2, Freigabe und Ablage
- [Pläne](docs/plan/): je Tag ein Excalidraw-Plan auf dem Endstand des Tages

## Grundlage aus Projekt 1

Projekt 2 baut auf der Content-Maschine K1 aus Projekt 1 auf: Der Agent nutzt deren Tabellen `k1_kunden`, `k1_posts` und `k1_einstellungen` (Erweiterungen aus Projekt 2 stehen in [sql/](sql/)) und deren Ablage-Workflow. Die Grundlagen (Bedarf, Use Case, Grenzen) stehen dort und werden hier nicht wiederholt:

- Repository: [content-maschine-k1](https://github.com/MinkeAutomation/content-maschine-k1)
- [Anforderungen und Planung (PDF)](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/abgaben/2026-10-05_W04T01/AGT-2606_W04T01_Projekt1-Planung.pdf)
- [Architektur](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/docs/architektur.md)
- [Grenzen und offene Punkte von Projekt 1](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/docs/bekannte-einschraenkungen.md)
- [Lessons Learned](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/docs/lessons-learned.md)
- [Ablage-Workflow `sub-nextcloud-ablage.json`](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/workflows/sub-nextcloud-ablage.json) (von Projekt 2 aufgerufen, nicht in diesem Repo)

Verwandtes Projekt: [k1-support-agent](https://github.com/MinkeAutomation/k1-support-agent) beantwortet Fragen zur Content-Maschine. Er ist nicht Grundlage von Projekt 2.

## Was der Agent tut

| Werkzeug | Aufgabe | Workflow |
|---|---|---|
| 1 Markenwissen abfragen | liest Markenrichtlinien und frühere Posts des Kunden (nur lesen) | `sub-markenwissen-abfragen.json` |
| 2 Thema recherchieren | holt belegte Fakten mit Quelle (Perplexity Sonar), höchstens 1 Aufruf je Auftrag und 1 Wiederholung | `sub-thema-recherchieren.json` |
| 3 Text schreiben | schreibt das Paket (Folien, Instagram-Text, LinkedIn-Post, Hashtags), prüft es und speichert es unter einer `paket_id` | `sub-text-schreiben.json` |
| 4 Bilder gestalten | Foto von Pixabay, sonst KI-Bild, gerendert mit Gotenberg, abgelegt in Supabase Storage (ohne Layout 4) | `sub-bilder-gestalten.json` |
| 5 Zur Freigabe einreichen | speichert den Beitrag mit Status `wartet_auf_freigabe`, höchstens 1 je Auftrag | `sub-zur-freigabe-einreichen.json` |

Der Agent reicht nur die `paket_id` weiter, das Paket selbst liegt in der Tabelle `k2_pakete`. Freigabe (Telegram, 2 Knöpfe), Ablage (Nextcloud) und die Bestätigung mit Link zum Kundenordner (Telegram) laufen im Hauptworkflow `redaktions-agent.json`, weil Warten auf einen Menschen nicht in einen Sub gehört. Eine Prüfung der Antwort des Agenten (Guardrail Ebene 3) steht vor der Freigabe. Seit v17 und v18 kommen eine Eingangsprüfung vor dem Agenten und eine Ausgangsprüfung des Beitragstextes vor der Freigabe dazu (Guardrails-Knoten, siehe [Tag 4](docs/w08t04.html)).

## Zusatzfunktionen

Zusatzfunktionen über die Grundanforderungen hinaus. Stand 11.11.2026. Die Läufe sind Ausführungsnummern in n8n und stehen in der [Test-Tabelle](docs/test-tabelle.md).

| Zusatzfunktion | Stand | Beleg |
|---|---|---|
| Human in the Loop | umgesetzt | Der Agent veröffentlicht nie selbst. Der Beitrag geht als Vorschau mit 2 Knöpfen nach Telegram: Freigeben oder Ablehnen mit Grund (Eingabe über ein Formular). Die Ablage in Nextcloud passiert erst nach der Freigabe. Getestet: 3 Freigaben mit Ablage (Läufe 2768 und 2782 mit Prompt V2, Lauf 2748 mit Prompt V1) und 1 Ablehnung (Lauf 2735: Status abgelehnt, Grund gespeichert, nichts abgelegt), siehe [Test-Tabelle](docs/test-tabelle.md) Abschnitt D. Nicht getestet: das Verfallen der Anfrage nach 24 Stunden ohne Klick. |
| Monitoring und Alerting | Ansatz, kein Überwachungssystem (seit 12.11.2026 mit Eingangs- und Ausgangsprüfung) | Der Fehlerweg am Agenten setzt bei einem Ausfall einen festen Text, die Ursache steht als Code im Lauf (Läufe 2576 und 2579, [Tag 2](docs/w08t02.html)). Die Ausgabe-Prüfung sperrt unzulässige Antworten, etwa einen Statuswert ohne Beitrags-ID (Lauf 2706) oder ungültiges JSON (Lauf 2708); sie schlug auch fälschlich an (Lauf 2719, Wort „Systemprompt“). Im Hauptworkflow ist ein Fehler-Workflow eingetragen (Platzhalter `ERROR_WORKFLOW_ID`); ein Lauf, der ihn ausgelöst hat, ist nicht belegt. Es gibt kein Dashboard, keine Auswertung von Laufzeit oder Kosten und keinen getesteten Alarm an einen Menschen bei Fehlern. Der Zweig „Ablage-Problem senden“ wurde nie ausgelöst. |
| Multi-Agent | nicht umgesetzt | 1 Agent mit 5 Werkzeugen, begründet in der [Projekt-Charter](docs/projekt-charter.md). |
| MCP-Integration | nicht umgesetzt | Die Werkzeuge sind n8n-Sub-Workflows, kein MCP-Server; in der Projekt-Charter ausdrücklich nicht im Umfang. |
| Eigenes Interface | nicht umgesetzt | Eingang ist der n8n-Chat, die Freigabe läuft über Telegram. |
| Kosten-Kalkulation | nicht umgesetzt | Kosten je Lauf, Tag und Monat sind nicht ausgewertet. |
| LLM-as-Judge | nicht umgesetzt | Im Workflow bewertet kein Sprachmodell die Antworten. Die Ausgabe-Prüfung ist regelbasiert, die Urteile der Test-Tabelle sind nach der Erwartung je Fall von Hand eingetragen. Geplant als Werkzeug 6 (siehe [Projekt-Charter](docs/projekt-charter.md), Abschnitt 3). |

## Umgebung

n8n (eigene Instanz), Supabase (Postgres und Storage), OpenRouter, Pixabay, Cloudflare Workers AI, Gotenberg, Telegram, Nextcloud. Zugangsdaten stehen nur in den n8n-Credentials, die Namen der nötigen Werte listet [.env.example](.env.example) (ohne Werte).

## Importhinweise

Die Exporte lassen sich nicht ohne Anpassung einspielen. Welche Datei welche Rolle hat, in welcher Reihenfolge sie importiert wird und welche Zugänge sie braucht:

| Datei | Rolle | Importreihenfolge | braucht Credential |
|---|---|---|---|
| `workflows/sub-markenwissen-abfragen.json` | Werkzeug 1 | 1 | Supabase API |
| `workflows/sub-thema-recherchieren.json` | Werkzeug 2 | 2 | OpenRouter API |
| `workflows/sub-text-schreiben.json` | Werkzeug 3 | 3 | Supabase API, OpenRouter API |
| `workflows/sub-bilder-gestalten.json` | Werkzeug 4 | 4 | Supabase API, Pixabay API, Cloudflare Workers AI (dazu der Gotenberg-Host als Platzhalter, kein Credential) |
| `workflows/sub-zur-freigabe-einreichen.json` | Werkzeug 5 | 5 | Supabase API |
| `sub-nextcloud-ablage.json` aus Projekt 1 (Repo [content-maschine-k1](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/workflows/sub-nextcloud-ablage.json), nicht in diesem Repo) | Ablage in Nextcloud | 6 | Nextcloud API |
| `workflows/redaktions-agent.json` | Hauptworkflow | 7, zuletzt, weil er die Werkzeuge per ID aufruft | OpenRouter API, Supabase API, Telegram API |
| `workflows/test/test-redaktions-agent-1-werkzeug.json` | Testkopie mit 1 Werkzeug | nicht nötig | OpenRouter API |
| `workflows/test/test-text-schreiben-lesefehler.json` | Testkopie, Lesefehler Werkzeug 3 | nicht nötig | Supabase API |
| `workflows/test/test-markenwissen-lesefehler.json` | Testkopie, Lesefehler Werkzeug 1 | nicht nötig | Supabase API |
| `workflows/test/test-jina-reader.json` | Testkopie, Einzeltest des Jina-Aufrufs | nicht nötig | keines |

Die Dateien in `archiv/` sind nicht zum Import gedacht (siehe [archiv/README.md](archiv/README.md)).

Vorgehen:

1. Datenbank vorbereiten (Supabase):
   - Tabellen `k1_kunden`, `k1_posts` und `k1_einstellungen` aus Projekt 1 (Beiträge, Kunden, Einstellungen).
   - Erweiterung von `k1_posts` um die Spalte `erzeugt_von` (Werte `p1_workflow` und `p2_agent`, kommt aus Projekt 2) und die Views `k2_v_markenwissen` und `k2_v_fruehere_posts`, beides in `sql/p2_k2_views_v01.sql` (Reihenfolge: erst die Spalte, dann die Views).
   - Tabelle `k2_pakete` aus `sql/p2_k2_pakete_v01.sql` (Paket-Speicher).
   - Einstellungsschlüssel in `k1_einstellungen`: `telegram_chat_id`, `telegram_freigabe_nutzer_id`, `cloudflare_account_id`.
   - Storage-Bucket `k1-medien` für die Bilder.
   - Testkunde `test-p2` in `k1_kunden` mit erfundenen Daten (Ton, Zielgruppe, No-Gos, Call to Action).
2. Platzhalter ersetzen. Die Platzhalter für Workflow-IDs ersetzt du erst in Schritt 3, weil die neuen IDs erst nach dem Import der Werkzeuge bekannt sind. Der Import in eine fremde Instanz ist bisher nicht nachgespielt, die Hinweise beschreiben den erwarteten Weg. Die Namen aller nötigen Werte stehen in [.env.example](.env.example).
   - `CREDENTIAL_ID`: steht für 6 verschiedene Zugänge. Nach dem Import wählst du je Knoten den eigenen Zugang aus, der angezeigte Name sagt, welcher gemeint ist (OpenRouter, Supabase, Telegram, Pixabay, Cloudflare Workers AI).
   - `https://SUPABASE_URL` (13 Stellen): Adresse der eigenen Supabase-Datenbank.
   - `https://DEINE-N8N-INSTANZ`: kommt nur in den Notizen (Sticky Notes) vor. Dort die Adresse der eigenen n8n-Instanz eintragen oder die Notiz so lassen, sie hat keine Funktion.
   - Sperrliste der Ausgabe-Prüfung, eigener Schritt: Im Code-Knoten „Agent-Antwort prüfen“ in `redaktions-agent.json` steht der Platzhalter `DEINE-N8N-INSTANZ` ohne `https://` in einem regulären Ausdruck (`/DEINE-N8N-INSTANZ/i`). Ihn durch den eigenen Hostnamen ersetzen, ohne `https://`, mit Punkten als `\.` geschrieben. Am einfachsten nach dem Import im n8n-Editor, dort mit einfachem Backslash, zum Beispiel `/n8n\.example\.org/i`. Wer schon vorher im Dateitext der JSON-Datei ersetzt, muss den Backslash doppelt schreiben (`/n8n\\.example\\.org/i`), sonst ist die Datei kein gültiges JSON mehr. Der Austausch von `https://DEINE-N8N-INSTANZ` aus dem Punkt davor erreicht diese Stelle nicht. Bleibt der Platzhalter stehen, sperrt die Prüfung die echte Adresse nicht, wenn der Agent sie in einer Antwort an den Menschen nennt. In `workflows/test/test-redaktions-agent-1-werkzeug.json` steht dieselbe Zeile.
   - `ERROR_WORKFLOW_ID`: eigener Fehler-Workflow oder die Zeile entfernen.
   - `WEBHOOK_ID`: steht in 6 Knoten (Chat-Eingang und 5 Telegram-Knoten) im Feld `webhookId`, gemeint ist je Knoten eine eigene Kennung des Webhooks in der eigenen Instanz. n8n vergibt sie beim Anlegen des Knotens selbst. Vor dem Import das Feld `webhookId` in diesen Knoten entfernen oder je Knoten eine eigene, neue Kennung (UUID) eintragen, nicht überall denselben Wert stehen lassen.
   - `GOTENBERG_HOST`: Adresse des eigenen Gotenberg-Dienstes, Port 3000. Port 3999 ist ein Testschalter für einen absichtlichen Ausfall.
3. Workflow-IDs eintragen, Reihenfolge einhalten. Die Exporte enthalten statt der echten n8n-Workflow-IDs die Platzhalter aus der Tabelle unten. Jeder Platzhalter steht in allen Dateien für dasselbe Ziel.
   1. Die 5 Werkzeuge (`sub-markenwissen-abfragen`, `sub-thema-recherchieren`, `sub-text-schreiben`, `sub-bilder-gestalten`, `sub-zur-freigabe-einreichen`) importieren (n8n: Workflow, Aus Datei importieren) und veröffentlichen. n8n vergibt dabei eine neue ID (bei einem anderen Importweg das Feld `id` am Ende der Datei vorher entfernen).
   2. Die neue ID jedes Werkzeugs notieren (Adressleiste, `/workflow/<ID>`).
   3. In `redaktions-agent.json` im Texteditor mit Suchen und Ersetzen (alle Treffer) jeden Platzhalter der Werkzeuge durch die neue ID ersetzen. Das erfasst die 5 Werkzeug-Knoten (Feld `workflowId`) und, soweit dort genannt (Werkzeug 1 und 2), die Sperrliste im Code-Knoten „Agent-Antwort prüfen“, die IDs als Muster führt.
   4. `WORKFLOW_ID_NEXTCLOUD_ABLAGE` durch die ID deines eigenen Ablage-Workflows ersetzen (Knoten „In Nextcloud ablegen“). Der Ablage-Workflow stammt aus Projekt 1: [workflows/sub-nextcloud-ablage.json im Repo content-maschine-k1](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/workflows/sub-nextcloud-ablage.json), er wird dort importiert und hier nur aufgerufen.
   5. Dann `redaktions-agent.json` importieren. Die Platzhalter `WORKFLOW_ID_REDAKTIONS_AGENT` und `WORKFLOW_ID_PROJEKT_1` stehen in `redaktions-agent.json` nur im Feld `id` und in der Sperrliste der Ausgabe-Prüfung; sie müssen nicht ersetzt werden. Wer die Sperrliste scharf halten will, trägt nach dem Import die neue ID des Hauptworkflows dort ein.

   | Platzhalter | Ziel |
   |---|---|
   | `WORKFLOW_ID_SUB_MARKENWISSEN` | Werkzeug 1, `sub-markenwissen-abfragen.json` |
   | `WORKFLOW_ID_SUB_RECHERCHE` | Werkzeug 2, `sub-thema-recherchieren.json` |
   | `WORKFLOW_ID_SUB_TEXT` | Werkzeug 3, `sub-text-schreiben.json` |
   | `WORKFLOW_ID_SUB_BILDER` | Werkzeug 4, `sub-bilder-gestalten.json` |
   | `WORKFLOW_ID_SUB_EINREICHEN` | Werkzeug 5, `sub-zur-freigabe-einreichen.json` |
   | `WORKFLOW_ID_NEXTCLOUD_ABLAGE` | Ablage-Workflow aus Projekt 1 (nicht in diesem Repo, Link oben) |
   | `WORKFLOW_ID_REDAKTIONS_AGENT` | dieser Workflow, also `redaktions-agent.json` |
   | `WORKFLOW_ID_PROJEKT_1` | Hauptworkflow von Projekt 1, kommt nur in der Sperrliste vor |
   | `TAG_ID_…` und `FOLDER_ID_PROJEKTORDNER` | Kennungen von Tags und Ordner der Ursprungsinstanz; nicht nötig, Tags legst du nach Bedarf selbst an |
   | `WORKFLOW_ID_TEST_…` | die Testkopien in `workflows/test/`; nicht nötig |

   Die Dateien in `konfiguration/` und `archiv/konfiguration/` sind Auszüge der Agent-Konfiguration zur Dokumentation und werden nicht importiert.
4. Die Dateien in `workflows/test/` sind Testkopien und nicht nötig.

Die LICENSE erlaubt das Lesen der Inhalte zur Durchsicht und zum Lernen. Die Importhinweise dienen dem Nachvollziehen dieser Arbeit; darüber hinaus gilt die LICENSE unverändert.
