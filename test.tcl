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
set opt(ifqlen)         1020                     	;# max packet in ifq
set opt(adhocRouting)   SIMUTAVR               	;# routing protocol

set opt(cp)             ""                     	;# connection pattern file
set opt(sc)     	"ns2mobility.tcl"    	       	;# node movement file. 


set opt(stop)   	100.0                         	;# time of simulation end

set opt(ftp1-start)     100.0





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
                 -routerTrace ON \
                 -macTrace OFF 

# Create HA and FA
set temp 1.0           ;# hierarchical addresses 
for {set i 0} {$i < $opt(nb)} {incr i} {
    set nodeb_($i) [$ns_ node $temp.$i] 
    $nodeb_($i) random-motion 0
}

source Lane.bas.tcl



# Position (fixed) for base-station nodes (HA & FA).


#$HA set X_ 1.000000000000
#$HA set Y_ 2.000000000000
#$HA set Z_ 0.000000000000


# create a mobilenode that would be moving between HA and FA.
# note address of MH indicates its in the same domain as HA.
$ns_ node-config -wiredRouting OFF
set temp 2.0
for {set i 0} {$i < $opt(nm)} {incr i} {
    set node_($i) [$ns_ node $temp.$i]
    set HAaddress [AddrParams addr2id [$nodeb_([expr $i % $opt(nb)]) node-addr]] 
    [$node_($i) set regagent_] set home_agent_ $HAaddress

#    puts "current index is $i"

    set ragent [$node_($i) set ragent_]
    $ragent msgINET 34
    $ragent vehi-num $opt(nm)
    $ragent base-num $opt(nb)
    $ragent nodeID $i
    $ragent comm_id $opt(nw)
    $ragent AXIS_ip 1

    $ragent conf-map $opt(x) $opt(y) $opt(rowc) $opt(colc)
    $ragent conf-base 3.0 3.0 $opt(nodesXx) $opt(nodesYy)
    $ragent init_juncInfo
}

# create links between wired and BaseStation nodes

# setup TCP connections between a wired node and the MobileHost
source Lane.pat.tcl


for {set i 0} {$i < $opt(nm)} {incr i} {
    set udp_r($i) [new Agent/UDP/TAVRAppAgent]
    $ns_ attach-agent $node_($i) $udp_r($i)

    $udp_r($i) node_id		$i
    $udp_r($i) node_type	2
    $udp_r($i) comm_id 		$opt(nw)

    set app_r($i) [new Application/TAVRApp]
    $app_r($i) attach-agent $udp_r($i)

    $app_r($i) node_id		$i
    $app_r($i) running		1
    $app_r($i) node_type	2
    $app_r($i) comm_id 		$opt(nw)
    $app_r($i) txinterval	2.7
    $app_r($i) rxinterval	3.0
#    set node_($i) [$ns_ node $temp.$i]
}



#Setup a MM UDP connection
for {set i 0} {$i < $opt(nw)} {incr i} {
#    puts "$i current IP is $tmpW.$i"
    set udp_s($i) [new Agent/UDP/TAVRAppAgent]
    $ns_ attach-agent $nodew_($i) $udp_s($i)

    $udp_s($i) node_id		$i
    $udp_s($i) node_type	0
    $udp_s($i) comm_id 		$opt(nw)


    set app_s($i) [new Application/TAVRApp]
    $app_s($i) attach-agent $udp_s($i)

    $app_s($i) node_id		$i
    $app_s($i) running		1
    $app_s($i) node_type	0
    $app_s($i) comm_id 		$opt(nw)
    $app_s($i) txinterval	15.2
    $app_s($i) rxinterval	3.0
#    set nodew_($i) [$ns_ node $tmpW.$i] 
}

    set udp_s($opt(nw)) [new Agent/UDP/TAVRAppAgent]
    $ns_ attach-agent $nodew_($opt(nw)) $udp_s($opt(nw))

    $udp_s($opt(nw)) node_id	$opt(nw)
    $udp_s($opt(nw)) node_type	4

    set app_s($opt(nw)) [new Application/TAVRApp]
    $app_s($opt(nw)) attach-agent $udp_s($opt(nw))

    $app_s($opt(nw)) node_id	$opt(nw)
    $app_s($opt(nw)) running	1
    $app_s($opt(nw)) node_type	4
    $app_s($opt(nw)) txinterval	15.2
    $app_s($opt(nw)) rxinterval	3.0




for {set i 0} {$i < $opt(nm)} {incr i} {
    $ns_ connect $udp_s($opt(nw)) $udp_r($i)
}

for {set i 0} {$i < $opt(nm)} {incr i} {
     $ns_ at 10.0002 "$app_r($i) starttx"
#    set node_($i) [$ns_ node $temp.$i]
}

for {set i 0} {$i < $opt(comm_id)} {incr i} {
#    puts "$i current IP is $tmpW.$i"
     $ns_ at 10.0002 "$app_s($i) starttx"
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



