------------------------------------------------------------------------------------------------------------------------
-- nums - массив, target - integer.
-- Для временного хранения данных используется jsonb.
-- Возврат в виде массива.
------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.twoSum
(nums int[], target int)
RETURNS RECORD
LANGUAGE plpgsql AS $$

    DECLARE
        curr_value int;
        difference int;
        complement int;
        ind int;
        answer record;

    BEGIN

        ind := 1;

	    -- Declaring temporary table
	    CREATE TEMPORARY TABLE IF NOT EXISTS temp_hash_map (
            -- column    -- data type    -- constraints
            key          int             PRIMARY KEY,
            value        int);

        FOREACH curr_value IN ARRAY nums LOOP
            difference := target - curr_value;
            SELECT value INTO complement FROM temp_hash_map WHERE key = difference;
            IF (complement IS NULL) THEN
                INSERT INTO temp_hash_map (key, value) VALUES (curr_value, ind);
            ELSE
                EXIT;
            END IF;
            ind := ind + 1;
        END LOOP;

        DROP TABLE IF EXISTS temp_hash_map;

        CREATE TEMPORARY TABLE temp_yui (a int, b int);
        INSERT INTO temp_yui(a, b) VALUES (complement, ind);
        SELECT * INTO answer FROM temp_yui;
        DROP TABLE temp_yui;
        RETURN answer;

    END;$$;
------------------------------------------------------------------------------------------------------------------------