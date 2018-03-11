# Copyright (c) 1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# wireless3.tcl
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
set opt(nm)             45                     	;# number of mobilenodes
set opt(nb)             18                     	;# number of base stations
set opt(nw)             18     			;# number of wired nodes
set opt(adhocRouting)   SIMUTAVR               	;# routing protocol

set opt(cp)             ""                     	;# connection pattern file
set opt(sc)     	"ns2mobility.tcl"    	       	;# node movement file. 

set opt(x)      	2131                      	;# X dimension of topography
set opt(y)      	1003                      	;# Y dimension of topography
set opt(rowc)		4		
set opt(colc)		3
set opt(stop)   	1000.0                         	;# time of simulation end

set opt(ftp1-start)     100.0

#set num_bs_nodes       2  ; this is not really used here.

# mobile nodes257 nb 78 nw 78   nam 1.5GB  tr 2.1GB. time 40m

# ======================================================================

# check for boundary parameters and random seed
if { $opt(x) == 0 || $opt(y) == 0 } {
	puts "No X-Y boundary values given for wireless topology\n"
}

# create simulator instance
set ns_   [new Simulator]

# set up for hierarchical routing
$ns_ node-config -addressType hierarchical 3 8 8 16

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
    puts "$i current IP is $tmpW.$i"
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
                 -wiredRouting ON \
		 -agentTrace ON \
                 -routerTrace OFF \
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
    set node_($i) [$ns_ node $temp.[expr $i + 1]]
    set HAaddress [AddrParams addr2id [$nodeb_([expr $i % $opt(nb)]) node-addr]] 
    [$node_($i) set regagent_] set home_agent_ $HAaddress

#    puts "current index is $i"

    set ragent [$node_($i) set ragent_]
    $ragent confdebug 102
    $ragent msgINET 34
    $ragent vehi-num $opt(nm)
    $ragent base-num $opt(nb)
    $ragent nodeID $i
#    $ragent confmapx $opt(x)
#    $ragent confmapy $opt(y)
#    $ragent confmapr $opt(rowc)
#    $ragent confmapc $opt(colc)
    $ragent conf-map $opt(x) $opt(y) $opt(rowc) $opt(colc)
    $ragent printbs
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




