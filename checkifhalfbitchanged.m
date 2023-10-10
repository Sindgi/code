function [res,res2]=checkifhalfbitchanged(val1,val2)

   numbits=length(val1)*8;
   samebits=0;
   for i=1:length(val1)
      
       binstring1 = dec2bin(val1(i),8);
       binstring2 = dec2bin(val2(i),8);
       
       for j=1:8
          if binstring1(j)==binstring2(j)
              samebits=samebits+1;
          end
       end
       
       
   end
   
   pr=samebits*1.0/numbits;
   
   res=0;
   res2=0;
   if pr==0.5
       res=1; 
   end
   
   if pr>0.5
       res2=1;
   end
 