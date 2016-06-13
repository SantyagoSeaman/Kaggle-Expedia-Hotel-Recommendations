
INSERT INTO train_data_countries_popularity
SELECT hotel_country, hotel_market, search_season, hotel_cluster,
	ceil(SUM((is_booking*11 + 1)*((date_time_year-2013)*1 + 1))) as search_qty,
    0 as search_freq
FROM train_data
WHERE search_season > 0
GROUP BY hotel_country, hotel_market, search_season, hotel_cluster;


UPDATE train_data_countries_popularity s
	JOIN (SELECT hotel_country, hotel_market, search_season,
                SUM(search_qty) as search_total_qty
			FROM train_data_countries_popularity
            GROUP BY hotel_country, hotel_market, search_season) s2
	ON s2.hotel_country = s.hotel_country
		AND s2.hotel_market = s.hotel_market
		AND s2.search_season = s.search_season
SET search_freq = search_qty / search_total_qty;


SET SESSION group_concat_max_len = 1000000;
SELECT concat(hotel_country, ':', hotel_market, ':', search_season),
	group_concat(hotel_cluster, ':', round(search_freq, 5)) as hotel_cluster_freq_array
FROM expedia.train_data_countries_popularity
GROUP BY hotel_country, hotel_market, search_season
INTO OUTFILE 'csv/train_data_countries_popularity.csv'
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n';

