Источник
is_mobile                       -- сомнительная полезность
channel                         -- сомнительная полезность

Откуда
user_location_country           --
user_location_region            -- 1К вариантов
user_location_city              -- 40К вариантов

Кто
srch_adults_cnt                 -- может иметь сильную корреляцию с кластером
srch_children_cnt               -- может иметь сильную корреляцию с кластером
srch_rm_cnt                     -- думаю, бесполезная фича
srch_adults_children_cnt        -- скорее всего имеет низкую корреляцию с кластером отеля, слишком много вариантов, проверить
srch_adults_children_flag       -- определяет семейный/индивидуальный вид размещения

Как
is_package                      -- полезность, возможно, преувеличена. перепроверить.

Куда
srch_destination_id             -- 16К вариантов
srch_destination_type_id        -- вид отдыха
hotel_continent                 -- бесполезная фича
hotel_country                   --
hotel_market                    -- 2К вариантов

Когда и на сколько
search_month                    -- может влиять на тип отдыха и следовательно кластер отеля
search_weeks_diff               -- сомнительная полезность фичи, проверить
search_nights                   -- продолжительность отдыха коррелирует с кластером отеля




