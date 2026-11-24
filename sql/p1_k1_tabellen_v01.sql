-- Projekt 1 Content-Maschine K1: die 4 Tabellen, auf denen der Redaktions-Agent aufbaut
-- Stand 23.11.2026, abgeleitet aus dem Live-Schema der Datenbank (information_schema und pg_catalog, nur gelesen).
-- Spalten, Typen, Vorgaben, Prüfregeln, Schlüssel und Indizes entsprechen dem Live-Stand, die Tabellenkommentare
-- sinngemäß. Trigger gibt es auf diesen 4 Tabellen live keine. Die Datei enthält keine Daten und keine Schlüssel.
--
-- Reihenfolge: diese Datei zuerst, danach sql/p2_k2_views_v01.sql (ergänzt k1_posts um die Spalte erzeugt_von
-- und legt die Views an), sql/p2_k2_pakete_v01.sql und zuletzt sql/p2_k2_sitzungen_laeufe_tests_v01.sql.
-- Die Spalte k1_posts.erzeugt_von steht deshalb hier nicht, sie kommt aus Projekt 2.
--
-- Wer nutzt was im Redaktions-Agent (gelesen aus den Exporten in workflows/):
--   k1_kunden         Werkzeug 4 und 5 (lesen), dazu Werkzeug 1, 3 und 6 über die View k2_v_markenwissen.
--   k1_posts          Werkzeug 5 (Beitrag anlegen), Hauptworkflow (Ausgangsprüfung, Sperre), Freigabe-Workflow
--                     (Status nach der Entscheidung).
--   k1_einstellungen  Hauptworkflow und Werkzeug 4 (lesen): Einstellungen außerhalb der Knoten, zum Beispiel
--                     telegram_chat_id, telegram_freigabe_nutzer_id, cloudflare_account_id.
--   k1_laufprotokoll  Werkzeug 4 liest die letzten Aufbauten; geschrieben wird die Tabelle von Projekt 1.
--
-- Rechte: live haben anon und authenticated auf diesen 4 Tabellen noch die Standardrechte von Supabase, allein
-- die Zeilensperre (RLS an, keine Policies) hält sie von den Zeilen fern (gelesen am 23.11.2026). Diese Datei
-- nimmt anon und authenticated die Rechte wie bei den Tabellen aus Projekt 2 und vergibt dem Dienstzugang
-- (service_role) die 4 Rechte, die die Workflows brauchen (select, insert, update, delete). Über die
-- Datenschnittstelle von Supabase ändert das nichts, die Zeilensperre ohne Policies zeigt anon und authenticated
-- dort schon jetzt keine Zeile. In der Datenbank selbst ist es strenger, weil zum Beispiel TRUNCATE nicht unter
-- die Zeilensperre fällt.

-- 1) Kunden mit Branding-Profil
create table if not exists public.k1_kunden (
  id                uuid primary key default gen_random_uuid(),
  kuerzel           text not null unique,
  name              text not null,
  farbe_primaer     text,
  farbe_sekundaer   text,
  farbe_akzent      text,
  farbe_hintergrund text,
  farbe_text        text,
  schrift_titel     text,
  schrift_text      text,
  ton               text,
  zielgruppe        text,
  no_gos            text[] default '{}'::text[],
  cta_text          text,
  hashtags_fest     text[] default '{}'::text[],
  logo_url          text,
  aktiv             boolean not null default true,
  erstellt_am       timestamptz not null default now(),
  branding_pack     jsonb
);

comment on table public.k1_kunden is 'Projekt 1: Branding-Profil je Kunde. Geschrieben wird nur über n8n mit dem Dienstzugang.';
comment on column public.k1_kunden.branding_pack is 'Flaches Branding-Paket je Kunde (Logo, Schriften, Farben, Postformen, 3 Layouts je Plattform und Format).';

-- 2) Beiträge (ein Content-Paket je Lauf)
create table if not exists public.k1_posts (
  id                uuid primary key default gen_random_uuid(),
  customer_id       uuid references public.k1_kunden (id),
  source_type       text,
  source            text,
  topic             text,
  slides            jsonb,
  slide_urls        text[],
  single_image_url  text,
  caption_instagram text,
  linkedin_post     text,
  hashtags          text[],
  model             text,
  status            text not null default 'in_arbeit' check (status = any (array['in_arbeit', 'wartet_auf_freigabe', 'fertig', 'abgelehnt', 'nur_texte', 'freigabe_abgelaufen', 'fehler'])),
  rejection_reason  text,
  ai_generated      boolean not null default true,
  approved_by       text,
  execution_id      text,
  created_at        timestamptz not null default now(),
  decided_at        timestamptz
);

comment on table public.k1_posts is 'Projekt 1: ein Content-Paket je Lauf, die Quelle gekürzt auf 500 Zeichen. approved_by ist der Telegram-Nutzer der Freigabe (Beleg der menschlichen Prüfung, Art. 50 AI Act). Geschrieben wird nur über n8n mit dem Dienstzugang.';

create index if not exists idx_k1_posts_customer_created on public.k1_posts (customer_id, created_at desc);

-- 3) Einstellungen außerhalb der Knoten
create table if not exists public.k1_einstellungen (
  setting_key   text primary key,
  setting_value text,
  description   text,
  updated_at    timestamptz not null default now()
);

comment on table public.k1_einstellungen is 'Projekt 1: Einstellungszeilen außerhalb der Knoten, zum Beispiel telegram_chat_id, damit sie nicht im Workflow-Export steht.';

-- 4) Laufprotokoll von Projekt 1 (nur Metadaten, keine Quelltexte, keine Chat-ID)
create table if not exists public.k1_laufprotokoll (
  id                bigint generated always as identity primary key,
  logged_at         timestamptz not null default now(),
  workflow_name     text,
  execution_id      text,
  execution_mode    text,
  stage             text check (stage = any (array['nach_ki', 'ende', 'fehlerweg'])),
  status            text check (status = any (array['ok', 'fallback', 'fehler'])),
  duration_ms       integer,
  model             text,
  prompt_tokens     integer,
  completion_tokens integer,
  total_tokens      integer,
  customer_code     text,
  post_id           uuid,
  error_text        text check (char_length(error_text) <= 300),
  cost_usd          numeric,
  trace_id          text,
  prompt_version    text,
  generation_ms     integer
);

comment on table public.k1_laufprotokoll is 'Projekt 1: Protokoll je Stelle des Laufs. Nur Metadaten, keine Quelltexte, keine Chat-ID. execution_mode ist der Ausführungsmodus von n8n.';
comment on column public.k1_laufprotokoll.trace_id is 'Je Lauf eindeutig (k1-<execution_id>-<ms>), von Konfiguration und Startzeit bis Protokoll durchgereicht.';
comment on column public.k1_laufprotokoll.prompt_version is 'Prompt-Fassung des Laufs, zum Beispiel k1-p1.';
comment on column public.k1_laufprotokoll.generation_ms is 'Laufzeit vom Start bis zur fertigen Vorschau in ms, ohne Wartezeit auf die Freigabe.';

-- 5) Zeilensperre und Rechte
alter table public.k1_kunden enable row level security;
alter table public.k1_posts enable row level security;
alter table public.k1_einstellungen enable row level security;
alter table public.k1_laufprotokoll enable row level security;

revoke all on public.k1_kunden, public.k1_posts, public.k1_einstellungen, public.k1_laufprotokoll from anon, authenticated, public;
grant select, insert, update, delete on public.k1_kunden, public.k1_posts, public.k1_einstellungen, public.k1_laufprotokoll to service_role;

-- Rückbau (nur bewusst, löscht alle Daten, erst nach den Dateien aus Projekt 2):
-- drop table if exists public.k1_laufprotokoll, public.k1_einstellungen, public.k1_posts, public.k1_kunden;
