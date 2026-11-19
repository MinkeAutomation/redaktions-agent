# Abgabestand W09T02 (Evaluation und Qualitätssicherung), Endstand 18.11.2026

Diese 4 Exporte sind die Workflow-Dateien der Abgabe W09T02, so wie sie abgegeben wurden: Hauptworkflow v23.1 mit Systemprompt v4.1 und Text-Sub v09.1 mit der Prüfung auf das Zahlenverbot (v09.1 prüft die Pflichtangabe mit Einheit und nach der Kürzung; die Versionsnotiz im Workflow nennt ihn „v10“). Testfälle und Messungen stehen in der [Testtabelle W09T02](../../../docs/test-tabelle-w09t02.md) und im [Bau-Protokoll W09T02](../../../docs/w09t02-bau-protokoll.md).

Die Versions-Karte im Hauptworkflow schreibt „19 PASS, 1 Grenzfall“. Gemeint ist 19 PASS und 1 FAIL (K03), siehe [Testtabelle W09T02](../../../docs/test-tabelle-w09t02.md).

| Datei | Workflow | Version | n8n-versionId |
|---|---|---|---|
| `AGT-2606_W09T02_Redaktions-Agent_Hauptworkflow_2026-11-18_v23.1.json` | Hauptworkflow Redaktions-Agent | v23.1 | `54dec01b` |
| `AGT-2606_W09T02_Redaktions-Agent_Text-Sub_2026-11-18_v09.json` | Werkzeug 3 Text schreiben | v09.1 (Dateiname trägt weiter v09) | `042698d3` |
| `AGT-2606_W09T02_Redaktions-Agent_Bilder-Sub_2026-11-17_v01.json` | Werkzeug 4 Bilder gestalten | Stand 17.11.2026 mit KI-Kennzeichnung, unverändert seit W09T01 | `4d00acc0` |
| `AGT-2606_W09T02_Redaktions-Agent_Einreich-Sub_2026-11-17_v02.json` | Werkzeug 5 Zur Freigabe einreichen | v02, unverändert seit W09T01 | `458a5989` |

**Bereinigung.** Zugangskennungen (`CREDENTIAL_ID`), die Projektadresse der Datenbank (`SUPABASE_URL`), die Adresse der n8n-Instanz (`DEINE-N8N-INSTANZ`) und der Name eines Testkunden (`KUNDE_B`) sind schon in der abgegebenen Datei Platzhalter, das Feld `meta` ist leer, es gibt keine Pins. Gegenüber der abgegebenen Datei sind hier nur ersetzt: Workflow-, Tag-, Ordner- und Webhook-Kennungen der Instanz durch `WORKFLOW_ID_…`, `TAG_ID_…`, `FOLDER_ID_PROJEKTORDNER`, `ERROR_WORKFLOW_ID` und `WEBHOOK_ID` (im Hauptworkflow auch in der Sperrliste von `Agent-Antwort prüfen`), der Name des n8n-Ordners durch `Projektordner` und der Host des Render-Dienstes im Bilder-Sub durch `GOTENBERG_HOST`. Diese Ersetzungen gelten nur für den Export, die laufende Instanz bleibt unverändert; sonst sind Code, Notizen, Positionen und Verbindungen gleich. Zum Nachbauen dienen die Live-Exporte und die Anleitung in der [README](../../../README.md).

Früherer Stand: [Abgabestand W09T01](../W09T01/README.md), geltende Stände unter `workflows/`, alle Versionen in [versionen.md](../../../versionen.md).

Bekannte Lücke (Prüfung 19.11.2026): Das Wörterbuch des Zahlenverbots kennt nur eine Auswahl ausgeschriebener Zahlwörter. Es fehlen unter anderem dreizehn, vierzehn, sechzehn bis neunzehn, einundzwanzig, sechzig bis neunzig und tausend; belegt erkannt werden zum Beispiel zehn und fünfzehn. Steht eine Pflichtangabe wie „13 Minuten“ im Briefing und schreibt das Modell sie mit einem fehlenden Zahlwort aus („dreizehn Minuten“), meldet die Prüfung sie als fehlend; wiederholt die Neufassung denselben Wortlaut, endet der Lauf mit einem Fehler statt eines Pakets. Angaben in Ziffern sind nicht betroffen. Die Korrektur folgt in der nächsten Fassung des Text-Werkzeugs.
