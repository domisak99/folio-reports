--metadb:function count_loans_by_user

DROP FUNCTION IF EXISTS count_loans_by_user;

CREATE FUNCTION count_loans_by_user(
    start_date date DEFAULT '1000-01-01',
    end_date date DEFAULT '3000-01-01')
RETURNS TABLE(
    "ID uživatele" uuid,
    "Uživatelské jméno" text,
    "Jméno" text,
    "Příjmení" text,
    "Email" text,
    "Skupina čtenářů" text,
    "Počet výpůjček" bigint)
AS $$
SELECT 
    jsonb_extract_path_text(l.jsonb, 'userId')::uuid AS "ID uživatele",
    jsonb_extract_path_text(u.jsonb, 'username') AS "Uživatelské jméno",
    jsonb_extract_path_text(u.jsonb, 'personal', 'firstName') AS "Jméno",
    jsonb_extract_path_text(u.jsonb, 'personal', 'lastName') AS "Příjmení",
    jsonb_extract_path_text(u.jsonb, 'personal', 'email') AS "Email",
    jsonb_extract_path_text(u.jsonb, 'patronGroup') AS "Skupina čtenářů",
    count(*) AS "Počet výpůjček"
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
ORDER BY "Počet výpůjček" DESC
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
