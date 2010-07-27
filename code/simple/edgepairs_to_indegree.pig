--
-- edgepairs_to_indegree.pig
--
-- This takes an edge-pairs representation of a graph
--
--    src       dest
--
-- and finds the in-degree (number of incoming edges)
-- and neighbor count (number of distinct nodes)
--
--    node      in_degree       neighbor_count
--
-- Usage:
--
--    pig -p A_REPLIES_B_FILE=a_replies_b.tsv edgepairs_to_indegree.pig 
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
-- -- Elaine	george
-- -- Elaine	jerry
-- -- Elaine	jerry
-- -- Newman	Elaine
-- -- george	jerry
-- -- george	kramer
-- -- jerry	Elaine
-- -- jerry	george
-- -- jerry	kramer
-- -- kramer	Elaine
-- -- kramer	george
-- -- kramer	jerry
-- -- kramer	jerry
-- -- kramer	Newman
--
a_replies_b    = LOAD '$DATA_DIR/a_replies_b.tsv' AS (src: chararray, dest:chararray);

--
-- Find all edges incoming to each node by grouping on destination
--
-- -- (jerry,{(Elaine,jerry),(Elaine,jerry),(george,jerry),(kramer,jerry),(kramer,jerry)})
-- -- (Elaine,{(kramer,Elaine),(Newman,Elaine),(jerry,Elaine)})
-- -- (Newman,{(kramer,Newman)})
-- -- (george,{(Elaine,george),(kramer,george),(jerry,george)})
-- -- (kramer,{(george,kramer),(jerry,kramer)})
--
replies_in  = GROUP a_replies_b BY dest; -- group on dest to get in-links
        
--
-- Count the distinct incoming repliers (neighbor nodes) and the total incoming replies
--
-- -- jerry	3	5
-- -- Elaine	3	3
-- -- Newman	1	1
-- -- george	3	3
-- -- kramer	2	2
--
replies_in_degree = FOREACH replies_in {
  nbrs = DISTINCT a_replies_b.src;
  GENERATE group, COUNT(nbrs), COUNT(a_replies_b);
};
-- DUMP replies_in_degree;

-- Save the output.
rmf                           $DATA_DIR/replies_in_degree
STORE replies_in_degree INTO '$DATA_DIR/replies_in_degree';

-- Follow up with a
--    cat replies_in_degree/part-r-00000 | sort -nk2 > replies_in_degree.tsv
-- if you like
