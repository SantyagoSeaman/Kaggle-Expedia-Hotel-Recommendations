
INSERT INTO train_data_trends
SELECT date_time_year, hotel_country, hotel_market, hotel_cluster,
	COUNT(*) as search_qty, 0 as search_freq
FROM train_data
GROUP BY date_time_year, hotel_country, hotel_market, hotel_cluster;


UPDATE train_data_trends s
	JOIN (SELECT date_time_year, hotel_country, hotel_market,
                SUM(search_qty) as search_total_qty
			FROM train_data_trends
            GROUP BY date_time_year, hotel_country, hotel_market) s2
	ON s2.hotel_country = s.hotel_country
		AND s2.hotel_market = s.hotel_market
		AND s2.date_time_year = s.date_time_year
SET search_freq = search_qty / search_total_qty;


SELECT * FROM train_data_trends WHERE date_time_year = 2013;

SELECT *
FROM(
	SELECT t2014.hotel_country, t2014.hotel_market, t2014.hotel_cluster,
		t2013.search_qty as t2013_search_qty, t2014.search_qty as t2014_search_qty,
		t2013.search_freq as t2013_search_freq, t2014.search_freq as t2014_search_freq,
		coalesce(t2014.search_freq/t2013.search_freq, 0) as slope
	FROM train_data_trends t2014
	LEFT JOIN train_data_trends t2013
		ON t2014.hotel_country = t2013.hotel_country
		AND t2014.hotel_market = t2013.hotel_market
		AND t2014.hotel_cluster = t2013.hotel_cluster
		AND t2014.date_time_year = 2014
		AND t2013.date_time_year = 2013        
-- 	WHERE t2013.hotel_country IS NOT NULL
) trends
WHERE slope > 0.1 AND slope < 10
	AND t2014_search_qty > 10
	AND t2013_search_qty > 10
	AND t2013_search_freq > 0.001 AND t2014_search_freq > 0.001
    
    AND hotel_country = 50
    
    AND hotel_cluster = 91
;

SET SESSION group_concat_max_len = 1000000;
SELECT concat(hotel_country, ':', hotel_market),
	group_concat(hotel_cluster, ':', slope) as hotel_cluster_slopes_array
FROM(
	SELECT t2014.hotel_country, t2014.hotel_market, t2014.hotel_cluster,
		t2013.search_qty as t2013_search_qty, t2014.search_qty as t2014_search_qty,
		t2013.search_freq as t2013_search_freq, t2014.search_freq as t2014_search_freq,
		round(sqrt(coalesce(t2014.search_freq/t2013.search_freq, 0)), 4) as slope
	FROM train_data_trends t2014
	LEFT JOIN train_data_trends t2013
		ON t2014.hotel_country = t2013.hotel_country
		AND t2014.hotel_market = t2013.hotel_market
		AND t2014.hotel_cluster = t2013.hotel_cluster
		AND t2014.date_time_year = 2014
		AND t2013.date_time_year = 2013        
) trends
WHERE slope > 0.1 AND slope < 10
	AND t2014_search_qty > 10
	AND t2013_search_qty > 10
	AND t2013_search_freq > 0.001 AND t2014_search_freq > 0.001
GROUP BY hotel_country, hotel_market
INTO OUTFILE 'csv/train_data_trends.csv'
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n';

