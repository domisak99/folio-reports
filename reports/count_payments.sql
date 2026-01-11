--metadb:function count_payments

DROP FUNCTION IF EXISTS count_payments;

CREATE FUNCTION count_payments(
    start_date date DEFAULT '1000-01-01',
    end_date date DEFAULT '3000-01-01')
RETURNS TABLE(
    user_id uuid,
    payment_count bigint,
    total_amount numeric(19,2))
AS $$
SELECT user_id,
       count(*) AS payment_count,
       sum(amount_action) AS total_amount
    FROM folio_feesfines.feefineactions__t
    WHERE type_action = 'Payment'
      AND start_date <= date_action AND date_action < end_date
    GROUP BY user_id
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
