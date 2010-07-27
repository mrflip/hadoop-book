%default TW_OBJ_PATH   '/data/sn/tw/fixd/objects'                   
%default NBRHOOD_PATH  '/data/sn/tw/projects/explorations/bigdata'
%default TMP_PATH      '/tmp/bigdata'
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

-- SCHEMAS
a_follows_b              = LOAD '$TW_OBJ_PATH/a_follows_b'  AS (rsrc:chararray, user_a_id:long, user_b_id:long);
a_atsigns_b              = LOAD '$TW_OBJ_PATH/a_atsigns_b'  AS (rsrc:chararray, user_a_id:long, user_b_id:long, twid:long, crat:long);
n1_ids                   = LOAD '$NBRHOOD_PATH/n1_ids'      AS (user_id:long);

--
-- Find all nodes in the in or out 2-neighborhood (at radius 1 from our community, radius 2 from our seed)
--
-- In this first version I didn't think very hard and put the foreach after the join.
--
-- 

--
-- Atsigns from n1_ids
--
-- Input 857M recs / 50GB - Output 9.2M recs 78 MB -- 2.5 mins on 31 m1.large
--
id_at_o_j        = JOIN a_atsigns_b BY user_a_id, n1_ids BY user_id using 'replicated';
id_at_o          = FOREACH id_at_o_j GENERATE a_atsigns_b::user_b_id AS user_id;
-- rmf                      $TMP_PATH/id_at_o
-- STORE id_at_o      INTO '$TMP_PATH/id_at_o';
-- id_at_o          = LOAD '$TMP_PATH/id_at_o'      AS (user_id:long);

--
-- Atsigns in to n1_ids
--
-- Input 857M recs / 50GB - Output 13M recs 115 MB -- 2.2 mins on 31 m1.large
--
id_at_i_j        = JOIN a_atsigns_b BY user_b_id, n1_ids BY user_id using 'replicated';
id_at_i          = FOREACH id_at_i_j GENERATE a_atsigns_b::user_a_id AS user_id;
-- rmf                      $TMP_PATH/id_at_i
-- STORE id_at_i      INTO '$TMP_PATH/id_at_i';
-- id_at_i          = LOAD '$TMP_PATH/id_at_i'      AS (user_id:long);

--
-- Follows from n1_ids
--
-- Input 4.2B recs / 300GB - Output 33M recs / 300 MB --  7 mins on 31 m1.large
--
id_fo_o_j        = JOIN a_follows_b BY user_a_id, n1_ids BY user_id using 'replicated';
id_fo_o          = FOREACH id_fo_o_j GENERATE a_follows_b::user_b_id AS user_id;
-- rmf                      $TMP_PATH/id_fo_o
-- STORE id_fo_o      INTO '$TMP_PATH/id_fo_o';
-- id_fo_o          = LOAD '$TMP_PATH/id_fo_o'      AS (user_id:long);

--
-- Group and count to find all ids by indiscriminate number of edges
--
-- Full data (no filter on seen >= x)
-- Input 500MB / 56M recs - map output 56M recs combiner output 45M recs shuffle 200M - output 4.2M recs / 45MB
-- with  1 reducer  11  mins
-- with 10 reducers  5.8 mins
--
n2_ids_u         = UNION id_at_o, id_at_i, id_fo_o;
n2_ids_g         = GROUP n2_ids_u BY user_id PARALLEL 10;
n2_ids_c         = FOREACH n2_ids_g GENERATE group AS user_id, COUNT(n2_ids_u) AS seen;
n2_ids           = FILTER n2_ids_c BY seen >= 4;
rmf                      $TMP_PATH/n2_ids_2
STORE n2_ids       INTO '$TMP_PATH/n2_ids_2';
n2_ids           = LOAD '$TMP_PATH/n2_ids_2'      AS (user_id:long, seen:long);

--
-- Distribution of records:
--   (about 2.3M of the 4.2M have only one or 2 connections.
--
-- cat /mnt/tmp/bigdata/n2_ids.tsv  | cuttab 2 | sort -n | uniq -c | egrep -v '^ +[12] ' 
-- >> i=0; tot=0; puts %w[ 1450843 857474 327096 233526 153052 119258 92491 77054 63112 54662].map(&:to_i).map{|x| i += 1; tot += x ; [i, x, tot, "%5.2f" % (100 * tot.to_f / 4196303) ].join("\t") }
--
-- 1	1450843	1450843	34.57
-- 2	857474	2308317	55.01
-- 3	327096	2635413	62.80 
-- 4	233526	2868939	68.37 <-- lets keep people with four or more edges (1.56M people)
-- 5	153052	3021991	72.02
-- 6	119258	3141249	74.86
-- 7	92491	3233740	77.06
-- 8	77054	3310794	78.90
-- 9	63112	3373906	80.40
-- 10	54662	3428568	81.70


