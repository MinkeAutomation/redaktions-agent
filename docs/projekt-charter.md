
# Projekt-Charter und Architekturentscheidung: Redaktions-Agent

Projekt 2, Stand 11.11.2026, umgesetzt in n8n.

## 1 Ziel und Use Case

Problem: Markengerechte Social-Media-Posts kosten kleine Firmen zu viel Zeit, und ein starrer Ablauf erkennt nicht, wann ein Thema gegen die Marke verstößt, schon gepostet wurde oder neue Fakten braucht.

Use Case: Ein Agent bekommt ein Thema, prüft es gegen Marke und frühere Posts, holt bei Bedarf belegte Fakten, lässt Text und Bilder bauen und legt das Paket einem Menschen zur Freigabe vor.

## 2 Scope

Drin: 1 Kunde je Auftrag, Instagram und LinkedIn, Text und Bilder im Branding, Freigabe in Telegram, Ablage in Nextcloud, Tests mit Testkunde und erfundenen Daten (Ausnahmen und offene Prüfung siehe Abschnitt 6).

Nicht drin: Veröffentlichen durch den Agenten, echte Kundendaten, Layout 4, Logo-Datei (derzeit Wortmarke), Kundenportal, MCP-Server, Multi-Agent, Nachbesserung nach Ablehnung (Kür).

## 3 Architekturentscheidung

Entscheidung: 1 Single-Agent mit 5 Werkzeugen, kein Multi-Agent. Die genutzten Schritte folgen einer festen Reihenfolge (nicht jeder Schritt läuft bei jeder Anfrage) und teilen sich ein Ergebnis, das Paket. Nur 1 Stelle wählt zwischen Recherche, Ablehnung, Rückfrage und Einreichen. Ein weiterer Agent brächte zu prüfende Übergaben, ohne dass ein Schritt eine eigene Rolle braucht. Der Agent trifft die Entscheidungen, die in Projekt 1 feste Regeln waren (Recherche nötig, Thema schon gepostet, No-Go verletzt, Rückfrage). Sonst wäre er nur eine Hülle um den alten Ablauf.

Warum ein Agent mit Werkzeugen und keine feste Kette: Die Schritte teilen sich zwar ein Ergebnis, aber der Agent wählt je Anfrage, welche Werkzeuge nötig sind. Belegt in den Tests: Mit Prompt v1 folgte der Agent bei einem Auftrag ohne Bilder dem Wunsch und ließ das Bild-Werkzeug aus (Lauf 2735), und ein Auftrag mit belegten Fakten rief zusätzlich die Recherche auf (Lauf 2747). Mit Prompt v2 blieb eine Frage zur Marke bei Markenwissen (Lauf 2706), und ein Festpreisversprechen wurde nach dem Markenwissen abgelehnt, ohne dass Text oder Bilder entstanden (Lauf 2709). Dieselben beiden Aufträge aus Fall 2 und 3 der Test-Tabelle verfehlte v2: Lauf 2708 rief Bilder trotz „keine Bilder“ auf, und bei Lauf 2723 ist nicht ausgelesen, ob die Recherche lief. Eine starre Kette würde bei jeder Anfrage alle Schritte durchlaufen. Die Wahl ist nicht immer richtig, siehe Abschnitt 7. Kein Werkzeug enthält einen eigenen Agenten: Das Text-Werkzeug nutzt bei Ausfall des Hauptmodells ein Ersatzmodell als einfache Sprachmodell-Kette (Basic LLM Chain), keinen Agenten, die übrigen 4 Werkzeuge rufen Dienste per HTTP auf und enthalten keine Agenten- oder Ketten-Knoten.

Neu bewerten: Die Werkzeugwahl macht Fehler (Bilder trotz „keine Bilder“, Werkzeuge bei Smalltalk). Zuerst wird der Prompt überarbeitet und neu gemessen, danach gegebenenfalls Multi-Agent mit derselben Testreihe.

Bausteine und Warum:
- Agent: Gratismodell nach Test auf Werkzeugaufrufe. Nemotron 3 Ultra traf 15 von 15, fiel am 11.11. zeitweise aus, seitdem läuft Nemotron 3.5 Super.
- Werkzeug 1, Markenwissen: liest über 2 Views nur nötige Spalten, die Kundenkennung setzt der Workflow, damit kein fremder Kunde abfragbar ist.
- Werkzeug 2, Recherche: Perplexity Sonar, höchstens 1 Aufruf plus 1 Wiederholung, weil Fakten nur bei Bedarf geholt werden.
- Werkzeug 3, Text: speichert das Paket unter einer paket_id, damit Bilder und Einreichen es lesen und der Agent nur die ID weiterreicht.
- Werkzeug 4, Bilder: Foto von Pixabay, sonst KI-Bild, damit ein fehlendes Foto den Auftrag nicht stoppt.
- Werkzeug 5, Einreichen: legt als einziges Werkzeug einen Beitrag an (Status wartet_auf_freigabe).
- Sub-Workflows: je Werkzeug 1 Workflow, der Eingaben prüft und immer einen Status zurückgibt.
- Supabase: Beiträge, Pakete, Läufe, läuft in Projekt 1 seit Oktober.
- Telegram-Freigabe: Ein Mensch entscheidet vor jeder Ablage. Das Warten liegt im Hauptworkflow, nicht in einem Sub.
- Nextcloud-Ablage: der vorhandene Ablage-Workflow aus Projekt 1, nur aufgerufen.

Verworfen: Projekt 1 zu Projekt 2 umbauen (Projekt 1 läuft getrennt weiter), Lauf-Log in der Tabelle von Projekt 1 (dort liest ein Dashboard mit), der vorhandene Protokoll-Workflow (erlaubt nur Tabellen früherer Wochen), Freigabe in einem Sub, Multi-Agent.

## 4 Datenquellen

Supabase: Markenwissen und die letzten 20 Posts eines Kunden als Views (nur lesen), dazu Beiträge, Pakete und Läufe. Web: Perplexity Sonar über OpenRouter, Jina Reader, Supadata. Bilder: Pixabay, Cloudflare Workers AI, Gotenberg, Supabase Storage. Dazu Telegram und Nextcloud. Die Sprachmodelle (Nemotron) laufen über OpenRouter, der direkte Weg zu NVIDIA wird seit 10.11. nicht mehr genutzt (Fehler 404 in Lauf 2586). Am 09.11. liefen alle Dienste außer NVIDIA und Jina Reader in 2 echten Läufen fehlerfrei, Jina Reader am 10.11. in einem Einzeltest (Lauf 2655).

Zugriff auf die Datenbank: Die Werkzeuge arbeiten mit dem Dienstzugang. Gemessen am 11.11.2026: Die beiden Views haben `security_invoker` und keine Leserechte für die Rollen `anon` und `authenticated` (Abfrage mit diesen Rollen: Zugriff verweigert). Die Tabellen haben Zeilensperre ohne Policies, die Rolle `anon` sieht dort 0 Zeilen.

## 5 Human in the Loop und Guardrails

Der Agent veröffentlicht nie. Ein Mensch gibt in Telegram frei oder lehnt mit Grund ab, erst danach wird abgelegt. Ohne Antwort verfällt die Anfrage nach 24 Stunden.

- Ebene 1, Systemprompt: Rolle und wichtigstes Verbot in den 2 Anfangssätzen, Quelltext als Material statt Auftrag, keine erfundenen Fakten, kein Rollenwechsel, höchstens 8 Werkzeugaufrufe.
- Ebene 2, Werkzeug: Eingaben geprüft. Werkzeug 1 liest nur über 2 Views mit fest vorgegebener Kundenkennung, Werkzeug 3 und 4 schreiben nur in den Paket-Speicher beziehungsweise in Storage, nur Werkzeug 5 legt einen Beitrag an, kein Werkzeug veröffentlicht. Die Werkzeuge 3, 4 und 5 lesen zusätzlich Kunden-, Paket- und Beitragsdaten (Werkzeug 3 über die View, 4 und 5 direkt); die Kundenkennung setzt der Hauptworkflow fest.
- Ebene 3, Ausgabe: Die Antwort wird auf Pflichtfelder, erlaubte Status, Prompt-Reste, Schlüssel und fremde Kundennamen geprüft. Ohne post_id gibt es keinen Erfolg.

Belegt: Rief der Agent Werkzeug 5 ohne Paket, speicherte es nichts (3 Läufe: 2738, 2710, 2755). Prompt-Versionen liegen als eigene Dateien mit Changelog vor: v1 (09.11.), v2 (10.11., live), v3 (verworfen).

## 6 Compliance kurz

Begrenztes Risiko (Transparenz), weder verboten noch Hochrisiko; bei Zweckänderung wie automatischem Posten wird neu bewertet. Beim Einsatz für Kunden ist man Betreiber und voraussichtlich Anbieter, rechtlich offen. Die Pflichten nach Art. 50 gelten seit 02.08.2026 für Systeme im Verkehr oder Betrieb, ob schon der Prototyp darunter fällt, ist offen. Im Testbetrieb laufen Testdaten ohne Personenbezug, mit 2 benannten Ausnahmen: die Telegram-Kennung der freigebenden Person und mögliche Namen realer Personen in öffentlichen Webtexten. Für diese 2 ist die Prüfung von Rechtsgrundlage, Empfängern und Drittland offen. Ersteinschätzung, keine Rechtsberatung; die Kurzfassung der Compliance steht in der Abgabe-Dokumentation zur Kurswoche, die nicht Teil dieses Repos ist.

## 7 Risiken und offene Punkte

- Dieselben 10 Anfragen, 1 Lauf je Fall: Prompt v2 bestand 2 von 10 vollständig, v1 dagegen 5 von 10. Stichprobe eines Gratismodells, nicht belastbar. v2 ist schwächer bei „keine Bilder“, Smalltalk und Gedicht.
- Ein Beitrag bleibt verwaist, wenn die Ausgabe-Prüfung nach dem Einreichen sperrt. Sie schlägt auch bei dem Wort „Systemprompt“ an (Fehlalarm).
- Das Gratismodell fiel zeitweise aus, Läufe dauerten bis zu 22 Minuten. Die Zahlenprüfung im Text erkennt nicht alle ausgeschriebenen Zahlen.
- Nie ausgelöst: Fehlerzweig „Ablage-Problem“. Getestet ist nur der n8n-Chat als Eingang, der Hauptworkflow ist unveröffentlicht.
- KI-Kennzeichnung der Posts geplant, nicht gebaut, rechtlich dringendste Lücke (geplant für Do 12.11.2026, früher, falls heute machbar). Offen: Nachweis zur KI-Kompetenz.
- Kosten je Lauf, Tag und Monat sind geplant, noch nicht ausgewertet.
- Der n8n-Chat ist ein freies Textfeld. Dort ist eine Vorverarbeitung (Anonymisierung, etwa Namen entfernen) vor dem Agenten Pflicht. Sie ist nicht gebaut und als offener Punkt geführt. Der freie Text beim Ablehnen in Telegram geht nicht an den Agenten, er wird beim Beitrag gespeichert. Im Testbetrieb laufen Testdaten ohne Personenbezug, mit 2 benannten Ausnahmen: die Telegram-Kennung der freigebenden Person und mögliche Namen realer Personen in öffentlichen Webtexten. Für diese 2 ist die Prüfung von Rechtsgrundlage, Empfängern und Drittland offen.

## 8 Zeitplan

- Mi 11.11.: Werkzeuge 4 und 5, Freigabe, Ablage, Lauf von Anfang bis Ende (erledigt).
- Do 12.11.: 20 Testfälle (15 normale, 5 adversarial); KI-Kennzeichnung der Posts (geplant, früher, falls heute machbar).
- Fr 13.11.: Zwischenstand.
- Di 17.11.: Systemprompt final, danach Feinschliff (vorläufig).
- Fr 20.11.: Feature-Freeze (eigenes Ziel, offiziell vorgegeben ist Di 24.11.), Woche 10 für Dokumentation und Präsentation.
- Do 26. oder Fr 27.11.: Abschlusspräsentation, Tag offen.

## 9 Erfolgskriterien

- 5 Werkzeuge laufen (erreicht).
- 20 Testfälle sind gelaufen, verglichen mit erwarteten und verbotenen Werkzeugen (bisher 10 je Prompt-Version).
- Jede Prompt-Version hat Datei und Changelog (erreicht).
- Nichts wird ohne Freigabe abgelegt (Freigabe 3 Mal, Ablehnung 1 Mal durchgelaufen).
- Die 5 adversarial Fälle geben weder Systemprompt noch Daten fremder Kunden preis (bisher 2 Fälle ohne Preisgabe).
- v2 schneidet mindestens so gut ab wie v1 (bisher 2 gegen 5 von 10).
- Kosten je Lauf, Tag und Monat sind ausgewiesen.

## Änderungsvermerk

11.11.2026: Abschnitt 3 um die Begründung ergänzt, warum ein Agent mit Werkzeugen statt einer festen Kette (mit Beispielen aus den Tests) und dass kein Werkzeug einen eigenen Agenten enthält. Abschnitt 7 um den offenen Punkt Vorverarbeitung vor dem Agenten ergänzt. Zahlen zu Freigabe, Ablehnung und Werkzeug 5 ohne Paket an die Test-Tabelle angeglichen. Ebene 2 und die Aussage zu schreibenden Werkzeugen an die Exporte angeglichen, Datenbankzugriff in Abschnitt 4 ergänzt.

11.11.2026 (Fassung 2): Laufnummern den Prompt-Versionen zugeordnet (Abschnitt 3), Datenschutzaussage in Abschnitt 6 und 7 vereinheitlicht (2 benannte Ausnahmen, Prüfung offen, Vorverarbeitung als offener Punkt), Verweis auf die Compliance-Kurzfassung der Abgabe-Dokumentation, Datum der KI-Kennzeichnung auf Do 12.11.2026 gesetzt.

11.11.2026 (Fassung 3): Architekturbegründung klargestellt (feste Reihenfolge gilt für die genutzten Schritte, der Agent wählt je Anfrage), Verweis bei den erfundenen Testdaten auf die 2 Ausnahmen, Feature-Freeze als eigenes Ziel gekennzeichnet (offiziell Di 24.11.), Formulierungen ohne Ordnungszahlen.

11.11.2026 (Fassung 4): Vorverarbeitung in Abschnitt 7 auf den n8n-Chat als freies Textfeld bezogen und als Pflicht gekennzeichnet (offen, nicht gebaut), Abschnitt 4 auf die gemessenen Zugriffe gekürzt, Datenquellen auf OpenRouter statt NVIDIA nachgezogen, Verworfen-Zeile zu Projekt 1 genauer gefasst.
