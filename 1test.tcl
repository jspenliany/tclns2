# Copyright (c) 1997 Regents of the University of California.
# All rights reserved.
#
# simulation of a wired-cum-wireless topology running with mobileIP
# ======================================================================
# Define options
# ======================================================================

set opt(chan)   	Channel/WirelessChannel        	;# channel type
set opt(prop)   	Propagation/TwoRayGround       	;# radio-propagation model
set opt(netif)  	Phy/WirelessPhy                	;# network interface type
set opt(mac)    	Mac/802_11                     	;# MAC type
set opt(ifq)    	Queue/DropTail/PriQueue        	;# interface queue type
set opt(ll)     	LL                             	;# link layer type
set opt(ant)    	Antenna/OmniAntenna            	;# antenna model
set opt(ifqlen)         50                     	;# max packet in ifq
set opt(adhocRouting)   SIMUTAVR               	;# routing protocol

set opt(cp)             ""                     	;# connection pattern file
set opt(sc)     	"ns2mobility.tcl"    	       	;# node movement file. 


set opt(stop)   	500.0                         	;# time of simulation end

set opt(ftp1-start)     100.0


#assign port number for all nodes
set opt(trans_port)	50				;#for transport layer protocol
#set opt(app_port)	51				;#for application layer protocol

#assign tx_delay for agent sending msg
set opt(mtx_delay)	8.002				;#vehicle info to base interval
set opt(wtx_delay)	23.2				;#base gather to vehicular interval
set opt(rtx_delay)	2.0				;#msg interval

set opt(hello_start)	50.2				;# hello will start tx at 15.02
set opt(wired_start)	[expr $opt(hello_start) + 18.8]  ;# wired will start tx at 18.02		
set opt(comm_start)	[expr $opt(hello_start) + 8.9]

set opt(output_debug)   false
set opt(output_time)	[expr $opt(hello_start) - 21.0]

#set num_bs_nodes       2  ; this is not really used here.
source "Lane.sce.tcl"
set opt(comm_id)	[expr $opt(nw) + 1]
# mobile nodes257 nb 78 nw 78   nam 1.5GB  tr 2.1GB. time 40m

#---------------------------energy model------------
set opt(engmodel) EnergyModel ;#energy model
set opt(initeng) 20.0 ;#total energy
set opt(txPower) 0.660 ;#transport energy
set opt(rxPower) 0.395 ;#receive energy
set opt(idlePower) 0.035 ;#wait energy

#===================================
#        Initialization        
#===================================

# check for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
	puts "No X-Y boundary values given for wireless topology\n"
}

# create simulator instance
set ns_   [new Simulator]

set startTime [clock seconds]
puts "The time is: [clock format $startTime -format %H:%M:%S]"



set tracefd  [open test.tr w]
set namtrace [open test.nam w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# Create topography object
set topo   [new Topography]

# define topology
$topo load_flatgrid $opt(x) $opt(y)
# create God
#    for HAs and FAs
create-god $opt(nm)

# Configure for ForeignAgent and HomeAgent nodes
$ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channelType $opt(chan) \
		 -topoInstance $topo \
                 -wiredRouting ON \
		 -agentTrace ON \
                 -routerTrace OFF  \
                 -macTrace OFF 


source Lane.len.tcl

# Position (fixed) for base-station nodes (HA & FA).


#$HA set X_ 1.000000000000
#$HA set Y_ 2.000000000000
#$HA set Z_ 0.000000000000


set temm 2.0
for {set i 0} {$i < $opt(nm)} {incr i} {
    set node_($i) [$ns_ node $i]

#    puts "current index is $i"

    set ragent_($i) [$node_($i) set ragent_]
    $ragent_($i) msgINET 34
    $ragent_($i) vehi-num $opt(nm)
    $ragent_($i) base-num $opt(nb)
    $ragent_($i) nodeID $i
    $ragent_($i) comm_id $opt(nw)
    $ragent_($i) AXIS_ip 1

    $ragent_($i) conf-map $opt(x) $opt(y) $opt(rowc) $opt(colc)
    $ragent_($i) conf-base 3.0 3.0 $opt(nodesXx) $opt(nodesYy)
    $ragent_($i) init_juncInfo
    $ragent_($i) app_port 		$opt(trans_port)
    $ragent_($i) wired_interval 	$opt(wtx_delay)
    $ragent_($i) hello_interval 	$opt(mtx_delay)
    $ragent_($i) send_interval 		$opt(rtx_delay)
    $ragent_($i) tavr_debug 		$opt(output_debug)
    $ragent_($i) tavr_fileTime 		$opt(output_time)
}

#INIT all info
for {set i 0} {$i < $opt(nm)} {incr i} {
}
for {set i 0} {$i < $opt(nm)} {incr i} {
}
for {set i 0} {$i < $opt(nm)} {incr i} {
}

for {set ri 0} {$ri < [expr $opt(rowc) - 1]} {incr ri} {
	puts "------------------$ri"
	$ragent_(0) guplength $opt(srlenup$ri)
	$ragent_(0) gupangle $opt(srangleup$ri)
}
for {set ri 0} {$ri < $opt(rowc)} {incr ri} {
	$ragent_(0) grightlength $opt(srlenright$ri)
	$ragent_(0) grightangle $opt(srangleright$ri)
}
for {set ri 0} {$ri < $opt(rowc)} {incr ri} {
	$ragent_(0) gXlist $opt(srXlist$ri)
	$ragent_(0) gYlist $opt(srYlist$ri)
}



#start the detect process of enter into the junction area
$ragent_(0) gscenLength		$opt(x)
$ragent_(0) gscenWidth 		$opt(y)
$ragent_(0) gscenRowc 		$opt(rowc)
$ragent_(0) gscenColc 		$opt(colc)
$ragent_(0) gscenVehiNum 	$opt(nm)

$ragent_(0) glaneWidth 		$opt(lane_width)
$ragent_(0) gjuncRadius 	3.1




source NodeActive.tcl




source Lane.way.tcl


for {set i 0} {$i < $opt(nm)} {incr i} {
	$ragent_($i) stimerVlocalperiod 	1.0
	$ragent_($i) stimerVglobalperiod  	1.0
	$ragent_($i) stimerBlocalperiod  	1.0
	$ragent_($i) stimerVlocalflag  		true
	$ragent_($i) stimerVglobalflag  	true
	$ragent_($i) stimerBlocalflag  		true
	$ragent_($i) sNode_runflag  		true
#	$ragent_($i) vehiLocal_Bcast
#	$ragent_($i) vehiGlobal_Bcast
#	$ragent_($i) baseLocal_Bcast
}

for {set i 0} {$i < 55} {incr i} {
	$ragent_($i) vehiLocal_Bcast
	$ragent_($i) vehiGlobal_Bcast
	$ragent_($i) baseLocal_Bcast
}

#set howName [set shortpath10TO1]
#puts $howName
# source connection-pattern and node-movement scripts
if { $opt(cp) == "" } {
	puts "*** NOTE: no connection pattern specified."
        set opt(cp) "none"
} else {
	puts "Loading connection pattern..."
	source $opt(cp)
}
if { $opt(sc) == "" } {
	puts "*** NOTE: no scenario file specified."
        set opt(sc) "none"
} else {
	puts "Loading scenario file..."
	source $opt(sc)
	puts "Load complete..."
}




# Setup traffic flow between nodes
# TCP connections between node_(0) and node_(1)

set tcp [new Agent/TCP]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp
$ns_ attach-agent $node_(1) $sink
$ns_ connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns_ at 10.0 "$ftp start"






# Tell all nodes when the siulation ends

source NodeEndTime.tcl

for {set i 0} {$i < $opt(nm) } {incr i} {
    $ns_ at $opt(stop).0 "$node_($i) reset";
}



$ns_ at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop).0001 "stop"
proc stop {} {
    global ns_ tracefd namtrace
    close $tracefd
    close $namtrace
}

# some useful headers for tracefile
puts $tracefd "M 0.0 nn $opt(nm) x $opt(x) y $opt(y) rp \
	$opt(adhocRouting)"
puts $tracefd "M 0.0 sc $opt(sc) cp $opt(cp)"
puts $tracefd "M 0.0 prop $opt(prop) ant $opt(ant)"

puts "Starting Simulation..."
$ns_ run

set endTime [clock seconds]
puts "The time is: [clock format $endTime -format %H:%M:%S]"

