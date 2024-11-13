------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
ALTER SYSTEM SET shared_preload_libraries = 'plugin_debugger';  -- добавление отладчика в систему
CREATE EXTENSION pldbgapi;  -- Отладчик для функций в pgAdmin 4

DROP FUNCTION IF EXISTS public.foo; -- Удаление функции из схемы public

--Если у какого-то параметра есть значение по умолчанию, у всех параметров,
-- расположенных в перечне параметров за ним, также должны быть значения по умолчанию.
CREATE OR REPLACE FUNCTION public.foo  -- Объявление функции в схеме public
(numbers int[], message text DEFAULT 'text', flag bool DEFAULT NULL)  -- перечисление аргументов
RETURNS text LANGUAGE plpgsql AS  -- тип возвращаемого значения text
$$
    DECLARE  -- Блок декларирования переменных которые будут использоваться в коде
        pointer1 int := 0; -- Можно присвоить значение по умолчанию
        pointer2 text;
        hash_map jsonb := '{"name": "Sergey"}':: jsonb;
    BEGIN
        CREATE TEMPORARY TABLE IF NOT EXISTS temporary_table (a int, b text);  -- Команда 1
        DROP TABLE IF EXISTS temporary_table;  -- Команда 2
        SELECT pg_typeof((SELECT 10.5));  -- Можно узнать тип переменных таким образом
        CALL add_distance_to_user_groups();  -- Можно позвать процедуру, написанную на SQL
        return '123' || to_char(CURRENT_TIMESTAMP, 'ddmmyy');  -- Возврат значения из функции
    END;
$$;
SELECT public.foo(numbers := ARRAY[1,2,3,4], message := 'Message', flag := false);  -- Вызов функции
SELECT public.foo(numbers => ARRAY[1,2,3,4], message => 'Message', flag => false);  -- Вызов функции с оператором =>

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

-- Сохранение переменной в значение осуществляется с помощью конструкции:
SELECT имя колонки или вычисляемое выражение
INTO имя переменной
FROM имя таблицы
WHERE ...
-- Если результат запроса SELECT окажется пустым, в переменную запишется NULL.

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Уже рассчитанные переменные вычисляются так:
-- Рассчитываем полную стоимость подписки
    _total_price := p_weeks_count * _price_per_week * (1 - _discount/100);

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Обработка исключений
-- DEBUG — отладка.
-- LOG — логирование.
-- INFO — дополнительная информация.
-- NOTICE — значимое сообщение.
-- WARNING — предупреждение.
-- EXCEPTION — исключение.

BEGIN
    -- Основной код
EXCEPTION
    WHEN Условие THEN
        Код обработки исключения  -- https://postgrespro.ru/docs/postgrespro/15/errcodes-appendix
                                  -- Также в качестве условия можно использовать слово others.
END;

CREATE OR REPLACE FUNCTION average_speed_kmh
    (p_distance numeric, p_dt_begin timestamp, p_dt_end timestamp)
RETURNS numeric
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN p_distance * 0.06 / extract(minutes from (p_dt_end - p_dt_begin));
EXCEPTION
    WHEN division_by_zero THEN
        RAISE NOTICE 'Ошибка выполнения: %', SQLERRM;  -- SQLERRM — это системный текст возникшей ошибки, он поможет
                                                       -- понять, что именно пошло не так
                                                       -- SQLSTATE Содержит код ошибки
        RETURN NULL;
END;
$$

-- В одном блоке EXCEPTION можно обрабатывать несколько условий:
BEGIN
    -- Основной код
EXCEPTION
    WHEN Условие THEN
        Код обработки исключения
    WHEN Условие THEN
        Код обработки исключения
END;

------------------------------------------------------------------------------------------------------------------------
-- Блоки BEGIN END
------------------------------------------------------------------------------------------------------------------------
-- Внутри одной процедуры или функции может быть сколько угодно блоков BEGIN - EXCEPTION - END:
CREATE OR REPLACE FUNCTION myfunc()
RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
    BEGIN
        -- Код блока 1
    EXCEPTION
        WHEN Условие THEN
            -- Код обработки исключения блока 1
    END;

    BEGIN
        -- Код блока 2
    EXCEPTION
        WHEN Условие THEN
            -- Код обработки исключения блока 2
    END;

    -- Код функции

EXCEPTION
    WHEN Условие THEN
        -- Код обработки исключения всей функции
END;
$$
------------------------------------------------------------------------------------------------------------------------
-- no_data_found
------------------------------------------------------------------------------------------------------------------------
-- нужно добавить ключевое слово STRICT после INTO. STRICT говорит, что в переменную нужно записать какое-то значение,
-- иначе сгенерируется ошибка:
-- Ошибка: запрос не вернул строк
SELECT user_id
INTO STRICT _user_id -- добавляем STRICT
FROM workouts WHERE id = p_workout_id;