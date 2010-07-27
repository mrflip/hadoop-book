%default TW_OBJ_PATH   '/data/sn/tw/fixd/objects'                   
%default NBRHOOD_PATH  '/data/sn/tw/projects/explorations/mrflip'
%default ICS_ID    '15748351L' -- @infochimps
%default HDP_ID    '19041500L' -- @hadoop
%default CLD_ID    '16134540L' -- @cloudera
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

-- Extract all follow edges that originate or terminate on the seed (n1_users)
a_follows_b_1  = FILTER a_follows_b BY
  (user_a_id == $ICS_ID) OR (user_b_id == $ICS_ID) OR
  (user_a_id == $HDP_ID) OR (user_b_id == $HDP_ID) OR
  (user_a_id == $CLD_ID) OR (user_b_id == $CLD_ID)
  ;
rmf                            $NBRHOOD_PATH/a_follows_b_1  
STORE a_follows_b_1      INTO '$NBRHOOD_PATH/a_follows_b_1';  
a_follows_b_1          = LOAD '$NBRHOOD_PATH/a_follows_b_1'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long);

-- Extract all tweets from, to, or mentioning on the seed (n1)
tweet_1  = FILTER tweet BY
  (org.apache.pig.piggybank.evaluation.string.UPPER(text) MATCHES '.*\\b(HADOOP|INFOCHIMPS?|CLOUDERA|MAP\\W*REDUCE|NETWORK\\W*GRAPH|BIG\\W*DATA)\\b.*') OR
  (uid == $ICS_ID) OR (in_re_uid == $ICS_ID) OR 
  (uid == $HDP_ID) OR (in_re_uid == $HDP_ID) OR 
  (uid == $CLD_ID) OR (in_re_uid == $CLD_ID)
  ;
-- tweet_1    = FOREACH tweet_1_f GENERATE
--         twid, crat, uid, sn, in_re_uid, in_re_sn, 
--         org.apache.pig.piggybank.evaluation.string.RegexExtract(text, '.*\\b(HADOOP|INFOCHIMPS?|CLOUDERA|MAP\\W*REDUCE|NETWORK\\W*GRAPH|BIG\\W*DATA)\\b.*', 0);
--         src, iso, lat, lon, text);
rmf                            $NBRHOOD_PATH/tweet_1
STORE tweet_1            INTO '$NBRHOOD_PATH/tweet_1';
tweet_1                = LOAD '$NBRHOOD_PATH/tweet_1'                 	AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);

--
-- Isolate all user id's in the community
--

id_fo_a    = FOREACH a_follows_b_1 GENERATE user_a_id AS user_id;
id_fo_b    = FOREACH a_follows_b_1 GENERATE user_b_id AS user_id;
id_tw      = FOREACH tweet_1       GENERATE uid       AS user_id;
id_tw_re   = FOREACH tweet_1       GENERATE in_re_uid AS user_id;
n1_ids_all = UNION id_fo_a, id_fo_b, id_tw, id_tw_re ;
n1_ids     = DISTINCT n1_ids_all PARALLEL 1;
rmf                            $NBRHOOD_PATH/n1_ids
STORE user_ids           INTO '$NBRHOOD_PATH/n1_ids';
user_ids               = LOAD '$NBRHOOD_PATH/n1_ids'                 	AS (user_id:long);
