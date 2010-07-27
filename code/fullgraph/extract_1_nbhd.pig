%default TW_OBJ_PATH   '/data/sn/tw/fixd/objects'
%default FIXD_PATH     '/data/sn/tw/fixd'
%default NBRHOOD2_PATH  '/data/sn/tw/projects/explorations/bigdata'
%default NBRHOOD1_PATH  '/data/sn/tw/projects/explorations/bigdata_1'
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
a_retweets_b_2           = LOAD '$NBRHOOD2_PATH/a_retweets_b_2'         	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long,    plz_flag:int);
a_atsigns_b_2            = LOAD '$NBRHOOD2_PATH/a_atsigns_b_2'          	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long);
a_follows_b_2            = LOAD '$NBRHOOD2_PATH/a_follows_b_2'          	AS (rsrc:chararray, user_a_id:long, user_b_id:long);
tweet_2                  = LOAD '$NBRHOOD2_PATH/tweet_2'                	AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       in_re_twid:long, text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
twitter_user_2           = LOAD '$NBRHOOD2_PATH/twitter_user_2'         	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long);
twitter_user_profile_2   = LOAD '$NBRHOOD2_PATH/twitter_user_profile_2' 	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, name:chararray,          url:chararray,     location:chararray,   description:chararray,        time_zone:chararray,        utc:chararray);
twitter_user_style_2     = LOAD '$NBRHOOD2_PATH/twitter_user_style_2'   	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, bg_col:chararray,        txt_col:chararray, link_col:chararray,   sidebar_border_col:chararray, sidebar_fill_col:chararray, bg_tile:chararray,     bg_img_url:chararray,       img_url:chararray);
twitter_user_id_2        = LOAD '$NBRHOOD2_PATH/twitter_user_id_2'      	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long,             sid:long,                   is_full:int,        health:chararray);
hashtag_2                = LOAD '$NBRHOOD2_PATH/hashtag_2'              	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
smiley_2                 = LOAD '$NBRHOOD2_PATH/smiley_2'               	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
tweet_url_2              = LOAD '$NBRHOOD2_PATH/tweet_url_2'            	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
stock_token_2            = LOAD '$NBRHOOD2_PATH/stock_token_2'          	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
trstrank_2               = LOAD '$NBRHOOD2_PATH/pagerank/trstrank_2'    	AS (rsrc:chararray, uid:long, screen_name:chararray, trstrank:double, tq:int);
wordbag_2                = LOAD '$NBRHOOD2_PATH/word/wordbag_json_2'    	AS (rsrc:chararray, uid:long, screen_name:chararray, wordbag_json:chararray);

n1_ids                   = LOAD '$NBRHOOD2_PATH/n1_ids'     AS (user_id:long);

a_retweets_b_1o_j        = JOIN    a_retweets_b_2           BY user_a_id,   n1_ids BY user_id using 'replicated';
a_retweets_b_1o          = FOREACH a_retweets_b_1o_j        GENERATE rsrc,  user_a_id, user_b_id, twid, plz_flag;
a_retweets_b_1_j         = JOIN    a_retweets_b_1o          BY user_b_id,   n1_ids BY user_id using 'replicated';
a_retweets_b_1           = FOREACH a_retweets_b_1_j         GENERATE rsrc,  user_a_id, user_b_id, twid, plz_flag;
--
a_atsigns_b_1o_j         = JOIN    a_atsigns_b_2            BY user_a_id,   n1_ids BY user_id using 'replicated';
a_atsigns_b_1o           = FOREACH a_atsigns_b_1o_j         GENERATE rsrc,  user_a_id, user_b_id, twid;
a_atsigns_b_1_j          = JOIN    a_atsigns_b_1o           BY user_b_id,   n1_ids BY user_id using 'replicated';
a_atsigns_b_1            = FOREACH a_atsigns_b_1_j          GENERATE rsrc,  user_a_id, user_b_id, twid;
--
a_follows_b_1o_j         = JOIN    a_follows_b_2            BY user_a_id,   n1_ids BY user_id using 'replicated';
a_follows_b_1o           = FOREACH a_follows_b_1o_j         GENERATE rsrc,  user_a_id, user_b_id;
a_follows_b_1_j          = JOIN    a_follows_b_1o           BY user_b_id,   n1_ids BY user_id using 'replicated';
a_follows_b_1            = FOREACH a_follows_b_1_j          GENERATE rsrc,  user_a_id, user_b_id;
--
tweet_1_j                = JOIN    tweet_2                  BY uid,         n1_ids BY user_id using 'replicated';
tweet_1                  = FOREACH tweet_1_j                GENERATE rsrc,  twid, crat, uid, sn, sid, in_re_uid, in_re_sn, in_re_sid, in_re_twid, text, src, iso, lat, lon, was_stw;
--
twitter_user_1_j         = JOIN    twitter_user_2           BY uid,         n1_ids BY user_id using 'replicated';
twitter_user_1           = FOREACH twitter_user_1_j         GENERATE rsrc,  uid, scrat, sn, prot, followers, friends, statuses, favs, crat;
twitter_user_profile_1_j = JOIN    twitter_user_profile_2   BY uid,         n1_ids BY user_id using 'replicated';
twitter_user_profile_1   = FOREACH twitter_user_profile_1_j GENERATE rsrc,  uid, scrat, sn, name, url, location, description, time_zone, utc;
twitter_user_style_1_j   = JOIN    twitter_user_style_2     BY uid,         n1_ids BY user_id using 'replicated';
twitter_user_style_1     = FOREACH twitter_user_style_1_j   GENERATE rsrc,  uid, scrat, sn, bg_col, txt_col, link_col, sidebar_border_col, sidebar_fill_col, bg_tile, bg_img_url, img_url;
twitter_user_id_1_j      = JOIN    twitter_user_id_2        BY uid,         n1_ids BY user_id using 'replicated';
twitter_user_id_1        = FOREACH twitter_user_id_1_j      GENERATE rsrc,  uid, scrat, sn, prot, followers, friends, statuses, favs, crat, sid, is_full, health;
--
hashtag_1_j              = JOIN    hashtag_2                BY uid,         n1_ids BY user_id using 'replicated';
hashtag_1                = FOREACH hashtag_1_j              GENERATE rsrc,  text, uid, twid, crat;
smiley_1_j               = JOIN    smiley_2                 BY uid,         n1_ids BY user_id using 'replicated';
smiley_1                 = FOREACH smiley_1_j               GENERATE rsrc,  text, uid, twid, crat;
tweet_url_1_j            = JOIN    tweet_url_2              BY uid,         n1_ids BY user_id using 'replicated';
tweet_url_1              = FOREACH tweet_url_1_j            GENERATE rsrc,  text, uid, twid, crat;
stock_token_1_j          = JOIN    stock_token_2            BY uid,         n1_ids BY user_id using 'replicated';
stock_token_1            = FOREACH stock_token_1_j          GENERATE rsrc,  text, uid, twid, crat;
--
trstrank_1_j             = JOIN    trstrank_2               BY uid,         n1_ids BY user_id using 'replicated';
trstrank_1               = FOREACH trstrank_1_j             GENERATE rsrc,  uid, screen_name, trstrank, tq;
wordbag_1_j              = JOIN    wordbag_2                BY uid,         n1_ids BY user_id using 'replicated';
wordbag_1                = FOREACH wordbag_1_j              GENERATE rsrc,  uid, screen_name, wordbag_json;


a_retweets_b_1            = ORDER a_retweets_b_1         BY user_a_id ASC PARALLEL 1;
a_atsigns_b_1             = ORDER a_atsigns_b_1          BY user_a_id ASC PARALLEL 1;
a_follows_b_1             = ORDER a_follows_b_1          BY user_a_id ASC PARALLEL 1;

twitter_user_1            = ORDER twitter_user_1         BY uid ASC       PARALLEL 1;
twitter_user_profile_1    = ORDER twitter_user_profile_1 BY uid ASC       PARALLEL 1;
twitter_user_style_1      = ORDER twitter_user_style_1   BY uid ASC       PARALLEL 1;
twitter_user_id_1         = ORDER twitter_user_id_1      BY uid ASC       PARALLEL 1;

trstrank_1                = ORDER trstrank_1             BY uid ASC       PARALLEL 1;
wordbag_1                 = ORDER wordbag_1              BY uid ASC       PARALLEL 1;

hashtag_1                 = ORDER hashtag_1              BY uid ASC       PARALLEL 1;
smiley_1                  = ORDER smiley_1               BY uid ASC       PARALLEL 1;
tweet_url_1               = ORDER tweet_url_1            BY uid ASC       PARALLEL 1;
stock_token_1             = ORDER stock_token_1          BY uid ASC       PARALLEL 1;

                                                                          
rmf                                $NBRHOOD1_PATH/twitter_user_1            
STORE twitter_user_1         INTO '$NBRHOOD1_PATH/twitter_user_1';         
rmf                                $NBRHOOD1_PATH/twitter_user_profile_1    
STORE twitter_user_profile_1 INTO '$NBRHOOD1_PATH/twitter_user_profile_1'; 
rmf                                $NBRHOOD1_PATH/twitter_user_style_1      
STORE twitter_user_style_1   INTO '$NBRHOOD1_PATH/twitter_user_style_1';   
rmf                                $NBRHOOD1_PATH/twitter_user_id_1         
STORE twitter_user_id_1      INTO '$NBRHOOD1_PATH/twitter_user_id_1';      
                                                                         
-- rmf                                $NBRHOOD1_PATH/hashtag_1                 
-- STORE hashtag_1              INTO '$NBRHOOD1_PATH/hashtag_1';              
-- rmf                                $NBRHOOD1_PATH/smiley_1                  
-- STORE smiley_1               INTO '$NBRHOOD1_PATH/smiley_1';               
-- rmf                                $NBRHOOD1_PATH/tweet_url_1               
-- STORE tweet_url_1            INTO '$NBRHOOD1_PATH/tweet_url_1';            
-- rmf                                $NBRHOOD1_PATH/stock_token_1             
-- STORE stock_token_1          INTO '$NBRHOOD1_PATH/stock_token_1';          
                                                                         
rmf                                $NBRHOOD1_PATH/trstrank_1                
STORE trstrank_1             INTO '$NBRHOOD1_PATH/trstrank_1';             
rmf                                $NBRHOOD1_PATH/wordbag_1                 
STORE wordbag_1              INTO '$NBRHOOD1_PATH/wordbag_1';              
--                                                                       
rmf                                $NBRHOOD1_PATH/tweet_1                   
STORE tweet_1                INTO '$NBRHOOD1_PATH/tweet_1';                
-- --                                                                    
rmf                                $NBRHOOD1_PATH/a_atsigns_b_1             
STORE a_atsigns_b_1          INTO '$NBRHOOD1_PATH/a_atsigns_b_1';          
rmf                                $NBRHOOD1_PATH/a_retweets_b_1            
STORE a_retweets_b_1         INTO '$NBRHOOD1_PATH/a_retweets_b_1';         
-- rmf                                $NBRHOOD1_PATH/a_follows_b_1             
-- STORE a_follows_b_1          INTO '$NBRHOOD1_PATH/a_follows_b_1';          
