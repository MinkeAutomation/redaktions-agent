# Bau-Protokoll W09T02: Redaktions-Agent (Projekt 2), Bau vom 18.11.2026

Stand 18.11.2026 nachts. Das Protokoll fasst zusammen, was am 18.11.2026 am Hauptworkflow und am Text-Werkzeug (Abschnitt 5b) gemessen und gebaut wurde. Es ist eine bereinigte Fassung des Arbeitsprotokolls: Zugangsdaten, Workflow- und Zugangskennungen, Projektadressen und interne Abläufe stehen hier nicht. Alle Läufe liefen im n8n-Chat oder manuell mit erfundenen Daten und dem Testkunden `test-p2`. Der Hauptworkflow war während des ganzen Baus nicht veröffentlicht (`active: false`), an Dritte ging nichts. Die Sub-Workflows liefen in den Messläufen echt mit (Läufe bis 3682); der Versand per Telegram und Mail, die Ablage und die Statusänderungen waren über gepinnte Knoten unterbunden, der Fehler-Workflow lief nicht.

Versionsnummern sind die ersten 8 Zeichen der n8n-Version. Läufe sind n8n-Ausführungsnummern.

## 1 Ausgangsstand und Methode

- Ausgangsstand: Hauptworkflow `2f925369`, 90 Knoten, inaktiv, keine gespeicherten Pins, Agent-Modell Claude Haiku 5.5.
- Methode: Jede Änderung wurde zuerst an einer Hilfskopie oder einem Hilfs-Workflow gemessen. Die Hilfskopien entstanden durch Duplizieren in der n8n-Oberfläche, danach wurde der Fehler-Workflow aus der Kopie entfernt, damit ein Lauf keine Mail auslösen kann.
- Vor jedem Lauf mit gepinnten Knoten wurde belegt, dass alle Knoten mit Außenwirkung (7 Telegram-Knoten, 5 Statusänderungen, Ablage, Recherche) gepinnt waren und kein Pin einen unbekannten Knoten nannte. Nach dem Lauf wurde gelesen, welche gepinnten Knoten erreicht wurden und dass der Versand unterblieb.
- Nach jedem Schreibzugriff am Hauptworkflow wurde der Stand mit der Hilfskopie Knoten für Knoten verglichen (63 ausführbare Knoten, 27 Notizen, 61 Verbindungsquellen). Erwartet war 0 Abweichung außer der gewollten Änderung. Der Vergleich wurde auch negativ geprüft: Ohne Angabe der gewollten Änderung meldete er genau 1 Abweichung.

## 2 Messungen vor dem Bau

| Messung | Ergebnis | Beleg |
|---|---|---|
| Standardprompt der Jailbreak-Prüfung | gleich dem vorgesehenen Ausgangstext (1.400 Zeichen, zeichengleich) | Knotenbeschreibung |
| Chat Trigger öffentlich schalten | lesend positiv (Basic Auth, ein gemeinsames Paar für alle Nutzer); der Antwortkörper im Browser ist nicht gemessen | Knotenbeschreibung und Herstellerdokumentation |
| Pins im manuellen Lauf | Ein Pin an einem HTTP-Knoten und an einem Werkzeug-Unterknoten wird beachtet, der Sub-Workflow läuft dann nicht. Ein Pin an einem abgeschalteten Knoten wirkt nicht. Ein Pin auf einen unbekannten Knoten wird vom Werkzeug abgelehnt (kein Lauf). Ein ungepinnter HTTP-Knoten läuft live. | Läufe 3457, 3458 |
| Muster-Prüfung ohne Modell (`Muster prüfen`) | läuft ohne Chat-Modell; der Mustername steht im Feld `entityType` der Treffer, nicht im Feld `name` | Läufe 3460 bis 3462 |
| 258 Sätze gegen 10 Muster | 182 bestanden, 76 Treffer, 0 Fehler, 0 Abweichungen vom erwarteten Ergebnis je Satz; 6 unsichtbare Zeichen werden gefangen | Lauf 3461 |
| Prüf-Prompt `eingang-jailbreak v2` | 10 Umgehungssätze und 10 harmlose Sätze, je 2 Läufe: 19 von 20 Umgehungen mit Wert ab 0,7, 0 von 20 harmlosen. Ein Satz mit Satzteilung wurde einmal mit 0,9 und einmal mit 0,2 bewertet. Grenze: 2 der harmlosen Sätze stehen fast wörtlich als Beispiele im Prompt | Läufe 3466, 3467 |
| Leere Datenbankantwort | Ein GET ohne Treffer liefert genau 1 leeres Element am Erfolgsausgang | Lauf 3465 |
| Zeitzone | 20:28 UTC am 16.11.2026 ergibt `21:28` in Berlin (Winterzeit) | Lauf 3465 |
| Linienführung mit 3 neuen Knoten (Muster prüfen, Filter loggen, Antwort setzen) | Läufe positiv, aber im Editor laufen Verbindungen durch Knoten und aus dem Rahmen. Deshalb werden die 3 Knoten am 18.11.2026 nicht live gebaut. | Läufe 3463, 3464, Bildschirmfotos |

## 3 Bauschritte am Hauptworkflow

| Schritt | Inhalt | Test | Ergebnis | Version |
|---|---|---|---|---|
| S6a Schwärzung mit Titeln | Das Muster `NAME_MIT_ANREDE` erlaubt nach der Anrede beliebig viele Titel (Dr, Prof, mit oder ohne Punkt) | Hilfs-Workflow mit 22 Sätzen (Lauf 3469): 20 von 20 Urteilen wie erwartet, 2 Grenzsätze protokolliert (ein großgeschriebenes Wort nach einem Titel geht mit verloren). Hilfskopie mit gepinntem Agent (Lauf 3470) und Lauf am Hauptworkflow (Lauf 3471): kein Klartextname vor Agent und Modell | erledigt | `d47f6ba8` |
| S6 Eingangsprüfung | `filterText` (Text mit normalisierter Schreibweise, ohne unsichtbare Zeichen), `Eingang prüfen` liest den geschwärzten Text, neuer Prüf-Prompt `eingang-jailbreak v2` (Schwelle 0,7 unverändert) | 10 Chat-Läufe an der Hilfskopie (3472 bis 3481): Umgehung der Freigabe auch mit Zeilenumbruch oder unsichtbaren Zeichen erkannt (Werte 0,9 bis 1,0), 3 verneinte harmlose Sätze durchgelassen, leerer Auftrag landet im Ausfallsatz, Text mit Emoji bleibt unverändert. Danach Vollvergleich am Hauptworkflow: 0 Abweichungen | erledigt (Linienfall: ohne die 3 neuen Knoten) | `4d955a4c` |
| S6b Status `auskunft`, Fassung 1 | 5. Status im Antwortformat, Systemprompt v4.1, Ausgabeprüfung mit 3 neuen Funden (`AUSKUNFT_LEER`, `AUSKUNFT_MIT_ERZEUGUNG`, `AUSKUNFT_OHNE_BELEG`) | K06 3 von 3 bestanden (Läufe 3493, 3495, 3497), 7 Negativfälle wie erwartet (3484 bis 3490). Regression über 20 Läufe: 17 PASS, 3 FAIL (K02, K10, K11b), davon 2 rot (K02: Rückfrage mit leerem Feld, 2 von 2 Läufen, ohne die Änderung PASS; K11b: Zahlen-Klasse, nicht die Änderung) | zurückgebaut, Inhalt gleich `4d955a4c` (0 Abweichungen) | `6df90284`, danach `1573919d` |
| S8 Anordnung | 16 Knotenpositionen und 2 Kartengrößen, sonst keine Änderung | Vollvergleich: 0 Abweichungen außer den Positionen und Größen; Layout-Funde 41 vorher und nachher | erledigt, Bildschirmfoto offen | `c88047cc` |
| S12 Notizen und Beschreibung | Versions-Karte nennt v23, Workflow-Beschreibung nennt das Modell Claude Haiku 5.5 | Vollvergleich: 0 Abweichungen | erledigt | `25a7700b` |

Versionskette des Vormittags: `2f925369` (Ausgangsstand), `d47f6ba8` (S6a), `4d955a4c` (S6), `6df90284` (S6b Fassung 1), `1573919d` (Rückbau von Fassung 1, Inhalt gleich `4d955a4c`), `c88047cc` (S8), `25a7700b` (S12, v23).

## 4 Fassung 1b und Fassung 2 von S6b an der Hilfskopie

Nach dem Rückbau von Fassung 1 wurde der Status `auskunft` an einer Hilfskopie neu gefasst. Die 3 Fassungen heißen in allen Abgabedateien gleich: **Fassung 1** am Hauptworkflow (zurückgebaut), **Fassung 1b** und **Fassung 2** an der Hilfskopie, Fassung 2 seit dem Abend live.

- Fassung 1b (Punkt 9 enger gefasst): K06 und K02 je 3 von 3 bestanden. Die Folgenachricht nach einer Rückfrage ergab 1 von 2 (Lauf 3596: `AUSKUNFT_OHNE_BELEG`, der Agent rief das Markenwissen nicht erneut auf, der Nutzer sah den festen Sperrsatz).
- Regression an Fassung 1b über 20 Fälle (3552 bis 3588): 17 PASS, 2 FAIL (K03, Zahlen-Klasse; K10 wie am 17.11.2026), 1 nicht gemessen (K15, das Prüfmodell fiel aus, der Agent allein ist durch K15b gedeckt).
- Fassung 2 (Markenwissen auch bei schon bekanntem Wissen abrufen): K06 3 von 3, Folgenachricht 3 von 3, K02 zuerst 2 von 3 (Lauf 3616 mit leerem Rückfragefeld), Nachmessung 3 von 3, gesamt 5 von 6. Eine volle Regression an Fassung 2 lief erst am Live-Stand (Abschnitt 5).
- Stand: an der Hilfskopie grün für K06, K02 und die Folgenachricht. Am Abend in den Hauptworkflow übernommen (Abschnitt 5).

## 5 Übernahme von S6b Fassung 2 und Nachtest

| Schritt | Inhalt | Test | Ergebnis | Version |
|---|---|---|---|---|
| S6b Fassung 2 live | 1 Schreibzugriff mit 3 Änderungen um 19:51: Systemprompt v4.1 mit Punkt 9 ([Systemprompt v4.1](../prompts/20261118_System-Prompt-Redaktions-Agent_V4.1.md)), Prüfungen für `auskunft` in `Agent-Antwort prüfen`, `prompt_version` `redaktions-agent v4.1` | Vorher Vollvergleich Hauptworkflow gegen Ausgangsstand der Hilfskopie: 0 Abweichungen. Danach: die 3 Werte zeichengleich mit der getesteten Fassung 2, Vollvergleich vorher gegen nachher nur die 3 gewollten Stellen, Vollvergleich gegen die Hilfskopie 0 Abweichungen. Versionsverlauf ohne automatische Zwischenspeicherung | erledigt | `9e889d2f` |
| Nachtest | K08 als Startlauf, K06 3 Mal (neue Sitzung je Lauf), K01 dann K02, K01 dann K06, alle mit gepinnten Knoten mit Außenwirkung | Läufe 3633 bis 3645, je Lauf belegt: alle Pins wirksam, Ergebnis `success`, Fehler-Workflow 0 Läufe, keine neue Zeile in `k1_posts` | **8 von 8 bestanden** | `9e889d2f` |
| Anordnung Ersatzmodell | Der deaktivierte Ersatzknoten Nemotron lag seit v22 über dem Modellknoten des Agenten, Rahmen 01b deckte den Modellknoten zu. Erster Versuch (Knoten nebeneinander, Rahmen kleiner), dann eigener Kasten „Reserve“ unter dem Ablauf, zuletzt Titel gekürzt und leerer Rahmen ohne Standardtext | Vollvergleich je Schritt: nur Positionen, Größen und Notizen; Prüfung der Anordnung (Überlappungen, Linien) 41 auf 36 Funde, keiner neu | erledigt | `0ca29704`, `cf8bc169`, `c7fb20f3` |
| Regression am Live-Stand | 20 Fälle wie an Fassung 1b, gleiche Pins | Läufe 3647 bis 3677, alle `success`, Fehler-Workflow 0 Läufe | **19 PASS, 1 FAIL (K03)**; K10 und K15 jetzt PASS | `c7fb20f3` |
| S12b Notiztexte v23.1 | Karte ③ nennt Systemprompt v4.1, Versions-Karte mit Eintrag v23.1, Kommentare gekürzt | Vollvergleich: genau die 2 Notizen; Prüfung der Anordnung (Überlappungen, Linien) 36 auf 35 Funde | erledigt | `b04d44c3` |
| S12c Karte KI-Hinweis verschoben | Nur Lage und Breite der Notiz „Karte KI-Hinweis“ (nach rechts, schmaler), damit die Linie von „Ergebnis Ablage“ zu „Sitzung prüfen“ sie nicht kreuzt | Vollvergleich der Exporte: genau diese eine Notiz; Prüfung der Anordnung (Überlappungen, Linien) 35 auf 34 Funde | erledigt | `54dec01b` |

Einzelergebnisse stehen in der [Testtabelle W09T02](test-tabelle-w09t02.md), Abschnitte „B14 neu live“ und „Regression am Live-Stand“. `c7fb20f3`, `b04d44c3` und `54dec01b` sind an Parametern und Verbindungen der ausführbaren Knoten gleich `9e889d2f`; die Regression gilt deshalb für den Abgabestand.

Versionskette ab Abend: `25a7700b` (v23), `3d1560a5` (inhaltlich gleich `25a7700b`, wiederhergestellt nach einer ungewollten automatischen Zwischenspeicherung im Editor, die nur 3 Knotenpositionen verschoben hatte), `9e889d2f` (S6b Fassung 2), `0ca29704`, `cf8bc169`, `c7fb20f3` (Anordnung Ersatzmodell), `b04d44c3` (Notiztexte, v23.1), `54dec01b` (Karte KI-Hinweis verschoben, Abgabestand).

## 5b Text-Werkzeug v09: Zahlenverbot im Auftrag (18.11.2026 nachts)

| Schritt | Inhalt | Test | Ergebnis | Version |
|---|---|---|---|---|
| Ursache | Am echten Text aus der Regression (K03, „am ersten Tag“, „das halbe Team“) nachgestellt: `Paket prüfen` im Text-Werkzeug prüft Ziffern und Grund-Zahlwörter, aber keine Ordnungszahlen, kein „halb“, keine Dauerangaben und nicht, ob eine Angabe mit Zahl aus dem Briefing im Text steht. Mit dem unveränderten Code liefen K03, K04 und K07 durch | lokal mit dem Code des Knotens | belegt | Werkzeug 3 v08 |
| Bau an einer Kopie | Neuer Schritt `Zahlenverbot prüfen` vor `Paket prüfen` (greift nur bei Zahlenverbot im Auftrag), `Neufassung nötig?`, `Neufassung vorbereiten` (Korrekturabschnitt mit den Fundwörtern), `Text neu schreiben` (gleiches Modell, gleicher Zugang), `Zahlenfehler zurückgeben`; `Rückgabe bauen` summiert Tokens und Kosten beider Aufrufe | 23 lokale Fälle; Kopie mit festen Modellantworten, Läufe 3683 bis 3689 (K03, K07, K04, Positivfall, ohne Verbot, 2. Treffer) | alle wie erwartet | Kopie |
| Übernahme | 1 Schreibzugriff, danach Code und Notizen gleich den getesteten Dateien, `Paket prüfen` und `Prompt bauen` unverändert, keine Position eines vorhandenen Knotens verschoben, Prüfung der Anordnung (Überlappungen, Linien) gleich viele Funde wie vorher | Vollvergleich Export gegen n8n | erledigt, veröffentlicht 23:36 | Werkzeug 3 v09 `2ea20c9a` |
| Nachtest | K03, K04, K07, K11a, K11b am Hauptworkflow `54dec01b` mit den Pins der Regression; `Freigabe abwarten` gepinnt, kein Klick | Läufe 3690, 3695, 3700, 3704, 3706, alle `success`, Fehler-Workflow 0 Läufe | **K03, K04, K07 PASS**; K11b PASS mit belegtem sicherem Ausfall (Unterlauf 3707: Fehler statt Paket nach der Neufassung) | `54dec01b` |

Einzelergebnisse: [Testtabelle W09T02](test-tabelle-w09t02.md), Abschnitt „Nachtest nach Text-Werkzeug v09“. Der Hauptworkflow wurde dafür nicht verändert.

## 5c Text-Werkzeug v09.1: Pflichtangabe mit Einheit, nach der Kürzung (19.11.2026 vormittags)

| Schritt | Inhalt | Test | Ergebnis | Version |
|---|---|---|---|---|
| Ursache | Die Prüfung von v09 hatte eine Lücke: Die Pflichtangabe aus dem Briefing wurde nur als Zahl ohne Einheit geprüft und nach der Kürzung des Instagram-Texts nicht erneut. „10 Euro“ statt „10 Minuten“ oder eine Angabe erst hinter der Kürzungsgrenze kam durch | lokal mit dem Code des Knotens | belegt | Werkzeug 3 v09 |
| Bau an einer Kopie | `Zahlenverbot prüfen [Code]` prüft Zahl und Einheit zusammen und den Text nach der Kürzung (Kürzungsregeln aus `Paket prüfen` 1 zu 1 nachgebaut); `Neufassung vorbereiten [Code]` verlangt Zahl und Einheit zusammen und nennt dem Modell die Längengrenze, wenn die Angabe in der ersten Fassung dahinter stand | 6 Läufe an einer Kopie mit festen Testantworten (3711 bis 3716): Euro statt Minuten und Angabe hinter der Kürzungsgrenze je mit Neufassung, danach sauber; „Zehn Minuten“ und eine lange Fassung mit der Angabe vorn ohne Fund; zweimal Fehler statt Paket nach fehlerhafter Neufassung | alle wie erwartet; 45 von 45 lokale Tests | Kopie |
| Übernahme | 1 Schreibzugriff mit 3 Änderungen am Text-Werkzeug, `Paket prüfen` unverändert, 45 Knoten | Export, Prüfung der Anordnung (Überlappungen, Linien) gleich viele Funde wie vorher | veröffentlicht am 19.11.2026 | Werkzeug 3 v09.1 `042698d3` |

**Nicht gemessen:** ein voller Lauf über das Gesamtsystem mit v09.1 und das Verhalten des echten Gratismodells auf den neuen Korrekturabschnitt. Einzelergebnisse: [Testtabelle W09T02](test-tabelle-w09t02.md), Abschnitt „Text-Werkzeug v09.1“.

## 6 Endzustand

- Hauptworkflow `54dec01b` (v23.1), 92 Knoten, inaktiv, keine gespeicherten Pins.
- Werkzeug 3 Text schreiben v09.1 (`042698d3`, 45 Knoten, seit 19.11.2026 veröffentlicht; Notiz im Workflow: v10) mit der Prüfung auf das Zahlenverbot, die Pflichtangabe jetzt mit Einheit und nach der Kürzung geprüft; Vorstand v09 (`2ea20c9a`, 18.11.2026 23:36); Werkzeug 4 und 5 unverändert seit W09T01. Die abgegebenen Exporte liegen unter [workflows/abgaben/W09T02/](../workflows/abgaben/W09T02/README.md).
- Live: Titelmuster in der Schwärzung (S6a), `filterText` und neuer Prüf-Prompt `eingang-jailbreak v2` (S6), Status `auskunft` mit Systemprompt v4.1 (S6b Fassung 2, seit 18.11.2026 19:51), Anordnung Variante 4 (S8) mit Kasten „Reserve“ für das Ersatzmodell, Notiztexte und Beschreibung (S12, S12b), Lage einer Notiz (S12c).
- Nicht live: die 3 neuen Knoten der Muster-Prüfung (Platz im Workflow noch nicht entschieden).
- Kosten des Tages am bezahlten Modellzugang bis 11:01: 0,0374 $ (27 Läufe), die Gratismodelle trugen die Prüfungen.

## 7 Offen und Grenzen

- Bildschirmfotos der Bauschritte S8 und S12 fehlen.
- Klick-Tests (K18, Freigabe-Klick) und der Test der Freigabefrist stehen aus. Ebenso steht ein voller Lauf über das Gesamtsystem mit Text-Werkzeug v09.1 aus.
- Zahlen im Text (K03, K04, K07): mit Werkzeug 3 v09 behoben, im Nachtest PASS (Abschnitt 5b). Grenze: Feste Wendungen wie „erste Kältewelle“ kosten bei einem Zahlenverbot eine Neufassung und können mit Fehler statt Paket enden (K11b); die Neufassung lief an echten Modellaufrufen nur bei K04 und K11b.
- Messbar nicht belegt: der Antwortkörper des öffentlichen Chats und der Statuscode 401 ohne Zugang (nur mit echtem Aufruf messbar).
- Testreste: 9 wartende Beiträge `test-p2` (fällig am 19.11.2026), dazu 4 aus dem Nachtest nach Werkzeug 3 v09, und Sitzungen mit dem Präfix `kitest-w09t02-`; sie werden nach der Abgabe entfernt.
