#<q1> Simulate three nodes point-to-point networks with Duplex links between them. Set the queue size and vary the bandwidth and find the number of packets dropped

#see here point to point means communication is only between those two points...a packet sent from one point reaches only 
#the other point and.

#create an object of class 'Simulator' (that has inbuilt functions) and assign it to variable ns
#Simulator is a class.

#REFER JGYAN FOR INFO ON NS2


set ns [new Simulator]

#this command sets the static routing strategy for packets movement while(static routing uses Dijkstra's all pair shortest path algorithm to calculate the path)
$ns rtproto Static

# NOTE : USE COMMAND SET WHENEVER U ARE CREATING A VARIABLE....

#setting the color of packets for the path specified by fid(flow id)
#we set this through a function of Simulator object (ns here represents the instace of it)

$ns color 2 blue

#open files with write permission to record the simulation trace(of individual packets)
#trace-all and namtrace-all are functions that come with Simulator class function records the trace in general format
#(NOTE: tracefile1 is identifier through which we access 1.tr) 
#creating variable tracefile1

set tracefile1 [open 1.tr w] 
$ns trace-all $tracefile1     

#namtrace records the trace in nam input format(for network animator)
#network animator is the simulator which shows your network simulation :)
set namfile1 [open nam1.nam w]
$ns namtrace-all $namfile1

#finish is a procedure with post simulation essentials called at the end of the end of the program
#empty braces indicated no parameters are passed into procedure
#identifiers outside the procedure are not directly accessible so they are declared using ''global' command
proc finish {} {

       global ns tracefile1 namfile1
       
       #flush-trace command writes all the traces recorded above(by namtrace-all and trace-all) into their respective files
       $ns flush-trace                  
       
       #closing the files
       close $tracefile1
       close $namfile1
       
       #following 'exec' command is to run NAM (nam1 is the file that contains the trace records in nam format)
       exec nam nam1.nam &
       exec awk -f lost.awk 1.tr &
       exec xgraph -geometry 800X800 -p -bg white -t BANDWIDTH_VS_PACKETDROPPED -x BANDWIDTH(MB)  -y PACKETS_DROPPED dropped.xg #&  
       exit 0 
       #exit to terminal
       }
       
#setting up nodes(which are also objects with functions in it) using 'node' member function of ns 
set n(1) [$ns node]
set n(2) [$ns node]
set n(3) [$ns node]

#setting up links between two node FORMAT: $ns duplex-link node1 nod2 bandwidth delay queue-type


#NOTE: THIS IS JUST PHYSICAL CONNECTION...LOGICAL CONNECTION HAPPENS WHEN U SET AGENT AND SINK TO RESPECTIVE NODES
$ns duplex-link $n(1) $n(2) 0.7Mb 20ms DropTail
$ns duplex-link $n(2) $n(3) 0.7Mb 20ms DropTail
$ns duplex-link $n(3) $n(1) 0.7Mb 20ms DropTail

#setting DropTail queue limit which by default is 50 packets
#when queue filled to its maximum capacity the newly incoming packets are dropped until queue have sufficient space to accept incoming traffic.
$ns queue-limit $n(1) $n(2) 10
$ns queue-limit $n(2) $n(3) 10

#next two blocks are optonal
$n(1) shape hexagon
$n(1) color blue

$n(3) shape square
$n(3) color blue

#orientation
$ns duplex-link-op $n(1) $n(2) orient right-down

$ns duplex-link-op $n(1) $n(3) orient left-bottom

#create a UDP agent and attach it to node n(1)
set udp1 [new Agent/UDP]
$ns attach-agent $n(1) $udp1

# create CBR traffic generator and attach it to udp agent wich is attached to the node 1
#it generates packet of constant size

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 512 #The default TCP packet size in ns-2 is 1000 bytes...here 512 Bytes
$cbr1 set interval_ 0.005 
#time between each packet generation

$cbr1 attach-agent $udp1 

#agent requires a sink which accepts data and UDP agent require a null agent which do not generate acknowledgement as udp is unreliable protocol
#see there may be a link between n1 and n2 but communic is taking palce only between n1 and n3
#as agent and sink are set for these two nodes only.
set null1 [new Agent/Null]
$ns attach-agent $n(3) $null1

#then we need to connect the source and the sink

$ns connect $udp1 $null1
$udp1 set fid_ 2  #flow id for this connection is set as 2 for which we assigned the color red

#we need to specify the simulation events 

$ns at 0.5 "$cbr1 start"
$ns at 2.0 "$cbr1 stop"
$ns at 2.0 "finish"

#to start Simulation
$ns run 
