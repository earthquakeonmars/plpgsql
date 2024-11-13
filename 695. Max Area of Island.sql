CREATE OR REPLACE FUNCTION public.max_are_of_island
(grid integer[][]) RETURNS integer LANGUAGE plpgsql AS $$
DECLARE
    directions integer[][] := ARRAY[[0, 1], [0, -1], [1, 0], [-1, 0]];
BEGIN
END;$$;

CREATE TEMPORARY TABLE asd (lst int[][]);
INSERT INTO asd VALUES (ARRAY[[1, 2], [3, 4]]);
SELECT lst[1][1] FROM asd;