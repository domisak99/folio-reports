--metadb:function count_payments2

DROP FUNCTION IF EXISTS count_payments2;

CREATE FUNCTION count_payments2(
    start_date date DEFAULT '1000-01-01',
    end_date date DEFAULT '3000-01-01')
RETURNS TABLE(
    "Jméno" text,
    "Příjmení" text,
    "Počet plateb" bigint,
    "Celková částka" numeric(19,2))
AS $$
SELECT 
    jsonb_extract_path_text(u.jsonb, 'personal', 'firstName') AS "Jméno",
    jsonb_extract_path_text(u.jsonb, 'personal', 'lastName') AS "Příjmení",
    count(*) AS "Počet plateb",
    sum(jsonb_extract_path_text(f.jsonb, 'amountAction')::numeric) AS "Celková částka"
FROM folio_feesfines.feefineactions f
LEFT JOIN folio_users.users u
    ON jsonb_extract_path_text(f.jsonb, 'userId')::uuid = u.id
WHERE jsonb_extract_path_text(f.jsonb, 'typeAction') = 'Payment'
  AND start_date <= (jsonb_extract_path_text(f.jsonb, 'dateAction')::timestamptz)::date 
  AND (jsonb_extract_path_text(f.jsonb, 'dateAction')::timestamptz)::date < end_date
GROUP BY 
    jsonb_extract_path_text(u.jsonb, 'personal', 'firstName'),
    jsonb_extract_path_text(u.jsonb, 'personal', 'lastName')
ORDER BY "Celková částka" DESC
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
