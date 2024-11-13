CREATE OR REPLACE FUNCTION public.counter (list int[])
RETURNS TABLE (value int, frequency int)
LANGUAGE plpgsql AS $$
    DECLARE
        element int;
    BEGIN
        CREATE TEMPORARY TABLE tmp_table_func_counter (value int, frequency int) ON COMMIT DROP;
        FOREACH element IN ARRAY list LOOP
            IF element =
                    (SELECT tmp_table_func_counter.value
                    FROM tmp_table_func_counter
                    WHERE tmp_table_func_counter.value = element)
                THEN
                UPDATE tmp_table_func_counter
                SET frequency = tmp_table_func_counter.frequency + 1
                WHERE tmp_table_func_counter.value = element;
            ELSE
                INSERT INTO tmp_table_func_counter (value, frequency)
                VALUES (element, 1);
            END IF;
        END LOOP;
        RETURN QUERY SELECT * FROM tmp_table_func_counter;
    END;
$$;



SELECT * FROM public.counter(ARRAY[1, 7, 0, 3, 2, 1, 3, 7, 7]);
