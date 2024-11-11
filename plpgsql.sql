------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

CREATE EXTENSION pldbgapi;  -- Отладчик для функций в pgAdmin 4

DROP FUNCTION IF EXISTS public.foo; -- Удаление функции из схемы public

CREATE OR REPLACE FUNCTION public.foo  -- Объявление функции в схеме public
(numbers int[], message text DEFAULT 'text', flag bool DEFAULT NULL)  -- перечисление аргументов
RETURNS text LANGUAGE plpgsql AS  -- тип возвращаемого значения text
$$
    DECLARE  -- Блок декларирования переменных которые будут использоваться в коде
        pointer1 int := 0;
        pointer2 text;
        hash_map jsonb := '{"name": "Sergey"}':: jsonb;
    BEGIN
        CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table (a int, b text);  -- Команда 1
        DROP TABLE IF EXISTS temporary_table;  -- Команда 2
        return '123' || to_char(CURRENT_TIMESTAMP, 'ddmmyy');  -- Возврат значения из функции
    END;
$$;
SELECT public.foo(numbers := ARRAY[1,2,3,4], message := 'Message', flag := false);  -- Вызов функции

-- Вот эта запись с дефолтным значением массива строк вроде работает.
CREATE OR REPLACE FUNCTION public.asd (words text[] default '{"123", "456"}')
RETURNS INTEGER LANGUAGE plpgsql AS
$$
BEGIN
	CREATE TEMPORARY TABLE kia(a int, c text);
    DROP TABLE kia;
	RETURN 10;
END;
$$;

-- Дефолтное значение для массива чисел
CREATE OR REPLACE FUNCTION public.asd (words int[] default array[1, 2, 3])
RETURNS INTEGER LANGUAGE plpgsql AS
$$ BEGIN RETURN 10; END; $$;

SELECT public.asd(ARRAY[1,2,3,4,5,6]);

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_users_count()  -- Также функцию можно сделать на языке SQL
RETURNS integer LANGUAGE SQL AS
$$ SELECT COUNT(*) FROM table_name $$;

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Функция, возвращающая void ничего не возвращает
-- Она работает точно так же как процедура, но только он функция

CREATE OR REPLACE FUNCTION add_workout_data
    (p_workout_id integer, p_heart_rate integer, p_distance numeric)
RETURNS void
LANGUAGE plpgsql
AS $$
    BEGIN
        INSERT INTO physiological_indicators(workout_id, date_time, heart_rate)
        VALUES (p_workout_id, current_timestamp, p_heart_rate);

        INSERT INTO distances(workout_id, date_time, distance)
        VALUES (p_workout_id, current_timestamp, p_distance);
    END;
$$;

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Если надо вызвать процедуру внутри блока кода функции, следует использовать ключевое слово PERFORM

CREATE OR REPLACE PROCEDURE test()
LANGUAGE plpgsql
AS $$
    BEGIN
        PERFORM add_workout_data(1, 130, 100.1);
    END;
$$;

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Также SQL-функции умеют возвращать таблицы для этого надо написать RETURNS TABLE
CREATE OR REPLACE FUNCTION get_workout_distances(p_workout_id integer)
RETURNS TABLE (datetime timestamp, distance numeric)
LANGUAGE SQL
AS $$
    SELECT d.date_time, d.distance FROM distances d
    WHERE workout_id = p_workout_id;
$$;

SELECT * FROM get_workout_distances(1001); -- Чтобы получить таблицу после вызова функции, используйте FROM


--  PL/pgSQL функции могут возвращать QUERY (Выражение RETURN QUERY работает немного не так, как обычный RETURN
--  в функциях — он не прекращает немедленно выполнение функции, и после него могут быть выполнены другие команды.

CREATE OR REPLACE FUNCTION get_workout_distances(p_workout_id integer)
RETURNS TABLE (datetime timestamp, distance numeric)
LANGUAGE plpgsql
AS $$
    BEGIN
        RETURN QUERY
        SELECT d.date_time, d.distance FROM distances d
        WHERE workout_id = p_workout_id;
    END;
$$;

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------