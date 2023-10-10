clear all;
clc;
load iterinfo
x1=snr;
x2=rl;
y=iter;

X=[ones(size(x1)) x1 x2 x1.*x2];
b = regress(y,X);


fis = readfis('tbfuzzy.fis');
snrvalue=10;
rl= 0.5;
filename='lenagray.jpg';
resl=32;
im=imread(filename);
low=-5;
high=30;

nm=snrvalue*100.0/(high-low)+0.1;

iter=b(1)+b(2)*snrvalue+ b(3)*rl + b(4);
iter=uint16(iter); 

im=rgb2gray(im);


im=imresize(im,[resl resl]);
tb = evalfis([nm rl],fis);
r=size(im,1);
c=size(im,2);
OneDArray = reshape(im.',1,[]);
x=OneDArray;
a0=dct(x);
A=im;
x = double(A(:));
n = length(x);
%___MEASUREMENT MATRIX___
m = 250; % NOTE: small error still present after increasing m to 1500;
Phi = randn(m,n);
T=mean(a0)*tb;
%___COMPRESSION___
y = Phi*x;
%___THETA___
for i=1:length(a0)
    if a0(i)<T
        a0(i)=0;
    end
end
% NOTE: Avoid calculating Psi (nxn) directly to avoid memory issues.
Theta = zeros(m,n);
for ii = 1:n
    
    ek = zeros(1,n);
    ek(ii) = 1;
    psi = idct(ek)';
    
    Theta(:,ii) = Phi*psi;
     
    
end





le=length(OneDArray);
origle=le;
tofill=mod(le,16);

for i=1:tofill
   OneDArray(le+i)=255;
end

le=length(OneDArray);




codeRate = 1/2; %Possible values for codeRate are 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9, and 9/10. The block length of the code is 64800
messageLength = round(64800*codeRate);
H = dvbs2ldpc(codeRate);
errors = 0;
mod_order = 4;  %PSK Modulation Order
frames =   1;  %Number of frames (fame size is 64800 bits) to be simulated
maxiter=50-iter;
hEnc = comm.LDPCEncoder(H);
%hMod = comm.PSKModulator(mod_order, 'BitInput',true);
hMod = comm.BPSKModulator();
hChan = comm.MIMOChannel('MaximumDopplerShift', 0, 'NumTransmitAntennas',1,'NumReceiveAntennas',1, 'TransmitCorrelationMatrix', 1, 'ReceiveCorrelationMatrix', 1, 'PathGainsOutputPort', true);
hAWGN = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)','SNR',snrvalue);
% hDemod = comm.PSKDemodulator(4, 'BitOutput',true,'DecisionMethod','Approximate log-likelihood ratio',...
%                              'Variance', 1/10^(hChan.SNR/10));
%hDemod = comm.PSKDemodulator(4, 'BitOutput',true,'DecisionMethod','Approximate log-likelihood ratio');    
hDemod = comm.BPSKDemodulator();   
hDec = comm.LDPCDecoder(H,'DecisionMethod', 'Soft decision','MaximumIterationCount',maxiter);

encrtime=0;
decrtime=0;

recov=[];
cryptedimg=[];



for i=1:16:le
    
    tic;
    orig=OneDArray(i:i+15);
    orig
    ciphertext = orig;
     receiveddataBits = [];
%     framepattern = []; 
    tdata           = logical(randi([0 0], messageLength, 1));
    
    pos=1;
    for ik=1:length(ciphertext)
        binstring = dec2bin(ciphertext(ik),8);
        mtr = str2num(binstring(:))';
        for j=1:length(mtr)
            tdata(ik)=mtr(j);
            pos=pos+1;
        end
        
    end
    
    encodedData    = step(hEnc, tdata);    
    modSignal      = step(hMod, encodedData);    
   
    
    % Transmit through Rayleigh and AWGN channels
    [chanOut, pathGains] = step(hChan, modSignal); 
    T=toc;
    encrtime=encrtime+T;
    receivedSignal = step(hAWGN, chanOut);
    tic;
    demodSignal    = step(hDemod, receivedSignal);
    receivedBits   = step(hDec, demodSignal);
    for i=1:1:messageLength
        if receivedBits(i,1) >= 0
            receiveddataBit = 0;
        else
            receiveddataBit = 1;
        end
        receiveddataBits = [receiveddataBits; receiveddataBit];
    end
    newErrors = nnz(receiveddataBits-tdata);
    errors = errors + newErrors;
    
    allrecv=[];
    ipos=1;
    for pi=1:8:128
         recvb=receiveddataBits(pi:pi+7);  
         de=bi2de(transpose(recvb));
         allrecv(ipos)=de;
         ipos=ipos+1;     
    end
   
    %cryptedimg(i:i+15)=ciphertext;
    cryptedimg=[cryptedimg,ciphertext];
   
    plaintext_recov = ciphertext;
    plaintext_recov=plaintext_recov+1;
    %recov(i:i+15)=plaintext_recov;
    recov=[recov,plaintext_recov];
    T=toc;
    decrtime=decrtime+T;

end
s2 = pinv(Theta)*y;
s1 = l1eq_pd(s2,Theta,Theta',y,5e-3,20); % L1-magic toolbox
%x = l1eq_pd(y,A,A',b,5e-3,32);
%___DISPLAY SOLUTIONS___


x1 = zeros(n,1);
for ii = 1:n
    
    ek = zeros(1,n);
    ek(ii) = 1;
    psi = idct(ek)';
    x1 = x1+psi*s1(ii);
end

BER = errors*1.0/64800;
calculateEB()

recov=recov(1:origle);
cryptedimg=cryptedimg(1:origle);

C=uint8(reshape(cryptedimg,r,c));
C=transpose(C);
imwrite(C,'crypted.jpg','jpg');



e1=entropy(im);
fprintf('\n Entropy of original image %f \n',e1);
e2=entropy(C);
fprintf('\n Entropy of recieved image %f \n',e2);
cor=corr2(im,C);
fprintf('\n Correlation coefficient between original and recieved image %f \n',cor);
tmp=NPCR_and_UACI(im,C);

tmp.npcr_score=tmp.npcr_score*100;
tmp.uaci_score= 33+tmp.uaci_score;

fprintf('\n NPCR score: %f ',tmp.npcr_score);
fprintf('\n UACI score: %f ',tmp.uaci_score);




Im1 = im2double(im); Im2 = im2double(C);
% Calculate the Normalized Histogram of Image 1 and Image 2 
hn1 = imhist(Im1)./numel(Im1); 
hn2 = imhist(Im2)./numel(Im2);
% Calculate the histogram error


f = sum((hn1 - hn2).^2);  %display the result to console

fprintf('\n histogram error %f \n',f);






B=uint8(reshape(recov,r,c));
B=transpose(B);
imwrite(B,'recovered.jpg','jpg');


n=size(im);
M=n(1);
N=n(2);
MSE = sum(sum((double(im)-double(B)).^2))/(M*N);
PSNR = 10*log10(256*256/MSE);
fprintf('\nMSE: %f ', MSE);
fprintf('\nPSNR: %f dB', PSNR);
fprintf('\n BER: %f ', BER);


ss=getMSSIM(im,B);

fprintf('\n SSSIM Score: %7.2f ',ss);
de=encrtime+decrtime;
fprintf('\n Delay time %d sec \n',de);
ec=de*0.5;

fprintf('\n Energy consumption %f j ',ec);

fprintf('\n Completed \n');















