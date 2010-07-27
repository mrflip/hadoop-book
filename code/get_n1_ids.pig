%default TW_OBJ_PATH   '/data/sn/tw/fixd/objects'                   
%default NBRHOOD_PATH  '/data/sn/tw/projects/explorations/bigdata'
%default ICS_ID    '15748351L' -- @infochimps
%default HDP_ID    '19041500L' -- @hadoop
%default CLD_ID    '16134540L' -- @cloudera
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

--
-- Take the seed and extract all actors in the community.
--
-- This is similar to the community extraction done in the book, but our n0 is
-- three entities + six terms, and we are following edges on the social graph (a
-- mentions, follows, replies b) and the term usage graph (a uses term y)
--


-- Schema -- /part-00035 both
a_follows_b       = LOAD '$TW_OBJ_PATH/a_follows_b'     AS (rsrc:chararray, user_a_id:long, user_b_id:long);
tweet             = LOAD '$TW_OBJ_PATH/tweet'           AS (rsrc:chararray, twid:long, crat:long, uid:long, sn:chararray, sid:long, in_re_uid:long, in_re_sn:chararray, in_re_sid:long, in_re_twid:long, text:chararray, src:chararray, iso:chararray, lat:float, lon:float, was_stw:int);


-- -- ===========================================================================
-- --
-- -- Extract all follow edges that originate or terminate on the seed (n1_users)
-- --
-- -- On 31 x m1.large (7GB), 142 GB input / 4.2B records => 0.3 MB / 11k recs output; 6.5 minutes
-- --
-- a_follows_b_1  = FILTER a_follows_b BY
--   (user_a_id == $ICS_ID) OR (user_b_id == $ICS_ID) OR
--   (user_a_id == $HDP_ID) OR (user_b_id == $HDP_ID) OR
--   (user_a_id == $CLD_ID) OR (user_b_id == $CLD_ID)
--   ;
-- rmf                       $NBRHOOD_PATH/a_follows_b_1  
-- STORE a_follows_b_1 INTO '$NBRHOOD_PATH/a_follows_b_1';  
a_follows_b_1     = LOAD '$NBRHOOD_PATH/a_follows_b_1'  AS (rsrc:chararray, user_a_id:long, user_b_id:long);


-- -- ===========================================================================
-- --
-- -- Extract all tweets from, to, or mentioning on the seed (n1)
-- --
-- -- On 31 x m1.large (7GB), 515 GB input / 2B records => 16 MB / 53k recs output; 24 minutes
-- --
-- tweet_1  = FILTER tweet BY
--   (org.apache.pig.piggybank.evaluation.string.UPPER(text) MATCHES '.*\\b(HADOOP|INFOCHIMPS?|CLOUDERA|MAP\\W*REDUCE|NETWORK\\W*GRAPH|BIG\\W*DATA)\\b.*') OR
--   (uid == $ICS_ID) OR (in_re_uid == $ICS_ID) OR 
--   (uid == $HDP_ID) OR (in_re_uid == $HDP_ID) OR 
--   (uid == $CLD_ID) OR (in_re_uid == $CLD_ID)
--   ;
-- -- tweet_1    = FOREACH tweet_1_f GENERATE
-- --         twid, crat, uid, sn, in_re_uid, in_re_sn, 
-- --         org.apache.pig.piggybank.evaluation.string.RegexExtract(text, '.*\\b(HADOOP|INFOCHIMPS?|CLOUDERA|MAP\\W*REDUCE|NETWORK\\W*GRAPH|BIG\\W*DATA)\\b.*', 0);
-- --         src, iso, lat, lon, text);
-- rmf                       $NBRHOOD_PATH/tweet_1
-- STORE tweet_1       INTO '$NBRHOOD_PATH/tweet_1';
tweet_1           = LOAD '$NBRHOOD_PATH/tweet_1'       	AS (rsrc:chararray, twid:long, crat:long, uid:long, sn:chararray, sid:long, in_re_uid:long, in_re_sn:chararray, in_re_sid:long, in_re_twid:long, text:chararray, src:chararray, iso:chararray, lat:float, lon:float, was_stw:int);

--
-- Optional: cleanup after run
--
-- hdp-mv /data/sn/tw/projects/explorations/bigdata/tweet_1 /tmp
-- hdp-catd /tmp/tweet_1       | sort -nk4 | hdp-put - /data/sn/tw/projects/explorations/bigdata/tweet_1
-- hdp-mv /data/sn/tw/projects/explorations/bigdata/a_follows_b_1 /tmp
-- hdp-catd /tmp/a_follows_b_1 | sort -nk2 | hdp-put - /data/sn/tw/projects/explorations/bigdata/a_follows_b_1

-- ===========================================================================
--
-- Extract all user id's in the community
--
-- MapReduces: 1/0, 1/0, 4/1 in about a minute wall-clock time. 22k output records, 0.2 MB
--

id_fo_a    = FOREACH a_follows_b_1 GENERATE user_a_id   AS user_id; 
id_fo_b    = FOREACH a_follows_b_1 GENERATE user_b_id   AS user_id; 
id_tw      = FOREACH tweet_1       GENERATE uid         AS user_id; 
id_tw_re   = FOREACH tweet_1       GENERATE in_re_uid   AS user_id; id_tw_re = FILTER id_tw_re BY (user_id IS NOT NULL);
n1_ids_all = UNION id_fo_a, id_fo_b, id_tw, id_tw_re ;
n1_ids     = DISTINCT n1_ids_all PARALLEL 1;
rmf                     $NBRHOOD_PATH/n1_ids
STORE n1_ids      INTO '$NBRHOOD_PATH/n1_ids';
n1_ids          = LOAD '$NBRHOOD_PATH/n1_ids'           AS (user_id:long);

-- hdp-mv   /data/sn/tw/projects/explorations/bigdata/n1_ids /tmp/n1_ids
-- hdp-catd /tmp/n1_ids | hdp-put - /data/sn/tw/projects/explorations/bigdata/n1_ids 
-- mkdir /mnt/tmp/bigdata
-- hdp-cat /data/sn/tw/projects/explorations/bigdata/n1_ids        > /mnt/tmp/bigdata/n1_ids.tsv
-- hdp-cat /data/sn/tw/projects/explorations/bigdata/a_follows_b_1 > /mnt/tmp/bigdata/a_follows_b_1.tsv
-- hdp-cat /data/sn/tw/projects/explorations/bigdata/tweet_1       > /mnt/tmp/bigdata/tweet_1.tsv
