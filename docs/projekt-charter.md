# Projekt-Charter und Architekturentscheidung: Redaktions-Agent

Projekt 2, Stand 11.11.2026, umgesetzt in n8n.

Repository: [github.com/MinkeAutomation/redaktions-agent](https://github.com/MinkeAutomation/redaktions-agent). Projektdokumentation: [Wochen-Doku](https://minkeautomation.github.io/redaktions-agent/) mit den Tagesseiten [Tag 1](https://minkeautomation.github.io/redaktions-agent/w08t01.html), [Tag 2](https://minkeautomation.github.io/redaktions-agent/w08t02.html) und [Tag 3](https://minkeautomation.github.io/redaktions-agent/w08t03.html). Grundlage ist [Projekt 1, die Content-Maschine K1](https://github.com/MinkeAutomation/content-maschine-k1).

## 1 Ziel und Use Case

Problem: Markengerechte Social-Media-Posts kosten kleine Firmen zu viel Zeit, und ein starrer Ablauf erkennt nicht, wann ein Thema gegen die Marke verstößt, schon gepostet wurde oder neue Fakten braucht.

Use Case: Ein Agent bekommt ein Thema, prüft es gegen Marke und frühere Posts, holt bei Bedarf belegte Fakten, lässt Text und Bilder bauen und legt das Paket einem Menschen zur Freigabe vor.

## 2 Scope

Drin: 1 Kunde je Auftrag, Instagram und LinkedIn, Text und Bilder im Branding, Freigabe in Telegram, Ablage in Nextcloud, Qualitätsprüfung vor dem Einreichen als Werkzeug 6 (geplant, siehe Abschnitt 3), Tests mit Testkunde und erfundenen Daten (Ausnahmen und offene Prüfung siehe Abschnitt 6).

Nicht drin: Veröffentlichen durch den Agenten, echte Kundendaten, Layout 4, Logo-Datei (derzeit Wortmarke), Kundenportal, MCP-Server, Multi-Agent, Nachbesserung nach Ablehnung (Kür).

## 3 Architekturentscheidung

Entscheidung: 1 Single-Agent mit 5 Werkzeugen (Stand heute, ein 6. Werkzeug ist entschieden und geplant, siehe unten), kein Multi-Agent. Die genutzten Schritte folgen einer festen Reihenfolge (nicht jeder Schritt läuft bei jeder Anfrage) und teilen sich ein Ergebnis, das Paket. Nur 1 Stelle wählt zwischen Recherche, Ablehnung, Rückfrage und Einreichen. Ein weiterer Agent brächte zu prüfende Übergaben, ohne dass ein Schritt eine eigene Rolle braucht. Der Agent trifft die Entscheidungen, die in Projekt 1 feste Regeln waren (Recherche nötig, Thema schon gepostet, No-Go verletzt, Rückfrage). Sonst wäre er nur eine Hülle um den alten Ablauf.

Warum ein Agent mit Werkzeugen und keine feste Kette: Die Schritte teilen sich zwar ein Ergebnis, aber der Agent wählt je Anfrage, welche Werkzeuge nötig sind. Belegt in den Tests ([Test-Tabelle](test-tabelle.md)): Mit [Prompt v1](../archiv/prompts/20261109_System-Prompt-Redaktions-Agent_V1.md) folgte der Agent bei einem Auftrag ohne Bilder dem Wunsch und ließ das Bild-Werkzeug aus (Lauf 2735), und ein Auftrag mit belegten Fakten rief zusätzlich die Recherche auf (Lauf 2747). Mit [Prompt v2](../prompts/20261110_System-Prompt-Redaktions-Agent_V2.md) blieb eine Frage zur Marke bei Markenwissen (Lauf 2706), und ein Festpreisversprechen wurde nach dem Markenwissen abgelehnt, ohne dass Text oder Bilder entstanden (Lauf 2709). Dieselben beiden Aufträge aus Fall 2 und 3 der Test-Tabelle verfehlte v2: Lauf 2708 rief Bilder trotz „keine Bilder“ auf, und bei Lauf 2723 ist nicht ausgelesen, ob die Recherche lief. Eine starre Kette würde bei jeder Anfrage alle Schritte durchlaufen. Die Wahl ist nicht immer richtig, siehe Abschnitt 7. Kein Werkzeug enthält einen eigenen Agenten: Das Text-Werkzeug nutzt bei Ausfall des Hauptmodells ein Ersatzmodell als einfache Sprachmodell-Kette (Basic LLM Chain), keinen Agenten, die übrigen 4 Werkzeuge rufen Dienste per HTTP auf und enthalten keine Agenten- oder Ketten-Knoten.

Neu bewerten: Die Werkzeugwahl macht Fehler (Bilder trotz „keine Bilder“, Werkzeuge bei Smalltalk). Zuerst wird der Prompt überarbeitet und neu gemessen, danach gegebenenfalls Multi-Agent mit derselben Testreihe.

Bausteine und Warum:
- Agent ([Hauptworkflow](../workflows/redaktions-agent.json)): Gratismodell nach Test auf Werkzeugaufrufe. Nemotron 3 Ultra wurde nach einem Test auf Werkzeugaufrufe gewählt (die Einzelfälle sind in diesem Repository nicht dokumentiert), fiel am 11.11. zeitweise aus, seitdem läuft Nemotron 3.5 Super.
- [Werkzeug 1, Markenwissen](../workflows/sub-markenwissen-abfragen.json): liest über [2 Views](../sql/p2_k2_views_v01.sql) nur nötige Spalten, die Kundenkennung setzt der Workflow, damit kein fremder Kunde abfragbar ist.
- [Werkzeug 2, Recherche](../workflows/sub-thema-recherchieren.json): Perplexity Sonar, höchstens 1 Aufruf plus 1 Wiederholung, weil Fakten nur bei Bedarf geholt werden.
- [Werkzeug 3, Text](../workflows/sub-text-schreiben.json): speichert das Paket in der [Tabelle k2_pakete](../sql/p2_k2_pakete_v01.sql) unter einer paket_id, damit Bilder und Einreichen es lesen und der Agent nur die ID weiterreicht.
- [Werkzeug 4, Bilder](../workflows/sub-bilder-gestalten.json): Foto von Pixabay, sonst KI-Bild, damit ein fehlendes Foto den Auftrag nicht stoppt.
- [Werkzeug 5, Einreichen](../workflows/sub-zur-freigabe-einreichen.json): legt als einziges Werkzeug einen Beitrag an (Status wartet_auf_freigabe).
- Werkzeug 6, Qualität prüfen (geplant, nicht gebaut): bewertet das Paket vor dem Einreichen nach einem festen Raster, damit schwache Beiträge nicht erst beim Menschen auffallen.
- [Sub-Workflows](../workflows): je Werkzeug 1 Workflow, der Eingaben prüft und immer einen Status zurückgibt.
- Supabase: Beiträge, Pakete, Läufe, läuft in Projekt 1 seit Oktober.
- Telegram-Freigabe: Ein Mensch entscheidet vor jeder Ablage. Das Warten liegt im Hauptworkflow, nicht in einem Sub.
- Nextcloud-Ablage: der vorhandene [Ablage-Workflow aus Projekt 1](https://github.com/MinkeAutomation/content-maschine-k1/blob/main/workflows/sub-nextcloud-ablage.json), nur aufgerufen.

Erweiterung um Werkzeug 6, Qualität prüfen (entschieden am 11.11.2026, Status geplant, nicht gebaut): Anlass ist, dass Beiträge zur Freigabe in alte Muster zurückfielen, obwohl die Qualitätsregeln aus Projekt 1 für LinkedIn und Instagram gelten sollten. Das Werkzeug läuft vor „Zur Freigabe einreichen“ und bewertet Text und Bildtexte nach einem festen Raster. Das Raster stammt aus den Qualitätsregeln von Projekt 1, zum Beispiel Einstieg mit Hook, belegte Kernaussagen, Zahlen nur mit Beleg und bei Instagram keine Links; die genaue Fassung und die Schwelle werden vor dem Bau festgelegt. Bewertet wird mit einem anderen Sprachmodell als dem, das schreibt, damit Schreiber und Bewerter nicht dieselben Schwächen teilen. Liegt das Ergebnis unter der Schwelle, geht das Paket höchstens 1 Mal zurück an „Text schreiben“, danach entscheidet der Mensch in der Freigabe.

Zuerst wird geprüft, ob „Text schreiben“ die Qualitätsregeln aus Projekt 1 überhaupt bekommt. Fehlen sie dort, werden sie wieder eingesetzt, bevor Werkzeug 6 entsteht, sonst würde der Bewerter einen Fehler messen, den der Schreiber nie hätte machen müssen. Gebaut wird bis zum Feature-Freeze am Ende der Woche 9 (Fr 20.11.2026). Das Werkzeug deckt die Zusatzfunktion LLM-as-Judge ab, sobald es läuft; bis dahin gilt sie als nicht umgesetzt (Abschnitt 10).

Verworfen: Projekt 1 zu Projekt 2 umbauen (Projekt 1 läuft getrennt weiter), Lauf-Log in der Tabelle von Projekt 1 (dort liest ein Dashboard mit), der vorhandene Protokoll-Workflow (erlaubt nur Tabellen früherer Wochen), Freigabe in einem Sub, Multi-Agent.

## 4 Datenquellen

Supabase: Markenwissen und die letzten 20 Posts eines Kunden als [Views](../sql/p2_k2_views_v01.sql) (nur lesen), dazu Beiträge, [Pakete](../sql/p2_k2_pakete_v01.sql) und Läufe. Web: Perplexity Sonar über OpenRouter, Jina Reader, Supadata. Bilder: Pixabay, Cloudflare Workers AI, Gotenberg, Supabase Storage. Dazu Telegram und Nextcloud. Die Sprachmodelle (Nemotron) laufen über OpenRouter, der direkte Weg zu NVIDIA wird seit 10.11. nicht mehr genutzt (Fehler 404 in Lauf 2586). Am 09.11. liefen alle Dienste außer NVIDIA und Jina Reader in 2 echten Läufen fehlerfrei, Jina Reader am 10.11. in einem Einzeltest (Lauf 2655).

Zugriff auf die Datenbank: Die Werkzeuge arbeiten mit dem Dienstzugang. Gemessen am 11.11.2026: Die beiden Views haben `security_invoker` und keine Leserechte für die Rollen `anon` und `authenticated` (Abfrage mit diesen Rollen: Zugriff verweigert). Die Tabellen haben Zeilensperre ohne Policies, die Rolle `anon` sieht dort 0 Zeilen.

## 5 Human in the Loop und Guardrails

Der Agent veröffentlicht nie. Ein Mensch gibt in Telegram frei oder lehnt mit Grund ab, erst danach wird abgelegt. Ohne Antwort verfällt die Anfrage nach 24 Stunden.

- Ebene 1, Systemprompt: Rolle und wichtigstes Verbot in den 2 Anfangssätzen, Quelltext als Material statt Auftrag, keine erfundenen Fakten, kein Rollenwechsel, höchstens 8 Werkzeugaufrufe.
- Ebene 2, Werkzeug: Eingaben geprüft. Werkzeug 1 liest nur über 2 Views mit fest vorgegebener Kundenkennung, Werkzeug 3 und 4 schreiben nur in den Paket-Speicher beziehungsweise in Storage, nur Werkzeug 5 legt einen Beitrag an, kein Werkzeug veröffentlicht. Die Werkzeuge 3, 4 und 5 lesen zusätzlich Kunden-, Paket- und Beitragsdaten (Werkzeug 3 über die View, 4 und 5 direkt); die Kundenkennung setzt der Hauptworkflow fest.
- Ebene 3, Ausgabe: Die Antwort wird auf Pflichtfelder, erlaubte Status, Prompt-Reste, Schlüssel und fremde Kundennamen geprüft. Der Status eingereicht gilt nur mit post_id.

Belegt: Rief der Agent Werkzeug 5 ohne Paket, speicherte es nichts (3 Läufe: 2738, 2710, 2755, siehe [Test-Tabelle](test-tabelle.md)). Prompt-Versionen liegen als eigene Dateien mit [Changelog](../CHANGELOG.md) vor: [v1](../archiv/prompts/20261109_System-Prompt-Redaktions-Agent_V1.md) (09.11.), [v2](../prompts/20261110_System-Prompt-Redaktions-Agent_V2.md) (10.11., live), [v3](../archiv/prompts/20261110_System-Prompt-Redaktions-Agent_V3.md) (verworfen). Den Status je Version führt [versionen.md](../versionen.md).

## 6 Compliance kurz

Begrenztes Risiko (Transparenz), weder verboten noch Hochrisiko; bei Zweckänderung wie automatischem Posten wird neu bewertet. Beim Einsatz für Kunden ist man Betreiber und voraussichtlich Anbieter, rechtlich offen. Die Pflichten nach Art. 50 gelten seit 02.08.2026 für Systeme im Verkehr oder Betrieb, ob schon der Prototyp darunter fällt, ist offen. Im Testbetrieb laufen Testdaten ohne Personenbezug, mit 2 benannten Ausnahmen: die Telegram-Kennung der freigebenden Person und mögliche Namen realer Personen in öffentlichen Webtexten. Für diese 2 ist die Prüfung von Rechtsgrundlage, Empfängern und Drittland offen. Ersteinschätzung, keine Rechtsberatung; die Kurzfassung der Compliance steht in der [Wochen-Doku im Abschnitt Compliance](https://minkeautomation.github.io/redaktions-agent/index.html#compliance).

## 7 Risiken und offene Punkte

- Dieselben 10 Anfragen ([Test-Tabelle](test-tabelle.md)), 1 Lauf je Fall: Prompt v2 bestand 2 von 10 vollständig, v1 dagegen 5 von 10. Stichprobe eines Gratismodells, nicht belastbar. v2 ist schwächer bei „keine Bilder“ und beim Gedicht, Smalltalk besteht bei keiner Fassung.
- Ein Beitrag bleibt verwaist, wenn die Ausgabe-Prüfung nach dem Einreichen sperrt. Sie schlägt auch bei dem Wort „Systemprompt“ an (Fehlalarm).
- Das Gratismodell fiel zeitweise aus, Läufe dauerten bis zu 22 Minuten. Die Zahlenprüfung im Text erkennt nicht alle ausgeschriebenen Zahlen.
- Nie ausgelöst: Fehlerzweig „Ablage-Problem“. Getestet ist nur der n8n-Chat als Eingang, der Hauptworkflow ist unveröffentlicht.
- KI-Kennzeichnung der Posts geplant, nicht gebaut, rechtlich dringendste Lücke (geplant für Do 12.11.2026, früher, falls heute machbar). Offen: Nachweis zur KI-Kompetenz.
- Beiträge zur Freigabe fielen in alte Muster zurück, die Qualitätsregeln aus Projekt 1 greifen nicht. Die Ursache ist noch nicht geprüft; Gegenmaßnahme sind die Prüfung von „Text schreiben“ und Werkzeug 6 (Abschnitt 3, geplant).
- Kosten je Lauf, Tag und Monat sind geplant, noch nicht ausgewertet.
- Der n8n-Chat ist ein freies Textfeld. Dort ist eine Vorverarbeitung (Anonymisierung, etwa Namen entfernen) vor dem Agenten Pflicht. Sie ist nicht gebaut und als offener Punkt geführt. Der freie Text beim Ablehnen in Telegram geht nicht an den Agenten, er wird beim Beitrag gespeichert. Im Testbetrieb laufen Testdaten ohne Personenbezug, mit 2 benannten Ausnahmen: die Telegram-Kennung der freigebenden Person und mögliche Namen realer Personen in öffentlichen Webtexten. Für diese 2 ist die Prüfung von Rechtsgrundlage, Empfängern und Drittland offen.

## 8 Zeitplan

- Mi 11.11.: Werkzeuge 4 und 5, Freigabe, Ablage, Lauf von Anfang bis Ende (erledigt).
- Do 12.11.: 20 Testfälle (15 normale, 5 adversarial); KI-Kennzeichnung der Posts (geplant, früher, falls heute machbar).
- Fr 13.11.: Zwischenstand.
- Di 17.11.: Systemprompt final, danach Feinschliff (vorläufig).
- Bis Fr 20.11.: Ursache des Rückfalls in alte Muster prüfen, danach Werkzeug 6 bauen (geplant, entschieden am 11.11.2026).
- Fr 20.11.: Feature-Freeze (eigenes Ziel, offiziell vorgegeben ist Di 24.11.), Woche 10 ist für Doku und Präsentation reserviert.
- Do 26. oder Fr 27.11.: Abschlusspräsentation, Tag offen.

## 9 Erfolgskriterien

- 5 Werkzeuge laufen (erreicht).
- 20 Testfälle sind gelaufen, verglichen mit erwarteten und verbotenen Werkzeugen (bisher 10 je Prompt-Version).
- Jede Prompt-Version hat Datei und Changelog (erreicht).
- Nichts wird ohne Freigabe abgelegt (Freigabe 3 Mal, Ablehnung 1 Mal durchgelaufen).
- Die 5 adversarial Fälle geben weder Systemprompt noch Daten fremder Kunden preis (bisher 2 Fälle ohne Preisgabe).
- v2 schneidet mindestens so gut ab wie v1: nicht erreicht (v2 2 von 10, v1 5 von 10).
- Kosten je Lauf, Tag und Monat sind ausgewiesen.
- Werkzeug 6 läuft vor dem Einreichen und schickt Pakete unter der Schwelle höchstens 1 Mal zurück an „Text schreiben“ (geplant, noch nicht erreicht).

## 10 Zusatzfunktionen

Stand 11.11.2026. Die Belege je Zusatzfunktion stehen in der [Wochen-Doku im Abschnitt Zusatzfunktionen](https://minkeautomation.github.io/redaktions-agent/index.html#bonus).

| Zusatzfunktion | Stand |
|---|---|
| Human in the Loop | umgesetzt: Freigabe oder Ablehnung in Telegram, abgelegt wird erst nach der Freigabe |
| Monitoring und Alerting | Ansatz, kein Überwachungssystem: fester Ausfalltext mit Ursachencode und Ausgabe-Prüfung, kein Dashboard und kein getesteter Alarm |
| LLM-as-Judge | geplant als Werkzeug 6 (Abschnitt 3), nicht umgesetzt |
| Multi-Agent | nicht umgesetzt (Abschnitt 3) |
| MCP-Integration | nicht umgesetzt (Abschnitt 2) |
| Eigenes Interface | nicht umgesetzt, Eingang ist der n8n-Chat |
| Kosten-Kalkulation | nicht umgesetzt, geplant (Abschnitt 7) |

## Dateien im Repository

- Workflows: [Hauptworkflow](../workflows/redaktions-agent.json) und die 5 Werkzeuge im Ordner [workflows/](../workflows).
- Systemprompt: [v2, live](../prompts/20261110_System-Prompt-Redaktions-Agent_V2.md), im Archiv [v1](../archiv/prompts/20261109_System-Prompt-Redaktions-Agent_V1.md) und [v3, verworfen](../archiv/prompts/20261110_System-Prompt-Redaktions-Agent_V3.md).
- Tests und Versionen: [Test-Tabelle](test-tabelle.md), [versionen.md](../versionen.md), [Versionsmatrix](versionsmatrix.md).
- Datenbank: [Tabelle k2_pakete](../sql/p2_k2_pakete_v01.sql) und [Lese-Views](../sql/p2_k2_views_v01.sql).

## Stand

Fassung 6 vom 11.11.2026. Frühere Fassungen und alle Änderungen stehen im [Repository](https://github.com/MinkeAutomation/redaktions-agent).
