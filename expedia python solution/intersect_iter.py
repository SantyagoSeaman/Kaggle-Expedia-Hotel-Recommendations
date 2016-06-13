import gzip
import csv
import math
import random
import collections
from datetime import datetime

clusters_index_range = range(0, 100)
clusters_index_range_sorted = list(map(int, sorted(map(str, clusters_index_range))))
month_to_season = {
    0: 0,
    1: 4,
    2: 4,
    3: 1,
    4: 1,
    5: 1,
    6: 2,
    7: 2,
    8: 2,
    9: 3,
    10: 3,
    11: 3,
    12: 4
}


def split_clusters(clusters_array, clusters_str, prefix):
    if clusters_str != '':
        clusters_list = clusters_str.split(',')
        for cluster_pair in clusters_list:
            cluster = cluster_pair.split(':')
            clusters_array[prefix + cluster[0]] = float(cluster[1])
    return clusters_array


def filter_negative(seq):
    for el in seq:
        if el >= 0: yield el


def slice_clusters(clusters, n, i):
    for s in range(0, n):
        yield clusters[i + s * 100]


def mean(arr):
    n = len(arr)
    if n == 0:
        return 0
    return sum(arr) / n


def get_random(prob):
    return random.choice([0] * (prob - 1) + [1])


def mult_clusters_trend(clusters, trend_key):
    return {k: round(a * b, 4) for k, a, b in
            zip(list(clusters.keys()), list(clusters.values()), list(trends[trend_key].values()))}


def divide_clusters_trend(clusters, trend_key):
    return {k: round(a / b, 4) for k, a, b in
            zip(list(clusters.keys()), list(clusters.values()), list(trends[trend_key].values()))}


# Hardcoded :)
def get_trended_clusters_by_year(clusters, row, year):
    trend_key = str(row['hotel_country']) + ':' + str(row['hotel_market'])
    if trend_key in trends:
        if year == 2015:
            return mult_clusters_trend(clusters, trend_key)
        else:
            if year == 2013:
                return divide_clusters_trend(clusters, trend_key)
    return clusters


def intersect_data(input_filename_prefix, nrows=-1, indexes=None, trends=None, add_noise=False, only_bookings=False):
    dest_headers = ['dest_' + str(i) for i in clusters_index_range]
    dir_headers = ['dir_' + str(i) for i in clusters_index_range]
    dist_headers = ['dist_' + str(i) for i in clusters_index_range]
    nigh_headers = ['nigh_' + str(i) for i in clusters_index_range]
    mon_headers = ['mon_' + str(i) for i in clusters_index_range]
    comp_headers = ['comp_' + str(i) for i in clusters_index_range]
    coun_headers = ['coun_' + str(i) for i in clusters_index_range]
    simp_headers = ['simp_' + str(i) for i in clusters_index_range]
    sum_headers = ['sum_' + str(i) for i in clusters_index_range]
    avg_headers = ['avg_' + str(i) for i in clusters_index_range]
    full_headers = dest_headers + dist_headers + nigh_headers + mon_headers + comp_headers + coun_headers \
                   + simp_headers + dir_headers + sum_headers + avg_headers
    # full_headers = dest_headers + dir_headers + dist_headers + nigh_headers + mon_headers + comp_headers + coun_headers + simp_headers
    # full_headers = dir_headers

    zero_dest_clusters = {h: 0.0 for h in dest_headers}
    zero_dir_clusters = {h: 0.0 for h in dir_headers}
    zero_dist_clusters = {h: 0.0 for h in dist_headers}
    zero_nigh_clusters = {h: 0.0 for h in nigh_headers}
    zero_mon_clusters = {h: 0.0 for h in mon_headers}
    zero_comp_clusters = {h: 0.0 for h in comp_headers}
    zero_coun_clusters = {h: 0.0 for h in coun_headers}
    zero_simp_clusters = {h: 0.0 for h in simp_headers}

    absent_dest_clusters = {h: -1.0 for h in dest_headers}
    absent_dir_clusters = {h: -1.0 for h in dir_headers}
    absent_dist_clusters = {h: -1.0 for h in dist_headers}
    absent_nigh_clusters = {h: -1.0 for h in nigh_headers}
    absent_mon_clusters = {h: -1.0 for h in mon_headers}
    absent_comp_clusters = {h: -1.0 for h in comp_headers}
    absent_coun_clusters = {h: -1.0 for h in coun_headers}
    absent_simp_clusters = {h: -1.0 for h in simp_headers}

    absent_counter = 0

    input_file = gzip.open("../input/%s.csv.gz" % input_filename_prefix, mode="rt")
    # output_dest = open('../calculated clusters probabilities/%s_dest_clusters_prob_random.csv' % input_filename_prefix, mode="wt")
    # output_dir = open('../calculated clusters probabilities/%s_dir_clusters_prob_random.csv' % input_filename_prefix, mode="wt")
    # output_dist = open('../calculated clusters probabilities/%s_dist_clusters_prob_random.csv' % input_filename_prefix, mode="wt")
    # output_nigh = open('../calculated clusters probabilities/%s_nigh_clusters_prob_random.csv' % input_filename_prefix, mode="wt")
    # output_mon = open('../calculated clusters probabilities/%s_mon_clusters_prob_random.csv' % input_filename_prefix, mode="wt")
    # output_comp = open('../calculated clusters probabilities/%s_comp_clusters_prob_random.csv' % input_filename_prefix, mode="wt")
    # output_coun = open('../calculated clusters probabilities/%s_coun_clusters_prob_random.csv' % input_filename_prefix, mode="wt")
    output_full = open(
        '../calculated clusters probabilities/%s_full_clusters_prob_bookings_only_without_trends.csv' % input_filename_prefix,
        mode="wt")

    # output_dest_writer = csv.DictWriter(output_dest, fieldnames=dest_headers)
    # output_dest_writer.writeheader()
    #
    # output_dir_writer = csv.DictWriter(output_dir, fieldnames=dir_headers)
    # output_dir_writer.writeheader()
    #
    # output_dist_writer = csv.DictWriter(output_dist, fieldnames=dist_headers)
    # output_dist_writer.writeheader()
    #
    # output_nigh_writer = csv.DictWriter(output_nigh, fieldnames=nigh_headers)
    # output_nigh_writer.writeheader()
    #
    # output_mon_writer = csv.DictWriter(output_mon, fieldnames=mon_headers)
    # output_mon_writer.writeheader()
    #
    # output_comp_writer = csv.DictWriter(output_comp, fieldnames=comp_headers)
    # output_comp_writer.writeheader()
    #
    # output_coun_writer = csv.DictWriter(output_coun, fieldnames=coun_headers)
    # output_coun_writer.writeheader()

    output_full_writer = csv.DictWriter(output_full, fieldnames=full_headers)
    output_full_writer.writeheader()

    input_file_reader = csv.DictReader(input_file)

    index = 0
    counter = 0
    next_index = 0
    if indexes is not None:
        next_index = indexes.pop(0)

    for row in input_file_reader:
        # print('================================================')
        # print(index)
        # print(row['hotel_cluster'])

        if indexes is not None:
            if index < next_index:
                index += 1
                continue

        if only_bookings:
            if int(row['is_booking']) == 0:
                index += 1
                continue

        clusters_full = {}

        # "adults" "adults and children" "single adult" "unknown"
        # srch_adults_children_flag = 4
        # if int(row['srch_adults_cnt']) > 0:
        #     if int(row['srch_children_cnt']) > 0:
        #         srch_adults_children_flag = 2
        #     else:
        #         if int(row['srch_adults_cnt']) == 1:
        #             srch_adults_children_flag = 3
        #         else:
        #             srch_adults_children_flag = 1

        if row['orig_destination_distance'] == '':
            row['orig_destination_distance_int'] = 0
        else:
            row['orig_destination_distance_int'] = math.floor(float(row['orig_destination_distance']) * 10000)

        row['search_nights_packed'] = 0
        row['search_month'] = 0
        row['search_season'] = 0
        if row['srch_ci'] != '':
            try:
                srch_ci = datetime.strptime(row['srch_ci'], "%Y-%m-%d")
                row['search_month'] = srch_ci.month
                if row['srch_co'] != '':
                    srch_co = datetime.strptime(row['srch_co'], "%Y-%m-%d")
                    delta = srch_co - srch_ci
                    row['search_nights'] = int(delta.days)
                    row['search_nights_packed'] = row['search_nights']
                    if row['search_nights_packed'] > 20:
                        row['search_nights_packed'] = 20
                    if row['search_nights_packed'] < 0:
                        row['search_nights_packed'] = 0
                row['search_season'] = month_to_season[row['search_month']]
            except ValueError:
                print("Invalid date: %s" % row['srch_ci'])
        date_time_year = datetime.strptime(row['date_time'], "%Y-%m-%d %H:%M:%S").year

        # --------------------------------------------------------------------------------------
        if add_noise and get_random(100) == 1:
            clusters = absent_dest_clusters
        else:
            key = str(row['srch_destination_id']) + ':' \
                  + str(row['hotel_country']) + ':' \
                  + str(row['hotel_market']) + ':' \
                  + str(row['search_season'])
            clusters_str = train_data_destinations_popularity.get(key, '')
            if clusters_str == '':
                clusters = absent_dest_clusters
                absent_counter += 1
                # print('Destination absent: %s' % key)
            else:
                clusters = split_clusters(zero_dest_clusters.copy(), clusters_str, 'dest_')
                if trends is not None:
                    clusters = get_trended_clusters_by_year(clusters, row, date_time_year)
        # output_dest_writer.writerow(clusters)
        clusters_full = dict(clusters_full, **clusters)

        # ------------------------------------------------
        if add_noise and get_random(100) == 1:
            clusters = absent_dir_clusters
        else:
            key = str(row['user_location_country']) + ':' \
                  + str(row['hotel_country']) + ':' \
                  + str(row['hotel_market']) + ':' \
                  + str(row['search_season'])
            clusters_str = train_data_directions_popularity.get(key, '')
            if clusters_str == '':
                clusters = absent_dir_clusters
                absent_counter += 1
                # print('Direction absent: %s' % key)
            else:
                clusters = split_clusters(zero_dir_clusters.copy(), clusters_str, 'dir_')
                if trends is not None:
                    clusters = get_trended_clusters_by_year(clusters, row, date_time_year)
        # output_dir_writer.writerow(clusters)
        clusters_full = dict(clusters_full, **clusters)

        # ------------------------------------------------
        if add_noise and get_random(100) == 1:
            clusters = absent_dist_clusters
        else:
            key = str(row['user_location_country']) + ':' \
                  + str(row['user_location_region']) + ':' \
                  + str(row['user_location_city']) + ':' \
                  + str(row['srch_destination_id']) + ':' \
                  + str(row['hotel_country']) + ':' \
                  + str(row['orig_destination_distance_int'])
            clusters_str = train_data_distances_popularity.get(key, '')
            if clusters_str == '':
                clusters = absent_dist_clusters
                # absent_counter += 1
            else:
                clusters = split_clusters(zero_dist_clusters.copy(), clusters_str, 'dist_')
        # output_dist_writer.writerow(clusters)
        clusters_full = dict(clusters_full, **clusters)

        # ------------------------------------------------
        if add_noise and get_random(100) == 1:
            clusters = absent_nigh_clusters
        else:
            key = str(row['hotel_country']) + ':' \
                  + str(row['hotel_market']) + ':' \
                  + str(row['srch_destination_type_id']) + ':' \
                  + str(row['search_nights_packed'])
            clusters_str = train_data_nights_popularity.get(key, '')
            if clusters_str == '':
                clusters = absent_nigh_clusters
                absent_counter += 1
                # print('Hotel absent: %s' % key)
            else:
                clusters = split_clusters(zero_nigh_clusters.copy(), clusters_str, 'nigh_')
                if trends is not None:
                    clusters = get_trended_clusters_by_year(clusters, row, date_time_year)
        # output_nigh_writer.writerow(clusters)
        clusters_full = dict(clusters_full, **clusters)

        # ------------------------------------------------
        if add_noise and get_random(100) == 1:
            clusters = absent_mon_clusters
        else:
            key = str(row['hotel_country']) + ':' \
                  + str(row['hotel_market']) + ':' \
                  + str(row['srch_destination_type_id']) + ':' \
                  + str(row['search_month'])
            clusters_str = train_data_months_popularity.get(key, '')
            if clusters_str == '':
                clusters = absent_mon_clusters
                absent_counter += 1
                # print('Month absent: %s' % key)
            else:
                clusters = split_clusters(zero_mon_clusters.copy(), clusters_str, 'mon_')
                if trends is not None:
                    clusters = get_trended_clusters_by_year(clusters, row, date_time_year)
        # output_mon_writer.writerow(clusters)
        clusters_full = dict(clusters_full, **clusters)

        # ------------------------------------------------
        if add_noise and get_random(100) == 1:
            clusters = absent_comp_clusters
        else:
            key = str(row['hotel_country']) + ':' \
                  + str(row['hotel_market']) + ':' \
                  + str(row['srch_destination_type_id']) + ':' \
                  + str(row['srch_adults_cnt']) + ':' \
                  + str(row['srch_children_cnt'])
            clusters_str = train_data_compositions_popularity.get(key, '')
            if clusters_str == '':
                clusters = absent_comp_clusters
                absent_counter += 1
                # print('Composition absent: %s' % key)
            else:
                clusters = split_clusters(zero_comp_clusters.copy(), clusters_str, 'comp_')
            if trends is not None:
                clusters = get_trended_clusters_by_year(clusters, row, date_time_year)
        # output_comp_writer.writerow(clusters)
        clusters_full = dict(clusters_full, **clusters)

        # ------------------------------------------------
        if add_noise and get_random(100) == 1:
            clusters = absent_coun_clusters
        else:
            key = str(row['hotel_country']) + ':' \
                  + str(row['hotel_market']) + ':' \
                  + str(row['search_season'])
            clusters_str = train_data_countries_popularity.get(key, '')
            if clusters_str == '':
                clusters = absent_coun_clusters
                absent_counter += 1
                # print('Month absent: %s' % key)
            else:
                clusters = split_clusters(zero_coun_clusters.copy(), clusters_str, 'coun_')
            if trends is not None:
                clusters = get_trended_clusters_by_year(clusters, row, date_time_year)
        # output_coun_writer.writerow(clusters)
        clusters_full = dict(clusters_full, **clusters)

        # ------------------------------------------------
        if add_noise and get_random(100) == 1:
            clusters = absent_simp_clusters
        else:
            key = str(row['hotel_country']) + ':' + str(row['hotel_market'])
            clusters_str = train_data_simple_popularity.get(key, '')
            if clusters_str == '':
                clusters = absent_simp_clusters
                absent_counter += 1
            else:
                clusters = split_clusters(zero_simp_clusters.copy(), clusters_str, 'simp_')
            if trends is not None:
                clusters = get_trended_clusters_by_year(clusters, row, date_time_year)
        # output_coun_writer.writerow(clusters)
        clusters_full = dict(clusters_full, **clusters)

        # ------------------------------------------------
        # v = list(clusters_full.values())
        # avg comp coun dest dist dir
        # ключи сортируются по алфавиту и поэтому нужен костыль с clusters_index_range_sorted
        v = list(collections.OrderedDict(sorted(clusters_full.items())).values())
        n = int(len(v) / 100)
        # Maximize distance factor
        for i in clusters_index_range:
            v[400 + i] *= 2
        # Minimize direction factor
        for i in clusters_index_range:
            v[500 + i] /= 2
        filtered_clusters = [list(filter_negative(slice_clusters(v, n, i))) for i in clusters_index_range]

        clusters_sum = {sum_headers[clusters_index_range_sorted[i]]: round(sum(filtered_clusters[i]), 5) for i in clusters_index_range}
        clusters_full = dict(clusters_full, **clusters_sum)

        clusters_avg = {avg_headers[clusters_index_range_sorted[i]]: round(mean(filtered_clusters[i]), 5) for i in clusters_index_range}
        clusters_full = dict(clusters_full, **clusters_avg)

        output_full_writer.writerow(clusters_full)

        # ------------------------------------------------
        if indexes is not None:
            if indexes.__len__() > 0:
                next_index = indexes.pop(0)
            else:
                break

        counter += 1
        index += 1
        if counter % 10000 == 0:
            print('Index: %s, absent: %s, time: %s' % (counter, absent_counter, datetime.now()))
        if nrows > 0 and counter >= nrows:
            break

    print('Index: %s, absent: %s, time: %s' % (counter, absent_counter, datetime.now()))


# --------------------------------------------------------------------------------------
indexes = []
for line in csv.reader(open("csv/indexes_3M.csv")):
    indexes.append(int(line[0]) - 1)
indexes.sort()

trends = {}
trends_headers = ['trend_' + str(i) for i in clusters_index_range]
zero_trends_clusters = {h: 1.0 for h in trends_headers}
for line in csv.reader(open("csv/train_data_trends.csv"), delimiter='\t'):
    trends[line[0]] = split_clusters(zero_trends_clusters.copy(), line[1], 'trend_')

train_data_destinations_popularity = {}
for line in csv.reader(open("csv/train_data_destinations_popularity.csv"), delimiter='\t'):
    train_data_destinations_popularity[line[0]] = line[1]

train_data_directions_popularity = {}
for line in csv.reader(open("csv/train_data_directions_popularity.csv"), delimiter='\t'):
    train_data_directions_popularity[line[0]] = line[1]

train_data_distances_popularity = {}
for line in csv.reader(open("csv/train_data_distances_popularity.csv"), delimiter='\t'):
    train_data_distances_popularity[line[0]] = line[1]

train_data_nights_popularity = {}
for line in csv.reader(open("csv/train_data_nights_popularity.csv"), delimiter='\t'):
    train_data_nights_popularity[line[0]] = line[1]

train_data_months_popularity = {}
for line in csv.reader(open("csv/train_data_months_popularity.csv"), delimiter='\t'):
    train_data_months_popularity[line[0]] = line[1]

train_data_compositions_popularity = {}
for line in csv.reader(open("csv/train_data_compositions_popularity.csv"), delimiter='\t'):
    train_data_compositions_popularity[line[0]] = line[1]

train_data_countries_popularity = {}
for line in csv.reader(open("csv/train_data_countries_popularity.csv"), delimiter='\t'):
    train_data_countries_popularity[line[0]] = line[1]

train_data_simple_popularity = {}
for line in csv.reader(open("csv/train_data_simple_popularity.csv"), delimiter='\t'):
    train_data_simple_popularity[line[0]] = line[1]

# --------------------------------------------------------------------------------------
# intersect_data('train', trends=trends, indexes=indexes, add_noise=True, only_bookings=True)
# intersect_data('train', trends=trends, add_noise=True, only_bookings=True)
# intersect_data('test', trends=trends)
intersect_data('test')

