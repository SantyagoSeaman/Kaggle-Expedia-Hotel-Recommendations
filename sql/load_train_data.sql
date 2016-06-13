-- 27490481
-- 
-- 
-- date_time  site_name  posa_continent
-- user_location_country  user_location_region  user_location_city
-- orig_destination_distance  user_id  is_mobile  is_package  channel  srch_ci  srch_co
-- srch_adults_cnt  srch_children_cnt  srch_rm_cnt  srch_destination_id  srch_destination_type_id
-- is_booking  cnt  hotel_continent  hotel_country  hotel_market  hotel_cluster



LOAD DATA INFILE '/usr/local/mysql/data/csv/train.csv'
INTO TABLE train_data
FIELDS TERMINATED BY ',' ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
	date_time, site_name, @dummy,
	user_location_country, user_location_region, user_location_city,
	@origdestinationdistance, user_id, is_mobile, is_package, channel, @srchci, @srchco,
	srch_adults_cnt, srch_children_cnt, srch_rm_cnt, srch_destination_id, srch_destination_type_id,
	is_booking, @dummy, hotel_continent, hotel_country, hotel_market, hotel_cluster
)
SET orig_destination_distance = IF(@origdestinationdistance='', 0, @origdestinationdistance),
	srch_ci = nullif(@srchci, ''),
    srch_co = nullif(@srchco, '')
;

UPDATE expedia.train_data
SET search_nights = DATEDIFF(srch_co, srch_ci)
WHERE srch_ci IS NOT NULL AND srch_ci IS NOT NULL;
UPDATE expedia.train_data SET search_nights = 0 WHERE search_nights < 0 OR search_nights IS NULL;
UPDATE expedia.train_data SET search_nights_packed = search_nights;
UPDATE expedia.train_data SET search_nights_packed = 20 WHERE search_nights_packed > 20;
UPDATE expedia.train_data SET search_year = YEAR(srch_ci) WHERE srch_ci IS NOT NULL;
UPDATE expedia.train_data SET search_month = MONTH(srch_ci) WHERE srch_ci IS NOT NULL;
UPDATE expedia.train_data SET search_season = GetSeason(search_month);
UPDATE expedia.train_data SET srch_adults_children_flag = GetSrchAdultsChildrenFlag(srch_adults_cnt, srch_children_cnt);
UPDATE expedia.train_data SET search_weeks_diff = FLOOR(DATEDIFF(DATE(srch_ci), DATE(date_time))/7)
	WHERE srch_ci IS NOT NULL AND srch_ci > date_time;
UPDATE expedia.train_data SET date_time_year = YEAR(date_time);


UPDATE expedia.train_data SET orig_destination_distance_int = floor(orig_destination_distance * 10000);
