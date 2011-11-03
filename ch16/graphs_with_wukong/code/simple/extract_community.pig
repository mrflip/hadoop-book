--
-- edgepairs_to_adjlist.pig
--
-- This takes an edge-pairs representation of a graph
--
--    src       dest
--
-- and converts it to adjacency-list representation
--
--    src 	destA,destB,destC
--
--
-- Usage:
--
--    cd /path/to/
--    pig -x local -p DATA_DIR=/path/to/hadoop_book/data/sampled edgepairs_to_adjlist.pig
--
-- Note that the data dir path must be absolute
--
-- Copyright 2010, Flip Kromer for Infochimps, Inc
-- Released under the Apache License
--

-- So far we’ve generated a node measure (in-degree) and an edge measure
-- (symmetric link identification). Let’s move out one step and look at a
-- neighborhood measure: how many of a given person’s friends are friends with
-- each other? Along the way, we’ll produce the edge set for a visualization
-- like the one above.

%default DATA_DIR      '/Users/flip/ics/hadoop/hadoop_book/data/sampled'
a_replies_b    = LOAD 'a_replies_b.tsv' AS (src: chararray, dest:chararray);

--
-- Get neighbors
--
-- Choose a seed node (here, <literal>@hadoop</literal>). First round up the
-- seed’s neighbors (all nodes that have replied to / been replied by the seed)
--
-- (band)
-- (mndoci)
-- (llimllib)
-- (dataspora)
-- (feziegler)
--
-- Extract edges that originate or terminate on the seed
n0_edges = FILTER a_replies_b BY ((src == 'infochimps') OR  (dest == 'infochimps'))
                         AND NOT ((src == 'infochimps') AND (dest == 'infochimps'));
-- Choose the node in each pair that *isn't* our seed:
n1_all   = FOREACH n0_edges GENERATE ((src == 'infochimps') ? dest : src) AS screen_name;
n1_nodes = DISTINCT n1_all;
-- DUMP n1_nodes;

--
-- Now intersect the set of neighbors with the set of starting nodes to find all
-- edges originating in <literal>n1_nodes</literal>:
--
n1_edges_out_j = JOIN a_replies_b BY src, 
                      n1_nodes    BY screen_name USING 'replicated';
n1_edges_out   = FOREACH n1_edges_out_j GENERATE src, dest;
-- DUMP n1_edges_out

--
-- To leave only edges where both source and destination are neighbors of the seed node, repeat the join:
--
n1_edges_j     = JOIN n1_edges_out BY dest, 
                      n1_nodes     BY screen_name USING 'replicated';
n1_edges       = FOREACH n1_edges_j GENERATE src, dest;
DUMP n1_edges
        
-- -- Save the output.
-- rmf                        $DATA_DIR/../output/n1_edges
-- STORE replies_out    INTO '$DATA_DIR/../output/n1_edges';

--
-- The edge density in the sample set is artificially small: the a_replies_b set
-- is only tweets that mention one of the target terms *and* is a reply.
-- On the full graph, we see
-- * 21882 n1_nodes
-- * 1870689 links from {n1 union n0} into {n1 union n0}
-- * clustering coefficient ~ 0.7%
