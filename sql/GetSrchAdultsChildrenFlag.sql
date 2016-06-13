DELIMITER $$

DROP FUNCTION IF EXISTS GetSrchAdultsChildrenFlag;$$
CREATE FUNCTION GetSrchAdultsChildrenFlag(srch_adults_cnt int, srch_children_cnt int) RETURNS tinyint
    DETERMINISTIC
BEGIN
    DECLARE flag tinyint;
	SET flag = 4;

-- "adults" "adults and children" "single adult" "unknown"
    IF srch_adults_cnt > 0 THEN
		IF srch_children_cnt > 0 THEN
			SET flag = 2;
		ELSE
			IF srch_adults_cnt = 1 THEN
				SET flag = 3;
            ELSE
				SET flag = 1;
			END IF;
		END IF;
    END IF;
 
	RETURN (flag);
END$$

DROP FUNCTION IF EXISTS GetSeason;$$
CREATE FUNCTION GetSeason(search_month int) RETURNS tinyint
    DETERMINISTIC
BEGIN
	CASE search_month
		WHEN 3 THEN RETURN(1);
		WHEN 4 THEN RETURN(1);
		WHEN 5 THEN RETURN(1);

		WHEN 6 THEN RETURN(2);
		WHEN 7 THEN RETURN(2);
		WHEN 8 THEN RETURN(2);

		WHEN 9 THEN RETURN(3);
		WHEN 10 THEN RETURN(3);
		WHEN 11 THEN RETURN(3);

		WHEN 12 THEN RETURN(4);
		WHEN 1 THEN RETURN(4);
		WHEN 2 THEN RETURN(4);

        ELSE return(0);
	END CASE;
END$$
