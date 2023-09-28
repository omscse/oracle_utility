DECLARE
    TYPE t_row IS RECORD (
        level_num NUMBER,
        search_word VARCHAR2(4000),
        object_name VARCHAR2(4000),
        line_num NUMBER,
        line_text VARCHAR2(4000)
    );

    TYPE t_table IS TABLE OF t_row;
    
    v_queue t_table := t_table();
    v_visited DBMS_UTILITY.NAME_TOKEN_TABLE;
    v_index NUMBER := 0;
    v_keyword VARCHAR2(4000) := 'YOUR_INITIAL_SEARCH_WORD'; -- Replace with your keyword

BEGIN
    -- Initialize the queue with the initial search
    v_queue.EXTEND;
    v_queue(v_queue.LAST).level_num := 0;
    v_queue(v_queue.LAST).search_word := v_keyword;
    v_queue(v_queue.LAST).object_name := null;
    v_queue(v_queue.LAST).line_num := null;
    v_queue(v_queue.LAST).line_text := null;
    
    -- BFS traversal
    WHILE v_index < v_queue.COUNT LOOP
        v_index := v_index + 1;
        FOR rec IN (
            SELECT DISTINCT NAME, TYPE, LINE, TEXT
            FROM ALL_SOURCE
            WHERE TYPE IN ('FUNCTION', 'PROCEDURE') 
            AND UPPER(TEXT) LIKE UPPER('%' || v_queue(v_index).search_word || '%')
        ) LOOP
            IF NOT v_visited.EXISTS(rec.NAME) THEN
                v_visited(rec.NAME) := 1;
                v_queue.EXTEND;
                v_queue(v_queue.LAST).level_num := v_queue(v_index).level_num + 1;
                v_queue(v_queue.LAST).search_word := rec.NAME;
                v_queue(v_queue.LAST).object_name := rec.TYPE || '.' || rec.NAME;
                v_queue(v_queue.LAST).line_num := rec.LINE;
                v_queue(v_queue.LAST).line_text := rec.TEXT;
            END IF;
        END LOOP;
    END LOOP;
    
    -- Output the results
    FOR i IN 1..v_queue.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(v_queue(i).level_num || ' ' || v_queue(i).search_word || ' ' || v_queue(i).object_name || ' ' || v_queue(i).line_num || ' ' || v_queue(i).line_text);
    END LOOP;

END;
/
