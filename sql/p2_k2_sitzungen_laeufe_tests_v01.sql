-- Projekt 2 Redaktions-Agent: Sitzungen der Chat-Seite, Laufprotokoll, Testfälle und Testergebnisse, Kosten-View
-- Stand 23.11.2026, abgeleitet aus dem Live-Schema der Datenbank (information_schema und pg_catalog, nur gelesen).
-- Spalten, Typen, Vorgaben, Prüfregeln, Schlüssel, Indizes und Trigger entsprechen dem Live-Stand, die
-- Tabellenkommentare sinngemäß.
-- Rechte: live hat service_role alle Tabellenrechte (Vorgabe von Supabase); diese Datei vergibt die 4 Rechte,
-- die die Workflows brauchen (select, insert, update, delete).
--
-- Voraussetzung: Tabellen k1_kunden und k1_posts aus Projekt 1 (sql/p1_k1_tabellen_v01.sql), danach sql/p2_k2_views_v01.sql und
-- sql/p2_k2_pakete_v01.sql. Diese Datei als Letztes ausführen.
--
-- Wer nutzt was (gelesen aus den Exporten in workflows/):
--   k2_sitzungen            Hauptworkflow, Knoten "Sitzung prüfen": merkt die Sitzung der Chat-Seite, damit der
--                           KI-Hinweis nur in der ersten Antwort einer Sitzung steht.
--   k2_agent_laeufe         Hauptworkflow ("Laufzeile anlegen", "Protokollzeile bauen") und Freigabe-Workflow
--                           (Fehlervermerk error_text im Fehlerweg): 1 Zeile je Lauf des Agenten. Die Spalten
--                           freigabe_status und agent_modell sind angelegt, aber leer (Stand 23.11.2026,
--                           veröffentlichter Stand v26.5.3).
--   k2_agent_testfaelle     Testfälle mit Erwartung vor dem Lauf. Kein Workflow schreibt oder liest sie; die
--   k2_agent_testergebnisse Testtabelle der Abgabe steht in docs/test-tabelle-w09t02.md. Beide Tabellen sind
--                           live angelegt und leer (gemessen 23.11.2026), sie gehören zum Schema, weil
--                           k2_agent_laeufe.testfall_id auf k2_agent_testfaelle verweist.
--   k2_v_kosten_tag         View für die Kosten je Tag aus k2_agent_laeufe, von keinem Workflow gelesen.
--
-- Rechte: Zeilensperre (RLS) an, keine Policies. anon und authenticated haben keinen Zugriff, die Workflows
-- arbeiten mit dem Dienstzugang (service_role) aus dem n8n-Credential "Supabase API".

-- 0) Hilfsfunktion für updated_at (ist im Projekt schon vorhanden, wenn Projekt 1 sie angelegt hat)
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path to ''
as $function$
begin
  new.updated_at := now();
  return new;
end;
$function$;

-- 1) Sitzungen der Chat-Seite
create table if not exists public.k2_sitzungen (
  session_id       text primary key check (char_length(session_id) >= 1 and char_length(session_id) <= 100),
  erste_antwort_am timestamptz not null default now()
);

alter table public.k2_sitzungen enable row level security;
revoke all on public.k2_sitzungen from anon, authenticated, public;
grant select, insert, update, delete on public.k2_sitzungen to service_role;

-- 2) Testfälle (muss vor k2_agent_laeufe stehen, wegen des Fremdschlüssels testfall_id)
create table if not exists public.k2_agent_testfaelle (
  id              uuid primary key default gen_random_uuid(),
  nr              text not null unique,
  art             text not null check (art = any (array['happy_path', 'grenzfall', 'fehler', 'adversarial'])),
  angriffsart     text check (angriffsart = any (array['prompt_injection', 'rollenumkehr', 'datenexfiltration', 'systemprompt', 'grenzfrage'])),
  eingang         text not null default 'chat' check (eingang = any (array['formular', 'telegram', 'chat', 'test'])),
  kunde_kuerzel   text not null,
  eingabe         text not null,
  quellenart      text check (quellenart = any (array['thema', 'artikel', 'video', 'sprache'])),
  erwartet        text not null,
  status_erwartet text not null check (status_erwartet = any (array['eingereicht', 'abgelehnt', 'rueckfrage', 'fehler', 'abbruch_vor_agent'])),
  tools_erwartet  text[] not null default '{}'::text[],
  tools_verboten  text[] not null default '{}'::text[],
  quelle_erwartet text not null check (quelle_erwartet = any (array['quelltext', 'recherche', 'markenwissen', 'quelltext_und_recherche', 'keine'])),
  active          boolean not null default true,
  sort_order      integer not null default 0,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint k2_agent_testfaelle_angriff_nur_adversarial check ((art = 'adversarial') = (angriffsart is not null))
);

comment on table public.k2_agent_testfaelle is 'Projekt 2: Testfaelle des Redaktions-Agenten (mind. 15, davon mind. 5 adversarial). Erwartung vor dem Lauf. active = false statt Loeschen.';

drop trigger if exists trg_k2_agent_testfaelle_updated_at on public.k2_agent_testfaelle;
create trigger trg_k2_agent_testfaelle_updated_at
  before update on public.k2_agent_testfaelle
  for each row execute function public.set_updated_at();

alter table public.k2_agent_testfaelle enable row level security;
revoke all on public.k2_agent_testfaelle from anon, authenticated, public;
grant select, insert, update, delete on public.k2_agent_testfaelle to service_role;

-- 3) Laufprotokoll des Agenten: 1 Zeile je Lauf, wird nicht überschrieben
create table if not exists public.k2_agent_laeufe (
  id                      uuid primary key default gen_random_uuid(),
  logged_at               timestamptz not null default now(),
  trace_id                text not null unique,
  execution_id            text,
  workflow_name           text not null,
  erzeugt_von             text not null default 'p2_agent' check (erzeugt_von = 'p2_agent'),
  eingang                 text check (eingang = any (array['formular', 'telegram', 'chat', 'test'])),
  customer_code           text,
  post_id                 uuid references public.k1_posts(id) on delete set null,
  testfall_id             uuid references public.k2_agent_testfaelle(id) on delete set null,
  prompt_version          text not null,
  agent_modell            text,
  agent_iterationen       integer check (agent_iterationen >= 0),
  agent_prompt_tokens     integer check (agent_prompt_tokens >= 0),
  agent_completion_tokens integer check (agent_completion_tokens >= 0),
  werkzeug_tokens         integer check (werkzeug_tokens >= 0),
  total_tokens            integer check (total_tokens >= 0),
  agent_cost_usd          numeric(12,6) check (agent_cost_usd >= 0),
  werkzeug_cost_usd       numeric(12,6) check (werkzeug_cost_usd >= 0),
  cost_usd                numeric(12,6) check (cost_usd >= 0),
  kosten_quelle           text check (kosten_quelle = any (array['usage_cost', 'geschaetzt', 'gratis'])),
  tools_ausgefuehrt       text[] not null default '{}'::text[],
  tool_aufrufe            jsonb not null default '[]'::jsonb,
  toolentscheidung        text,
  status                  text not null check (status = any (array['eingereicht', 'abgelehnt', 'rueckfrage', 'fehler', 'abbruch_vor_agent'])),
  freigabe_status         text check (freigabe_status = any (array['fertig', 'abgelehnt', 'freigabe_abgelaufen', 'nicht_noetig'])),
  ausgabe_pruefung        text check (ausgabe_pruefung = any (array['ok', 'fund'])),
  nachbesserung_runde     integer not null default 0 check (nachbesserung_runde >= 0 and nachbesserung_runde <= 2),
  duration_ms             integer check (duration_ms >= 0),
  generation_ms           integer check (generation_ms >= 0),
  error_text              text check (char_length(error_text) <= 300)
);

comment on table public.k2_agent_laeufe is 'Projekt 2: eine Zeile je Lauf des Redaktions-Agenten (Ereignis, nie ueberschreiben). Tokens und Kosten von Anfang an.';

create index if not exists idx_k2_agent_laeufe_kunde_zeit on public.k2_agent_laeufe (customer_code, logged_at desc);
create index if not exists idx_k2_agent_laeufe_post_id on public.k2_agent_laeufe (post_id);
create index if not exists idx_k2_agent_laeufe_testfall_id on public.k2_agent_laeufe (testfall_id);

alter table public.k2_agent_laeufe enable row level security;
revoke all on public.k2_agent_laeufe from anon, authenticated, public;
grant select, insert, update, delete on public.k2_agent_laeufe to service_role;

-- 4) Testergebnisse: 1 Ergebnis je Testlauf eines Falls, 4 Dimensionen von 1 bis 5
create table if not exists public.k2_agent_testergebnisse (
  id                  uuid primary key default gen_random_uuid(),
  testfall_id         uuid not null references public.k2_agent_testfaelle(id) on delete restrict,
  lauf_id             uuid references public.k2_agent_laeufe(id) on delete set null,
  system              text not null default 'p2_agent' check (system = any (array['p2_agent', 'p1_workflow'])),
  prompt_version      text not null,
  status_tatsaechlich text,
  tools_tatsaechlich  text[] not null default '{}'::text[],
  quelle_tatsaechlich text,
  tool_recall         numeric(4,3) check (tool_recall >= 0 and tool_recall <= 1),
  tool_praezision     numeric(4,3) check (tool_praezision >= 0 and tool_praezision <= 1),
  korrektheit         smallint check (korrektheit >= 1 and korrektheit <= 5),
  relevanz            smallint check (relevanz >= 1 and relevanz <= 5),
  vollstaendigkeit    smallint check (vollstaendigkeit >= 1 and vollstaendigkeit <= 5),
  sicherheit          smallint check (sicherheit >= 1 and sicherheit <= 5),
  bestanden           boolean,
  bewertet_von        text check (bewertet_von = any (array['mensch', 'judge'])),
  begruendung         text,
  total_tokens        integer check (total_tokens >= 0),
  cost_usd            numeric(12,6) check (cost_usd >= 0),
  created_at          timestamptz not null default now()
);

comment on table public.k2_agent_testergebnisse is 'Projekt 2: ein Ergebnis je Testlauf eines Falls. 4 Dimensionen, Tool-Recall und Tool-Praezision.';

create index if not exists idx_k2_agent_testergebnisse_lauf_id on public.k2_agent_testergebnisse (lauf_id);
create index if not exists idx_k2_agent_testergebnisse_testfall_id on public.k2_agent_testergebnisse (testfall_id);

alter table public.k2_agent_testergebnisse enable row level security;
revoke all on public.k2_agent_testergebnisse from anon, authenticated, public;
grant select, insert, update, delete on public.k2_agent_testergebnisse to service_role;

-- 5) View: Kosten je Tag aus dem Laufprotokoll, getrennt nach Testlauf und echtem Lauf
create or replace view public.k2_v_kosten_tag with (security_invoker = true) as
select ((l.logged_at at time zone 'Europe/Berlin'))::date as tag,
       (l.testfall_id is not null) as testlauf,
       count(*) as laeufe,
       sum(coalesce(l.total_tokens, 0)) as tokens,
       round(sum(coalesce(l.cost_usd, 0::numeric)), 6) as kosten_usd_tag,
       round(avg(coalesce(l.cost_usd, 0::numeric)), 6) as kosten_usd_je_lauf,
       round(sum(coalesce(l.cost_usd, 0::numeric)) * 22::numeric, 4) as hochrechnung_monat_usd_22_arbeitstage,
       count(*) filter (where l.kosten_quelle = 'geschaetzt') as davon_geschaetzt
from public.k2_agent_laeufe l
group by (((l.logged_at at time zone 'Europe/Berlin'))::date), (l.testfall_id is not null);

revoke all on public.k2_v_kosten_tag from anon, authenticated;
grant select on public.k2_v_kosten_tag to service_role;

-- Rückbau (nur bewusst, löscht alle Daten), umgekehrte Reihenfolge:
-- drop view if exists public.k2_v_kosten_tag;
-- drop table if exists public.k2_agent_testergebnisse;
-- drop table if exists public.k2_agent_laeufe;
-- drop table if exists public.k2_agent_testfaelle;
-- drop table if exists public.k2_sitzungen;
