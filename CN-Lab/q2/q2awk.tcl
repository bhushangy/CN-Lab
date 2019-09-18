BEGIN{
        
        
        telnetsize=0;
        ftpsize=0;
        totaltelnet=0;
        ftptotal=0;
        
      }
      
    {
    
      event=$1;
      pkttype=$5;
      fromnode=$9;
      tonode=$10;
      pktsize=$6;
      
      if(event=="r" && pkttype=="tcp" && fromnode =="0.0" && tonode=="3.0")
       {
          
           totaltelnet+=pktsize;
       }
       
       if(event=="r" && pkttype=="tcp" && fromnode =="1.0" && tonode=="3.1")         
        {
             
             ftptotal+=pktsize;
        }
        
        
    }
    
END {
   printf("Throughput of ftp is %d \n",(ftptotal*8)/24);
   printf("throughput of telnet is %d \n",(totaltelnet*8)/24);  
   
} 
