--metadb:function count_loans_by_user

DROP FUNCTION IF EXISTS count_loans_by_user;

CREATE FUNCTION count_loans_by_user(
    start_date date DEFAULT '1000-01-01',
    end_date date DEFAULT '3000-01-01')
RETURNS TABLE(
    id_uzivatele uuid,
    "Uživatelské jméno" text,
    jmeno text,
    prijmeni text,
    email text,
    skupina_ctenaru text,
    pocet_vypujcek bigint)
AS $$
SELECT 
    jsonb_extract_path_text(l.jsonb, 'userId')::uuid AS id_uzivatele,
    jsonb_extract_path_text(u.jsonb, 'username') AS "Uživatelské jméno",
    jsonb_extract_path_text(u.jsonb, 'personal', 'firstName') AS jmeno,
    jsonb_extract_path_text(u.jsonb, 'personal', 'lastName') AS prijmeni,
    jsonb_extract_path_text(u.jsonb, 'personal', 'email') AS email,
    jsonb_extract_path_text(u.jsonb, 'patronGroup') AS skupina_ctenaru,
    count(*) AS pocet_vypujcek
FROM folio_circulation.loan l
LEFT JOIN folio_users.users u 
    ON jsonb_extract_path_text(l.jsonb, 'userId')::uuid = u.id
WHERE start_date <= (jsonb_extract_path_text(l.jsonb, 'loanDate')::timestamptz)::date 
  AND (jsonb_extract_path_text(l.jsonb, 'loanDate')::timestamptz)::date < end_date
GROUP BY 
    jsonb_extract_path_text(l.jsonb, 'userId'),
    jsonb_extract_path_text(u.jsonb, 'username'),
    jsonb_extract_path_text(u.jsonb, 'personal', 'firstName'),
    jsonb_extract_path_text(u.jsonb, 'personal', 'lastName'),
    jsonb_extract_path_text(u.jsonb, 'personal', 'email'),
    jsonb_extract_path_text(u.jsonb, 'patronGroup')
ORDER BY pocet_vypujcek DESC
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
