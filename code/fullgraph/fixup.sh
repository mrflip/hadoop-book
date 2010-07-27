#!/usr/bin/env bash

# 
# /data/sn/tw/projects/explorations/bigdata/n1_ids                       	         192831	       188.3 KB
# /data/sn/tw/projects/explorations/bigdata/n1_ids_seen                  	         237603	       232.0 KB
# /data/sn/tw/projects/explorations/bigdata/a_follows_b_1                	         321434	       313.9 KB
# /data/sn/tw/projects/explorations/bigdata_1/twitter_user_1             	        1691796	         1.6 MB
# /data/sn/tw/projects/explorations/bigdata_1/twitter_user_profile_1     	        4608335	         4.4 MB
# /data/sn/tw/projects/explorations/bigdata/n2_ids                       	       13994163	        13.3 MB
# /data/sn/tw/projects/explorations/bigdata/tweet_1                      	       15984000	        15.2 MB
# /data/sn/tw/projects/explorations/bigdata/n2_ids_seen                  	       18033454	        17.2 MB
#
# /data/sn/tw/projects/explorations/bigdata/stock_token_2                	        6029984	         5.8 MB
# /data/sn/tw/projects/explorations/bigdata/hashtag_2                    	        6060018	         5.8 MB
# /data/sn/tw/projects/explorations/bigdata/smiley_2                     	        6115100	         5.8 MB
# /data/sn/tw/projects/explorations/bigdata/tweet_url_2                  	        6168365	         5.9 MB
#
# /data/sn/tw/projects/explorations/bigdata/trstrank_2                   	       78546599	        74.9 MB
# /data/sn/tw/projects/explorations/bigdata/twitter_user_2               	      123331561	       117.6 MB
# /data/sn/tw/projects/explorations/bigdata/twitter_user_id_2            	      134571845	       128.3 MB
# /data/sn/tw/projects/explorations/bigdata/twitter_user_profile_2       	      351688937	       335.4 MB
# /data/sn/tw/projects/explorations/bigdata/twitter_user_style_2         	      355811970	       339.3 MB
#
# /data/sn/tw/projects/explorations/bigdata/a_retweets_b_2               	     3500175947	         3.3 GB
# /data/sn/tw/projects/explorations/bigdata/wordbag_2                    	     7215241675	         6.7 GB
# /data/sn/tw/projects/explorations/bigdata/a_atsigns_b_2                	    10006271854	         9.3 GB
# /data/sn/tw/projects/explorations/bigdata_tweet_2/tweet_2                   	   193091050646	       179.8 GB
#                                                       21 entries       	   214936128117	       200.2 GB

nbhd=/data/sn/tw/projects/explorations/bigdata
nbhd_2=/data/sn/tw/projects/explorations/bigdata_2
for foo in hashtag smiley stock_token trstrank tweet_url twitter_user twitter_user_id twitter_user_profile twitter_user_style ; do echo $foo ; hdp-mv /data/sn/tw/projects/explorations/bigdata/${foo}_2 /data/sn/tw/projects/explorations/bigdata_2/ & done 

for foo in hashtag smiley stock_token tweet_url ; do echo $foo ; hdp-catd $nbhd_2/${foo}_2 | sort -nk3 | hdp-put - $nbhd/${foo}_2 & done   

for foo in trstrank ; do echo $foo ; hdp-catd $nbhd_2/${foo}_2 | sort -nk3 | hdp-put - $nbhd/${foo}_2 & done   
  
