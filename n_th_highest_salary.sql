CREATE OR REPLACE FUNCTION NthHighestSalary (N int)
RETURNS TABLE (Salary int) LANGUAGE plpgsql AS $$
DECLARE
    nth_highest integer;

BEGIN
    CREATE TEMPORARY TABLE tmp_salaries_in_order
    (rank integer, salary integer) ON COMMIT DROP;

    INSERT INTO tmp_salaries_in_order SELECT
    DENSE_RANK() OVER (ORDER BY dist_sals.distinct_sal DESC),
    dist_sals.distinct_sal FROM
    (SELECT DISTINCT(e.salary) AS distinct_sal
    FROM public.employee AS e
    ORDER BY distinct_sal DESC) AS dist_sals;

    SELECT tmp_salaries_in_order.salary INTO nth_highest
    FROM tmp_salaries_in_order
    WHERE rank = N;

    RETURN QUERY
    SELECT nth_highest AS nth_highest_salary;

END;$$;