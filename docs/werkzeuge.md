# Werkzeuge des Redaktions-Agenten

Stand 23.11.2026, veröffentlichter Hauptworkflow v26.5.3. Die Descriptions stehen im Wortlaut so, wie der Agent sie sieht: gelesen aus der veröffentlichten Version in n8n am 23.11.2026 und zeichengleich mit dem Export [workflows/redaktions-agent.json](../workflows/redaktions-agent.json) (Feld `description` der 6 Knoten vom Typ „Call n8n Workflow Tool“).

Jedes Werkzeug ist ein eigener Sub-Workflow. Der Agent füllt nur die Eingaben, die per `$fromAI()` gekennzeichnet sind; Kundenkennung (`kuerzel`) und Laufkennung (`trace_id`) setzt der Hauptworkflow fest, damit der Agent keinen fremden Kunden abfragen kann. Jedes Werkzeug antwortet mit einem Text, der mit `STATUS: OK` beginnt (bei Werkzeug 6 auch `STATUS: UEBERARBEITEN`), sonst mit `NICHT_GEFUNDEN:` oder `FEHLER:`.

Die Nummern sind die Reihenfolge, in der die Werkzeuge gebaut wurden. Im Ablauf ruft der Agent sie so auf (Systemprompt V4.4): Markenwissen, bei Bedarf Recherche, Text, Qualität prüfen (bei `UEBERARBEITEN` 1 Nachbesserung und 1 erneute Prüfung), Bilder, Einreichen. Für den ganzen Lauf gilt eine Grenze von 14 Werkzeugaufrufen; sie wird nach der Antwort geprüft, `maxIterations` des Agenten steht auf 16.

## Übersicht

| Nr | Werkzeug (Name für den Agenten) | Zweck in 1 Satz | Obergrenze | Workflow-Datei, Version |
|---|---|---|---|---|
| 1 | `Markenwissen_abfragen` | Liefert dem Agenten die Richtlinien der Marke und die letzten 20 Beiträge des Kunden, damit er ein Thema gegen No-Gos und Doppel-Themen prüfen kann, bevor etwas geschrieben wird. | keine eigene (immer zuerst) | [`sub-markenwissen-abfragen.json`](../workflows/sub-markenwissen-abfragen.json), v03.3 |
| 2 | `Thema_recherchieren` | Holt 3 bis 5 aktuelle, belegte Fakten mit Quelle aus dem Web, wenn Quelltext und Markenwissen für den Beitrag nicht reichen. | 1 Aufruf plus 1 Wiederholung | [`sub-thema-recherchieren.json`](../workflows/sub-thema-recherchieren.json), v03.2 |
| 3 | `Text_schreiben` | Schreibt aus dem Briefing des Agenten das Text-Paket (Folien, Instagram-Text, LinkedIn-Post, Hashtags, Bildmotiv) im Ton der Marke, prüft es im Code und speichert es unter einer `paket_id`. | 1 Mal je Runde | [`sub-text-schreiben.json`](../workflows/sub-text-schreiben.json), v09.3 |
| 6 | `Qualitaet_pruefen` | Bewertet das gespeicherte Text-Paket vor den Bildern nach einem festen Raster gegen das Markenwissen und die Hausregeln und gibt eine Note. | 2 Prüfungen je Auftrag | [`sub-qualitaet-pruefen.json`](../workflows/sub-qualitaet-pruefen.json), v05.1 |
| 4 | `Bilder_gestalten` | Baut zum endgültigen Text die Bilder im Branding des Kunden: 1 Bild je Folie und 1 Einzelbild im dunklen Layout aus Projekt 1. | 1 Mal, Wiederholung nur nach Fehler | [`sub-bilder-gestalten.json`](../workflows/sub-bilder-gestalten.json), v05 |
| 5 | `Zur_Freigabe_einreichen` | Legt aus Paket und Bildern einen Beitrag mit Status `wartet_auf_freigabe` an. | 1 Mal, Wiederholung nur nach Fehler | [`sub-zur-freigabe-einreichen.json`](../workflows/sub-zur-freigabe-einreichen.json), v03 |

Hart gesperrt im Werkzeug selbst sind nur die Recherche (ab dem 3. Aufruf) und das Einreichen (1 Beitrag je Auftrag); die übrigen Grenzen stehen in Description und Systemprompt und werden nach der Antwort des Agenten geprüft.

## Werkzeug 1: Markenwissen abfragen (`Markenwissen_abfragen`)

- **Zweck:** Liefert dem Agenten die Richtlinien der Marke und die letzten 20 Beiträge des Kunden, damit er ein Thema gegen No-Gos und Doppel-Themen prüfen kann, bevor etwas geschrieben wird.
- **Eingabe vom Agenten:** `thema` (Text, Thema des Auftrags in wenigen Worten)
- **Eingabe fest vom Workflow:** `kuerzel` (Kundenkennung aus dem Knoten `Konfiguration`)
- **Ausgabe:** Text mit `STATUS: OK` und dem Markenprofil (Ton, Zielgruppe, No-Gos, Call to Action, feste Hashtags) samt den letzten 20 Beiträgen; sonst `NICHT_GEFUNDEN:` (keine aktive Marke) oder `FEHLER:` (ungültige Eingabe).
- **Grenze:** Nur lesen. Liest über die Views `k2_v_markenwissen` und `k2_v_fruehere_posts`, die Kundenkennung setzt der Workflow, nicht der Agent. Kein Sprachmodell.
- **Workflow:** [`workflows/sub-markenwissen-abfragen.json`](../workflows/sub-markenwissen-abfragen.json), v03.3

Description im Wortlaut:

```text
Markenwissen_abfragen: liefert die Richtlinien der Marke (Ton, Zielgruppe, No-Gos, Call to Action, feste Hashtags) und die letzten 20 Posts des aktuellen Kunden. Immer zuerst aufrufen. Eingabe: thema, das Thema des Auftrags in wenigen Worten. Rückgabe: Text, der mit STATUS: OK beginnt; NICHT_GEFUNDEN, wenn der Kunde keine aktive Marke hat; FEHLER, wenn die Eingabe ungültig war. Nur lesen.
```

## Werkzeug 2: Thema recherchieren (`Thema_recherchieren`)

- **Zweck:** Holt 3 bis 5 aktuelle, belegte Fakten mit Quelle aus dem Web, wenn Quelltext und Markenwissen für den Beitrag nicht reichen.
- **Eingabe vom Agenten:** `thema` (Text, Thema in wenigen Worten), `fragen` (Text, 1 bis 3 konkrete Fragen in einem Satz)
- **Eingabe fest vom Workflow:** `trace_id` (Kennung des Laufs aus dem Knoten `Konfiguration`)
- **Ausgabe:** Text mit `STATUS: OK` und Fakten mit Quelle; sonst `NICHT_GEFUNDEN:` (keine Belege) oder `FEHLER:` (Recherche ausgefallen).
- **Grenze:** Höchstens 1 Aufruf je Auftrag plus 1 Wiederholung nach einem Fehler, ab dem 3. Aufruf sperrt der Sub selbst. Modell `perplexity/sonar` über OpenRouter, kostenpflichtig.
- **Workflow:** [`workflows/sub-thema-recherchieren.json`](../workflows/sub-thema-recherchieren.json), v03.2

Description im Wortlaut:

```text
Thema_recherchieren: holt 3 bis 5 aktuelle, belegte Fakten mit Quelle aus dem Web (Perplexity Sonar). Nur aufrufen, wenn Quelltext und Markenwissen für den Post nicht reichen oder aktuelle Zahlen nötig sind, höchstens 1 Mal je Auftrag, nach einem FEHLER 1 Wiederholung (der Sub sperrt ab dem 3. Aufruf), kostet Geld. Eingaben: thema (Thema in wenigen Worten), fragen (1 bis 3 konkrete Fragen in einem Satz). Rückgabe: Text, der mit STATUS: OK beginnt und Fakten mit Quelle enthält; NICHT_GEFUNDEN, wenn es keine Belege gibt; FEHLER, wenn die Recherche ausfiel. Verwende nur die zurückgegebenen Fakten.
```

## Werkzeug 3: Text schreiben (`Text_schreiben`)

- **Zweck:** Schreibt aus dem Briefing des Agenten das Text-Paket (Folien, Instagram-Text, LinkedIn-Post, Hashtags, Bildmotiv) im Ton der Marke, prüft es im Code und speichert es unter einer `paket_id`.
- **Eingabe vom Agenten:** `briefing` (Text, mindestens 40 Zeichen: Thema, Kernaussage, belegte Fakten mit Quelle, Zahlen wörtlich), `nachbesserung` (Text, nur bei einer Überarbeitung, sonst leer)
- **Eingabe fest vom Workflow:** `kuerzel`, `trace_id`
- **Ausgabe:** Text mit `STATUS: OK` und der `paket_id` (das Paket liegt in `k2_pakete`, der Agent reicht nur die Kennung weiter); sonst `NICHT_GEFUNDEN:` oder `FEHLER:` (zum Beispiel Zahlen, die nicht im Briefing stehen).
- **Grenze:** 1 Mal je Runde. Zahlen ohne Beleg im Briefing lösen 1 Neufassung aus, ein zu langer LinkedIn-Post wird nur um ganze Sätze gekürzt, sonst neu gefasst. Hängt an Instagram-Text und LinkedIn-Post den Satz „Dieser Beitrag wurde mit KI erstellt.“ (Maßnahme C). Modell `nvidia/nemotron-3-ultra-550b-a55b:free`, Ersatz `nvidia/nemotron-3.5-super-vl:free`, beide über OpenRouter. Veröffentlicht nichts.
- **Workflow:** [`workflows/sub-text-schreiben.json`](../workflows/sub-text-schreiben.json), v09.3

Description im Wortlaut:

```text
Text_schreiben: schreibt aus deinem Briefing das Text-Paket für Instagram und LinkedIn im Ton der Marke (Folien, Instagram-Text, LinkedIn-Post, Hashtags, Bildmotiv) und speichert es. Nutze es, sobald Thema, Kernaussage und belegte Fakten feststehen, und nur 1 Mal je Runde. Eingaben: briefing (Thema, Kernaussage, Fakten nur aus Quelltext und Recherche mit ihrer Quelle, Zahlen wörtlich; mindestens 40 Zeichen), nachbesserung (nur, was am Text zu ändern ist, aus Ablehnungsgrund oder Prüfung, sonst leer; eine Zahl, die im Beitrag stehen soll, gehört wörtlich mit ihrem Zusammenhang ins briefing, nicht in die nachbesserung). Rückgabe: Text, der mit STATUS: OK beginnt und die paket_id nennt (das Paket selbst ist gespeichert, gib nur die paket_id weiter); NICHT_GEFUNDEN, wenn der Kunde keine aktive Marke hat; FEHLER, wenn das Paket nicht erstellt werden konnte (zum Beispiel Zahlen, die nicht im Briefing stehen). Veröffentlicht nichts, erfindet nichts.
```

## Werkzeug 6: Qualität prüfen (`Qualitaet_pruefen`)

- **Zweck:** Bewertet das gespeicherte Text-Paket vor den Bildern nach einem festen Raster gegen das Markenwissen und die Hausregeln und gibt eine Note. Bei einer schwachen Bewertung schickt der Agent den Text genau 1 Mal zur Nachbesserung zurück (LLM-as-Judge).
- **Eingabe vom Agenten:** `paket_id` (aus der letzten Antwort von `Text_schreiben`)
- **Eingabe fest vom Workflow:** `kuerzel`, `trace_id`
- **Ausgabe:** Text mit `STATUS: OK` (das Paket kann weiter) oder `STATUS: UEBERARBEITEN` mit höchstens 3 konkreten Verbesserungen; sonst `NICHT_GEFUNDEN:` oder `FEHLER:` (dann geht es ohne Prüfung weiter, der Beitrag trägt in der Freigabe den Hinweis „Achtung, Endtext ungeprüft“). Die Note setzt der Workflow, nicht der Agent.
- **Grenze:** Höchstens 2 Prüfungen je Auftrag. Erst prüft Code ohne Modell, dann bewertet ein Sprachmodell eines anderen Herstellers als der Schreiber: `particle-ai/particle-1:free`, Ersatz `google/gemma-4-31b-it:free`, über OpenRouter, bis zu 3 Versuche bei Überlast. Liest `k2_pakete` und `k2_v_markenwissen`, ändert nichts am Paket.
- **Workflow:** [`workflows/sub-qualitaet-pruefen.json`](../workflows/sub-qualitaet-pruefen.json), v05.1

Description im Wortlaut:

```text
Qualitaet_pruefen: bewertet das gespeicherte Text-Paket (Folientexte, Instagram-Text, LinkedIn-Post, Hashtags) nach einem festen Raster gegen das Markenwissen des Kunden und die Hausregeln. Feste Regel: Text schreiben, prüfen; bei UEBERARBEITEN genau 1 Nachbesserung, danach den NEUEN Text genau 1 Mal erneut prüfen; danach keine weitere Schleife (höchstens 2 Prüfungen je Auftrag). Erst aufrufen, nachdem Text_schreiben STATUS: OK mit einer paket_id geliefert hat, immer vor Bilder_gestalten (Bilder erst nach dem endgültigen Text, 1 Mal). Eingabe: paket_id, genau die aus der letzten Antwort von Text_schreiben. Rückgabe: Text, der mit STATUS: OK beginnt (das Paket kann weiter) oder mit STATUS: UEBERARBEITEN und höchstens 3 konkreten Verbesserungen (diese als nachbesserung an Text_schreiben geben); NICHT_GEFUNDEN, wenn Paket oder Marke fehlt; FEHLER, wenn die Prüfung ausfiel (dann nicht erneut aufrufen und ohne Prüfung weitermachen). Die Note setzt der Workflow selbst, schreibe sie nicht in den Hinweis. Ändert nichts am Paket und veröffentlicht nichts.
```

## Werkzeug 4: Bilder gestalten (`Bilder_gestalten`)

- **Zweck:** Baut zum endgültigen Text die Bilder im Branding des Kunden: 1 Bild je Folie und 1 Einzelbild im dunklen Layout aus Projekt 1.
- **Eingabe vom Agenten:** `paket_id` (aus der Antwort von `Text_schreiben`)
- **Eingabe fest vom Workflow:** `kuerzel`, `trace_id`
- **Ausgabe:** Text mit `STATUS: OK` und Anzahl, Bildquelle und `ki_bild`; sonst `NICHT_GEFUNDEN:` (Paket oder Branding fehlt, der Agent reicht dann nur die Texte ein) oder `FEHLER:`.
- **Grenze:** Genau 1 Mal je Auftrag, Wiederholung nur nach einem Fehler. Foto von Pixabay, sonst KI-Bild über Cloudflare Workers AI (FLUX.1 schnell), gerendert mit Gotenberg, abgelegt in Supabase Storage (Bucket `k1-medien`). Jedes Bild trägt einen Herkunftsmarker im PNG. Einzelbilder mit Pixabay-Foto erhalten einen Fremdfoto-Marker und keinen Schriftzug „Mit KI erstellt“. Die übrigen Bilder tragen den KI-Schriftzug. Regeln: Maßnahme C in der [Compliance-Doku](w09t01-compliance-doku.md). Ändert keine Texte, keine Bilder echter Personen.
- **Workflow:** [`workflows/sub-bilder-gestalten.json`](../workflows/sub-bilder-gestalten.json), v05

Description im Wortlaut:

```text
Bilder_gestalten: baut zum gespeicherten Text-Paket die Bilder im Branding des Kunden (Bild je Folie und 1 Einzelbild; Foto von Pixabay, sonst KI-Bild). Erst aufrufen, wenn der Text endgültig ist (nach der letzten Qualitätsprüfung), genau 1 Mal je Auftrag; eine Wiederholung nur, wenn der Aufruf mit FEHLER endete. Eingabe: paket_id, genau die paket_id aus der Antwort von Text_schreiben. Rückgabe: Text, der mit STATUS: OK beginnt und Anzahl, Bildquelle und ki_bild nennt; NICHT_GEFUNDEN, wenn Paket oder Branding fehlt (dann reicht der Agent nur die Texte ein); FEHLER, wenn die Bilder nicht erstellt werden konnten. Ändert keine Texte und erstellt keine Bilder echter Personen.
```

## Werkzeug 5: Zur Freigabe einreichen (`Zur_Freigabe_einreichen`)

- **Zweck:** Legt aus Paket und Bildern einen Beitrag mit Status `wartet_auf_freigabe` an. Als einziges Werkzeug erzeugt es einen Beitrag; die Freigabe selbst macht danach ein Mensch in Telegram (Freigabe-Workflow).
- **Eingabe vom Agenten:** `paket_id` (aus der Antwort von `Text_schreiben`), `hinweis_an_mensch` (1 Satz für die freigebende Person)
- **Eingabe fest vom Workflow:** `kuerzel`, `trace_id`
- **Ausgabe:** Text mit `STATUS: OK` und der `post_id`; sonst `NICHT_GEFUNDEN:` (Paket oder Kundenprofil fehlt) oder `FEHLER:`.
- **Grenze:** Genau 1 Mal je Auftrag, Wiederholung nur nach einem Fehler. Kein Beitrag ohne KI-Kennzeichnung. Veröffentlicht nichts und legt nichts ab.
- **Workflow:** [`workflows/sub-zur-freigabe-einreichen.json`](../workflows/sub-zur-freigabe-einreichen.json), v03

Description im Wortlaut:

```text
Zur_Freigabe_einreichen: speichert das Paket mit den Bildern als Beitrag mit Status wartet_auf_freigabe und legt ihn einem Menschen zur Freigabe vor. Erst aufrufen, wenn Text_schreiben STATUS: OK mit einer paket_id geliefert hat und Bilder_gestalten STATUS: OK geliefert hat oder NICHT_GEFUNDEN meldete (dann geht der Beitrag ohne Bilder raus). Genau 1 Mal je Auftrag; eine Wiederholung nur, wenn der Aufruf mit FEHLER endete. Eingaben: paket_id (genau die aus der Antwort von Text_schreiben), hinweis_an_mensch (1 Satz für den Menschen, was er beachten soll, zum Beispiel ein ähnliches Thema in den letzten 30 Tagen, sonst kurz den Inhalt). Rückgabe: Text, der mit STATUS: OK beginnt und die post_id nennt; NICHT_GEFUNDEN, wenn Paket oder Kundenprofil fehlt; FEHLER, wenn nichts eingereicht werden konnte. Veröffentlicht nichts und legt nichts ab, das entscheidet danach ein Mensch.
```

## Nicht als Werkzeug

Freigabe in Telegram, Ablage in Nextcloud und Bestätigung laufen im Freigabe-Workflow [`sub-freigabe-abwarten-und-ablegen.json`](../workflows/sub-freigabe-abwarten-und-ablegen.json) (v02.1). Den startet der Hauptworkflow nach dem Einreichen ohne Warten, der Agent kann ihn nicht aufrufen. So entscheidet immer ein Mensch, und kein Werkzeug veröffentlicht.
