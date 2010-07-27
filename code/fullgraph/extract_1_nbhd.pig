%default TW_OBJ_PATH   '/data/sn/tw/fixd/objects'
%default FIXD_PATH     '/data/sn/tw/fixd'
%default NBRHOOD_PATH  '/data/sn/tw/projects/explorations/bigdata'
%default TMP_PATH      '/tmp/bigdata'
REGISTER /usr/local/share/pig/contrib/piggybank/java/piggybank.jar;

--
--
-- Run this AFTER running the extract_2_nbhd

--
-- Ran this on m1.large (7GB memory) with max 3 mappers and JVM settings of
--
--   "java_child_opts":"-Xmx3152m -XX:+UseCompressedOops -XX:MaxNewSize=200m -server","java_child_ulimit":6670016
--

-- SCHEMAS
a_follows_b            = LOAD '$TW_OBJ_PATH/a_follows_b_2'          	AS (rsrc:chararray, user_a_id:long, user_b_id:long);
a_atsigns_b            = LOAD '$TW_OBJ_PATH/a_atsigns_b_2'          	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long);
a_retweets_b           = LOAD '$TW_OBJ_PATH/a_retweets_b_2'         	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long,    plz_flag:int);
tweet                  = LOAD '$TW_OBJ_PATH/tweet_2'                	AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       in_re_twid:long, text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
twitter_user           = LOAD '$TW_OBJ_PATH/twitter_user_2'         	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long);
twitter_user_profile   = LOAD '$TW_OBJ_PATH/twitter_user_profile_2' 	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, name:chararray,          url:chararray,     location:chararray,   description:chararray,        time_zone:chararray,        utc:chararray);
twitter_user_style     = LOAD '$TW_OBJ_PATH/twitter_user_style_2'   	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, bg_col:chararray,        txt_col:chararray, link_col:chararray,   sidebar_border_col:chararray, sidebar_fill_col:chararray, bg_tile:chararray,     bg_img_url:chararray,       img_url:chararray);
twitter_user_id        = LOAD '$TW_OBJ_PATH/twitter_user_id_2'      	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long,             sid:long,                   is_full:int,        health:chararray);
hashtag                = LOAD '$TW_OBJ_PATH/hashtag_2'              	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
smiley                 = LOAD '$TW_OBJ_PATH/smiley_2'               	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
tweet_url              = LOAD '$TW_OBJ_PATH/tweet_url_2'            	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
stock_token            = LOAD '$TW_OBJ_PATH/stock_token_2'          	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
trstrank               = LOAD '$FIXD_PATH/pagerank/trstrank_2'           AS (screen_name:chararray, uid:long, trstrank:double, tq:int);
wordbag                = LOAD '$FIXD_PATH/word/wordbag_json_2'           AS (uid:long, screen_name:chararray, wordbag_json:chararray);

n2_ids                 = LOAD '$NBRHOOD_PATH/n2_ids_2'     AS (user_id:long);

a_retweets_b_1o_j        = JOIN    a_retweets_b_2           BY user_a_id,   n2_ids BY user_id using 'replicated';
a_retweets_b_1o          = FOREACH a_retweets_b_1o_j        GENERATE rsrc,  user_a_id, user_b_id, twid, plz_flag;
a_retweets_b_1_j         = JOIN    a_retweets_b_1o          BY user_b_id,   n2_ids BY user_id using 'replicated';
a_retweets_b_1           = FOREACH a_retweets_b_1_j         GENERATE rsrc,  user_a_id, user_b_id, twid, plz_flag;
--
a_follows_b_1o_j         = JOIN    a_follows_b_2            BY user_a_id,   n2_ids BY user_id using 'replicated';
a_follows_b_1o           = FOREACH a_follows_b_1o_j         GENERATE rsrc,  user_a_id, user_b_id;
a_follows_b_1_j          = JOIN    a_follows_b_1o           BY user_b_id,   n2_ids BY user_id using 'replicated';
a_follows_b_1            = FOREACH a_follows_b_1_j          GENERATE rsrc,  user_a_id, user_b_id;
--
a_atsigns_b_1o_j         = JOIN    a_atsigns_b_2            BY user_a_id,   n2_ids BY user_id using 'replicated';
a_atsigns_b_1o           = FOREACH a_atsigns_b_1o_j         GENERATE rsrc,  user_a_id, user_b_id, twid;
a_atsigns_b_1_j          = JOIN    a_atsigns_b_1o           BY user_b_id,   n2_ids BY user_id using 'replicated';
a_atsigns_b_1            = FOREACH a_atsigns_b_1_j          GENERATE rsrc,  user_a_id, user_b_id, twid;
--
tweet_1_j                = JOIN    tweet_2                  BY uid,         n2_ids BY user_id using 'replicated';
tweet_1                  = FOREACH tweet_1_j                GENERATE rsrc,  twid, crat, uid, sn, sid, in_re_uid, in_re_sn, in_re_sid, in_re_twid, text, src, iso, lat, lon, was_stw;
--
twitter_user_1_j         = JOIN    twitter_user_2           BY uid,         n2_ids BY user_id using 'replicated';
twitter_user_1           = FOREACH twitter_user_1_j         GENERATE rsrc,  uid, scrat, sn, prot, followers, friends, statuses, favs, crat;
twitter_user_profile_1_j = JOIN    twitter_user_profile     BY uid,         n2_ids BY user_id using 'replicated';
twitter_user_profile_1   = FOREACH twitter_user_profile_1_j GENERATE rsrc,  uid, scrat, sn, name, url, location, description, time_zone, utc;
twitter_user_style_1_j   = JOIN    twitter_user_style       BY uid,         n2_ids BY user_id using 'replicated';
twitter_user_style_1     = FOREACH twitter_user_style_1_j   GENERATE rsrc,  uid, scrat, sn, bg_col, txt_col, link_col, sidebar_border_col, sidebar_fill_col, bg_tile, bg_img_url, img_url;
twitter_user_id_1_j      = JOIN    twitter_user_id          BY uid,         n2_ids BY user_id using 'replicated';
twitter_user_id_1        = FOREACH twitter_user_id_1_j      GENERATE rsrc,  uid, scrat, sn, prot, followers, friends, statuses, favs, crat, sid, is_full, health;
--
hashtag_1_j              = JOIN    hashtag_2                BY uid,         n2_ids BY user_id using 'replicated';
hashtag_1                = FOREACH hashtag_1_j              GENERATE rsrc,  text, uid, twid, crat;
smiley_1_j               = JOIN    smiley                   BY uid,         n2_ids BY user_id using 'replicated';
smiley_1                 = FOREACH smiley_1_j               GENERATE rsrc,  text, uid, twid, crat;
tweet_url_1_j            = JOIN    tweet_url                BY uid,         n2_ids BY user_id using 'replicated';
tweet_url_1              = FOREACH tweet_url_1_j            GENERATE rsrc,  text, uid, twid, crat;
stock_token_1_j          = JOIN    stock_token              BY uid,         n2_ids BY user_id using 'replicated';
stock_token_1            = FOREACH stock_token_1_j          GENERATE rsrc,  text, uid, twid, crat;
--
trstrank_1_j             = JOIN    trstrank_2               BY uid,         n2_ids BY user_id using 'replicated';
trstrank_1               = FOREACH trstrank_1_j             GENERATE 'trstrank' AS rsrc:chararray, uid, screen_name, trstrank, tq;
wordbag_1_j              = JOIN    wordbag_2                BY uid,         n2_ids BY user_id using 'replicated';
wordbag_1                = FOREACH wordbag_1_j              GENERATE 'wordbag' AS rsrc:chararray, uid, screen_name, wordbag_json;
                                                                             
--                                                                           
-- rmf                                $NBRHOOD_PATH/twitter_user_1            
-- STORE twitter_user_1         INTO '$NBRHOOD_PATH/twitter_user_1';         
-- rmf                                $NBRHOOD_PATH/twitter_user_profile_1    
-- STORE twitter_user_profile_1 INTO '$NBRHOOD_PATH/twitter_user_profile_1'; 
-- rmf                                $NBRHOOD_PATH/twitter_user_style_1      
-- STORE twitter_user_style_1   INTO '$NBRHOOD_PATH/twitter_user_style_1';   
-- rmf                                $NBRHOOD_PATH/twitter_user_id_1         
-- STORE twitter_user_id_1      INTO '$NBRHOOD_PATH/twitter_user_id_1';      
--                                                                          
-- rmf                                $NBRHOOD_PATH/hashtag_1                 
-- STORE hashtag_1              INTO '$NBRHOOD_PATH/hashtag_1';              
-- rmf                                $NBRHOOD_PATH/smiley_1                  
-- STORE smiley_1               INTO '$NBRHOOD_PATH/smiley_1';               
-- rmf                                $NBRHOOD_PATH/tweet_url_1               
-- STORE tweet_url_1            INTO '$NBRHOOD_PATH/tweet_url_1';            
-- rmf                                $NBRHOOD_PATH/stock_token_1             
-- STORE stock_token_1          INTO '$NBRHOOD_PATH/stock_token_1';          
--                                                                          
-- rmf                                $NBRHOOD_PATH/trstrank_1                
-- STORE trstrank_1             INTO '$NBRHOOD_PATH/trstrank_1';             
-- rmf                                $NBRHOOD_PATH/wordbag_1                 
-- STORE wordbag_1              INTO '$NBRHOOD_PATH/wordbag_1';              
-- --                                                                       
-- rmf                                $NBRHOOD_PATH/tweet_1                   
-- STORE tweet_1                INTO '$NBRHOOD_PATH/tweet_1';                
-- -- --                                                                    
-- rmf                                $NBRHOOD_PATH/a_atsigns_b_1             
-- STORE a_atsigns_b_1          INTO '$NBRHOOD_PATH/a_atsigns_b_1';          
-- rmf                                $NBRHOOD_PATH/a_follows_b_1             
-- STORE a_follows_b_1          INTO '$NBRHOOD_PATH/a_follows_b_1';          
-- rmf                                $NBRHOOD_PATH/a_retweets_b_1            
-- STORE a_retweets_b_1         INTO '$NBRHOOD_PATH/a_retweets_b_1';         
