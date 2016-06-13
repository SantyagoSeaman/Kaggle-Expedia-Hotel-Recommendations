
INSERT INTO train_data_directions_popularity
SELECT user_location_country, hotel_country, hotel_market,
	search_season, hotel_cluster,
	ceil(SUM((is_booking*11 + 1)*((date_time_year-2013)*1 + 1))) as search_qty,
    0 as search_freq
FROM train_data
GROUP BY user_location_country, hotel_country, hotel_market,
	search_season, hotel_cluster;

UPDATE train_data_directions_popularity s
	JOIN (SELECT user_location_country, hotel_country, hotel_market,
				search_season,
				SUM(search_qty) as search_total_qty
			FROM train_data_directions_popularity
            GROUP BY user_location_country, hotel_country, hotel_market,
				search_season) s2
	ON s2.user_location_country = s.user_location_country
		AND s2.hotel_country = s.hotel_country
		AND s2.hotel_market = s.hotel_market
		AND s2.search_season = s.search_season
SET search_freq = search_qty / search_total_qty;


SET SESSION group_concat_max_len = 1000000;
SELECT concat(user_location_country, ':', hotel_country, ':', hotel_market, ':', search_season),
	group_concat(hotel_cluster, ':', round(search_freq, 4)) as hotel_cluster_freq_array
FROM train_data_directions_popularity
GROUP BY user_location_country, hotel_country, hotel_market,
	search_season
INTO OUTFILE 'csv/train_data_directions_popularity.csv'
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n';


SELECT *
FROM expedia.train_data_searches_stat
WHERE user_location_country = 66 AND hotel_country = 50 AND is_package = 1
	AND srch_adults_children_flag = 2
ORDER BY search_qty DESC, search_freq DESC;


explain select * from train_data;
select count(*) from train_data;

select count(*) from train_data_directions_popularity;
select count(*) from train_data_destinations_popularity;


select *
from train_data_directions_popularity
WHERE user_location_country = 0
ORDER BY search_qty DESC;


