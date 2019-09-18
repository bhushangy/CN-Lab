BEGIN{

    totallost=0;
  }

{
   packettype=$5;
   event =$1; 
   
  if(packettype=="cbr")
   {
      if(event=="d")
       {
           totallost++;
      }
   }
   
}   
END{

  printf("total number of packet lost is: %d\n",totallost);
  
}
