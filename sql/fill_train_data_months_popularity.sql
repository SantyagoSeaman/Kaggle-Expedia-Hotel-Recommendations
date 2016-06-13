
INSERT INTO train_data_months_popularity
SELECT hotel_country, hotel_market,
	srch_destination_type_id,
    search_month, hotel_cluster,
	ceil(SUM((is_booking*11 + 1)*((date_time_year-2013)*1 + 1))) as search_qty,
    0 as search_freq
FROM train_data
GROUP BY hotel_country, hotel_market,
	srch_destination_type_id,
    search_month, hotel_cluster;


UPDATE train_data_months_popularity s
	JOIN (SELECT hotel_country, hotel_market,
				srch_destination_type_id,
				search_month,
                SUM(search_qty) as search_total_qty
			FROM train_data_months_popularity
            GROUP BY hotel_country, hotel_market,
				srch_destination_type_id,
				search_month) s2
	ON s2.hotel_country = s.hotel_country
		AND s2.hotel_market = s.hotel_market
		AND s2.srch_destination_type_id = s.srch_destination_type_id
		AND s2.search_month = s.search_month
SET search_freq = search_qty / search_total_qty;


select count(*) from train_data_hotels_popularity;


SET SESSION group_concat_max_len = 1000000;
SELECT concat(hotel_country, ':', hotel_market, ':',
	srch_destination_type_id, ':', search_month),
	group_concat(hotel_cluster, ':', round(search_freq, 5)) as hotel_cluster_freq_array
FROM train_data_months_popularity
GROUP BY hotel_country, hotel_market, srch_destination_type_id, search_month
INTO OUTFILE 'csv/train_data_months_popularity.csv'
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n';

