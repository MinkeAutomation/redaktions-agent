# Redaktions-Agent

Projekt 2 im Kurs KI-Automatisierung (AGT-2606): Ein Agent in n8n plant Social-Media-Posts (Instagram und LinkedIn) für einen Kunden, prüft das Thema gegen Markenrichtlinien und frühere Posts, holt bei Bedarf belegte Fakten, schreibt das Text-Paket, baut die Bilder im Branding des Kunden und reicht alles zur Freigabe durch einen Menschen ein. Nach der Freigabe in Telegram wird der Beitrag in Nextcloud abgelegt.

> Stand 24.11.2026, 15:00: Der Freeze-Stand (Hauptworkflow veröffentlicht 24.11.2026 09:37, Fristen-Workflow aktiv 10:24) und die Läufe des 24.11.2026 stehen in der Dokumentations-PDF vom 24.11.2026; Export, Testtabelle und Diagramme dieses Repos folgen mit der finalen Fassung am 25.11.2026.

## Stand (21.11.2026, SQL und Doku 23.11.2026)

Status heißt hier ✅ Live (geltender Stand), 🧪 In Test (Testkopie, wird nicht Live), 🗄️ Archiviert (abgelöst, Datei unter `archiv/` oder als Abgabestand unter `workflows/abgaben/`) oder 🚫 Verworfen (getestet, nicht übernommen). Der Status je Version steht in [versionen.md](versionen.md), die Datei zu jeder Version in der Spalte Archivdatei.

| Bestandteil | Version | Status | Datei |
|---|---|---|---|
| Hauptworkflow Redaktions-Agent | v26.5.3 | ✅ Live, in n8n veröffentlicht seit 21.11.2026 14:03 | [workflows/redaktions-agent.json](workflows/redaktions-agent.json) |
| Freigabe-Workflow (Freigabe abwarten und ablegen) | v02.1 | ✅ Live, veröffentlicht seit 21.11.2026 14:03 | [workflows/sub-freigabe-abwarten-und-ablegen.json](workflows/sub-freigabe-abwarten-und-ablegen.json) |
| Werkzeug 1 Markenwissen abfragen | v03.3 | ✅ Live | [workflows/sub-markenwissen-abfragen.json](workflows/sub-markenwissen-abfragen.json) |
| Werkzeug 2 Thema recherchieren | v03.2 | ✅ Live | [workflows/sub-thema-recherchieren.json](workflows/sub-thema-recherchieren.json) |
| Werkzeug 3 Text schreiben | v09.3 | ✅ Live, veröffentlicht seit 21.11.2026 14:03 | [workflows/sub-text-schreiben.json](workflows/sub-text-schreiben.json) |
| Werkzeug 4 Bilder gestalten | v05 (dunkles Layout aus Projekt 1, Layout 4, Rückgabe mit Ergebnis oder Fehler) | ✅ Live, veröffentlicht seit 19.11.2026 | [workflows/sub-bilder-gestalten.json](workflows/sub-bilder-gestalten.json) |
| Werkzeug 5 Zur Freigabe einreichen | v03 | ✅ Live | [workflows/sub-zur-freigabe-einreichen.json](workflows/sub-zur-freigabe-einreichen.json) |
| Werkzeug 6 Qualität prüfen | v05.1 | ✅ Live | [workflows/sub-qualitaet-pruefen.json](workflows/sub-qualitaet-pruefen.json) |
| Abgabestände Woche 9 | W09T01, W09T02, W09T03, W09T04 | 🗄️ Archiviert (so abgegeben) | [W09T01](workflows/abgaben/W09T01/README.md), [W09T02](workflows/abgaben/W09T02/README.md), [W09T03](workflows/abgaben/W09T03/README.md), [W09T04](workflows/abgaben/W09T04/README.md) |
| Systemprompt | V4.4 | ✅ Live (Hauptworkflow v26.1 bis v26.5.3) | [prompts/20261119_System-Prompt-Redaktions-Agent_V4.4.md](prompts/20261119_System-Prompt-Redaktions-Agent_V4.4.md) |
| Systemprompt | V4.3, V4.2 | 🗄️ Archiviert (Zwischenstände des 19.11.2026, nie veröffentlicht) | [V4.3](archiv/prompts/20261119_System-Prompt-Redaktions-Agent_V4.3.md), [V4.2](archiv/prompts/20261119_System-Prompt-Redaktions-Agent_V4.2.md) |
| Systemprompt | V4.1 | 🗄️ Archiviert (von V4.4 abgelöst, Hauptworkflow v23.1, bleibt wie V4 in `prompts/`) | [prompts/20261118_System-Prompt-Redaktions-Agent_V4.1.md](prompts/20261118_System-Prompt-Redaktions-Agent_V4.1.md) |
| Systemprompt | V4 | 🗄️ Archiviert (abgelöst, Baseline für Vergleiche, bleibt in `prompts/`) | [prompts/20261112_System-Prompt-Redaktions-Agent_V4.md](prompts/20261112_System-Prompt-Redaktions-Agent_V4.md) |
| Systemprompt | V2 | 🗄️ Archiviert (abgelöst von V4) | [archiv/prompts/20261110_System-Prompt-Redaktions-Agent_V2.md](archiv/prompts/20261110_System-Prompt-Redaktions-Agent_V2.md) |
| Systemprompt | V1 | 🗄️ Archiviert | [archiv/prompts/20261109_System-Prompt-Redaktions-Agent_V1.md](archiv/prompts/20261109_System-Prompt-Redaktions-Agent_V1.md) |
| Systemprompt | V3 | 🚫 Verworfen (V2 blieb live, später von V4 abgelöst, heute gilt V4.4) | [archiv/prompts/20261110_System-Prompt-Redaktions-Agent_V3.md](archiv/prompts/20261110_System-Prompt-Redaktions-Agent_V3.md) |
| Agent-Konfiguration | V2 | Stand 11.11.2026 (ein Auszug zum geltenden Stand V4.4 liegt noch nicht vor) | [konfiguration/20261111_Redaktions-Agent_V2_Agent-Konfiguration.json](konfiguration/20261111_Redaktions-Agent_V2_Agent-Konfiguration.json) |
| Agent-Konfiguration | V1 | 🗄️ Archiviert (bleibt in `konfiguration/`, die Abgabe verweist dorthin) | [konfiguration/20261109_Redaktions-Agent_V1_Agent-Konfiguration.json](konfiguration/20261109_Redaktions-Agent_V1_Agent-Konfiguration.json) |
| Agent-Konfiguration | V3 | 🚫 Verworfen (zunächst blieb V2 live, heute gilt V4.4) | [archiv/konfiguration/20261110_Redaktions-Agent_V3_Agent-Konfiguration.json](archiv/konfiguration/20261110_Redaktions-Agent_V3_Agent-Konfiguration.json) |
| Testkopie Redaktions-Agent mit 1 Werkzeug | v04 | 🧪 In Test (Testkopie, wird nicht Live) | [workflows/test/test-redaktions-agent-1-werkzeug.json](workflows/test/test-redaktions-agent-1-werkzeug.json) |
| Testkopie Text schreiben, Lesefehler | v03 | 🧪 In Test (Testkopie, wird nicht Live) | [workflows/test/test-text-schreiben-lesefehler.json](workflows/test/test-text-schreiben-lesefehler.json) |
| Testkopie Markenwissen, Lesefehler | 1 Stand | 🧪 In Test (Testkopie, wird nicht Live) | [workflows/test/test-markenwissen-lesefehler.json](workflows/test/test-markenwissen-lesefehler.json) |
| Testkopie Jina Reader | v01 | 🧪 In Test (Testkopie, wird nicht Live) | [workflows/test/test-jina-reader.json](workflows/test/test-jina-reader.json) |
| Tabellen aus Projekt 1 `k1_kunden`, `k1_posts`, `k1_einstellungen`, `k1_laufprotokoll` | v01 (aus dem Live-Schema abgeleitet am 23.11.2026) | ✅ Live | [sql/p1_k1_tabellen_v01.sql](sql/p1_k1_tabellen_v01.sql) |
| Tabelle Paket-Speicher `k2_pakete` | v01 | ✅ Live | [sql/p2_k2_pakete_v01.sql](sql/p2_k2_pakete_v01.sql) |
| Lese-Views und Spalte `erzeugt_von` | v01 | ✅ Live | [sql/p2_k2_views_v01.sql](sql/p2_k2_views_v01.sql) |
| Tabellen `k2_sitzungen`, `k2_agent_laeufe`, `k2_agent_testfaelle`, `k2_agent_testergebnisse` und View `k2_v_kosten_tag` | v01 (aus dem Live-Schema abgeleitet am 23.11.2026) | ✅ Live | [sql/p2_k2_sitzungen_laeufe_tests_v01.sql](sql/p2_k2_sitzungen_laeufe_tests_v01.sql) |

- Seit 21.11.2026 14:03 ist der Hauptworkflow v26.5.3 veröffentlicht, zusammen mit dem Freigabe-Workflow und dem Text-Werkzeug v09.3. Eingang ist eine Chat-Seite mit Anmeldung, der Kunde steht fest auf Ordwin. Die Chat-Seite antwortet, sobald der Beitrag eingereicht ist; die Freigabe in Telegram läuft im eigenen Freigabe-Workflow, den der Hauptworkflow ohne Warten startet ([W9 Tag 3](docs/w09t03.html)). 6 Werkzeuge sind angebunden, Werkzeug 6 „Qualität prüfen“ bewertet den Beitrag und löst höchstens 1 Nachbesserung aus ([W9 Tag 4](docs/w09t04.html)).
- Test von außen am 21.11.2026 vom Handy über Mobilfunk: ohne Anmeldung abgewiesen, mit Anmeldung Antwort mit Werkzeugliste nach 3:27,6 min (Lauf 4064), Freigabe-Läufe 4062 und 4070. **Grenze:** Die Chat-Seite muss bis zur Antwort offen und im Vordergrund bleiben. Der letzte Knoten `Antwort senden [Chat]` sendet die Antwort und wartet, bis die Chat-Seite sie abholt. War die Seite zu (Handy gesperrt oder App gewechselt, Lauf 4056) oder lief der Lauf im Editor ohne Chat-Seite (Lauf 4047), holt sie niemand ab, und die Ausführung bleibt in n8n im Status „Waiting“ stehen. Einreichung, Freigabe und Ablage sind davon nicht betroffen, sie waren schon erledigt oder laufen im eigenen Freigabe-Workflow. Die Demo läuft deshalb am PC.
- Am veröffentlichten Stand liefen 3 volle Läufe über die Chat-Seite (4056 und 4064 am 21.11.2026, 4104 am 23.11.2026), dazu 1 Lauf im Editor kurz vor dem Veröffentlichen (4047), nicht die 20 Fälle der Regression; die letzte Regression über 20 Fälle lief am 18.11.2026 an v23.1 (19 bestanden, K03 nicht bestanden). Die Regression ist bis zum Hard Freeze am Di 24.11.2026 geplant. Kosten je Lauf: vorher rund 0,0046 $ (Stand V4.1, aus der Abrechnung), nachher rund 0,0070 $ (berechnet aus Tokens und Listenpreis, Läufe 4056 und 4064) ([W9 Tag 4, Kapitel 2 und 3](docs/w09t04.html#k2)).
- Feature Freeze am 19.11.2026 abends, Fehlerbehebung bis Di 24.11.2026, 11:00 (eigene Frist), Hard Freeze am selben Tag (Uhrzeit noch nicht bestätigt); bis dahin Reparatur von Fristablauf T3 und Eingangsfilter T4 mit Regression.
- Agent-Modell (aktueller Stand): `anthropic/claude-haiku-5.5` über den Projektzugang bei OpenRouter, Nemotron 3.5 Super free liegt deaktiviert im Reserve-Kasten. Früherer Stand: Nemotron 3.5 Super free (Gratis) von v19 bis v20.2 mit 4.000 Ausgabe-Tokens; der Endpunkt von Nemotron 3 Ultra free war am 11.11.2026 zeitweise ausgefallen.
- Systemprompt: V4.4 live (19.11.2026, Qualitätsschleife mit höchstens 1 Nachbesserung und 1 erneuten Prüfung, höchstens 14 Werkzeugaufrufe; seit 20.11.2026 in dieser Fassung). V4.1 (18.11.2026, Status `auskunft`) und V4 (12.11.2026, Guardrails) sind abgelöst, V4.2 und V4.3 Zwischenstände; V1 und V2 archiviert, V3 und V5 verworfen. Vergleich V1 gegen V2 mit 10 Anfragen in der [Test-Tabelle](docs/test-tabelle.md). Der Vergleich V2 gegen V4 steht aus.
- Guardrails (12.11.2026, Hauptworkflow v17 bis v19, gebaut für den Chat-Eingang): Eingangsprüfung vor dem Agenten (schwärzen, Jailbreak, Themenbindung) und Ausgangsprüfung vor der Freigabe (Schlüssel, Links, Personendaten, Anstößiges, mit Sperre). 9 Kernfälle in 12 Testzeilen (13 Ausführungen): 7 bestanden, 4 nicht bestanden (A1b, A6, P2 in 2 Anläufen), 1 Fehler (A3 am Eingang), siehe [Tag 4](docs/w08t04.html). Seither gebaut: Laufzeile und Veröffentlichung (21.11.2026). Offen: Eingänge Formular und Telegram, Prüfung der Recherche-Texte, 11 weitere Fälle.
- Vertrauensstufen und Freigabe (13. bis 15.11.2026, Hauptworkflow v20 bis v20.2): 12 Aktionen mit Stufe und Rechten, die Freigabe per Knopf in Telegram ist die Stufe „Fragt“. 4 Freigabetests: freigegeben (Lauf 3047), abgelehnt mit Grund (3053) und Angriff (3058) bestanden, Fristablauf (3064) **nicht bestanden**: nach der Frist gibt es keinen Ausgang, der Beitrag bleibt ohne Status und ohne Meldung liegen. Die Reparatur ist als Entwurf gebaut und noch nicht veröffentlicht (Stand 23.11.2026, Charter Abschnitt 7). Siehe [Tag 5](docs/w08t05.html) und die [Testtabelle Tag 5](docs/test-tabelle-w08t05.md). In v20.2 steht die Schlüsselprüfung der Ausgangsprüfung auf „permissive“, weil „balanced“ deutsche Wörter als Schlüssel sperrte.
- Grenzen: Die Zahlenprüfung im Text-Werkzeug löst seit v09.2 bei Ziffern und Zahlwörtern 1 Neufassung aus, seit v09.3 kürzt sie den LinkedIn-Post nur in ganzen Sätzen und schützt Absätze mit Einschränkungen; die Neufassung kostete in Lauf 4064 fast 1 Minute. Die Grenze von 14 Werkzeugaufrufen ist eine nachträgliche Prüfung der Antwort, keine harte Sperre vor dem Aufruf. Der Notenfilter erkennt Noten ohne Schlüsselwort und Noten in Worten nicht. Die Freigabe braucht einen Klick in Telegram; der Fristablauf der Freigabe ist nicht neu getestet.
- Die Exporte in [workflows/](workflows/) und die älteren Stände in [archiv/workflows/](archiv/workflows/) sind vor dem Hochladen bereinigt: Credential-IDs, Workflow-IDs (auch die Verweise der Werkzeug-Knoten), Tag- und Ordner-Kennungen, Adresse der Datenbank, Adresse der n8n-Instanz (auch die erlaubte Herkunft der Chat-Seite), Fehler-Workflow, Webhook-IDs und Hosts des Bild-Dienstes sind durch Platzhalter ersetzt. Die Exporte von Woche 9 Tag 3 und Tag 4 entsprechen dem veröffentlichten Stand in n8n und sind deshalb im Text nicht weiter bearbeitet: In einzelnen Notizen und Code-Kommentaren stehen noch interne Kennungen aus dem Bau; sie werden mit dem nächsten veröffentlichten Stand bereinigt. Die Statusnotizen in mehreren Workflow-Exporten nennen noch einen vorläufigen Stand: „Entwurf“ (Hauptworkflow, Freigabe-Workflow, Werkzeug 6), „Test läuft“ (Freigabe-Workflow) oder „Tests laufen“ (Werkzeug 3 und 5). Sie beschreiben den Stand vor der jeweiligen Veröffentlichung und wurden bewusst nicht nachträglich geändert. Auch in der Fassung zum Hard Freeze (geplant für Di 24.11.2026, Stand 23.11.2026 noch nicht veröffentlicht) bleiben die Wörter „Entwurf“ und „Test läuft“ in den Statusnotizen stehen; fortgeschrieben werden dort nur Versionsnummer und Kurzbeschreibung. Der Name eines Testkunden ist in den Exporten durch `KUNDE_B` ersetzt, live in n8n steht der Originalwert. Die Funktion ist gleich, der Export weicht deshalb im Text von der laufenden Instanz ab.

## Versionstabelle

Je Kurstag der Endstand des Hauptworkflows, dazu der Abgabestand mit Git-Tag. Jede einzelne Version mit Plan, Testtabelle, Tages-Doku und Export steht in der [Versionsmatrix](docs/versionsmatrix.md), die Versionen der Werkzeuge in [versionen.md](versionen.md). Git-Tags gibt es nur für Abgabestände, nicht je Workflow-Version.

| Version | Datum | Tag | Export-Datei | Tages-Doku | Kurzinhalt | Git-Tag |
|---|---|---|---|---|---|---|
| v26.5.3 | 21.11.2026 | W9 Tag 3 und Tag 4, Endstand, veröffentlicht 14:03 | [workflows/redaktions-agent.json](workflows/redaktions-agent.json), Abgabestände [W09T03](workflows/abgaben/W09T03/README.md) und [W09T04](workflows/abgaben/W09T04/README.md) | [W9 Tag 3](docs/w09t03.html), [W9 Tag 4](docs/w09t04.html) | Anordnung in Laufrichtung, Rahmen 01 bis 12, Setup-Zeile je Rahmen; abgekoppelter Block der alten Freigabe entfernt; Logik wie v26.5.2 | `v26.5.3` |
| v26.5.2 | 20.11.2026 | W9 Tag 3 und Tag 4, Stand der ersten Pläne vom 20.11.2026 (seit der Nachreichung vom 22.11.2026 zeigen die Pläne v26.5.3) | gab es nicht als Datei: Entwurf, vor der Veröffentlichung in v26.5.3 aufgegangen | [W9 Tag 3](docs/w09t03.html), [W9 Tag 4](docs/w09t04.html) | Chat-Seite mit Anmeldung, Sofortantwort, Freigabe-Workflow ohne Warten, Werkzeug 6, Systemprompt V4.4, Statuswechsel werden bestätigt | keiner |
| v23.1 | 18.11.2026 | W9 Tag 2 | [Abgabestand W09T02](workflows/abgaben/W09T02/AGT-2606_W09T02_Redaktions-Agent_Hauptworkflow_2026-11-18_v23.1.json) | [W9 Tag 2](docs/w09t02.html) | Status `auskunft`, Systemprompt V4.1, Reserve-Kasten | keiner |
| v22 | 17.11.2026 | W9 Tag 1 | [Abgabestand W09T01](workflows/abgaben/W09T01/AGT-2606_W09T01_Redaktions-Agent_Hauptworkflow_2026-11-17_v22.json) | [W9 Tag 1](docs/w09t01.html) | KI-Kennzeichnung, Agent-Modell Claude Haiku 5.5 | keiner |
| v20.2 | 15.11.2026 | W8 Tag 5 | gab es nicht als eigene Datei: im Verlauf dieses Repos, Commit 4555a53 | [W8 Tag 5](docs/w08t05.html) | Vertrauensstufen, Verwerfen-Zweig, Schlüsselprüfung auf permissive | keiner |
| v19.2 | 13.11.2026 | W8 Tag 4 | [archiv/workflows/redaktions-agent/20261113_redaktions-agent_v19.2.json](archiv/workflows/redaktions-agent/20261113_redaktions-agent_v19.2.json) | [W8 Tag 4](docs/w08t04.html) | Guardrails an Eingang und Ausgang, Systemprompt V4 | keiner |
| v16.2 | 11.11.2026 | W8 Tag 3, Tagesendstand | gab es nicht als eigene Datei: im Verlauf dieses Repos bis Commit 8951ffc | [W8 Tag 3](docs/w08t03.html) | Notiztext überarbeitet, Funktion wie v16 | keiner |
| v16 | 11.11.2026 | W8 Tag 3, Wochenabgabe | [archiv/workflows/redaktions-agent/20261111_redaktions-agent_v16.json](archiv/workflows/redaktions-agent/20261111_redaktions-agent_v16.json), abrufbar auch über Tag v16 | [W8 Tag 3](docs/w08t03.html) | Werkzeug 4 und 5, Freigabe und Ablage, Bestätigung mit Link | [v16](https://github.com/MinkeAutomation/redaktions-agent/releases/tag/v16) (Release „W08 Abgabe“) |
| v07 | 10.11.2026 | W8 Tag 2 | [archiv/workflows/redaktions-agent/20261110_redaktions-agent_v07.json](archiv/workflows/redaktions-agent/20261110_redaktions-agent_v07.json) | [W8 Tag 2](docs/w08t02.html) | Fehlerweg, Ausgabe-Prüfung, Werkzeug 3 | keiner |
| v01.2 | 09.11.2026 | W8 Tag 1 | [archiv/workflows/redaktions-agent/20261109_redaktions-agent_v01.2.json](archiv/workflows/redaktions-agent/20261109_redaktions-agent_v01.2.json) | [W8 Tag 1](docs/w08t01.html) | Chat, Agent, Werkzeug 1 und 2, Ausgabe-Prüfung | keiner |

## In 5 Minuten

1. Den Ablauf und die Stände liest du in [CHANGELOG.md](CHANGELOG.md): je Version des Systemprompts was geändert wurde, Ergebnis, nächste Idee, Status und die zugehörige Agent-Konfiguration.
2. Die 6 Werkzeuge, der Freigabe-Workflow und der Hauptworkflow liegen als Export in [workflows/](workflows/), die Abgabestände der Woche 9 in [workflows/abgaben/](workflows/abgaben/), die Testkopien in [workflows/test/](workflows/test/), die älteren Versionen mit eigenem Export in [archiv/](archiv/README.md). Die Liste aller Versionen mit Status, Archivdatei und n8n-Versions-ID steht in [versionen.md](versionen.md), was es je Version an Plan, Test und Doku gibt in [docs/versionsmatrix.md](docs/versionsmatrix.md). Dieses Repo beginnt mit dem Stand vom 11.11.2026 (Hauptworkflow v16) als erstem Commit; die Commit-Spalte in `versionen.md` verweist bei den älteren Ständen auf den Verlauf eines privaten Archiv-Repos, ab v19.1 (Commits c71efd7 und d234ae5) auf dieses Repo, soweit die Spalte nichts anderes sagt. Einzelne Zwischenstände wurden vor der Veröffentlichung zusammengeführt und haben keinen eigenen Commit.
3. Der geltende Systemprompt liegt als Markdown-Datei in [prompts/](prompts/) (Muster `YYYYMMDD_System-Prompt-Redaktions-Agent_V<Nummer>.md`), die älteren Fassungen V1, V2, V3 (verworfen), V4.2 und V4.3, die zeichengleiche Live-Fassung von V2 (`..._V2_vor-V3.md`) und die Testkopie-Prompts in [archiv/prompts/](archiv/prompts/).
4. Die Tests, auch der Vergleich von Prompt v1 gegen v2, stehen in [docs/test-tabelle.md](docs/test-tabelle.md).
5. Alle Tabellen und Views von Projekt 2 stehen als SQL in [sql/](sql/), die Reihenfolge im Abschnitt [Setup](#setup).
6. Ziel, Umfang und die gewählte Architektur (1 Agent mit 6 Werkzeugen) stehen in [docs/projekt-charter.md](docs/projekt-charter.md) (Fassung 10, Stand 23.11.2026). Die Begründung als Hybrid (feste Reihenfolge, Entscheidungen des Agenten an mehreren Stellen) steht auch in [W9 Tag 1](docs/w09t01.html#k5), [W9 Tag 4, Kapitel 6](docs/w09t04.html#k6) und in der [Compliance-Doku](docs/w09t01-compliance-doku.md).
7. Die 6 Werkzeuge mit Zweck, Eingabe, Ausgabe und der Description im Wortlaut stehen in [docs/werkzeuge.md](docs/werkzeuge.md).
8. Welche Dienste und Zugänge du zum Nachbauen brauchst, steht im Abschnitt [Setup](#setup); die Namen der Werte listet [.env.example](.env.example) (nur Namen, keine Werte).

## Dokumentation

Die Projektdokumentation liegt als Webseite im Ordner [docs/](docs/):

- [Wochen-Doku und Projektdokumentation](docs/index.html): Use Case, Architektur, Stand je Werkzeug, Prompt-Versionen, Ergebnis V1 gegen V2, Freigabe, Compliance, offene Punkte
- [Tag 1 (09.11.2026)](docs/w08t01.html): Use Case, Datenmodell, Systemprompt V1, Werkzeug 1 und 2
- [Tag 2 (10.11.2026)](docs/w08t02.html): Fehlerweg, Ausgabe-Prüfung, Werkzeug 3, Testreihe mit 1 Werkzeug
- [Tag 3 (11.11.2026)](docs/w08t03.html): Werkzeug 4 und 5, Freigabe und Ablage, Vergleich V1 gegen V2
- [Tag 4 (12.11.2026)](docs/w08t04.html): Guardrails an Eingang und Ausgang, Erlaubt und verboten, Übersicht nach den 3 Ebenen, Systemprompt V4, Planbild des Endstands, 9 Kernfälle in 12 Testzeilen (13 Ausführungen); die Testtabelle mit Eingabe und Antwort im Wortlaut steht in [docs/test-tabelle-w08t04.md](docs/test-tabelle-w08t04.md)
- [Tag 5 (13.11.2026, Tests 15.11.2026)](docs/w08t05.html): Vertrauensstufen je Aktion mit Rechten, Freigabe-Schleife per Telegram, 4 Freigabetests mit Ausführungsnummern (3 bestanden, 1 nicht bestanden), Plan v20.2, Export und Changelog
- [W9 Tag 1 (16.11.2026, Stand 17.11.2026)](docs/w09t01.html): Einordnung nach dem EU AI Act, 3 Schutzmaßnahmen gebaut und gemessen (Freigabe, Schwärzung, KI-Kennzeichnung), 20 Datenflüsse mit Standort, Datenflussbild Plan v22, Architektur als Hybrid begründet
- [W9 Tag 2 (17.11.2026, Stand 19.11.2026)](docs/w09t02.html): Testtabelle mit den Fällen K01 bis K18 und Varianten ohne Eingangsprüfung (Nachtrag 23.11.2026 mit K22 und K23 nur in der [Testtabelle](docs/test-tabelle-w09t02.md)), Bewertung nach 4 Dimensionen, Fehler behoben, danach Regression mit 19 von 20, Systemprompt V4.1 final, Plan v23.1
- [W9 Tag 3 (18.11.2026, Stand 21.11.2026)](docs/w09t03.html): Interface als Chat-Seite mit Anmeldung, Sofortantwort und Zeile „Werkzeuge genutzt“, Freigabe als eigener Workflow ohne Warten, Test von außen vom Handy, 7 Fehlerfälle mit Fix, bekannte Grenzen, Plan v26
- [W9 Tag 4 (19.11.2026, Stand 21.11.2026)](docs/w09t04.html): Token und Laufzeit vorher und nachher, Kosten je Anfrage, Tag und Monat, MUSS-Kriterien 20 von 25, Werkzeug 6 „Qualität prüfen“, Feature Freeze, 23 Fehlerfälle an Freigabe, Datenbank und Kürzung, Plan v26

Dazu gehören:

- [Projekt-Charter mit Begründung der Architektur](docs/projekt-charter.md) (Fassung 10, Stand 23.11.2026: Ziel, Scope, 1 Agent mit 6 Werkzeugen gegen Multi-Agent) und das ältere [Architekturbild](docs/bilder/architektur-redaktions-agent.svg) (Stand Woche 8; aktuell ist die Architektur v26.5.3 unten)
- [Werkzeuge](docs/werkzeuge.md): die 6 Werkzeuge mit Zweck, Eingabe, Ausgabe, Grenze und Description im Wortlaut
- Grenzen und Risiken: [Charter, Abschnitt 7](docs/projekt-charter.md) (Stand 23.11.2026, mit Gedächtnis, Ausführungsprotokoll, nicht getesteten Angriffen und Ersatztermin der Präsentation; das Budget steht in Abschnitt 5) und [W9 Tag 4, Kapitel 7](docs/w09t04.html#k7)
- [Projekt-Charter als Webseite](https://minkeautomation.github.io/redaktions-agent/charter.html): derselbe Inhalt wie die Markdown-Fassung, mit Navigation zur Wochen-Doku
- [Versionsmatrix](docs/versionsmatrix.md): je Version Plan, Testtabelle, Tages-Doku und Export, Lücken mit Grund
- [Test-Tabelle](docs/test-tabelle.md): Werkzeug-Tests, Vergleich V1 gegen V2, Freigabe und Ablage
- [Testtabelle Tag 4](docs/test-tabelle-w08t04.md): Guardrails, 12 Testzeilen
- [Testtabelle Tag 5](docs/test-tabelle-w08t05.md): 4 Freigabetests, Fehlalarm der Ausgangsprüfung
- [Compliance-Doku W9 Tag 1](docs/w09t01-compliance-doku.md): Einordnung mit Gesetzeswortlaut, Maßnahmen mit Läufen, Tabelle der 20 Datenflüsse, im Nachtrag vom 23.11.2026 2 weitere, neue Begründung der Architektur
- [Testtabelle W9 Tag 2](docs/test-tabelle-w09t02.md): alle Fälle mit Eingabe, Erwartung, Antwort und Bewertung je Dimension
- [Bau-Protokoll W9 Tag 2](docs/w09t02-bau-protokoll.md): was am 18.11.2026 am Hauptworkflow und am Text-Werkzeug gebaut und gemessen wurde
- [Pläne](docs/plan/): je Tag ein Excalidraw-Plan auf dem Endstand des Tages, in Woche 9 als Datenflussbild: [Plan v22](docs/plan/plan-w09t01-v22.excalidraw) (W9 Tag 1), [Plan v23.1](docs/plan/plan-w09t02-v23.excalidraw) (W9 Tag 2), [Plan W9 Tag 3](docs/plan/plan-w09t03-v26.excalidraw) und [Plan W9 Tag 4](docs/plan/plan-w09t04-v26.excalidraw) (beide am 22.11.2026 auf v26.5.3 neu gezeichnet, Hauptlauf D1 bis D35, Nebenwege D36 bis D54, Freigabe-Workflow D55 bis D59; die Fassungen vom 20.11.2026 bleiben über den Git-Tag v26.5.3 abrufbar)
- [Architektur des Hauptworkflows v26.5.3](docs/plan/architektur-hauptworkflow-v26.5.3-blatt1.png), 2 Blätter: Rahmen 01 bis 12 mit Diensten und der Freigabe-Workflow ([Blatt 1](docs/plan/architektur-hauptworkflow-v26.5.3-blatt1.png)), Datenquellen, Protokoll und Innenansicht ([Blatt 2](docs/plan/architektur-hauptworkflow-v26.5.3-blatt2.png)), Quelle [Excalidraw](docs/plan/architektur-hauptworkflow-v26.5.3.excalidraw)

## Grundlage aus Projekt 1

Projekt 2 baut auf der Content-Maschine K1 aus Projekt 1 auf: Der Agent nutzt deren Tabellen `k1_kunden`, `k1_posts`, `k1_einstellungen` und `k1_laufprotokoll` (Definition in [sql/p1_k1_tabellen_v01.sql](sql/p1_k1_tabellen_v01.sql), Erweiterungen aus Projekt 2 in den übrigen Dateien in [sql/](sql/)) und deren Ablage-Workflow. Die Grundlagen (Bedarf, Use Case, Grenzen) stehen dort und werden hier nicht wiederholt:

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
| 4 Bilder gestalten | Foto von Pixabay, sonst KI-Bild, gerendert mit Gotenberg im dunklen Layout aus Projekt 1 (mit Layout 4), „Mit KI erstellt“ auf jeder Folie, abgelegt in Supabase Storage | `sub-bilder-gestalten.json` |
| 5 Zur Freigabe einreichen | speichert den Beitrag mit Status `wartet_auf_freigabe`, höchstens 1 je Auftrag | `sub-zur-freigabe-einreichen.json` |
| 6 Qualität prüfen | prüft das Paket erst mit festen Regeln, dann bewertet ein Sprachmodell es gegen Markenpaket und Kriterien und gibt eine Note; bei Ausfall springt ein Ersatzmodell ein | `sub-qualitaet-pruefen.json` |

Eingabe, Ausgabe, Grenze und die Description jedes Werkzeugs im Wortlaut stehen in [docs/werkzeuge.md](docs/werkzeuge.md). Die Nummern sind die Reihenfolge, in der die Werkzeuge gebaut wurden. Im Ablauf ruft der Agent Werkzeug 6 direkt nach dem Text auf, vor den Bildern (Systemprompt V4.4). Der Agent reicht nur die `paket_id` weiter, das Paket selbst liegt in der Tabelle `k2_pakete`. Seit dem 19.11.2026 laufen Freigabe (Telegram, 2 Knöpfe), Ablage (Nextcloud) und Bestätigung im eigenen Freigabe-Workflow `sub-freigabe-abwarten-und-ablegen.json`, den der Hauptworkflow ohne Warten startet; so antwortet die Chat-Seite sofort, und das Warten auf den Menschen hängt nicht am Chat. Bis v23.1 lief die Freigabe im Hauptworkflow. Eine Prüfung der Antwort des Agenten (Guardrail Ebene 3) steht vor der Freigabe. Seit v17 und v18 kommen eine Eingangsprüfung vor dem Agenten und eine Ausgangsprüfung des Beitragstextes vor der Freigabe dazu (Guardrails-Knoten, siehe [Tag 4](docs/w08t04.html)).

## Zusatzfunktionen

Zusatzfunktionen über die Grundanforderungen hinaus. Stand 11.11.2026, die Zeilen mit eigenem Datum am 21.11.2026 nachgezogen. Die Läufe sind Ausführungsnummern in n8n und stehen in der [Test-Tabelle](docs/test-tabelle.md).

| Zusatzfunktion | Stand | Beleg |
|---|---|---|
| Human in the Loop | umgesetzt | Der Agent veröffentlicht nie selbst. Der Beitrag geht als Vorschau mit 2 Knöpfen nach Telegram: Freigeben oder Ablehnen mit Grund (Eingabe über ein Formular). Die Ablage in Nextcloud passiert erst nach der Freigabe. Getestet: 3 Freigaben mit Ablage (Läufe 2768 und 2782 mit Prompt V2, Lauf 2748 mit Prompt V1) und 1 Ablehnung (Lauf 2735: Status abgelehnt, Grund gespeichert, nichts abgelegt), siehe [Test-Tabelle](docs/test-tabelle.md) Abschnitt D. Das Verfallen der Anfrage ohne Klick (Sollwert 24, Einheit nicht bestätigt) ist im Test T3 nicht gelungen, siehe [Tag 5](docs/w08t05.html). |
| Monitoring mit Meldungen | Laufprotokoll und Meldungen an den Betreiber, kein Überwachungssystem | Für jeden Lauf entsteht eine Zeile im Laufprotokoll in Supabase (Kennung, Zeitpunkt, Status; Fehler im Freigabe-Workflow werden vermerkt, [W9 Tag 4, Kapitel 8](docs/w09t04.html#k8)). Laufzeit und Kosten sind einmalig an 3 Läufen gemessen ([W9 Tag 4, Kapitel 2](docs/w09t04.html#k2) und [3](docs/w09t04.html#k3)). Bei einem gesperrten Beitrag, einem verworfenen Beitrag und bei Fehlern in Freigabe und Protokoll geht eine Meldung über Telegram an den Betreiber; das ist in der Fehlerbehebung und in Proben belegt, nicht im Dauerbetrieb. Der Fehlerweg am Agenten setzt bei einem Ausfall einen festen Text, die Ursache steht als Code im Lauf (Läufe 2576 und 2579, [Tag 2](docs/w08t02.html)). Die Ausgabe-Prüfung sperrt unzulässige Antworten, etwa einen Statuswert ohne Beitrags-ID (Lauf 2706) oder ungültiges JSON (Lauf 2708); sie schlug auch fälschlich an (Lauf 2719, Wort „Systemprompt“). Im Hauptworkflow ist ein Fehler-Workflow eingetragen (Platzhalter `ERROR_WORKFLOW_ID`); ein Lauf, der ihn ausgelöst hat, ist nicht belegt. Es gibt kein Dashboard und keine laufende Auswertung von Laufzeit oder Kosten. Der Zweig „Ablage-Problem senden“ wurde nie ausgelöst. |
| Multi-Agent | nicht umgesetzt | 1 Agent mit 6 Werkzeugen, begründet in der [Projekt-Charter](docs/projekt-charter.md) und in [W9 Tag 4, Kapitel 6](docs/w09t04.html#k6). |
| MCP-Integration | nicht umgesetzt | Die Werkzeuge sind n8n-Sub-Workflows, kein MCP-Server; in der Projekt-Charter ausdrücklich nicht im Umfang. |
| Eigenes Interface | umgesetzt (Stand 21.11.2026) | Chat-Seite mit Anmeldung, Sofortantwort und Zeile „Werkzeuge genutzt“; von außen am 21.11.2026 vom Handy getestet (Lauf 4064), Grenze: Seite bis zur Antwort offen lassen ([W9 Tag 3](docs/w09t03.html)). |
| Kosten-Kalkulation | vorher und nachher gerechnet (Stand 21.11.2026) | Vorher rund 0,0046 $ je Lauf ohne Recherche (V4.1, aus der Abrechnung), nachher rund 0,0070 $ (v26.5.3, berechnet aus Tokens und Listenpreis), je mit Staffel bis 100.000 Aufrufe im Monat ([W9 Tag 4, Kapitel 3](docs/w09t04.html#k3)). |
| LLM-as-Judge | umgesetzt als Werkzeug 6 (Stand 21.11.2026) | Werkzeug 6 „Qualität prüfen“ vergibt Noten, zum Beispiel 4,6 in Lauf 3997 und 4064; bei einer schwachen Note folgt höchstens 1 Nachbesserung ([W9 Tag 4, Kapitel 5](docs/w09t04.html#k5)). |

## Future Features

Was bewusst noch nicht gebaut ist, je mit dem Grund. Was über die Grundanforderungen hinaus bis zum Hard Freeze am Di 24.11.2026 nicht fertig wird, kommt ebenfalls in diese Liste.

| Feature | Was es bringt | Warum noch nicht |
|---|---|---|
| Leitstand mit Chat und Kundenbereich | Aufträge, Freigabe und Status im Browser statt in Telegram, mit eigenem Bereich je Kunde | Seit dem Feature Freeze am 19.11.2026 kommen keine neuen Funktionen dazu, und die Reparatur von Fristablauf und Eingangsfilter hat Vorrang. |
| Weitere Eingangskanäle (Formular, Telegram, Slack, WhatsApp) | Aufträge dort annehmen, wo der Kunde ohnehin schreibt | Eingangsprüfung und Schwärzung sind nur für die Chat-Seite gebaut und getestet; jeder neue Kanal braucht eigene Tests gegen Angriffe und Personendaten. |
| MCP-Server für die Werkzeuge | Kunden können die Werkzeuge mit ihrem eigenen Agenten nutzen, wenn der Workflow weitergegeben wird | Heute arbeitet ein Agent mit allen Werkzeugen in derselben n8n-Instanz; dafür sind Sub-Workflows einfacher, ohne zusätzlichen Server. Ein MCP-Server lohnt sich erst bei der Weitergabe an Kunden. |
| Automatisches Posten nach der Freigabe | Der freigegebene Beitrag geht ohne Handgriff zu Instagram und LinkedIn | Das wäre eine Zweckänderung: Einordnung nach dem EU AI Act, Kennzeichnung auf der Plattform und Auftragsverarbeitung müssen vorher geklärt sein. Bis dahin veröffentlicht nur ein Mensch. |

Weitere Idee für die Zeit nach dem Kurs: mehrere Agenten mit Orchestrator ([W9 Tag 4, Kapitel 6 und 7](docs/w09t04.html#k6)).

## Umgebung

n8n (eigene Instanz), Supabase (Postgres und Storage), OpenRouter, Pixabay, Cloudflare Workers AI, Gotenberg, Telegram, Nextcloud. Zugangsdaten stehen nur in den n8n-Credentials, die Namen der nötigen Werte listet [.env.example](.env.example) (ohne Werte).

## Setup

So setzt du das System auf. Werte für Zugänge stehen nie im Repo, nur in den Credentials deiner n8n-Instanz; die Namen der Werte listet [.env.example](.env.example). Wie das System innen aufgebaut ist, zeigen [Werkzeuge](docs/werkzeuge.md), die [Architektur v26.5.3](docs/plan/architektur-hauptworkflow-v26.5.3-blatt1.png) und [W9 Tag 4](docs/w09t04.html).

### Dienste

| Dienst | Zweck | Zugang in n8n (ohne Wert) | Wie einrichten |
|---|---|---|---|
| n8n | Workflow-Plattform: Hauptworkflow, 6 Werkzeuge, Freigabe-Workflow, Chat-Seite | keiner | Eigene Instanz (selbst gehostet oder n8n Cloud). Workflows importieren nach den Schritten unten. |
| Supabase | Datenbank (Markenprofil, Pakete, Beiträge, Sitzungen, Laufzeilen) und Storage für die Bilder | `Supabase API` (Adresse und Service-Key) | Projekt anlegen, die SQL-Dateien in der Reihenfolge unten im SQL-Editor ausführen, Storage-Bucket `k1-medien` anlegen. |
| OpenRouter | Zugang zu allen Sprachmodellen | 2 Zugänge vom Typ OpenAI-API mit der Basisadresse von OpenRouter: einer für die kostenpflichtigen Modelle (Agent `anthropic/claude-haiku-5.5`, Recherche `perplexity/sonar`), einer für die kostenlosen (Text, Qualitätsprüfung, Eingangs- und Ausgangsprüfung); in den Exporten heißt der kostenpflichtige Zugang `OpenRouter API \| KI-AGT-2606`, der kostenlose `OpenRouter API \| CHAT` | Konto anlegen, API-Key erzeugen, für den kostenpflichtigen Zugang Guthaben laden. Welche Modelle wo laufen: [Werkzeuge](docs/werkzeuge.md) und [Charter, Abschnitt 4](docs/projekt-charter.md#4-datenquellen). |
| Telegram | Vorschau, Freigabe mit 2 Knöpfen, Meldungen an den Betreiber | `Telegram API` (Bot-Token) | Bot über BotFather anlegen; Chat-ID und Nutzer-ID der freigebenden Person in `k1_einstellungen` eintragen (`telegram_chat_id`, `telegram_freigabe_nutzer_id`). |
| Nextcloud | Ablage des freigegebenen Beitrags mit Bildern | im Ablage-Workflow aus Projekt 1 (`Nextcloud API`) | Ablage-Workflow aus dem Repo [content-maschine-k1](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/workflows/sub-nextcloud-ablage.json) importieren, seine ID im Freigabe-Workflow eintragen. |
| Pixabay | Fotos zu Schlagwörtern | `Pixabay API` (Query-Auth mit API-Key) | Konto anlegen, API-Key aus der API-Dokumentation von Pixabay. |
| Cloudflare Workers AI | KI-Bild (FLUX.1 schnell), wenn kein Foto passt | `Cloudflare Workers AI` (Header-Auth mit API-Token) | API-Token mit Rechten für Workers AI anlegen; Account-ID in `k1_einstellungen` eintragen (`cloudflare_account_id`). |
| Gotenberg | rendert die Folien zu PNG | keiner, nur der Platzhalter `GOTENBERG_HOST` | Eigenen Gotenberg-Container im selben Netz wie n8n starten (Port 3000). |
| Chat-Seite | Eingang des Auftrags mit Anmeldung | `Basic Auth` (Benutzername und Passwort der Chat-Seite) | Zugang anlegen, im Chat-Eingang die eigene n8n-Adresse als erlaubte Herkunft eintragen (siehe Importhinweise, Schritt 2). |
| Fehler-Workflow mit Mail (optional) | Alarm bei einem Fehler im Lauf | im eigenen Fehler-Workflow (SMTP) | Eigenen Fehler-Workflow anlegen und seine ID für `ERROR_WORKFLOW_ID` eintragen, oder die Zeile in den Einstellungen entfernen. |

### Tabellen und wer sie nutzt

Spalten je Tabelle ohne Daten, gelesen aus dem Live-Schema am 23.11.2026. Die Tabellen `k1_*` stammen aus Projekt 1; ihre Definition (Typen, Prüfregeln, Schlüssel) steht in [sql/p1_k1_tabellen_v01.sql](sql/p1_k1_tabellen_v01.sql), am 23.11.2026 aus dem Live-Schema abgeleitet.

| Tabelle oder View | Spalten | Genutzt von | SQL |
|---|---|---|---|
| `k1_kunden` | id, kuerzel, name, farbe_primaer, farbe_sekundaer, farbe_akzent, farbe_hintergrund, farbe_text, schrift_titel, schrift_text, ton, zielgruppe, no_gos, cta_text, hashtags_fest, logo_url, aktiv, erstellt_am, branding_pack | Werkzeug 4 und 5 (lesen), Werkzeug 1, 3 und 6 über `k2_v_markenwissen` | [p1_k1_tabellen_v01.sql](sql/p1_k1_tabellen_v01.sql) |
| `k1_posts` | id, customer_id, source_type, source, topic, slides, slide_urls, single_image_url, caption_instagram, linkedin_post, hashtags, model, status, rejection_reason, ai_generated, approved_by, execution_id, created_at, decided_at, erzeugt_von | Werkzeug 5 (anlegen), Hauptworkflow (Ausgangsprüfung, Sperre), Freigabe-Workflow (Status) | [p1_k1_tabellen_v01.sql](sql/p1_k1_tabellen_v01.sql), Spalte `erzeugt_von` in [p2_k2_views_v01.sql](sql/p2_k2_views_v01.sql) |
| `k1_einstellungen` | setting_key, setting_value, description, updated_at | Hauptworkflow, Werkzeug 4 (lesen) | [p1_k1_tabellen_v01.sql](sql/p1_k1_tabellen_v01.sql) |
| `k1_laufprotokoll` | id, logged_at, workflow_name, execution_id, execution_mode, stage, status, duration_ms, model, prompt_tokens, completion_tokens, total_tokens, customer_code, post_id, error_text, cost_usd, trace_id, prompt_version, generation_ms | Werkzeug 4 (liest die letzten Aufbauten) | [p1_k1_tabellen_v01.sql](sql/p1_k1_tabellen_v01.sql) |
| `k2_v_markenwissen` | kuerzel, name, ton, zielgruppe, no_gos, cta_text, hashtags_fest | Werkzeug 1, 3 und 6 (lesen) | [p2_k2_views_v01.sql](sql/p2_k2_views_v01.sql) |
| `k2_v_fruehere_posts` | kuerzel, topic, source_type, status, rejection_reason, erzeugt_von, created_at | Werkzeug 1 (lesen) | [p2_k2_views_v01.sql](sql/p2_k2_views_v01.sql) |
| `k2_pakete` | paket_id, kuerzel, trace_id, paket, modell, erstellt_am, bilder | Werkzeug 3 (anlegen), Werkzeug 4 (Spalte bilder), Werkzeug 4, 5 und 6 (lesen) | [p2_k2_pakete_v01.sql](sql/p2_k2_pakete_v01.sql) |
| `k2_sitzungen` | session_id, erste_antwort_am | Hauptworkflow (`Sitzung prüfen`, KI-Hinweis nur in der ersten Antwort) | [p2_k2_sitzungen_laeufe_tests_v01.sql](sql/p2_k2_sitzungen_laeufe_tests_v01.sql) |
| `k2_agent_laeufe` | id, logged_at, trace_id, execution_id, workflow_name, erzeugt_von, eingang, customer_code, post_id, testfall_id, prompt_version, agent_modell, agent_iterationen, agent_prompt_tokens, agent_completion_tokens, werkzeug_tokens, total_tokens, agent_cost_usd, werkzeug_cost_usd, cost_usd, kosten_quelle, tools_ausgefuehrt, tool_aufrufe, toolentscheidung, status, freigabe_status, ausgabe_pruefung, nachbesserung_runde, duration_ms, generation_ms, error_text | Hauptworkflow (Laufzeile), Freigabe-Workflow (nur Fehlervermerk `error_text`); `freigabe_status` und `agent_modell` sind angelegt, aber leer (Stand 23.11.2026, veröffentlichter Stand v26.5.3) | [p2_k2_sitzungen_laeufe_tests_v01.sql](sql/p2_k2_sitzungen_laeufe_tests_v01.sql) |
| `k2_agent_testfaelle` | id, nr, art, angriffsart, eingang, kunde_kuerzel, eingabe, quellenart, erwartet, status_erwartet, tools_erwartet, tools_verboten, quelle_erwartet, active, sort_order, created_at, updated_at | kein Workflow (leer, Ziel des Fremdschlüssels `testfall_id`) | [p2_k2_sitzungen_laeufe_tests_v01.sql](sql/p2_k2_sitzungen_laeufe_tests_v01.sql) |
| `k2_agent_testergebnisse` | id, testfall_id, lauf_id, system, prompt_version, status_tatsaechlich, tools_tatsaechlich, quelle_tatsaechlich, tool_recall, tool_praezision, korrektheit, relevanz, vollstaendigkeit, sicherheit, bestanden, bewertet_von, begruendung, total_tokens, cost_usd, created_at | kein Workflow (leer; die Testtabelle der Abgabe steht in [docs/test-tabelle-w09t02.md](docs/test-tabelle-w09t02.md)) | [p2_k2_sitzungen_laeufe_tests_v01.sql](sql/p2_k2_sitzungen_laeufe_tests_v01.sql) |
| `k2_v_kosten_tag` | tag, testlauf, laeufe, tokens, kosten_usd_tag, kosten_usd_je_lauf, hochrechnung_monat_usd_22_arbeitstage, davon_geschaetzt | kein Workflow (Auswertung von Hand) | [p2_k2_sitzungen_laeufe_tests_v01.sql](sql/p2_k2_sitzungen_laeufe_tests_v01.sql) |

### Kurz: Schritte zum Aufsetzen

1. Supabase: [sql/p1_k1_tabellen_v01.sql](sql/p1_k1_tabellen_v01.sql) (Tabellen `k1_kunden`, `k1_posts`, `k1_einstellungen` und `k1_laufprotokoll` aus Projekt 1), dann [sql/p2_k2_views_v01.sql](sql/p2_k2_views_v01.sql), [sql/p2_k2_pakete_v01.sql](sql/p2_k2_pakete_v01.sql) und [sql/p2_k2_sitzungen_laeufe_tests_v01.sql](sql/p2_k2_sitzungen_laeufe_tests_v01.sql) in dieser Reihenfolge ausführen. Bucket `k1-medien` anlegen, Einstellungsschlüssel und einen Testkunden eintragen.
2. In n8n die Zugänge aus der Tabelle Dienste anlegen.
3. Die Workflows in der Reihenfolge der Importhinweise importieren: erst die 6 Werkzeuge, dann der Ablage-Workflow aus Projekt 1, dann der Freigabe-Workflow, zuletzt der Hauptworkflow. Nach jedem Import die neue Workflow-ID in die Platzhalter eintragen.
4. Platzhalter für Adressen ersetzen (Supabase, n8n-Instanz, Gotenberg) und im Knoten `Konfiguration` das Kürzel des eigenen Kunden eintragen.
5. Werkzeuge, Freigabe-Workflow und Hauptworkflow veröffentlichen, die Chat-Seite öffnen, einen Testauftrag schicken und in Telegram freigeben. Die Chat-Seite bis zur Antwort offen lassen.

Die Einzelheiten zu jedem Schritt stehen in den Importhinweisen. Der Import in eine fremde Instanz ist bisher nicht nachgespielt.

## Importhinweise

Die Exporte lassen sich nicht ohne Anpassung einspielen. Welche Datei welche Rolle hat, in welcher Reihenfolge sie importiert wird und welche Zugänge sie braucht:

| Datei | Rolle | Importreihenfolge | braucht Credential |
|---|---|---|---|
| `workflows/sub-markenwissen-abfragen.json` | Werkzeug 1 | 1 | Supabase API |
| `workflows/sub-thema-recherchieren.json` | Werkzeug 2 | 2 | OpenRouter API |
| `workflows/sub-text-schreiben.json` | Werkzeug 3 | 3 | Supabase API, OpenRouter API |
| `workflows/sub-bilder-gestalten.json` | Werkzeug 4 | 4 | Supabase API, Pixabay API, Cloudflare Workers AI (dazu der Gotenberg-Host als Platzhalter, kein Credential) |
| `workflows/sub-zur-freigabe-einreichen.json` | Werkzeug 5 | 5 | Supabase API |
| `workflows/sub-qualitaet-pruefen.json` | Werkzeug 6 | 6 | Supabase API, OpenRouter API |
| `sub-nextcloud-ablage.json` aus Projekt 1 (Repo [content-maschine-k1](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/workflows/sub-nextcloud-ablage.json), nicht in diesem Repo) | Ablage in Nextcloud | 7 | Nextcloud API |
| `workflows/sub-freigabe-abwarten-und-ablegen.json` | Freigabe-Workflow (Freigabe in Telegram, Ablage, Status) | 8, nach dem Ablage-Workflow, weil er ihn per ID aufruft | Supabase API, Telegram API |
| `workflows/redaktions-agent.json` | Hauptworkflow | 9, zuletzt, weil er die Werkzeuge und den Freigabe-Workflow per ID aufruft | OpenRouter API, Supabase API, Telegram API, Basic Auth (Anmeldung der Chat-Seite) |
| `workflows/test/test-redaktions-agent-1-werkzeug.json` | Testkopie mit 1 Werkzeug | nicht nötig | OpenRouter API |
| `workflows/test/test-text-schreiben-lesefehler.json` | Testkopie, Lesefehler Werkzeug 3 | nicht nötig | Supabase API |
| `workflows/test/test-markenwissen-lesefehler.json` | Testkopie, Lesefehler Werkzeug 1 | nicht nötig | Supabase API |
| `workflows/test/test-jina-reader.json` | Testkopie, Einzeltest des Jina-Aufrufs | nicht nötig | keines |

Die Dateien in `archiv/` sind nicht zum Import gedacht (siehe [archiv/README.md](archiv/README.md)).

Vorgehen:

1. Tabellen in Supabase anlegen:
   - Tabellen `k1_kunden`, `k1_posts`, `k1_einstellungen` und `k1_laufprotokoll` aus Projekt 1 (Kunden, Beiträge, Einstellungen, Laufprotokoll von Projekt 1) aus `sql/p1_k1_tabellen_v01.sql`, als Erstes. Werkzeug 4 liest aus `k1_laufprotokoll` die letzten Aufbauten und läuft ohne die Tabelle weiter, sie gehört trotzdem dazu.
   - Erweiterung von `k1_posts` um die Spalte `erzeugt_von` (Werte `p1_workflow` und `p2_agent`, kommt aus Projekt 2) und die Views `k2_v_markenwissen` und `k2_v_fruehere_posts`, beides in `sql/p2_k2_views_v01.sql` (Reihenfolge: erst die Spalte, dann die Views).
   - Tabelle `k2_pakete` aus `sql/p2_k2_pakete_v01.sql` (Paket-Speicher).
   - Einstellungsschlüssel in `k1_einstellungen`: `telegram_chat_id`, `telegram_freigabe_nutzer_id`, `cloudflare_account_id`.
   - Storage-Bucket `k1-medien` für die Bilder.
   - Testkunde `test-p2` in `k1_kunden` mit erfundenen Daten (Ton, Zielgruppe, No-Gos, Call to Action). Seit dem 19.11.2026 steht der Kunde im Knoten Konfiguration auf `ordwin`; wer nachbaut, trägt dort das Kürzel des eigenen Testkunden ein.
   - Tabellen `k2_sitzungen` (Sitzungen der Chat-Seite für den KI-Hinweis), `k2_agent_laeufe` (Laufprotokoll), `k2_agent_testfaelle` und `k2_agent_testergebnisse` (leer, Ziel des Fremdschlüssels `testfall_id`) und die View `k2_v_kosten_tag` aus `sql/p2_k2_sitzungen_laeufe_tests_v01.sql`, als Letztes, weil `k2_agent_laeufe` auf `k1_posts` verweist. Die Datei ist am 23.11.2026 aus dem Live-Schema abgeleitet (bis dahin fehlte diese SQL-Definition im Repo).
2. Platzhalter ersetzen. Die Platzhalter für Workflow-IDs ersetzt du erst in Schritt 3, weil die neuen IDs erst nach dem Import der Werkzeuge bekannt sind. Der Import in eine fremde Instanz ist bisher nicht nachgespielt, die Hinweise beschreiben den erwarteten Weg. Die Namen aller nötigen Werte stehen in [.env.example](.env.example).
   - `CREDENTIAL_ID`: steht für 7 verschiedene Zugänge. Nach dem Import wählst du je Knoten den eigenen Zugang aus, der angezeigte Name sagt, welcher gemeint ist (2 Zugänge zu OpenRouter, Supabase, Telegram, Pixabay, Cloudflare Workers AI und die Anmeldung der Chat-Seite als Basic Auth).
   - `https://SUPABASE_URL` (26 Stellen in den Live-Exporten: 12 im Hauptworkflow, 7 im Freigabe-Workflow, 5 in Werkzeug 4, je 1 in Werkzeug 3 und 5): Adresse der eigenen Supabase-Datenbank.
   - `https://DEINE-N8N-INSTANZ`: steht in den Notizen (Sticky Notes) und, mit Funktion, im Chat-Eingang des Hauptworkflows im Feld der erlaubten Herkunft (`allowedOrigins`). Dort muss die Adresse der eigenen n8n-Instanz stehen, sonst lädt die Chat-Seite nicht; in den Notizen hat der Platzhalter keine Funktion.
   - Sperrliste der Ausgabe-Prüfung, eigener Schritt: Im Code-Knoten „Agent-Antwort prüfen“ in `redaktions-agent.json` steht der Platzhalter `DEINE-N8N-INSTANZ` ohne `https://` in einem regulären Ausdruck (`/DEINE-N8N-INSTANZ/i`). Ihn durch den eigenen Hostnamen ersetzen, ohne `https://`, mit Punkten als `\.` geschrieben. Am einfachsten nach dem Import im n8n-Editor, dort mit einfachem Backslash, zum Beispiel `/n8n\.example\.org/i`. Wer schon vorher im Dateitext der JSON-Datei ersetzt, muss den Backslash doppelt schreiben (`/n8n\\.example\\.org/i`), sonst ist die Datei kein gültiges JSON mehr. Der Austausch von `https://DEINE-N8N-INSTANZ` aus dem Punkt davor erreicht diese Stelle nicht. Bleibt der Platzhalter stehen, sperrt die Prüfung die echte Adresse nicht, wenn der Agent sie in einer Antwort an den Menschen nennt. In `workflows/test/test-redaktions-agent-1-werkzeug.json` steht dieselbe Zeile.
   - `ERROR_WORKFLOW_ID`: eigener Fehler-Workflow oder die Zeile entfernen.
   - `WEBHOOK_ID`: steht in 7 Knoten des Hauptworkflows (Chat-Eingang und Telegram-Knoten) und in 11 Knoten des Freigabe-Workflows im Feld `webhookId`, gemeint ist je Knoten eine eigene Kennung des Webhooks in der eigenen Instanz. n8n vergibt sie beim Anlegen des Knotens selbst. Vor dem Import das Feld `webhookId` in diesen Knoten entfernen oder je Knoten eine eigene, neue Kennung (UUID) eintragen, nicht überall denselben Wert stehen lassen.
   - `GOTENBERG_HOST`: Adresse des eigenen Gotenberg-Dienstes, Port 3000. Port 3999 ist ein Testschalter für einen absichtlichen Ausfall.
3. Workflow-IDs eintragen, Reihenfolge einhalten. Die Exporte enthalten statt der echten n8n-Workflow-IDs die Platzhalter aus der Tabelle unten. Jeder Platzhalter steht in allen Dateien für dasselbe Ziel.
   1. Die 6 Werkzeuge (`sub-markenwissen-abfragen`, `sub-thema-recherchieren`, `sub-text-schreiben`, `sub-bilder-gestalten`, `sub-zur-freigabe-einreichen`, `sub-qualitaet-pruefen`) importieren (n8n: Workflow, Aus Datei importieren) und veröffentlichen. n8n vergibt dabei eine neue ID (bei einem anderen Importweg das Feld `id` am Ende der Datei vorher entfernen).
   2. Die neue ID jedes Werkzeugs notieren (Adressleiste, `/workflow/<ID>`).
   3. In `sub-freigabe-abwarten-und-ablegen.json` `WORKFLOW_ID_NEXTCLOUD_ABLAGE` durch die ID deines eigenen Ablage-Workflows ersetzen. Der Ablage-Workflow stammt aus Projekt 1: [workflows/sub-nextcloud-ablage.json im Repo content-maschine-k1](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/workflows/sub-nextcloud-ablage.json), er wird dort importiert und hier nur aufgerufen. Dann den Freigabe-Workflow importieren, veröffentlichen und seine neue ID notieren.
   4. In `redaktions-agent.json` im Texteditor mit Suchen und Ersetzen (alle Treffer) jeden Platzhalter der Werkzeuge und `WORKFLOW_ID_SUB_FREIGABE` durch die neue ID ersetzen. Das erfasst die 6 Werkzeug-Knoten (Feld `workflowId`), den Knoten `Freigabe starten` und, soweit dort genannt (Werkzeug 1 und 2), die Sperrliste im Code-Knoten „Agent-Antwort prüfen“, die IDs als Muster führt.
   5. Dann `redaktions-agent.json` importieren. Die Platzhalter `WORKFLOW_ID_REDAKTIONS_AGENT` und `WORKFLOW_ID_PROJEKT_1` stehen in `redaktions-agent.json` nur im Feld `id` und in der Sperrliste der Ausgabe-Prüfung; sie müssen nicht ersetzt werden. Wer die Sperrliste scharf halten will, trägt nach dem Import die neue ID des Hauptworkflows dort ein.

   | Platzhalter | Ziel |
   |---|---|
   | `WORKFLOW_ID_SUB_MARKENWISSEN` | Werkzeug 1, `sub-markenwissen-abfragen.json` |
   | `WORKFLOW_ID_SUB_RECHERCHE` | Werkzeug 2, `sub-thema-recherchieren.json` |
   | `WORKFLOW_ID_SUB_TEXT` | Werkzeug 3, `sub-text-schreiben.json` |
   | `WORKFLOW_ID_SUB_BILDER` | Werkzeug 4, `sub-bilder-gestalten.json` |
   | `WORKFLOW_ID_SUB_EINREICHEN` | Werkzeug 5, `sub-zur-freigabe-einreichen.json` |
   | `WORKFLOW_ID_SUB_QUALITAET` | Werkzeug 6, `sub-qualitaet-pruefen.json` |
   | `WORKFLOW_ID_SUB_FREIGABE` | Freigabe-Workflow, `sub-freigabe-abwarten-und-ablegen.json` |
   | `WORKFLOW_ID_NEXTCLOUD_ABLAGE` | Ablage-Workflow aus Projekt 1 (nicht in diesem Repo, Link oben), steht im Freigabe-Workflow |
   | `WORKFLOW_ID_REDAKTIONS_AGENT` | dieser Workflow, also `redaktions-agent.json` |
   | `WORKFLOW_ID_PROJEKT_1` | Hauptworkflow von Projekt 1, kommt nur in der Sperrliste vor |
   | `TAG_ID_…` und `FOLDER_ID_PROJEKTORDNER` | Kennungen von Tags und Ordner der Ursprungsinstanz; nicht nötig, Tags legst du nach Bedarf selbst an |
   | `WORKFLOW_ID_TEST_…` | die Testkopien in `workflows/test/`; nicht nötig |

   Die Dateien in `konfiguration/` und `archiv/konfiguration/` sind Auszüge der Agent-Konfiguration zur Dokumentation und werden nicht importiert.
4. Die Dateien in `workflows/test/` sind Testkopien und nicht nötig.

Die LICENSE erlaubt das Lesen der Inhalte zur Durchsicht und zum Lernen. Die Importhinweise dienen dem Nachvollziehen dieser Arbeit; darüber hinaus gilt die LICENSE unverändert.
