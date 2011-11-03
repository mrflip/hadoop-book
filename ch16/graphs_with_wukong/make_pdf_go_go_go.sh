#!/usr/bin/env bash

basename='flip'
version='v3'

script_dir=`dirname $0`
raw_xml=${basename}.xml
xsl_file=/usr/local/src/docbook-xsl-1.74.1/fo/docbook.xsl
fop_file=${script_dir}/rendered/${basename}_${version}.fo
pdf_file=${script_dir}/rendered/${basename}_${version}.pdf

xsltproc -o  $fop_file $xsl_file $raw_xml
fop      -fo $fop_file -pdf $pdf_file | egrep -v 'relative-align|"background-position'

open $pdf_file
