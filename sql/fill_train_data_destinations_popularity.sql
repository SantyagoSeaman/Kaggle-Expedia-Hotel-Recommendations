
-- is_booking 0 1   - 1 11
-- date_time_year 2013 2014  - 1 2

INSERT INTO train_data_destinations_popularity
SELECT srch_destination_id, hotel_country,
	hotel_market, search_season, hotel_cluster,
	ceil(SUM((is_booking*11 + 1)*((date_time_year-2013)*1 + 1))) as search_qty,
    0 as search_freq
FROM train_data
WHERE search_season > 0
GROUP BY srch_destination_id, hotel_country,
	hotel_market, search_season, hotel_cluster;


UPDATE train_data_destinations_popularity s
	JOIN (SELECT srch_destination_id, hotel_country,
				hotel_market, search_season,
				SUM(search_qty) as search_total_qty
			FROM train_data_destinations_popularity
            GROUP BY srch_destination_id, hotel_country,
				hotel_market, search_season) s2
	ON s2.srch_destination_id = s.srch_destination_id
		AND s2.hotel_country = s.hotel_country
		AND s2.hotel_market = s.hotel_market
		AND s2.search_season = s.search_season
SET search_freq = search_qty / search_total_qty;


SET SESSION group_concat_max_len = 1000000;
SELECT concat(srch_destination_id, ':', hotel_country, ':', hotel_market, ':',
				search_season) as destination_key,
                group_concat(hotel_cluster, ':', round(search_freq, 5)) as hotel_cluster_freq_array
FROM train_data_destinations_popularity
GROUP BY srch_destination_id, hotel_country,
	hotel_market, search_season
INTO OUTFILE 'csv/train_data_destinations_popularity.csv'
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n';


SELECT *
FROM expedia.train_data_destinations_popularity
WHERE search_freq < 0.5
ORDER BY search_freq DESC;


SELECT count(*)
FROM expedia.train_data_destinations_popularity;


SELECT *
FROM expedia.train_data_destinations_popularity
WHERE srch_destination_id = 8250 AND srch_destination_type_id = 1
	AND hotel_country = 50 AND hotel_market = 628 AND is_package = 1
    AND srch_adults_children_flag = 2;


SELECT srch_destination_id, srch_destination_type_id,
	hotel_country, hotel_market, srch_adults_children_flag,
	is_package,
    group_concat(hotel_cluster, ':', search_freq)
FROM expedia.train_data_destinations_popularity
WHERE search_freq < 0.5
GROUP BY srch_destination_id, srch_destination_type_id,
	hotel_country, hotel_market,
    srch_adults_children_flag, is_package;


SELECT concat(srch_destination_id, ':', srch_destination_type_id, ':',
        hotel_country, ':', hotel_market, ':', srch_adults_children_flag, ':',
        is_package) as destination_key,
        group_concat(hotel_cluster, ':', search_freq) as hotel_cluster_freq_array
FROM expedia.train_data_destinations_popularity
GROUP BY srch_destination_id, srch_destination_type_id,
	hotel_country, hotel_market,
    srch_adults_children_flag, is_package
LIMIT 10;


select *
from train_data_destinations_popularity
WHERE srch_destination_type_id = 0
ORDER BY search_qty DESC;



