
-- --
-- -- Atsigns from n1_ids
-- at_user_b        = FOREACH a_atsigns_b GENERATE user_b_id AS user_id;
-- id_at_o_j        = JOIN at_user_b BY user_id, n1_ids BY user_id using 'replicated';
-- id_at_o          = FOREACH id_at_o_j GENERATE n1_ids::user_id AS user_id;
-- -- Atsigns in to n1_ids
-- at_user_a        = FOREACH a_atsigns_b GENERATE user_a_id AS user_id;
-- id_at_i_j        = JOIN at_user_a BY user_id, n1_ids BY user_id using 'replicated';
-- id_at_i          = FOREACH id_at_i_j GENERATE n1_ids::user_id AS user_id;
-- -- Follows from n1_ids
-- fo_user_b        = FOREACH a_follows_b GENERATE user_b_id AS user_id;
-- id_fo_o_j        = JOIN fo_user_b BY user_id, n1_ids BY user_id using 'replicated';
-- id_fo_o          = FOREACH id_fo_o_j GENERATE n1_ids::user_id AS user_id;

-- --
-- -- Group and count to find all ids by indiscriminate number of edges
-- --
-- -- Full data (no filter on seen >= x)
-- -- Input 500MB / 56M recs - map output 56M recs combiner output 45M recs shuffle 200M - output 4.2M recs / 45MB
-- -- with  1 reducer  11  mins
-- -- with 10 reducers  5.8 mins
-- --
-- n2_ids_u         = UNION id_at_o, id_at_i, id_fo_o;
-- n2_ids_g         = GROUP n2_ids_u BY user_id PARALLEL 10;
-- n2_ids_c         = FOREACH n2_ids_g GENERATE group AS user_id, COUNT(n2_ids_u) AS seen;
-- n2_ids           = FILTER n2_ids_c BY seen >= 4;
-- rmf                      $TMP_PATH/n2_ids_2
-- STORE n2_ids       INTO '$TMP_PATH/n2_ids_2';
-- n2_ids           = LOAD '$TMP_PATH/n2_ids_2'      AS (user_id:long, seen:long);
