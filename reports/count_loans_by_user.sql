--metadb:function count_loans_by_user

DROP FUNCTION IF EXISTS count_loans_by_user;

CREATE FUNCTION count_loans_by_user(
    start_date date DEFAULT '1000-01-01',
    end_date date DEFAULT '3000-01-01')
RETURNS TABLE(
    user_id uuid,
    username text,
    first_name text,
    last_name text,
    email text,
    patron_group text,
    loan_count bigint)
AS $$
SELECT 
    jsonb_extract_path_text(l.jsonb, 'userId')::uuid AS user_id,
    jsonb_extract_path_text(u.jsonb, 'username') AS username,
    jsonb_extract_path_text(u.jsonb, 'personal', 'firstName') AS first_name,
    jsonb_extract_path_text(u.jsonb, 'personal', 'lastName') AS last_name,
    jsonb_extract_path_text(u.jsonb, 'personal', 'email') AS email,
    jsonb_extract_path_text(u.jsonb, 'patronGroup') AS patron_group,
    count(*) AS loan_count
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
ORDER BY loan_count DESC
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
