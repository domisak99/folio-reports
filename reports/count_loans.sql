--metadb:function count_loans

DROP FUNCTION IF EXISTS count_loans;

CREATE FUNCTION count_loans(
    start_date date DEFAULT '1000-01-01',
    end_date date DEFAULT '3000-01-01')
RETURNS TABLE(
    itemId uuid,
    loan_count bigint)
AS $$
SELECT itemId::uuid,
       count(*) AS loan_count
    FROM folio_circulation.loan__t
    WHERE start_date <= loan_date::date AND loan_date::date < end_date
    GROUP BY itemId
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
