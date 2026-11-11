-- Projekt 2 Redaktions-Agent: Erweiterung von k1_posts und Lese-Views
-- Voraussetzung: Tabellen k1_kunden und k1_posts aus Projekt 1.
-- Werkzeug 1 (Markenwissen) und Werkzeug 3 (Text) lesen das Markenprofil über die View k2_v_markenwissen,
-- Werkzeug 1 zusätzlich die frühen Posts über k2_v_fruehere_posts. Die Werkzeuge 4 und 5 lesen k1_kunden,
-- k2_pakete und k1_posts direkt; geschrieben wird nur in k2_pakete (Werkzeug 3 und 4), in Storage (Werkzeug 4)
-- und in k1_posts (Werkzeug 5).

-- 1) Spalte k1_posts.erzeugt_von (kommt aus Projekt 2, in Projekt 1 nicht vorhanden)
alter table k1_posts add column if not exists erzeugt_von text not null default 'p1_workflow';
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'k1_posts_erzeugt_von_check') then
    alter table k1_posts add constraint k1_posts_erzeugt_von_check check (erzeugt_von in ('p1_workflow', 'p2_agent'));
  end if;
end $$;

-- 2) Views, mit den Rechten des Aufrufers (security_invoker)
create or replace view k2_v_markenwissen with (security_invoker = true) as
select kuerzel, name, ton, zielgruppe, no_gos, cta_text, hashtags_fest
from k1_kunden k
where aktiv = true;

create or replace view k2_v_fruehere_posts with (security_invoker = true) as
select kuerzel, topic, source_type, status, rejection_reason, erzeugt_von, created_at
from (
  select k.kuerzel, p.topic, p.source_type, p.status, p.rejection_reason, p.erzeugt_von, p.created_at,
         row_number() over (partition by p.customer_id order by p.created_at desc) as nr
  from k1_posts p
  join k1_kunden k on k.id = p.customer_id
  where k.aktiv = true and p.status <> 'fehler'
) x
where nr <= 20;

-- 3) Rechte: nur der Dienstzugang liest die Views, anon und authenticated nicht
revoke all on k2_v_markenwissen from anon, authenticated;
revoke all on k2_v_fruehere_posts from anon, authenticated;
grant select on k2_v_markenwissen to service_role;
grant select on k2_v_fruehere_posts to service_role;
