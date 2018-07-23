

rm "NodeActive.tcl"
rm "NodeActive_info.txt"


awk '
BEGIN{

pre_define_time=20;


flag=0;
cID=-1;


Time_Asymptotic_flag=-100;

tcl_first="$ns_ at ";
tcl_second=" \"$app_r(";
tcl_third=") starttx\"";
tcl_final="";


tcl_rtrFirst="$ns_ at ";
tcl_rtrSecond=" \"$ragent_(";
tcl_rtrThird=") vehicle_gone true\"";
tcl_rtrFinal="";

tcl_locFirst="$ns_ at ";
tcl_locSecond=" \"$ragent_(";
tcl_locThird=") send_Rmsg\"";
tcl_locFinal="";

#-------------------------------
tcl_GSBFirst="$ns_ at ";
tcl_GSBSecond=" \"$ragent_(";
tcl_GSBThird=") vehiSelf_Bcast\"";
tcl_GSBFinal="";

tcl_GLBFirst="$ns_ at ";
tcl_GLBSecond=" \"$ragent_(";
tcl_GLBThird=") vehiLocal_Bcast\"";
tcl_GLBFinal="";

tcl_GGBFirst="$ns_ at ";
tcl_GGBSecond=" \"$ragent_(";
tcl_GGBThird=") vehiGlobal_Bcast\"";
tcl_GGBFinal="";

tcl_GBBFirst="$ns_ at ";
tcl_GBBSecond=" \"$ragent_(";
tcl_GBBThird=") baseLocal_Bcast\"";
tcl_GBBFinal="";



tcl_GNrtrFirst="$ns_ at ";
tcl_GNrtrSecond=" \"$ragent_(";
tcl_GNrtrThird=") sNode_runflag true\"";
tcl_GNrtrFinal="";

tcl_GLrtrFirst="$ns_ at ";
tcl_GLrtrSecond=" \"$ragent_(";
tcl_GLrtrThird=") stimerVlocalflag true\"";
tcl_GLrtrFinal="";

tcl_GBrtrFirst="$ns_ at ";
tcl_GBrtrSecond=" \"$ragent_(";
tcl_GBrtrThird=") stimerBlocalflag true\"";
tcl_GBrtrFinal="";

tcl_GGrtrFirst="$ns_ at ";
tcl_GGrtrSecond=" \"$ragent_(";
tcl_GGrtrThird=") stimerVglobalflag true\"";
tcl_GGrtrFinal="";

tcl_GSrtrFirst="$ns_ at ";
tcl_GSrtrSecond=" \"$ragent_(";
tcl_GSrtrThird=") stimerSlocalflag true\"";
tcl_GSrtrFinal="";

}

{

if(flag==1)
	{
		flag=0;		
		print "cid=",cID," is start at ",$3 >> "NodeActive_info.txt";
		START_time=$3*0.97;
		print pre_define_time""START_time;

#		if(START_time < $3 - 3 && $3 - 3 > pre_define_time){
		if(START_time < $3 - 0.7 && $3 - 0.7 > pre_define_time){
			Time_Asymptotic_flag=100;
		}

		if(Time_Asymptotic_flag < 0){
			START_time=pre_define_time;
		}else{
			START_time=$3-3;
		}


		tcl_final=tcl_first""START_time""tcl_second""cID""tcl_third;
#		print tcl_final  >>"NodeActive.tcl";


#------------------------timer starting ----------------------------starting--------------------------

		START_time-=4;
		tcl_GSBFinal=tcl_GSBFirst""START_time""tcl_GSBSecond""cID""tcl_GSBThird;
		print tcl_GSBFinal  >>"NodeActive.tcl";

		tcl_GLBFinal=tcl_GLBFirst""START_time""tcl_GLBSecond""cID""tcl_GLBThird;
		print tcl_GLBFinal  >>"NodeActive.tcl";

		tcl_GGBFinal=tcl_GGBFirst""START_time""tcl_GGBSecond""cID""tcl_GGBThird;
		print tcl_GGBFinal  >>"NodeActive.tcl";

		tcl_GBBFinal=tcl_GBBFirst""START_time""tcl_GBBSecond""cID""tcl_GBBThird;
		print tcl_GBBFinal  >>"NodeActive.tcl";

#------------------------flag variables change ----------------------------flag variables--------------------------

		START_time+=2;
		tcl_GNrtrFinal=tcl_GNrtrFirst""START_time""tcl_GNrtrSecond""cID""tcl_GNrtrThird;
		print tcl_GNrtrFinal  >>"NodeActive.tcl";

		tcl_GSrtrFinal=tcl_GSrtrFirst""START_time""tcl_GSrtrSecond""cID""tcl_GSrtrThird;
		print tcl_GSrtrFinal  >>"NodeActive.tcl";

		tcl_GLrtrFinal=tcl_GLrtrFirst""START_time""tcl_GLrtrSecond""cID""tcl_GLrtrThird;
		print tcl_GLrtrFinal  >>"NodeActive.tcl";

		tcl_GGrtrFinal=tcl_GGrtrFirst""START_time""tcl_GGrtrSecond""cID""tcl_GGrtrThird;
		print tcl_GGrtrFinal  >>"NodeActive.tcl";

		tcl_GBrtrFinal=tcl_GBrtrFirst""START_time""tcl_GBrtrSecond""cID""tcl_GBrtrThird;
		print tcl_GBrtrFinal  >>"NodeActive.tcl";




	}

i=index($3,"Z_");
if(i>0)
	{		
		print "=======";
		flag=1;
		print $0;
#		print length($1);
		print substr($1,8, length($1)-8);
		cID=0+substr($1,8, length($1)-8); 
	}
}

END{}' ns2mobility.tcl
