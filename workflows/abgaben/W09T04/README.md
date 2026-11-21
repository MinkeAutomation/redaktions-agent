# Abgabestand W09T04 (Optimierung und Feature Freeze), Endstand 21.11.2026

Diese 5 Exporte gehören zur Abgabe W09T04: der Hauptworkflow im Fix-Stand und die Werkzeuge, die bis zum Feature Freeze neu gebaut oder geändert wurden. Kosten, Token, Laufzeit, MUSS-Kriterien und die Fehlerfälle stehen in der [Tages-Doku W9 Tag 4](../../../docs/w09t04.html). Der Hauptworkflow ist derselbe Stand wie im [Abgabestand W09T03](../W09T03/README.md).

| Datei | Workflow | Version | n8n-versionId |
|---|---|---|---|
| `AGT-2606_W09T04_Redaktions-Agent_Hauptworkflow_2026-11-21_v26.5.3.json` | Hauptworkflow Redaktions-Agent | v26.5.3, Systemprompt V4.4, Aufrufgrenze 14, veröffentlicht 21.11.2026 14:03 | `c9dba438` |
| `AGT-2606_W09T04_Redaktions-Agent_Text-Sub_2026-11-20_v09.3.json` | Werkzeug 3 Text schreiben | v09.3 (Absatzschutz, Kürzung nur in ganzen Sätzen, Neufassung bei Ziffern), veröffentlicht 21.11.2026 14:03 | `f1d7aecf` |
| `AGT-2606_W09T04_Redaktions-Agent_Qualitaet-pruefen-Sub_2026-11-19_v05.1.json` | Werkzeug 6 Qualität prüfen | v05.1 (3 Versuche am Prüfmodell und am Ersatzmodell) | `247c549f` |
| `AGT-2606_W09T04_Redaktions-Agent_Bilder-Sub_2026-11-19_v05.json` | Werkzeug 4 Bilder gestalten | v05 (dunkles Layout aus Projekt 1, Layout 4, Pixabay-Foto auf dem Einzelbild, Rückgabe mit Ergebnis oder Fehler), veröffentlicht 19.11.2026 | `1f546c08` |
| `AGT-2606_W09T04_Redaktions-Agent_Einreich-Sub_2026-11-19_v03.json` | Werkzeug 5 Zur Freigabe einreichen | v03 (Folienzahl aus der Bildliste, 5 bis 10 Folien) | `22456237` |

Im Feld `activeVersionId` der Exporte von Werkzeug 4 und 6 steht noch die vorherige Version (`3a06ea23`, `dbb49b76`), beim Text-Werkzeug `13643ae5`: Die Exporte wurden vor dem Veröffentlichen gezogen. Veröffentlicht sind die Stände der Spalte n8n-versionId.

**Bereinigung.** Ersetzt sind wie im [Abgabestand W09T03](../W09T03/README.md) Zugangskennungen, Adressen von Datenbank und n8n-Instanz, Workflow-, Tag-, Ordner- und Webhook-Kennungen, der Name eines Testkunden und im Bilder-Werkzeug der Host des Render-Dienstes (`GOTENBERG_HOST`). In Code-Kommentaren und Notizen stehen noch einzelne Verweise auf interne Prüfrunden (etwa „Runde 2“); sie werden mit der Reparatur bis Mo 23.11.2026 bereinigt, der Code selbst ist unverändert. Interne Regel-, Fehler- und Entscheidungskennungen des Baus (Regelnummern, Fehlerspeicher-Nummern wie F-241) stehen noch in einzelnen Notizen und Kommentaren, und die Statusnotizen nennen teils noch den Entwurfsstand vor dem Veröffentlichen; beides wird mit der Fehlerbehebung bis Mo 23.11.2026 bereinigt. Knoten, Verbindungen und Positionen sind gegenüber dem Export der Instanz gleich (Blatt-für-Blatt-Vergleich, 0 Abweichungen außer den Ersetzungen).

Bekannte Lücke: Am veröffentlichten Stand liefen 2 volle Läufe über die Chat-Seite (4056, 4064), dazu 1 Lauf im Editor kurz vor dem Veröffentlichen (4047), nicht die 20 Fälle der Regression. Die Regression ist bis zum Freeze am 23.11.2026 geplant. Die letzte Regression über 20 Fälle lief am 18.11.2026 an v23.1 (19 bestanden, K03 nicht bestanden), siehe [Testtabelle W09T02](../../../docs/test-tabelle-w09t02.md).

Früherer Stand: [Abgabestand W09T02](../W09T02/README.md), geltende Stände unter `workflows/`, alle Versionen in [versionen.md](../../../versionen.md).
