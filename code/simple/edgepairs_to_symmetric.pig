--
-- edgepairs_to_symmetric.pig
--
-- This takes an edge-pairs representation of a graph
--
--    src       dest
--
-- and finds the links that are symmetric
--
--    user_a    user_b    a_re_b    b_re_a      a_symm_b
--
-- Usage:
--
--    pig -p A_REPLIES_B_FILE=a_replies_b.tsv edgepairs_to_symmetric.pig
--
-- Note that the data dir path must be absolute
--
--
-- Copyright 2010, Flip Kromer for Infochimps, Inc
-- Released under the Apache License
--

%default DATA_DIR      '/Users/flip/ics/hadoop/hadoop_book/data/sampled'

--
-- Edges file is tab-separated: source label in first column, destination label in second
--
-- -- mrflip     	tom_e_white
-- -- wattsteve  	josephkelly
-- -- mrflip     	mza        
-- -- nealrichter	tlipcon    
-- -- rabble     	rashmi     
-- -- kellan     	rcrowley   
-- -- blaine     	kellan     
-- -- jot        	MarkABaker 
-- -- nitin      	shashivelur
-- -- davemcclure	hackingdata
--
a_replies_b    = LOAD '$DATA_DIR/a_replies_b.tsv' AS (src: chararray, dest:chararray);

--
-- We want to make the graph undirected -- but cleverly!!!
--
-- * To make the edges unambiguous (so that a => b and b => a both map to the
--   same undirected pair), we just arbitrarily put the one with lowest id first
--
-- -- (mrflip,tom_e_white,1,0)
-- -- (josephkelly,wattsteve,0,1)
-- -- (mrflip,mza,1,0)
-- -- (nealrichter,tlipcon,1,0)
--
a_b_rels = FOREACH a_replies_b GENERATE
  ((src <= dest) ? src  : dest) AS user_a,
  ((src <= dest) ? dest : src)  AS user_b,
  ((src <= dest) ? 1 : 0)       AS a_re_b:int,
  ((src <= dest) ? 0 : 1)       AS b_re_a:int;
-- DUMP a_b_rels
-- pig -x local -p DATA_DIR=/Users/flip/ics/hadoop/hadoop_book/data/sampled ~/ics/hadoop/hadoop_book/code/simple/edgepairs_to_symmetric.pig > data/output/replies_undir_1-dump.txt

--
-- Now gather each undirected user pair together
-- and count up the strength of their relationship in each direction:
-- * how many replies a => b
-- * how many replies b => a
-- * boolean 1 / 0 for being symmetric (at least one reply in each direction)
-- 
-- -- (mrflip,tom_e_white,1,1,1)
-- -- (josephkelly,wattsteve,0,2,0)
-- -- (mrflip,mza,2,0,0)
-- -- (nealrichter,tlipcon,2,0,0)

a_b_rels_g   = GROUP a_b_rels BY (user_a, user_b);
-- DUMP a_b_rels_g;

--
-- -- -- You'd like to say
--
-- a_symm_b_all  = FOREACH a_b_rels_g {
--   n_a_re_b    = SUM(a_b_rels.a_re_b);
--   n_b_re_a    = SUM(a_b_rels.b_re_a);
--   is_symm     = (((n_a_re_b >= 1L) AND (n_b_re_a >= 1L)) ? 1 : 0);
--   GENERATE group.user_a AS user_a, group.user_b AS user_b, n_a_re_b, n_b_re_a, is_symm;
-- };
--
-- -- but my version of pig is giving wrong results. wtf.
-- -- This works though:
--
a_symm_b_all  = FOREACH a_b_rels_g {
  n_a_re_b    = SUM(a_b_rels.a_re_b);
  n_b_re_a    = SUM(a_b_rels.b_re_a);
  a_re_b_bool = (n_a_re_b >= 1L ? 1 : 0);
  b_re_a_bool = (n_b_re_a >= 1L ? 1 : 0);
  is_symm     = ((a_re_b_bool + b_re_a_bool == 2) ? 1 : 0);
  GENERATE group.user_a AS user_a, group.user_b AS user_b, n_a_re_b AS n_a_re_b, n_b_re_a AS n_b_re_a, is_symm AS is_symm;
};
DUMP a_symm_b_all

a_symm_b = FILTER a_symm_b_all BY (is_symm == 1);
-- DUMP a_symm_b

-- rmf                  $DATA_DIR/a_symm_b         
-- STORE a_symm_b INTO '$DATA_DIR/a_symm_b';
