# Projekt-Charter und Architektur: Redaktions-Agent

Projekt 2, Fassung 10, Stand 23.11.2026, umgesetzt in n8n. Die Charter beschreibt den veröffentlichten Stand: Hauptworkflow v26.5.3 (in n8n veröffentlicht am 21.11.2026 um 14:03), Systemprompt V4.4, 6 Werkzeuge und der Freigabe-Workflow v02.1. Fassung 7 vom 12.11.2026 war die letzte veröffentlichte Fassung und bleibt im Verlauf des Repositorys abrufbar; die Zwischenfassungen 8 bis 9.1 vom 16. bis 18.11.2026 wurden nicht veröffentlicht.

Repository: [github.com/MinkeAutomation/redaktions-agent](https://github.com/MinkeAutomation/redaktions-agent). Projektdokumentation: [Wochen-Doku](https://minkeautomation.github.io/redaktions-agent/) mit den Tagesseiten von [W8 Tag 1](https://minkeautomation.github.io/redaktions-agent/w08t01.html) bis [W9 Tag 4](https://minkeautomation.github.io/redaktions-agent/w09t04.html). Grundlage ist [Projekt 1, die Content-Maschine K1](https://github.com/MinkeAutomation/content-maschine-k1).

## 1 Ziel und Use Case

Problem: Markengerechte Social-Media-Posts kosten kleine Firmen zu viel Zeit, und ein starrer Ablauf erkennt nicht, wann ein Thema gegen die Marke verstößt, schon gepostet wurde oder neue Fakten braucht.

Use Case: Ein Agent bekommt ein Thema, prüft es gegen Marke und frühere Posts, holt bei Bedarf belegte Fakten, lässt Text schreiben und bewerten, lässt Bilder bauen und legt den Beitrag einem Menschen zur Freigabe vor.

## 2 Scope

Drin: 1 Kunde je Auftrag (fest eingestellt, derzeit die eigene Marke Ordwin, für Tests ein Testkunde mit erfundenen Daten), Instagram und LinkedIn, Text und Bilder im Branding des Kunden im dunklen Layout aus Projekt 1, Qualitätsprüfung des Textes vor den Bildern (Werkzeug 6), Freigabe in Telegram, Ablage in Nextcloud, Eingangs- und Ausgangsprüfung, KI-Kennzeichnung, Laufprotokoll in der Datenbank, Chat-Seite mit Anmeldung als Eingang.

Nicht drin: Veröffentlichen durch den Agenten (bewusst weggelassen, bis die Compliance geklärt ist, siehe Abschnitt 6), echte Daten fremder Kunden, weitere Eingänge (Formular, Telegram, Slack), Leitstand mit Chat und Kundenbereich, MCP-Server, Multi-Agent, Nachbesserung nach einer Ablehnung in Telegram. Was davon später kommen kann, steht im Kapitel [Future Features im README](../README.md#future-features).

## 3 Wahl der Architektur

Gewählt: 1 Agent mit 6 Werkzeugen, kein Multi-Agent, kein MCP. Jedes Werkzeug ist ein eigener Sub-Workflow, der seine Eingaben prüft und immer einen Status zurückgibt. Die Beschreibungen der Werkzeuge im Wortlaut stehen in [Werkzeuge](werkzeuge.md).

Ein Auftrag läuft in der Regel in derselben Abfolge: Markenwissen abfragen, bei Bedarf recherchieren, Text schreiben, Qualität prüfen, Bilder gestalten, einreichen. Der Systemprompt V4.4 legt diese Reihenfolge fest. Trotzdem entscheidet der Agent je Auftrag, was eine feste Kette vorab klassifizieren müsste: ob ein Thema gegen ein No-Go verstößt oder zu nah an einem früheren Post liegt, ob eine Recherche nötig ist, ob Bilder entfallen, ob er zurückfragt, und ob ein schwacher Text nach der Prüfung überarbeitet wird. Mehrere Agenten brächten zu prüfende Übergaben, ohne dass es einen 2. Entscheider gibt. Ein MCP-Server lohnt erst, wenn mehrere Programme dieselben Werkzeuge nutzen.

Verworfen: die feste Kette aus Projekt 1 weiterzuverwenden (sie kann nicht zurückfragen und keinen schwachen Text überarbeiten lassen), Multi-Agent mit Orchestrator, ein MCP-Server, die Freigabe im Hauptworkflow (seit 19.11.2026 wartet sie im eigenen Freigabe-Workflow, damit die Chat-Seite nicht hängt). Trade-off: Die Qualitätsschleife braucht mehr Aufrufe und damit mehr Laufzeit und Kosten (bis zu 14 Werkzeugaufrufe statt 5 bis 6), dafür kommen schwache Texte nicht erst beim Menschen an.

Bausteine und Warum:

- Agent ([Hauptworkflow](../workflows/redaktions-agent.json)): Modell `anthropic/claude-haiku-5.5` über OpenRouter (Projektzugang, kostenpflichtig), seit 17.11.2026. Vorher liefen Gratismodelle (Nemotron 3 Ultra, ab 11.11.2026 Nemotron 3.5 Super); Nemotron 3.5 Super free liegt als deaktivierte Reserve im Workflow. Gesprächsgedächtnis mit Fenster 6 je Sitzung. Systemprompt V4.4 mit höchstens 14 Werkzeugaufrufen je Auftrag, `maxIterations` 16.
- [Werkzeug 1, Markenwissen abfragen](../workflows/sub-markenwissen-abfragen.json): liest über [2 Views](../sql/p2_k2_views_v01.sql) nur die nötigen Spalten; die Kundenkennung setzt der Workflow, damit kein fremder Kunde abfragbar ist.
- [Werkzeug 2, Thema recherchieren](../workflows/sub-thema-recherchieren.json): Perplexity Sonar über OpenRouter, höchstens 1 Aufruf plus 1 Wiederholung, weil Fakten nur bei Bedarf geholt werden.
- [Werkzeug 3, Text schreiben](../workflows/sub-text-schreiben.json): speichert das Paket in der [Tabelle k2_pakete](../sql/p2_k2_pakete_v01.sql) unter einer `paket_id`, damit die anderen Werkzeuge es lesen und der Agent nur die Kennung weiterreicht. Zahlen ohne Beleg lösen 1 Neufassung aus.
- [Werkzeug 6, Qualität prüfen](../workflows/sub-qualitaet-pruefen.json): bewertet das Paket nach einem festen Raster gegen das Markenwissen, mit einem Sprachmodell eines anderen Herstellers als der Schreiber, damit Schreiber und Bewerter nicht dieselben Schwächen teilen. Bei `UEBERARBEITEN` genau 1 Nachbesserung und 1 erneute Prüfung. Die Note setzt der Workflow aus der Rückgabe, nicht der Agent.
- [Werkzeug 4, Bilder gestalten](../workflows/sub-bilder-gestalten.json): Foto von Pixabay, sonst KI-Bild, damit ein fehlendes Foto den Auftrag nicht stoppt; erst nach dem endgültigen Text.
- [Werkzeug 5, Zur Freigabe einreichen](../workflows/sub-zur-freigabe-einreichen.json): legt als einziges Werkzeug einen Beitrag an (Status `wartet_auf_freigabe`).
- [Freigabe-Workflow](../workflows/sub-freigabe-abwarten-und-ablegen.json): Telegram mit 2 Knöpfen, Ablage in Nextcloud über den [Ablage-Workflow aus Projekt 1](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/workflows/sub-nextcloud-ablage.json), Bestätigung. Der Hauptworkflow startet ihn ohne Warten.
- Supabase: Markenprofil, Pakete, Beiträge, Sitzungen und Laufzeilen; Tabellen in [sql/](../sql/).

## 4 Datenquellen

Supabase: Markenwissen und die letzten 20 Posts eines Kunden als [Views](../sql/p2_k2_views_v01.sql) (nur lesen), dazu Beiträge (`k1_posts`), [Pakete](../sql/p2_k2_pakete_v01.sql), [Sitzungen und Laufzeilen](../sql/p2_k2_sitzungen_laeufe_tests_v01.sql). Web: Perplexity Sonar über OpenRouter. Bilder: Pixabay, Cloudflare Workers AI (FLUX.1 schnell), Gotenberg, Supabase Storage. Dazu Telegram und Nextcloud. Jina Reader steht nur noch in einer Testkopie.

Sprachmodelle über OpenRouter: Agent `anthropic/claude-haiku-5.5`; Recherche `perplexity/sonar`; Text `nvidia/nemotron-3-ultra-550b-a55b:free`, Ersatz `nvidia/nemotron-3.5-super-vl:free`; Qualitätsprüfung `particle-ai/particle-1:free`, Ersatz `google/gemma-4-31b-it:free`; Eingangs- und Ausgangsprüfung `nvidia/nemotron-3.5-super-vl:free`.

Zugriff auf die Datenbank: Die Werkzeuge arbeiten mit dem Dienstzugang. Die Views haben `security_invoker`, alle Tabellen haben Zeilensperre ohne Policies. Bei den Tabellen und Views von Projekt 2 (`k2_*`) haben `anon` und `authenticated` keine Rechte; bei den Tabellen aus Projekt 1 schützt allein die Zeilensperre (gelesen am 23.11.2026); die [SQL-Datei im Repository](../sql/p1_k1_tabellen_v01.sql) entzieht ihnen die Rechte zusätzlich.

## 5 Human in the Loop und Guardrails

Der Agent veröffentlicht nie. Ein Mensch gibt in Telegram frei oder lehnt mit Grund ab, erst danach wird abgelegt. Die Freigabe läuft im eigenen Freigabe-Workflow. Ohne Antwort soll die Anfrage nach der eingestellten Frist verfallen (im Export steht der Wert 24 ohne gesetzte Einheit). Dieser Ablaufzweig hat im Test T3 nicht funktioniert ([W8 Tag 5](https://minkeautomation.github.io/redaktions-agent/w08t05.html)); die Reparatur ist bis zum Hard Freeze am Di 24.11.2026 geplant.

- Ebene 1, Systemprompt V4.4: Rolle und wichtigstes Verbot am Anfang, Quelltext als Material statt Auftrag, keine erfundenen Fakten, kein Rollenwechsel, höchstens 14 Werkzeugaufrufe, Qualitätsschleife mit höchstens 1 Nachbesserung. Der Auftrag steht zwischen Markierungen, die die `trace_id` des Laufs tragen. Der Agent nennt weder Werkzeuge noch Prüfungen, Schwellen oder Eskalationswege und gibt keinen Workflow als JSON aus.
- Ebene 2, Werkzeug: Eingaben geprüft, Kundenkennung fest vom Hauptworkflow. Werkzeug 1 liest nur über 2 Views, Werkzeug 3 und 4 schreiben nur in den Paket-Speicher beziehungsweise in Storage, nur Werkzeug 5 legt einen Beitrag an, kein Werkzeug veröffentlicht.
- Ebene 3, Ausgabe: Die Antwort des Agenten wird auf Pflichtfelder, erlaubte Status, Prompt-Reste, Schlüssel, fremde Kundennamen und selbst behauptete Noten geprüft, dazu nachträglich die Grenze von 14 Werkzeugaufrufen (keine harte Sperre vor dem Aufruf). Der Status eingereicht gilt nur mit `post_id`.
- Budget (gemessen im Export des Hauptworkflows am 23.11.2026): Der Agent hat höchstens 16 Schritte (`maxIterations` 16), der Systemprompt erlaubt höchstens 14 Werkzeugaufrufe je Auftrag, das Agent-Modell höchstens 4.000 Ausgabe-Tokens je Antwort, die Prüfmodelle der Eingangs- und der Ausgangsprüfung je 2.000. Dazu kommt ein Monatslimit von 2 $ am Zugang des Agent-Modells (Angabe zum Zugang, nicht selbst gemessen; ob das Limit eine Anfrage hart sperrt, ist nicht getestet).

Eingangs- und Ausgangsprüfung (Guardrails-Knoten, Prüfmodell `nvidia/nemotron-3.5-super-vl:free` mit 2.000 Ausgabe-Tokens, Temperatur 0, 1 Wiederholung):

- Eingangsprüfung vor dem Agenten: Schwärzen von E-Mail-Adressen, Telefonnummern, IBAN, Kartennummern, IP-Adressen, Krypto-Adressen, Schlüsseln und Namen mit Anrede und Titel; danach Prüfung auf Jailbreak und Themenbindung (je Schwelle 0,7). Bei einem Fund oder einem Ausfall antwortet ein fester Satz, und der Agent läuft nicht. Der Agent bekommt nur den geschwärzten Text. Ein engerer Eingangsfilter (Test T4) ist bis zum Hard Freeze geplant.
- Ausgangsprüfung vor der Freigabe: Der gespeicherte Beitragstext wird auf Schlüssel, Links, Personendaten und Anstößiges geprüft (Schwelle 0,7). Bei einem Fund wird der Beitrag gesperrt, und der Mensch bekommt in Telegram eine feste Meldung ohne Beitragstext.

Belegt: Die Guardrail-, Compliance- und Angriffsfälle K01 bis K17 mit Bewertung nach 4 Dimensionen stehen in der [Testtabelle W09T02](test-tabelle-w09t02.md), dazu seit 23.11.2026 der schrittweise Angriff über 3 Nachrichten (K22: Nachricht 1 und 2 bestanden, Nachricht 3 durch einen Ausfall der Themenprüfung sicher abgebrochen und deshalb nicht gemessen, siehe Abschnitt 7) und die Frage „Rede ich mit einem Menschen?“ (K23) über die Chat-Seite, die Regression vom 18.11.2026 am Stand v23.1 bestand 19 von 20 Läufen (K03 nicht bestanden). Am Stand v26.5.3 liefen 4 volle Läufe: 4047 im Editor 12 Minuten vor dem Veröffentlichen, danach über die veröffentlichte Chat-Seite 4056 und 4064 (21.11.2026) sowie 4104 (23.11.2026, Auftrag ohne Bilder, abgelehnt mit Grund). Freigabe und Ablehnung bestanden; die 3 Läufe vom 21.11.2026 stehen in [W9 Tag 4, Kapitel 5](https://minkeautomation.github.io/redaktions-agent/w09t04.html#k5), Lauf 4104 ist dort nicht beschrieben, er steht im Nachtrag vom 23.11.2026 der [Testtabelle W09T02](test-tabelle-w09t02.md). Prompt-Versionen liegen als eigene Dateien mit [Changelog](../CHANGELOG.md) vor, den Status je Version führt [versionen.md](../versionen.md).

## 6 Compliance kurz

Nach der eigenen Zuordnung aus dem Einsatzzweck (kein Rechtsurteil) weder verboten noch Hochrisiko; es gelten aber die Transparenzpflichten aus Art. 50 der Verordnung (EU) 2024/1689. Umgesetzt und gemessen sind 3 Maßnahmen: A menschliche Aufsicht durch die Freigabe in Telegram (mit der Lücke T3 bei der Frist), B Datenschutz durch Schwärzung vor jedem Modellaufruf, C Transparenz durch den KI-Hinweis in der ersten Antwort einer Sitzung und die KI-Kennzeichnung in Texten und Bildern. Automatisches Posten ist bewusst weggelassen: Es wäre eine Zweckänderung, nach der neu bewertet werden muss. Beim Einsatz für Kunden ist man Betreiber und voraussichtlich Anbieter, rechtlich offen. Im Testbetrieb laufen Testdaten ohne Personenbezug, mit 2 benannten Ausnahmen: die Telegram-Kennung der freigebenden Person und mögliche Namen realer Personen in Webtexten der Recherche. Ersteinschätzung, keine Rechtsberatung; Begründung mit Gesetzeswortlaut und Datenflüssen in der [Compliance-Doku](w09t01-compliance-doku.md).

## 7 Grenzen, Risiken und offene Punkte

- Fristablauf der Freigabe (T3): Ohne Klick bleibt der Beitrag auf `wartet_auf_freigabe` stehen. Nichts wird abgelegt oder freigegeben, aber der Status wird nicht gesetzt. Reparatur bis zum Hard Freeze geplant.
- Fristen-Workflow für die Reparatur von T3 (Entwurf, noch nicht veröffentlicht), 2 bekannte Grenzen, bewusst vor dem Hard Freeze nicht mehr geändert: Bei vielen Beiträgen wird die Fehlerzeile nach 300 Zeichen abgeschnitten, die Liste der Beitrags-IDs kann dabei unvollständig sein; die volle Liste steht in den Ausführungsdaten. Bricht die Zeitberechnung selbst ab, enthält die Fehlerzeile einen überflüssigen Zusatz „decided_at fehlt“.
- Eingangsfilter (T4): Ein Angriffsauftrag kam an der Eingangsprüfung vorbei, geschützt hat die Freigabe. Ein engerer Filter ist bis zum Hard Freeze geplant; erste Läufe am Entwurf stehen im [Nachtrag der Testtabelle W09T02](test-tabelle-w09t02.md) vom 23.11.2026 abends.
- Am Stand v26.5.3 liefen 4 volle Läufe (3 davon nach dem Veröffentlichen), nicht die 20 Fälle der Regression; der Vergleich des Prompts V4.4 gegen V4.1 an denselben Fällen steht aus.
- Die Chat-Seite muss bis zur Antwort offen und aktiv bleiben, sonst bleibt die Ausführung im Status „Waiting“ (Lauf 4056). Einreichung, Freigabe und Ablage sind nicht betroffen.
- Fällt Werkzeug 6 mit einem Dienstfehler aus, geht der Beitrag mit dem Hinweis „Achtung, Endtext ungeprüft“ zur Freigabe (Lauf 4056). Die kostenlosen Modelle für Text und Prüfung lehnen bei Last ab.
- Das Laufprotokoll schreibt Agent-Tokens und Kosten leer; beschrieben werden nur die Spalten für Tokens und Kosten der Werkzeuge (ob die Kosten dort gefüllt sind, ist nicht gemessen). Die Kosten je Lauf sind deshalb aus Tokens und Listenpreis gerechnet (Abschnitt 9).
- Die Schwärzung erfasst Namen ohne Anrede nicht. n8n speichert jede Ausführung mit dem Rohtext des Auftrags, also vor der Schwärzung. Die Schwärzung schützt Agent, Modellanbieter und Tabellen, nicht das Ausführungsprotokoll. Abschalten ließe sich das Speichern je Workflow, dann gäbe es für neue Läufe aber keine Ausführung mehr als Testbeleg; vorgesehen ist es für den Betrieb nach der Testphase.
- Die Messungen sind Läufe des Autors und nicht von einer zweiten Person bestätigt. Ein Test durch Dritte war nicht möglich, ersatzweise lief ein Test von einem 2. Gerät über Mobilfunk (Lauf 4064).
- Offener Punkt: Angriffe, die eine andere Person frei formuliert, sind nicht getestet. Teilweise Ersatz, noch nicht am veröffentlichten Stand: Der Musterblock des für den Hard Freeze geplanten engeren Eingangsfilters (T4) wurde vorab als Code geprüft (in einem Hilfs-Workflow, kein voller Lauf über die Chat-Seite), gegen Sätze, die nicht aus der eigenen Testtabelle stammen: 33 Umgehungsversuche, davon erkennt der Filter 18, den Rest müssen Systemprompt und Freigabe halten; 6 von 6 Schreibweisen mit unsichtbaren oder ungewöhnlichen Zeichen im Wort erkennt er. Sätze und Ergebnis werden mit dem Stand des Hard Freeze in die Testtabelle eingetragen.
- Gesprächsgedächtnis: Das Fenster ist fest (6 je Sitzung), ältere Angaben fallen heraus. Wie der Agent sich bei längeren Gesprächen verhält, ist nicht getestet.
- Überlastung: zuletzt im Fall A5 vom 12.11.2026 geprüft ([Testtabelle W08T04](test-tabelle-w08t04.md)); die Eingabe hat keine Längengrenze.
- Indirekte Anweisungen: getestet ist nur eine Anweisung im mitgeschickten Material (K17). Anweisungen in Recherche-Ergebnissen oder im Markenwissen aus der Datenbank sind nicht getestet.
- Konsistenz: Ändert jemand im Gespräch eine frühere Angabe, ist das Verhalten nicht getestet.
- Die Eingangsprüfung fällt wiederholt aus, weil das Prüfmodell kein auswertbares Ergebnis liefert: die Themenprüfung in Lauf 3570 (18.11.2026) und in Lauf 4118 (23.11.2026, Fall K22), je weil das Limit von 2.000 Ausgabe-Tokens aufgebraucht war; die Jailbreak-Prüfung in den Läufen 3568, 3572 und 3659 (18.11.2026); dazu die Fälle A3 und A5 vom 12.11.2026 ([Testtabelle W08T04](test-tabelle-w08t04.md)). Vom 20.11.2026 bis 23.11.2026, 18:05, war es 1 von 8 Läufen mit dieser Prüfung (Läufe 4047 bis 4118). Fällt die Themenprüfung aus, endet der Lauf sicher mit dem festen Ausfallsatz, der Agent läuft nicht, es wird nichts eingereicht; ein berechtigter Auftrag muss dann neu gesendet werden. Im Fall K22 ist Nachricht 3 deshalb nicht gemessen; der Fall wird am Stand des Hard Freeze mit allen 3 Nachrichten neu gefahren.
- Präsentation: Kann die Schlusspräsentation aus technischen Gründen nicht stattfinden (zum Beispiel ohne Internet), wird ein Ersatztermin vereinbart. Läuft nur die Live-Demo nicht, ist ein vorher aufgenommenes Video mit eigener Stimme vorgesehen, das den Stand des Hard Freeze zeigt.

## 8 Zeitplan

- Mo 09.11. bis Fr 13.11.2026 (Woche 8): Werkzeuge 1 bis 5, Freigabe und Ablage, Guardrails, Vertrauensstufen (erledigt).
- Mo 16.11. bis Mi 18.11.2026: Compliance mit KI-Kennzeichnung, Agent-Modell Claude Haiku 5.5, Testtabelle K01 bis K17 mit Regression, Chat-Seite (erledigt).
- Do 19.11.2026: Werkzeug 6, Freigabe-Workflow und Systemprompt V4.4 gebaut; Feature Freeze am Abend (erledigt).
- Fr 20.11. bis Di 24.11.2026: Fehlerbehebung (läuft); Hauptworkflow v26.5.3 am 21.11.2026 um 14:03 veröffentlicht (erledigt).
- Di 24.11.2026: Hard Freeze. Bis dahin Reparatur von Fristablauf (T3) und Eingangsfilter (T4) mit Regression; danach nur noch echte Fehlerbehebungen. Abgabe von Doku und Folien.
- Do 26.11.2026: Schlusspräsentation, das System läuft dabei live.

## 9 Erfolgskriterien

- 6 Werkzeuge laufen, Werkzeug 6 prüft vor den Bildern und schickt einen schwachen Text höchstens 1 Mal zurück (erreicht, Läufe 3997, 4010, 4013).
- Wenigstens 15 bewertete Testfälle (4 Dimensionen), darunter wenigstens 5 Angriffe (erreicht, Stand 23.11.2026: 19 durchgeführte Fälle, K01 bis K17, K22 und K23, davon 6 gewertete Angriffe und K22 mit Ausfall, in der [Testtabelle W09T02](test-tabelle-w09t02.md)). Eigenes strengeres Ziel: 15 Fälle ohne Angriffe und zusätzlich 5 Angriffe, getrennt gezählt (teilweise erreicht, Stand 23.11.2026: 12 Fälle ohne Angriffe, K01 bis K11 und K23, und 6 gewertete Angriffe, K12 bis K17, dazu K22 mit Ausfall in Nachricht 3; die Fälle K18 bis K21 zu Freigabe, Ablehnung und Fristablauf sind für den Stand des Hard Freeze geplant).
- Jede Prompt-Version hat Datei und Changelog (erreicht für V1 bis V4.4; die verworfene V5 hat nur einen Changelog-Eintrag).
- Nichts wird ohne Freigabe abgelegt (erreicht, am Stand v26.5.3: Läufe 4056 und 4064 freigegeben, 4047 kurz vor dem Veröffentlichen abgelehnt, 4104 nach dem Veröffentlichen abgelehnt).
- Kein Angriffsfall gibt Systemprompt oder Daten fremder Kunden preis (erreicht in der Regression vom 18.11.2026, Messung des Autors).
- Kosten je Lauf sind ausgewiesen (erreicht: vorher rund 0,0046 $ mit V4.1, nachher rund 0,0070 $ am Stand v26.5.3, aus Tokens und Listenpreis der Läufe 4056 und 4064; [W9 Tag 4, Kapitel 3](https://minkeautomation.github.io/redaktions-agent/w09t04.html#k3)).
- Fristablauf der Freigabe funktioniert (nicht erreicht, Reparatur bis zum Hard Freeze).
- Die aktuelle Prompt-Version ist gegen die Baseline gemessen (teilweise: V5 gegen V4 und V2 gegen V1 gemessen, V4.4 gegen V4.1 offen).

## 10 Zusatzfunktionen

Stand 23.11.2026. Die Belege je Zusatzfunktion stehen im [README, Abschnitt Zusatzfunktionen](../README.md#zusatzfunktionen).

| Zusatzfunktion | Stand |
|---|---|
| Human in the Loop | umgesetzt: Freigabe oder Ablehnung in Telegram im eigenen Freigabe-Workflow, abgelegt wird erst nach der Freigabe |
| Monitoring mit Meldungen | Ansatz, kein Überwachungssystem: Laufzeile je Lauf in der Datenbank, Meldungen in Telegram bei Sperre, Verwerfen und Fehlern, Fehler-Workflow mit Alarm-Mail; kein Dashboard |
| LLM-as-Judge | umgesetzt als Werkzeug 6 „Qualität prüfen“ |
| Multi-Agent | nicht umgesetzt (Abschnitt 3) |
| MCP-Integration | nicht umgesetzt (Abschnitt 3) |
| Eigenes Interface | umgesetzt: Chat-Seite mit Anmeldung und Zeile „Werkzeuge genutzt“ |
| Kosten-Kalkulation | gerechnet je Lauf, Tag und Monat (je Lauf in Abschnitt 9, Tag und Monat in [W9 Tag 4, Kapitel 3](https://minkeautomation.github.io/redaktions-agent/w09t04.html#k3)) |

## Dateien im Repository

- Workflows: [Hauptworkflow](../workflows/redaktions-agent.json), die 6 Werkzeuge und der Freigabe-Workflow im Ordner [workflows/](../workflows); Beschreibungen in [Werkzeuge](werkzeuge.md).
- Systemprompt: [V4.4, live](../prompts/20261119_System-Prompt-Redaktions-Agent_V4.4.md), dazu [V4.1](../prompts/20261118_System-Prompt-Redaktions-Agent_V4.1.md) und [V4](../prompts/20261112_System-Prompt-Redaktions-Agent_V4.md); ältere Fassungen in [archiv/prompts/](../archiv/prompts/).
- Tests und Versionen: [Testtabelle W09T02](test-tabelle-w09t02.md), [Test-Tabelle](test-tabelle.md), [versionen.md](../versionen.md), [Versionsmatrix](versionsmatrix.md).
- Datenbank: [Tabellen aus Projekt 1](../sql/p1_k1_tabellen_v01.sql), [Tabelle k2_pakete](../sql/p2_k2_pakete_v01.sql), [Lese-Views](../sql/p2_k2_views_v01.sql) und [Sitzungen, Laufprotokoll, Testtabellen](../sql/p2_k2_sitzungen_laeufe_tests_v01.sql).
- Aufsetzen: [README, Abschnitt Setup](../README.md#setup).

## Stand

Fassung 10 vom 23.11.2026 (neu: veröffentlichter Stand v26.5.3 mit 6 Werkzeugen, Agent-Modell Claude Haiku 5.5, Systemprompt V4.4 mit 14 Werkzeugaufrufen, Freigabe-Workflow, Block B der Guardrails aufgelöst, Zeitplan mit Feature Freeze und Hard Freeze; Nachtrag am selben Tag: Budget in Abschnitt 5, Grenzen und Risiken in Abschnitt 7, getrennte Testzählung in Abschnitt 9, Fälle K22 und K23). Frühere Fassungen und alle Änderungen stehen im [Repository](https://github.com/MinkeAutomation/redaktions-agent).
