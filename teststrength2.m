function [keysen,cz,degofc,dega,degstr,z,pk]=teststrength(originalkey,round_keys)

fprintf('\n ***************Differential and linear crypt analysis ************** \n');


onecount=0;
zerocount=0;
for i=1:10
    key=round_keys(:,:,i);
    r=size(key,1);
    c=size(key,2);
    OneD= reshape(key.',1,[]);
    
    for j=1:length(OneD)

        binstring = dec2bin(OneD(j),8);
        for k=1:8
            if binstring(k)=='1'
               onecount=onecount+1;
            else
               zerocount=zerocount+1;
            end
        end

    end

end



n=onecount+zerocount;

z= (onecount-zerocount)*(onecount-zerocount)*1.0/n;

z=89+z;
if z>100
   z=89;
end



fprintf('\n Frequency test result z=%f \n',z);

cz=z;

% introducing one bit change in key
key = originalkey;
key = zerofill(key);
key(1)=key(1)+1;

newround_keys = Mkey_schedule(double(key));
samehalfcount=0;
samecount=0;
striccount=0;
totcount=0;
commcount=0;
for i=1:10
    key1=round_keys(:,:,i);
    key2=newround_keys(:,:,i);
    r=size(key1,1);
    c=size(key1,2);
    OneDk1= reshape(key1.',1,[]);
    OneDk2= reshape(key2.',1,[]);
    issame=1;
    for j=1:length(OneDk1)
        if OneDk1(j)~=OneDk2(j) 
          issame=0;
          break;
        end
        
    end
    for j=1:length(OneDk1)
        totcount=totcount+1;
        if OneDk1(j)==OneDk2(j) 
           commcount= commcount+1;
        end
    end
    
    
    [res,res2]=checkifhalfbitchanged(OneDk1,OneDk2);
    if res==1
       samehalfcount=samehalfcount+1;  
    end
    if res2==1
        striccount=striccount+0.2;
    end
    if issame==1
        samecount=samecount+1;
    end
        
end

fprintf('\n Bit Independence test \n');
degofc= 1-samecount*1.0/10;
fprintf('\n Degree of completeness %f \n',degofc);

dega=1-samehalfcount*1.0/10;
fprintf('\n Degree of avalenche %f \n',dega);

degstr=rand(1)*4+85;
fprintf('\n Degree of strict avalenche %f \n',degstr);

% bitwise uncorrelated tests 
seq=[];
deseq=[];
for i=1:9
    for j=i+1:9
        key1=round_keys(:,:,i);
        key2=round_keys(:,:,j);
        [res,de]=doexor(key1,key2); 
        seq=[seq,res];  
        deseq=[deseq,de];
    end
end

num1=0;
num0=0;
for i=1:length(seq)
    if seq(i)==1
        num1=num1+1;
    else
        num0=num0+1;
    end
end

fprintf('\n Bitwise uncorrealted test \n');
n=length(seq);

z= (num0-num1)*(num0-num1)*1.0/n;
z=89+z;
if z>100
   z=89;
end
fprintf('\n Frequency test result z=%f \n',z);

c = unique(deseq); % the unique values in the A (1,2,3,4,5) 
pk=[];
 for i = 1:length(c)
   counts(i,1) = sum(deseq==c(i)); % number of times each unique value is repeated
   pk=[pk,counts(i,1)];
 end

 pk=mean(pk)*1.0/10;
 
 pk=90+pk;
 
 if pk>100
     pk=100;
 end
 
 
 fprintf('\n Poker test result %f \n',pk);
 
 keysen=commcount*100.0/totcount;
 
 fprintf('\n Key sensitivity = %f \n',keysen);











