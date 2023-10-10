function [res,de]=doexor(val1,val2)

pos=1;
for i=1:length(val1)
      
       binstring1 = dec2bin(val1(i),8);
       binstring2 = dec2bin(val2(i),8);
       
       for j=1:8
          if binstring1(j)~=binstring2(j)              
              res(pos)=1;
          else
              res(pos)=0;
          end
          pos=pos+1;
       end
       
       
end

de=uint8(bi2de(res));


       
       
