%default TW_OBJ_PATH   '/data/sn/tw/fixd/objects'
%default FIXD_PATH     '/data/sn/tw/fixd'
%default NBRHOOD2_PATH  '/data/sn/tw/projects/explorations/bigdata_2'
%default NBRHOOD_PATH   '/data/sn/tw/projects/explorations/bigdata'
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
a_follows_b_2            = LOAD '$NBRHOOD2_PATH/a_follows_b_2'          	AS (rsrc:chararray, user_a_id:long, user_b_id:long);
a_atsigns_b_2            = LOAD '$NBRHOOD2_PATH/a_atsigns_b_2'          	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long);
a_retweets_b_2           = LOAD '$NBRHOOD2_PATH/a_retweets_b_2'         	AS (rsrc:chararray, user_a_id:long, user_b_id:long,        twid:long,    plz_flag:int);
tweet_2                  = LOAD '$NBRHOOD2_PATH/tweet_2'                	AS (rsrc:chararray, twid:long,      crat:long,             uid:long,     sn:chararray,            sid:long,          in_re_uid:long, in_re_sn:chararray,     in_re_sid:long,       in_re_twid:long, text:chararray,        src:chararray,              iso:chararray,      lat:float, lon:float, was_stw:int);
twitter_user_2           = LOAD '$NBRHOOD2_PATH/twitter_user_2'         	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long);
twitter_user_profile_2   = LOAD '$NBRHOOD2_PATH/twitter_user_profile_2' 	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, name:chararray,          url:chararray,     location:chararray,   description:chararray,        time_zone:chararray,        utc:chararray);
twitter_user_style_2     = LOAD '$NBRHOOD2_PATH/twitter_user_style_2'   	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, bg_col:chararray,        txt_col:chararray, link_col:chararray,   sidebar_border_col:chararray, sidebar_fill_col:chararray, bg_tile:chararray,     bg_img_url:chararray,       img_url:chararray);
twitter_user_id_2        = LOAD '$NBRHOOD2_PATH/twitter_user_id_2'      	AS (rsrc:chararray, uid:long,       scrat:long,            sn:chararray, prot:int,                followers:int,     friends:int,          statuses:int,                 favs:int,                   crat:long,             sid:long,                   is_full:int,        health:chararray);
hashtag_2                = LOAD '$NBRHOOD2_PATH/hashtag_2'              	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
smiley_2                 = LOAD '$NBRHOOD2_PATH/smiley_2'               	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
tweet_url_2              = LOAD '$NBRHOOD2_PATH/tweet_url_2'            	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
stock_token_2            = LOAD '$NBRHOOD2_PATH/stock_token_2'          	AS (rsrc:chararray, text:chararray, uid:long,              twid:long,    crat:long);
trstrank_2               = LOAD '$NBRHOOD2_PATH/pagerank/trstrank_2'            AS (rsrc:chararray, uid:long, screen_name:chararray, trstrank:double, tq:int);
wordbag_2                = LOAD '$NBRHOOD2_PATH/wordbag_2'                      AS (rsrc:chararray, uid:long, screen_name:chararray, wordbag_json:chararray);

twitter_user_2           = ORDER twitter_user_2         BY uid ASC PARALLEL 10;
twitter_user_profile_2   = ORDER twitter_user_profile_2 BY uid ASC PARALLEL 20;
twitter_user_style_2     = ORDER twitter_user_style_2   BY uid ASC PARALLEL 20;
twitter_user_id_2        = ORDER twitter_user_id_2      BY uid ASC PARALLEL 10;
wordbag_2                = ORDER wordbag_2              BY uid ASC PARALLEL 10;
a_atsigns_b_2            = ORDER a_atsigns_b_2          BY user_a_id ASC  PARALLEL 60;
a_retweets_b_2           = ORDER a_retweets_b_2         BY user_a_id ASC   PARALLEL 60;
-- a_follows_b_2            = ORDER a_follows_b_2          BY user_a_id ASC  PARALLEL 60;

                                                                          
-- rmf                                $NBRHOOD_PATH/twitter_user_2            
-- STORE twitter_user_2         INTO '$NBRHOOD_PATH/twitter_user_2';         
-- rmf                                $NBRHOOD_PATH/twitter_user_profile_2    
-- STORE twitter_user_profile_2 INTO '$NBRHOOD_PATH/twitter_user_profile_2'; 
-- rmf                                $NBRHOOD_PATH/twitter_user_style_2      
-- STORE twitter_user_style_2   INTO '$NBRHOOD_PATH/twitter_user_style_2';   
-- rmf                                $NBRHOOD_PATH/twitter_user_id_2         
-- STORE twitter_user_id_2      INTO '$NBRHOOD_PATH/twitter_user_id_2';      
                                                                         
-- rmf                                $NBRHOOD_PATH/hashtag_2                 
-- STORE hashtag_2              INTO '$NBRHOOD_PATH/hashtag_2';              
-- rmf                                $NBRHOOD_PATH/smiley_2                  
-- STORE smiley_2               INTO '$NBRHOOD_PATH/smiley_2';               
-- rmf                                $NBRHOOD_PATH/tweet_url_2               
-- STORE tweet_url_2            INTO '$NBRHOOD_PATH/tweet_url_2';            
-- rmf                                $NBRHOOD_PATH/stock_token_2             
-- STORE stock_token_2          INTO '$NBRHOOD_PATH/stock_token_2';          
                                                                         
-- rmf                                $NBRHOOD_PATH/trstrank_2                
-- STORE trstrank_2             INTO '$NBRHOOD_PATH/trstrank_2';             
rmf                                $NBRHOOD_PATH/wordbag_2                 
STORE wordbag_2              INTO '$NBRHOOD_PATH/wordbag_2';              
-- --                                                                       
-- rmf                                $NBRHOOD_PATH/tweet_2                   
-- STORE tweet_2                INTO '$NBRHOOD_PATH/tweet_2';                
-- --                                                                    
-- rmf                                $NBRHOOD_PATH/a_atsigns_b_2             
-- STORE a_atsigns_b_2          INTO '$NBRHOOD_PATH/a_atsigns_b_2';          
-- rmf                                $NBRHOOD_PATH/a_retweets_b_2            
-- STORE a_retweets_b_2         INTO '$NBRHOOD_PATH/a_retweets_b_2';         
-- rmf                                $NBRHOOD_PATH/a_follows_b_2             
-- STORE a_follows_b_2          INTO '$NBRHOOD_PATH/a_follows_b_2';          
