awk 'BEGIN{print " Abstract TAVRWIRED packet lines....."; i = -1;}
     {i=index($0,"TAVRWIRED"); if(i > 0)print $0}
     END{print "end....."}' test.tr > current.tr
