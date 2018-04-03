awk 'BEGIN{print " Abstract MAC packet lines....."; i = -1;j=-1;}
     {i=index($0,"MAC"); j=index($0,"udp");if(i > 0 && j==0)print $0}
     END{print "end....."}' test.tr > MAC.tr
