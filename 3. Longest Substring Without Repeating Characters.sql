CREATE OR REPLACE FUNCTION longest_substring (string TEXT)
RETURNS TEXT LANGUAGE plpgsql AS $$
    DECLARE
        _array_string text[]; -- Array of characters made from input string
        _input_string_length int;  -- Input string length
        _left int := 1; -- Left boundary of the window
        _right int := 1; -- Right boundary of the window
        _string_answer text := ''; -- Variable longest_substring function returns
        _array_answer text[] := '{}':: text[]; -- Array of characters for _string_answer
        _curr_right_char text; -- Current character at the right edge of the window
        _curr_left_char text; -- Current character at the left edge of the window
        _curr_substring text[]; -- Current window

    BEGIN
        -- If the given string is 0 characters long - raises an exception
        IF (SELECT LENGTH(string)) = 0 THEN
            RAISE EXCEPTION 'Input string cannot be empty!';
        END IF;

        -- Concatenating the given string into an array of characters
        SELECT regexp_split_to_array(string, '')
        INTO _array_string;

        -- Calculating length of the given string
        SELECT LENGTH(string)
        INTO _input_string_length;

        -- Creating a temporary table for storing individual characters
        CREATE TEMPORARY TABLE hash_set
        (char TEXT PRIMARY KEY)
        ON COMMIT DROP;

        -- Iterating over the array of characters of the given string
        WHILE _right <= _input_string_length LOOP
            SELECT _array_string[_right]
            INTO _curr_right_char;

            -- As long hash_set contains current right character
            WHILE EXISTS (SELECT 1 FROM hash_set WHERE hash_set.char = _curr_right_char) LOOP
                SELECT _array_string[_left]
                INTO _curr_left_char;

                -- Delete value equal to the current left character from the hash_set
                DELETE FROM hash_set WHERE hash_set.char = _curr_left_char;

                -- And move left pointer one step forward
                _left := _left + 1;
            END LOOP;

            INSERT INTO hash_set VALUES (_curr_right_char); -- Save current right character to the hash_set

            _curr_substring := _array_string[_left: _right]; -- Update current window

            _right := _right + 1;

            -- If current window's length is greater than _array_answer's length - update _array_answer
            IF COALESCE(ARRAY_LENGTH(_array_answer, 1), 0) < ARRAY_LENGTH(_curr_substring, 1) THEN
                _array_answer := _curr_substring;
            END IF;
        END LOOP;

        SELECT ARRAY_TO_STRING(_array_answer, '')
        INTO _string_answer;

        RETURN _string_answer;
    END;$$;
