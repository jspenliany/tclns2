awk 'BEGIN{print " Abstract SIMUTAVR packet lines....."; i = 0;j=0;k=0;}
     
	{
i=index($7,"SIMUTAVR");
j=index($4,"MAC");
k=index($7,"udp")

if(k == 0 && i > 0)
print $0
	}
     END{print "end....."}' test.tr > TAVR.tr
