
INSERT INTO train_data_distances_popularity
SELECT user_location_country, user_location_region, user_location_city,
	srch_destination_id, hotel_country, orig_destination_distance_int, hotel_cluster,
	ceil(SUM((is_booking*11 + 1)*((date_time_year-2013)*1 + 1))) as search_qty,
    0 as search_freq
FROM train_data
WHERE orig_destination_distance_int > 0
GROUP BY user_location_country, user_location_region, user_location_city,
	srch_destination_id, hotel_country, orig_destination_distance_int, hotel_cluster;


UPDATE train_data_distances_popularity s
	JOIN (SELECT user_location_country, user_location_region, user_location_city,
				srch_destination_id, hotel_country, orig_destination_distance_int,
                SUM(search_qty) as search_total_qty
			FROM train_data_distances_popularity
            GROUP BY user_location_country, user_location_region, user_location_city,
				srch_destination_id, hotel_country, orig_destination_distance_int) s2
	ON s2.user_location_country = s.user_location_country
		AND s2.user_location_region = s.user_location_region
		AND s2.user_location_city = s.user_location_city
		AND s2.srch_destination_id = s.srch_destination_id
		AND s2.hotel_country = s.hotel_country
		AND s2.orig_destination_distance_int = s.orig_destination_distance_int
SET search_freq = search_qty / search_total_qty;


SET SESSION group_concat_max_len = 1000000;
SELECT concat(user_location_country, ':', user_location_region, ':', user_location_city, ':',
				srch_destination_id, ':', hotel_country, ':', orig_destination_distance_int),
	group_concat(hotel_cluster, ':', round(search_freq, 5)) as hotel_cluster_freq_array
FROM expedia.train_data_distances_popularity
GROUP BY user_location_country, user_location_region, user_location_city,
				srch_destination_id, hotel_country, orig_destination_distance_int
INTO OUTFILE 'csv/train_data_distances_popularity.csv'
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n';


SELECT count(*)
FROM expedia.train_data_distances_popularity;
EXPLAIN SELECT * FROM expedia.train_data_distances_popularity;


SELECT orig_destination_distance, count(*)
FROM expedia.train_data
GROUP BY orig_destination_distance LIMIT 100;


SELECT *
FROM expedia.train_data_distances_popularity
ORDER BY search_qty DESC;

SELECT *
FROM expedia.train_data_distances_popularity
WHERE user_location_city = 0
ORDER BY search_qty DESC;

SELECT *
FROM expedia.train_data_distances_popularity
WHERE user_location_city > 0 AND orig_destination_distance_int > 0
ORDER BY search_qty DESC;



