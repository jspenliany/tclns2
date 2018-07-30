

rm "NodeActiveBase.tcl"


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
tcl_rtrSecond=" \"$ragentB_(";
tcl_rtrThird=") vehicle_gone true\"";
tcl_rtrFinal="";

tcl_locFirst="$ns_ at ";
tcl_locSecond=" \"$ragentB_(";
tcl_locThird=") send_Rmsg\"";
tcl_locFinal="";

#-------------------------------
tcl_GSBFirst="$ns_ at ";
tcl_GSBSecond=" \"$ragentB_(";
tcl_GSBThird=") vehiSelf_Bcast\"";
tcl_GSBFinal="";

tcl_GLBFirst="$ns_ at ";
tcl_GLBSecond=" \"$ragentB_(";
tcl_GLBThird=") vehiLocal_Bcast\"";
tcl_GLBFinal="";

tcl_GGBFirst="$ns_ at ";
tcl_GGBSecond=" \"$ragentB_(";
tcl_GGBThird=") vehiGlobal_Bcast\"";
tcl_GGBFinal="";

tcl_GBBFirst="$ns_ at ";
tcl_GBBSecond=" \"$ragentB_(";
tcl_GBBThird=") baseLocal_Bcast\"";
tcl_GBBFinal="";



tcl_GNrtrFirst="$ns_ at ";
tcl_GNrtrSecond=" \"$ragentB_(";
tcl_GNrtrThird=") sNode_runflag true\"";
tcl_GNrtrFinal="";

tcl_GLrtrFirst="$ns_ at ";
tcl_GLrtrSecond=" \"$ragentB_(";
tcl_GLrtrThird=") stimerVlocalflag true\"";
tcl_GLrtrFinal="";

tcl_GBrtrFirst="$ns_ at ";
tcl_GBrtrSecond=" \"$ragentB_(";
tcl_GBrtrThird=") stimerBlocalflag true\"";
tcl_GBrtrFinal="";

tcl_GGrtrFirst="$ns_ at ";
tcl_GGrtrSecond=" \"$ragentB_(";
tcl_GGrtrThird=") stimerVglobalflag true\"";
tcl_GGrtrFinal="";

tcl_GSrtrFirst="$ns_ at ";
tcl_GSrtrSecond=" \"$ragentB_(";
tcl_GSrtrThird=") stimerSlocalflag true\"";
tcl_GSrtrFinal="";

}

{
j=index($3,"X_");

if(j>0) {

cID=0+substr($1,9, length($1)-9);

#------------------------timer starting ----------------------------starting--------------------------

		START_time=0.12;
		tcl_GSBFinal=tcl_GSBFirst""START_time""tcl_GSBSecond""cID""tcl_GSBThird;
#		print tcl_GSBFinal  >>"NodeActiveBase.tcl";

		tcl_GLBFinal=tcl_GLBFirst""START_time""tcl_GLBSecond""cID""tcl_GLBThird;
#		print tcl_GLBFinal  >>"NodeActiveBase.tcl";

		tcl_GGBFinal=tcl_GGBFirst""START_time""tcl_GGBSecond""cID""tcl_GGBThird;
#		print tcl_GGBFinal  >>"NodeActiveBase.tcl";

		tcl_GBBFinal=tcl_GBBFirst""START_time""tcl_GBBSecond""cID""tcl_GBBThird;
		print tcl_GBBFinal  >>"NodeActiveBase.tcl";

#------------------------flag variables change ----------------------------flag variables--------------------------
		tcl_GNrtrFinal=tcl_GNrtrFirst""START_time""tcl_GNrtrSecond""cID""tcl_GNrtrThird;
		print tcl_GNrtrFinal  >>"NodeActiveBase.tcl";

		tcl_GSrtrFinal=tcl_GSrtrFirst""START_time""tcl_GSrtrSecond""cID""tcl_GSrtrThird;
#		print tcl_GSrtrFinal  >>"NodeActiveBase.tcl";

		tcl_GLrtrFinal=tcl_GLrtrFirst""START_time""tcl_GLrtrSecond""cID""tcl_GLrtrThird;
#		print tcl_GLrtrFinal  >>"NodeActiveBase.tcl";

		tcl_GGrtrFinal=tcl_GGrtrFirst""START_time""tcl_GGrtrSecond""cID""tcl_GGrtrThird;
#		print tcl_GGrtrFinal  >>"NodeActiveBase.tcl";

		tcl_GBrtrFinal=tcl_GBrtrFirst""START_time""tcl_GBrtrSecond""cID""tcl_GBrtrThird;
		print tcl_GBrtrFinal  >>"NodeActiveBase.tcl";


}

}
END{}' Lane.bas.tcl
