function [fil]= compose3(i)

  if i<10; fil=compose("00%i",i);end
  if (i>9 && i<100); fil=compose("0%i",i);end
  if (i>99 && i<1000); fil=compose("%i",i);end 
