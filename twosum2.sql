------------------------------------------------------------------------------------------------------------------------
/*
nums - массив, target - integer,
для временного хранения данных используется jsonb
Возврат в виде массива
*/
------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.twoSum
(nums int[], target int)
RETURNS int[] 
LANGUAGE plpgsql AS $$

    DECLARE
        -- TODO добавить переменные

    BEGIN
        FOREACH curr_value IN ARRAY nums LOOP
            difference := target - curr_value;
            IF (hash_map ? difference) THEN
                second_position := 
                answer := ARRAY[, curr_position];
                EXIT;
            ELSE
                hash_map := hash_map || '{curr_value: curr_position}'::jsonb; 
            END IF;
        END LOOP;
    END;$$;
------------------------------------------------------------------------------------------------------------------------

SELECT {1: 2}:: JSONB;