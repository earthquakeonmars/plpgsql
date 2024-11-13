------------------------------------------------------------------------------------------------------------------------
/*
nums - массив, target - integer,
для временного хранения данных используется таблица
Возврат в виде массива
*/
------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.twoSum
(nums int[], target int)
RETURNS int[] 
LANGUAGE plpgsql AS $$

    DECLARE
        i int;
        nums_length int;
        curr_value int;
        difference int;
        complement int;
        answer int[];

    BEGIN
	    -- Assigning values
	    i := 1;
	    SELECT ARRAY_LENGTH(nums, 1) INTO nums_length;
	    answer := '{}'::integer[];

	    -- Declaring temporary table
	    CREATE TEMPORARY TABLE IF NOT EXISTS temp_hash_map (
            -- column    -- data type    -- constraints
            key          int             PRIMARY KEY,
            value        int);

        WHILE i <= nums_length LOOP
            curr_value := nums[i];
            difference := target - curr_value;
            SELECT value INTO complement FROM temp_hash_map WHERE key = difference;
            IF (complement IS NULL) THEN
                INSERT INTO temp_hash_map (key, value) VALUES
                (curr_value, i);
            ELSE
                answer := ARRAY[complement, i];
                EXIT;
            END IF;
            i := i + 1;
        END LOOP;

        DROP TABLE IF EXISTS temp_hash_map;
        RETURN answer;

    END;$$;
------------------------------------------------------------------------------------------------------------------------

