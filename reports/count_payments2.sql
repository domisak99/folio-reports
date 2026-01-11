--metadb:function count_payments2

DROP FUNCTION IF EXISTS count_payments2;

CREATE FUNCTION count_payments(
    start_date date DEFAULT '1000-01-01',
    end_date date DEFAULT '3000-01-01')
RETURNS TABLE(
    user_id uuid,
    payment_count bigint,
    total_amount numeric(19,2))
AS $$
SELECT jsonb_extract_path_text(jsonb, 'userId')::uuid AS user_id,
       count(*) AS payment_count,
       sum(jsonb_extract_path_text(jsonb, 'amountAction')::numeric) AS total_amount
    FROM folio_feesfines.feefineactions
    WHERE jsonb_extract_path_text(jsonb, 'typeAction') = 'Payment'
      AND start_date <= (jsonb_extract_path_text(jsonb, 'dateAction')::timestamptz)::date 
      AND (jsonb_extract_path_text(jsonb, 'dateAction')::timestamptz)::date < end_date
    GROUP BY jsonb_extract_path_text(jsonb, 'userId')
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
