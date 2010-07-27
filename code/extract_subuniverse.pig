%default TW_OBJ_PATH   '/data/sn/tw/fixd/objects'                   
%default NBRHOOD_PATH  '/data/sn/tw/projects/explorations/bigdata'
%default TMP_PATH      '/tmp/bigdata'
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

--
-- Ran this on m1.large (7GB memory) with max 3 mappers and JVM settings of
--
--   "java_child_opts":"-Xmx3152m -XX:+UseCompressedOops -XX:MaxNewSize=200m -server","java_child_ulimit":6670016
-- 

-- SCHEMAS
a_follows_b            = LOAD '$TW_OBJ_PATH/a_follows_b'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long);                                                                                                                                                                                                                                                                    
a_atsigns_b            = LOAD '$TW_OBJ_PATH/a_atsigns_b'           	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long);
a_retweets_b           = LOAD '$TW_OBJ_PATH/a_retweets_b'          	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long,    plz_flag:int);
tweet                  = LOAD '$TW_OBJ_PATH/tweet'                 	AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       in_re_twid:long, text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
twitter_user           = LOAD '$TW_OBJ_PATH/twitter_user'          	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long);                                                                             
twitter_user_profile   = LOAD '$TW_OBJ_PATH/twitter_user_profile'  	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, name:chararray,          url:chararray,     location:chararray,   description:chararray,        time_zone:chararray,        utc:chararray);                                                                           
twitter_user_style     = LOAD '$TW_OBJ_PATH/twitter_user_style'    	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, bg_col:chararray,        txt_col:chararray, link_col:chararray,   sidebar_border_col:chararray, sidebar_fill_col:chararray, bg_tile:chararray,     bg_img_url:chararray,       img_url:chararray);                         
twitter_user_id        = LOAD '$TW_OBJ_PATH/twitter_user_id'       	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long,             sid:long,                   is_full:int,        health:chararray);
hashtag                = LOAD '$TW_OBJ_PATH/hashtag'               	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                           
smiley                 = LOAD '$TW_OBJ_PATH/smiley'                	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                           
tweet_url              = LOAD '$TW_OBJ_PATH/tweet_url'             	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);                                                           
stock_token            = LOAD '$TW_OBJ_PATH/stock_token'           	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);

n2_ids                 = LOAD '$NBRHOOD_PATH/n2_ids'      AS (user_id:long);


-- /data/sn/tw/fixd/apeyeye/conversation                                  	     8394070549	         7.8 GB
-- /data/sn/tw/fixd/apeyeye/influence                                     	     8078040256	         7.5 GB
-- /data/sn/tw/fixd/apeyeye/trstrank                                      	     7104946076	         6.6 GB
-- /data/sn/tw/fixd/pagerank/trstrank
-- /data/sn/tw/fixd/word/extracted_user_wordbag_json

a_follows_b_2o_j         = JOIN    a_follows_b              BY user_a_id,   n2_ids BY user_id using 'replicated';
a_follows_b_2o           = FOREACH a_follows_b_2o_j         GENERATE rsrc,  user_a_id, user_b_id; 
a_atsigns_b_2o_j         = JOIN    a_atsigns_b              BY user_a_id,   n2_ids BY user_id using 'replicated';
a_atsigns_b_2o           = FOREACH a_atsigns_b_2o_j         GENERATE rsrc,  user_a_id, user_b_id, twid;
a_retweets_b_2o_j        = JOIN    a_retweets_b             BY user_a_id,   n2_ids BY user_id using 'replicated';
a_retweets_b_2o          = FOREACH a_retweets_b_2o_j        GENERATE rsrc,  user_a_id, user_b_id, twid, plz_flag;
--
a_follows_b_2i_j         = JOIN    a_follows_b              BY user_b_id,   n2_ids BY user_id using 'replicated';
a_follows_b_2i           = FOREACH a_follows_b_2i_j         GENERATE rsrc,  user_a_id, user_b_id; 
a_atsigns_b_2i_j         = JOIN    a_atsigns_b              BY user_b_id,   n2_ids BY user_id using 'replicated';
a_atsigns_b_2i           = FOREACH a_atsigns_b_2i_j         GENERATE rsrc,  user_a_id, user_b_id, twid;
a_retweets_b_2i_j        = JOIN    a_retweets_b             BY user_b_id,   n2_ids BY user_id using 'replicated';
a_retweets_b_2i          = FOREACH a_retweets_b_2i_j        GENERATE rsrc,  user_a_id, user_b_id, twid, plz_flag;
--
tweet_2_j                = JOIN    tweet                    BY uid,         n2_ids BY user_id using 'replicated';
tweet_2                  = FOREACH tweet_2_j                GENERATE rsrc,  twid, crat, uid, sn, sid, in_re_uid, in_re_sn, in_re_sid, in_re_twid, text, src, iso, lat, lon, was_stw;
twitter_user_2_j         = JOIN    twitter_user             BY uid,         n2_ids BY user_id using 'replicated';
twitter_user_2           = FOREACH twitter_user_2_j         GENERATE rsrc,  uid, scrat, sn, prot, followers, friends, statuses, favs, crat; 
twitter_user_profile_2_j = JOIN    twitter_user_profile     BY uid,         n2_ids BY user_id using 'replicated';
twitter_user_profile_2   = FOREACH twitter_user_profile_2_j GENERATE rsrc,  uid, scrat, sn, name, url, location, description, time_zone, utc; 
twitter_user_style_2_j   = JOIN    twitter_user_style       BY uid,         n2_ids BY user_id using 'replicated';
twitter_user_style_2     = FOREACH twitter_user_style_2_j   GENERATE rsrc,  uid, scrat, sn, bg_col, txt_col, link_col, sidebar_border_col, sidebar_fill_col, bg_tile, bg_img_url, img_url; 
twitter_user_id_2_j      = JOIN    twitter_user_id          BY uid,         n2_ids BY user_id using 'replicated';
twitter_user_id_2        = FOREACH twitter_user_id_2_j      GENERATE rsrc,  uid, scrat, sn, prot, followers, friends, statuses, favs, crat, sid, is_full, health;
hashtag_2_j              = JOIN    hashtag                  BY uid,         n2_ids BY user_id using 'replicated';
hashtag_2                = FOREACH hashtag_2_j              GENERATE rsrc,  text, uid, twid, crat; 
smiley_2_j               = JOIN    smiley                   BY uid,         n2_ids BY user_id using 'replicated';
smiley_2                 = FOREACH smiley_2_j               GENERATE rsrc,  text, uid, twid, crat; 
tweet_url_2_j            = JOIN    tweet_url                BY uid,         n2_ids BY user_id using 'replicated';
tweet_url_2              = FOREACH tweet_url_2_j            GENERATE rsrc,  text, uid, twid, crat; 
stock_token_2_j          = JOIN    stock_token              BY uid,         n2_ids BY user_id using 'replicated';
stock_token_2            = FOREACH stock_token_2_j          GENERATE rsrc,  text, uid, twid, crat;

-- rmf                                   $NBRHOOD_PATH/twitter_user_2
-- STORE twitter_user_2            INTO '$NBRHOOD_PATH/twitter_user_2';
-- rmf                                   $NBRHOOD_PATH/twitter_user_profile_2
-- STORE twitter_user_profile_2    INTO '$NBRHOOD_PATH/twitter_user_profile_2';
-- rmf                                   $NBRHOOD_PATH/twitter_user_style_2
-- STORE twitter_user_style_2      INTO '$NBRHOOD_PATH/twitter_user_style_2';
-- rmf                                   $NBRHOOD_PATH/twitter_user_id_2
-- STORE twitter_user_id_2         INTO '$NBRHOOD_PATH/twitter_user_id_2';
-- rmf                                   $NBRHOOD_PATH/hashtag_2
-- STORE hashtag_2                 INTO '$NBRHOOD_PATH/hashtag_2';
-- rmf                                   $NBRHOOD_PATH/smiley_2
-- STORE smiley_2                  INTO '$NBRHOOD_PATH/smiley_2';
-- rmf                                   $NBRHOOD_PATH/tweet_url_2
-- STORE tweet_url_2               INTO '$NBRHOOD_PATH/tweet_url_2';
-- rmf                                   $NBRHOOD_PATH/stock_token_2
-- STORE stock_token_2             INTO '$NBRHOOD_PATH/stock_token_2';
--
rmf                                   $NBRHOOD_PATH/a_follows_b_2o
STORE a_follows_b_2o            INTO '$NBRHOOD_PATH/a_follows_b_2o';
rmf                                   $NBRHOOD_PATH/a_atsigns_b_2o
STORE a_atsigns_b_2o            INTO '$NBRHOOD_PATH/a_atsigns_b_2o';
rmf                                   $NBRHOOD_PATH/a_retweets_b_2o
STORE a_retweets_b_2o           INTO '$NBRHOOD_PATH/a_retweets_b_2o';
rmf                                   $NBRHOOD_PATH/a_follows_b_2i
STORE a_follows_b_2i            INTO '$NBRHOOD_PATH/a_follows_b_2i';
rmf                                   $NBRHOOD_PATH/a_atsigns_b_2i
STORE a_atsigns_b_2i            INTO '$NBRHOOD_PATH/a_atsigns_b_2i';
rmf                                   $NBRHOOD_PATH/a_retweets_b_2i
STORE a_retweets_b_2i           INTO '$NBRHOOD_PATH/a_retweets_b_2i';
rmf                                   $NBRHOOD_PATH/tweet_2
STORE tweet_2                   INTO '$NBRHOOD_PATH/tweet_2';
