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


set opt(stop)   	50.0                         	;# time of simulation end

set opt(ftp1-start)     100.0




#set num_bs_nodes       2  ; this is not really used here.
source "Lane.sce.tcl"

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
lappend eilastlevel $opt(nw) $opt(nb) $opt(nm)          ;# number of nodes in each cluster 
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
for {set i 0} {$i < $opt(nw)} {incr i} {
#    puts "$i current IP is $tmpW.$i"
    set nodew_($i) [$ns_ node $tmpW.$i] 
}

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
		-energyModel   $opt(engmodel) \
		-initialEnergy $opt(initeng) \
		-txPower       $opt(txPower) \
		-rxPower       $opt(rxPower) \
		-idlePower     $opt(idlePower) \
                 -wiredRouting ON \
		 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON 

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
#    $ragent AXIS_ip 1
#    $ragent confmapx $opt(x)
#    $ragent confmapy $opt(y)
#    $ragent confmapr $opt(rowc)
#    $ragent confmapc $opt(colc)
    $ragent conf-map $opt(x) $opt(y) $opt(rowc) $opt(colc)
#    $ragent printbs
#                          0123456789
#    $ragent debug-flaglist 122406089
}

# create links between wired and BaseStation nodes





# setup TCP connections between a wired node and the MobileHost
source Lane.pat.tcl

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

for {set i 0} {$i < $opt(nw) } {incr i} {
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



