#<q2> Simulate the different types of internet traffic such as FTP and TELNET over network and analyze the throughput

#create a 'simulator' Object instance(that ha0s inbuilt function) and assign it to variable ns
set ns [new Simulator]

#set colors for ftp and telnet packets..here 1 and 2 are field id's
$ns color 1 blue
$ns color 2 red


#open files with write permission to record the simulation trace(of individual packets)
#trace-all function records the trace in general format(NOTE: tracefile1 is identifier through which we access 1.tr) 
set tracefile2 [open 2.tr w]
$ns trace-all $tracefile2    

#namtrace records the trace in nam input format(for network animator)
#network animator is the simulator which shows your network simulation :)
set namfile2 [open nam2.nam w]
$ns namtrace-all $namfile2


#finish is a procedure with post simulation essentials called at the end of the end of the program
#empty braces indicated no parameters are passed into procedure
#identifiers outside the procedure are not directly accessible so they are declared using ''global' command
proc finish {} {

       global ns tracefile2 namfile2
       
       #flush-trace command writes all the traces recorded above(by namtrace-all and trace-all) into their respective files
       $ns flush-trace                  
       
       #closing the files
       close $tracefile2
       close $namfile2
       
       #following 'exec' command is to run NAM (nam1 is the file that contains the trace records in nam format)
       exec nam nam2.nam &
       exec awk -f q2awk.awk 2.tr  &
       #exec xgraph -geometry 800X800 -p -bg white -t BANDWIDTH_VS_THROUGHPUT(ftp) -x BANDWIDTH(kB)  -y THROUGHPUT(bps) ftp.xg &  
        #exec xgraph -geometry 800X800 -p -bg white -t BANDWIDTH_VS_THROUGHPUT(telnet) -x BANDWIDTH(kB)  -y THROUGHPUT(bps) telnet.xg &  
       exit 0 
       #exit to terminal
       }

#create four node using for loop(NOTE: in ns2 variables are accessed using dollar sign)
for {set i 0} {$i < 4} {incr i} { 
    

          set n($i) [$ns node]
     }
  
#create duplex links between the nodes
$ns duplex-link $n(0) $n(2) 100Kb 10ms DropTail  
$ns duplex-link $n(1) $n(2) 100Kb 10ms DropTail
$ns duplex-link $n(2) $n(3) 100Kb 10ms DropTail 

#set queue limit
$ns queue-limit $n(0) $n(2) 10 
$ns queue-limit $n(1) $n(2) 10 
$ns queue-limit $n(2) $n(3) 10 

#orientation
$ns duplex-link-op $n(0) $n(2) orient down
$ns duplex-link-op $n(2) $n(1) orient right-down
$ns duplex-link-op $n(2) $n(3) orient left-down


#set up a TELNET connection over TCP between node n(0) and n(3)
set tcp2 [new Agent/TCP]
$ns attach-agent $n(0) $tcp2
#create a sink for this tcp agent
set sink2 [new Agent/TCPSink]
$ns attach-agent $n(3) $sink2
$ns connect $tcp2 $sink2
$tcp2 set fid_ 2

#create a TELNET(Application layer protocol) Application over tcp
#TELNET objects produce individual packets with inter arrival time as set(if it is set zero then interval time between packets is chosen from "tcplib"(a library of TCP internetwork 
# Traffic characteristics) telnet distribution(wich is cumulative distribution as per library documentation)  
set telnet2 [new Application/Telnet]
$telnet2 attach-agent $tcp2
$telnet2 set interval_ 0
#$telnet2 set type_ Telnet

#set up  a FTP connection over TCP between node n(1) and (3)
set tcp0 [new Agent/TCP]
$ns attach-agent $n(1) $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n(3) $sink0
$ns connect $tcp0 $sink0
$tcp0 set fid_ 1

#create a FTP application over TCP agent
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp0
$ftp2 set type_ FTP
#$telnet2 set interval_ 0.01

$ns at 0.3 "$telnet2 start"
$ns at 0.6 "$ftp2 start"
$ns at 24.5 "$telnet2 stop"
$ns at 24.5 "$ftp2 stop"
$ns at 25.0 "finish"

#command to run Simulation
$ns run
