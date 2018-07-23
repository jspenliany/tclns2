
rm "NodeEndTime.tcl"
rm "NodeEndTime_info.txt"

awk '
BEGIN{
pre_define_time=100;

tcl_first="$ns_ at ";
tcl_second=" \"$app_r(";
tcl_third=") stoptx\"";
tcl_final="";


tcl_rtrFirst="$ns_ at ";
tcl_rtrsecond=" \"$ragent_(";
tcl_rtrThird=") vehicle_gone false\"";
tcl_rtrFinal="";

#-------------------------------
tcl_GNrtrFirst="$ns_ at ";
tcl_GNrtrSecond=" \"$ragent_(";
tcl_GNrtrThird=") sNode_runflag false\"";
tcl_GNrtrFinal="";

tcl_GLrtrFirst="$ns_ at ";
tcl_GLrtrSecond=" \"$ragent_(";
tcl_GLrtrThird=") stimerVlocalflag false\"";
tcl_GLrtrFinal="";

tcl_GBrtrFirst="$ns_ at ";
tcl_GBrtrSecond=" \"$ragent_(";
tcl_GBrtrThird=") stimerBlocalflag false\"";
tcl_GBrtrFinal="";

tcl_GGrtrFirst="$ns_ at ";
tcl_GGrtrSecond=" \"$ragent_(";
tcl_GGrtrThird=") stimerVglobalflag false\"";
tcl_GGrtrFinal="";

tcl_GSrtrFirst="$ns_ at ";
tcl_GSrtrSecond=" \"$ragent_(";
tcl_GSrtrThird=") stimerSlocalflag false\"";
tcl_GSrtrFinal="";

}

{
i=index($4,"node_");
if(i>0)
	{		
#		print $4;
		id_node=substr($4,9, length($4)-9);
		Rtime[id_node]=$3;
		print substr($4,9, length($4)-9) >> "NodeEndTime_info.txt";
	}
}

END{

print Rtime[0];

for(value_time in Rtime)
{
	print "id=",value_time," value=",Rtime[value_time]+2.33 >> "NodeEndTime_info.txt";
	tcl_final=tcl_first""Rtime[value_time]+2.33""tcl_second""value_time""tcl_third;
#	print tcl_final  >>"NodeEndTime.tcl";

	tcl_GNrtrFinal=tcl_GNrtrFirst""Rtime[value_time]+2.33""tcl_GNrtrSecond""value_time""tcl_GNrtrThird;
	print tcl_GNrtrFinal  >>"NodeEndTime.tcl";

	tcl_GLrtrFinal=tcl_GLrtrFirst""Rtime[value_time]+2.33""tcl_GLrtrSecond""value_time""tcl_GLrtrThird;
	print tcl_GLrtrFinal  >>"NodeEndTime.tcl";

	tcl_GBrtrFinal=tcl_GBrtrFirst""Rtime[value_time]+2.33""tcl_GBrtrSecond""value_time""tcl_GBrtrThird;
	print tcl_GBrtrFinal  >>"NodeEndTime.tcl";

	tcl_GGrtrFinal=tcl_GGrtrFirst""Rtime[value_time]+2.33""tcl_GGrtrSecond""value_time""tcl_GGrtrThird;
	print tcl_GGrtrFinal  >>"NodeEndTime.tcl";

	tcl_GSrtrFinal=tcl_GSrtrFirst""Rtime[value_time]+2.33""tcl_GSrtrSecond""value_time""tcl_GSrtrThird;
	print tcl_GSrtrFinal  >>"NodeEndTime.tcl";



}

}' ns2mobility.tcl
