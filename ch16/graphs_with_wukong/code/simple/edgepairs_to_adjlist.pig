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
-- Group edges by their source node
--
-- -- (jerry,{(jerry,Drake),(jerry,Elaine)})
-- -- (Elaine,{(Elaine,george),(Elaine,jerry)})
-- -- (Newman,{(Newman,Elaine)})
-- -- (george,{(george,jerry),(george,kramer)})
-- -- (kramer,{(kramer,Elaine),(kramer,george),(kramer,jerry),(kramer,Newman)})
--
replies_out_g = GROUP a_replies_b BY src;

--
-- Retain only the distinct destination nodes along with the number of replies exchanged
--
-- -- (Elaine,{(george),(jerry)})
-- -- (Newman,{(Elaine)})
-- -- (george,{(jerry),(kramer)})
-- -- (jerry,{(Drake),(Elaine)})
-- -- (kramer,{(Elaine),(Newman),(george),(jerry)})
--
replies_out = FOREACH replies_out_g { nbrs = DISTINCT a_replies_b.dest ; GENERATE group, nbrs ; };

-- Save the output.
rmf                        $DATA_DIR/replies_out
STORE replies_out    INTO '$DATA_DIR/replies_out';
