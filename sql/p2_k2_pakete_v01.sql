-- Projekt 2 Redaktions-Agent: Paket-Speicher (Entscheidung 11.11.2026: Speichern je Paket)
-- Zweck: Werkzeug 3 (Text schreiben) speichert das fertige Text-Paket unter einer paket_id, Werkzeug 4 (Bilder)
-- und Werkzeug 5 (Einreichen) lesen es per paket_id. Der Agent reicht nur die paket_id weiter und kopiert kein JSON.
-- Warum eigene Tabelle und kein Feld in k1_posts: ein Beitrag (k1_posts) entsteht erst beim Einreichen (Werkzeug 5);
-- das Paket ist ein Zwischenstand je Lauf, Projekt 1 und das Dashboard von Projekt 1 bleiben unberuehrt.
-- Anlegen nur Werkzeug 3, die Spalte bilder setzt nur Werkzeug 4, lesen Werkzeug 4 und 5 (Service-Key aus dem Credential), anon und authenticated ohne Zugriff.

create table if not exists public.k2_pakete (
  paket_id    text primary key check (paket_id ~ '^paket-[A-Za-z0-9_-]{3,100}$'),
  kuerzel     text not null check (kuerzel ~ '^[a-z0-9-]{2,40}$'),
  trace_id    text not null check (char_length(trace_id) between 1 and 60),
  paket       jsonb not null check (jsonb_typeof(paket) = 'object'),
  modell      text,
  erstellt_am timestamptz not null default now()
);

comment on table public.k2_pakete is 'Projekt 2: Text-Paket je paket_id (Zwischenstand zwischen Werkzeug 3, 4 und 5). Eine Zeile je Paket, wird nie ueberschrieben.';
comment on column public.k2_pakete.paket_id is 'paket-<trace_id>-<Zeitmarke>, von Werkzeug 3 vergeben.';
comment on column public.k2_pakete.kuerzel is 'Kundenkennung, vom Hauptworkflow fest vorgegeben; Werkzeug 4 und 5 lesen nur Pakete des eigenen Kunden.';

create index if not exists idx_k2_pakete_kunde_zeit on public.k2_pakete (kuerzel, erstellt_am desc);

alter table public.k2_pakete enable row level security;
revoke all on public.k2_pakete from anon, authenticated, public;
grant select, insert on public.k2_pakete to service_role;

-- Rueckbau (nur nach Ansage): drop table if exists public.k2_pakete;

-- ---------------------------------------------------------------------------------------------
-- v02 (11.11.2026): Spalte bilder. Werkzeug 4 (Bilder) vermerkt hier die erzeugten Bilder,
-- Werkzeug 5 (Einreichen) liest sie von hier, der Agent reicht nur die paket_id weiter.
-- Angewendet als Migration p2_k2_pakete_v02_bilder.
alter table public.k2_pakete add column if not exists bilder jsonb check (bilder is null or jsonb_typeof(bilder) = 'object');
comment on column public.k2_pakete.bilder is 'Von Werkzeug 4 (Bilder) gesetzt: {pfade: [Storage-Pfade ohne Bucket], quelle: pixabay|flux|farbverlauf, ki_bild: bool, hinweis: text}. Werkzeug 5 liest die Bilder von hier.';
grant update (bilder) on public.k2_pakete to service_role;
