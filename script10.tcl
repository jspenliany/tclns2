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
set opt(wtx_delay)	30.2				;#base gather to vehicular interval
set opt(rtx_delay)	2.0				;#msg interval

set opt(hello_start)	50.2				;# hello will start tx at 15.02
set opt(wired_start)	[expr $opt(hello_start) + 18.8]  ;# wired will start tx at 18.02		
set opt(comm_start)	[expr $opt(hello_start) + 8.9]

set opt(output_debug)   true
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

# set up for hierarchical routing
$ns_ node-config -addressType hierarchical 3 10 11 11

AddrParams set domain_num_ 3           			;# number of domains
lappend cluster_num 1 1 1              			;# number of clusters in each domain
AddrParams set cluster_num_ $cluster_num
lappend eilastlevel $opt(comm_id) $opt(nb) $opt(nm)          ;# number of nodes in each cluster 
AddrParams set nodes_num_ $eilastlevel 			;# of each domain

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
create-god [expr $opt(nm) + $opt(nb)]
#create wired nodes
set tmpW 0.0
for {set i 0} {$i < $opt(comm_id)} {incr i} {
#    puts "$i current IP is $tmpW.$i"
    set nodew_($i) [$ns_ node $tmpW.$i] 
}

#set nodew_($opt(comm_id)) [$ns_ node $tmpW.$opt(comm_id)] 

source Lane.wir.tcl


# Configure for ForeignAgent and HomeAgent nodes
$ns_ node-config -mobileIP ON \
                 -adhocRouting $opt(adhocRouting) \
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

# Create HA and FA
set temb 1.0           ;# hierarchical addresses 
for {set i 0} {$i < $opt(nb)} {incr i} {
    set nodeb_($i) [$ns_ node $temb.$i] 
    $nodeb_($i) random-motion 0
}

source Lane.bas.tcl

source Lane.len.tcl
for {set i 0} {$i < $opt(nb)} {incr i} {
    set ragentB_($i) [$nodeb_($i) set ragent_]
    $ragentB_($i) stimerBlocalperiod  	1.0

}
source NodeActiveBase.tcl

# create a mobilenode that would be moving between HA and FA.
# note address of MH indicates its in the same domain as HA.
$ns_ node-config -wiredRouting OFF \
                 -macTrace OFF

set temm 2.0
for {set i 0} {$i < $opt(nm)} {incr i} {
    set node_($i) [$ns_ node $temm.$i]
    set HAaddress [AddrParams addr2id [$nodeb_([expr $i % $opt(nb)]) node-addr]] 
    [$node_($i) set regagent_] set home_agent_ $HAaddress

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
    for {set ri 0} {$ri < [expr $opt(rowc) - 1]} {incr ri} {
	$ragent_($i) uplength $opt(srlenup$ri)
	$ragent_($i) upangle $opt(srangleup$ri)
    }
}

for {set i 0} {$i < $opt(nm)} {incr i} {
    for {set ri 0} {$ri < $opt(rowc)} {incr ri} {
	$ragent_($i) rightlength $opt(srlenright$ri)
	$ragent_($i) rightangle $opt(srangleright$ri)
    }
}

for {set i 0} {$i < $opt(nm)} {incr i} {
    for {set ri 0} {$ri < $opt(rowc)} {incr ri} {
	$ragent_($i) Xlist $opt(srXlist$ri)
	$ragent_($i) Ylist $opt(srYlist$ri)
    }
}

#start the detect process of enter into the junction area
for {set i 0} {$i < $opt(nm)} {incr i} {
    $ragent_($i) test_BASE
#    $ragent send_Rmsg
}

# create links between wired and BaseStation nodes

# setup TCP connections between a wired node and the MobileHost
source Lane.pat.tcl


for {set i 0} {$i < $opt(nm)} {incr i} {
    set udp_r($i) [new Agent/UDP/TAVRAppAgent]
#    $ns_ attach-agent $node_($i) $udp_r($i)
    $node_($i) attach $udp_r($i) $opt(trans_port)

    $udp_r($i) node_id		$i
    $udp_r($i) node_type	2
    $udp_r($i) comm_id 		$opt(nw)
    $udp_r($i) vehi-num 	$opt(nm)
    $udp_r($i) wired_interval 	$opt(wtx_delay)
    $udp_r($i) hello_interval 	$opt(mtx_delay)
    $udp_r($i) tavr_debug 	$opt(output_debug)
    $udp_r($i) tavr_fileTime 	$opt(output_time)

    set app_r($i) [new Application/TAVRApp]
    $app_r($i) attach-agent $udp_r($i)

    $app_r($i) node_id		$i
    $app_r($i) running		1
    $app_r($i) node_type	2
    $app_r($i) comm_id 		$opt(nw)
    $app_r($i) txinterval	$opt(mtx_delay)
    $app_r($i) vehi-num 	$opt(nm)
    $app_r($i) rxinterval	3.0
    $app_r($i) tavr_debug 	$opt(output_debug)
    $app_r($i) tavr_fileTime 	$opt(output_time)
#    set node_($i) [$ns_ node $temp.$i]
}




#Setup a MM UDP connection
for {set i 0} {$i < $opt(comm_id)} {incr i} {
#    puts "$i current IP is $tmpW.$i"
    set udp_s($i) [new Agent/UDP/TAVRAppAgent]
#    $ns_ attach-agent $nodew_($i) $udp_s($i)
    $nodew_($i) attach $udp_s($i) $opt(trans_port)

    $udp_s($i) node_id		$i
    $udp_s($i) vehi-num 	$opt(nm)


if {$i < $opt(nw)} {
    $udp_s($i) node_type	0
} else {
    $udp_s($i) node_type	4
}
    $udp_s($i) comm_id 		$opt(nw)
    $udp_s($i) wired_interval 	$opt(wtx_delay)
    $udp_s($i) hello_interval 	$opt(mtx_delay)
    $udp_s($i) tavr_debug 	$opt(output_debug)
    $udp_s($i) tavr_fileTime 	$opt(output_time)

    set app_s($i) [new Application/TAVRApp]
    $app_s($i) attach-agent $udp_s($i)

    $app_s($i) node_id		$i
    $app_s($i) running		1
    $app_s($i) vehi-num 	$opt(nm)
if {$i < $opt(nw)} {
    $app_s($i) node_type	0
} else {
    $app_s($i) node_type	4
}
    $app_s($i) comm_id 		$opt(nw)
if {$i < $opt(nw)} {
    $app_s($i) txinterval	$opt(wtx_delay)
} else {
    $app_s($i) txinterval	$opt(wtx_delay)
}
    $app_s($i) rxinterval	3.0
    $app_s($i) tavr_debug 	$opt(output_debug)
    $app_s($i) tavr_fileTime 	$opt(output_time)
#    set nodew_($i) [$ns_ node $tmpW.$i] 
}





for {set i 0} {$i < $opt(nm)} {incr i} {
    $ns_ connect $udp_s($opt(nw)) $udp_r($i)
}

for {set i 0} {$i < $opt(nw)} {incr i} {
    $ns_ connect $udp_s($opt(nw)) $udp_s($i)
}

#for {set i 0} {$i < $opt(nm)} {incr i} {
#     $ns_ at $opt(hello_start) "$app_r($i) starttx"
#    set node_($i) [$ns_ node $temp.$i]
#}

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
$ragent_(0) gNBRadius		230.0

source Lane.way.tcl


for {set i 0} {$i < $opt(nm)} {incr i} {
	$ragent_($i) stimerSlocalperiod 	0.5
	$ragent_($i) stimerVlocalperiod 	1.0
	$ragent_($i) stimerVglobalperiod  	1.0
    	$ragent_($i) stimerBlocalperiod  	1.0
}

#this intends to set parameters for traffic information 
source NodeActiveInfo.tcl
#this intends to set parameters for messages transfer
source NodeActiveMSG.tcl

for {set i 0} {$i < $opt(comm_id)} {incr i} {
#    puts "$i current IP is $tmpW.$i"

if {$i < $opt(nw)} {
     $ns_ at $opt(wired_start) "$app_s($i) starttx"
} else {
     $ns_ at $opt(comm_start) "$app_s($i) starttx"
}


#    set nodew_($i) [$ns_ node $tmpW.$i] 
}





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

# Define initial node position in nam

for {set i 0} {$i < $opt(nm)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your
    # scenario
    # The function must be called after mobility model is defined

    $ns_ initial_node_pos $node_($i) 10
}  

# Tell all nodes when the siulation ends
source NodeEndTimeInfo.tcl
source NodeEndTimeMSG.tcl

for {set i 0} {$i < $opt(nm) } {incr i} {
    $ns_ at $opt(stop).0 "$node_($i) reset";
}

for {set i 0} {$i < $opt(nb) } {incr i} {
    $ns_ at $opt(stop).0 "$nodeb_($i) reset";
}

for {set i 0} {$i < $opt(comm_id) } {incr i} {
    $ns_ at $opt(stop).0 "$nodew_($i) reset";
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
