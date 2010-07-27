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

--
-- Atsigns in and out, and follows in, from n1_ids
--
at_user_a        = FOREACH a_atsigns_b GENERATE user_a_id AS user_id;
at_user_b        = FOREACH a_atsigns_b GENERATE user_b_id AS user_id;
fo_user_b        = FOREACH a_follows_b GENERATE user_b_id AS user_id;
user_ids         = UNION at_user_a, at_user_b, fo_user_b;
n2_ids_j         = JOIN user_ids BY user_id, n1_ids BY user_id using 'replicated';
n2_ids_u         = FOREACH n2_ids_j GENERATE n1_ids::user_id AS user_id;

--
-- Group and count on ID
-- 
n2_ids_g         = GROUP n2_ids_u BY user_id PARALLEL 10;
n2_ids_c         = FOREACH n2_ids_g GENERATE group AS user_id, COUNT(n2_ids_u) AS seen;
n2_ids           = FILTER n2_ids_c BY seen >= 4;
rmf                      $TMP_PATH/n2_ids_3
STORE n2_ids       INTO '$TMP_PATH/n2_ids_3';
n2_ids           = LOAD '$TMP_PATH/n2_ids_3'      AS (user_id:long, seen:long);

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


