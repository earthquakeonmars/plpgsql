-- Создаём процедуру с тремя входными параметрами
CREATE OR REPLACE PROCEDURE add_workout_data
    (p_workout_id integer, p_heart_rate integer, p_distance numeric)
LANGUAGE SQL
    AS $$
        -- Вставляем данные в таблицу physiological_indicators
        INSERT INTO physiological_indicators(workout_id, date_time, heart_rate)
        VALUES (p_workout_id, CURRENT_TIMESTAMP, p_heart_rate);

        -- Вставляем данные в таблицу distances
        INSERT INTO distances(workout_id, date_time, distance)
        VALUES (p_workout_id, CURRENT_TIMESTAMP, p_distance);
    $$;

CALL add_workout_data(1001, 130, 350.1);