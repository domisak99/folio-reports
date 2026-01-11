--metadb:function count_loans

DROP FUNCTION IF EXISTS count_loans;

CREATE FUNCTION count_loans(
    start_date date DEFAULT '1000-01-01',
    end_date date DEFAULT '3000-01-01')
RETURNS TABLE(
    item_id uuid,
    loan_count bigint)
AS $$
SELECT jsonb_extract_path_text(jsonb, 'itemId')::uuid AS item_id,
       count(*) AS loan_count
    FROM folio_circulation.loan
    WHERE start_date <= (jsonb_extract_path_text(jsonb, 'loanDate')::timestamptz)::date 
      AND (jsonb_extract_path_text(jsonb, 'loanDate')::timestamptz)::date < end_date
    GROUP BY jsonb_extract_path_text(jsonb, 'itemId')
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
