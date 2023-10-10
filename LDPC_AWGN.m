%--------------------------------------------------------------------------
%-----Chamitha-de-Alwis----------------------------------------------------
%-----University-of-Surrey-------------------------------------------------
%-----chamithadealwis@hotmail.com------------------------------------------
%--------------------------------------------------------------------------

clear
clc
clear

%--------------------------------------------------------------------------
%-----Set-Simulation-Parameters--------------------------------------------
%--------------------------------------------------------------------------

snrs = [10 13 15];      %SNR values
%codeRate = 9/10; %Possible values for codeRate are 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9, and 9/10. The block length of the code is 64800
codeRate = 1/2; %Possible values for codeRate are 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9, and 9/10. The block length of the code is 64800

mod_order = 4;  %PSK Modulation Order
frames =   1;  %Number of frames (fame size is 64800 bits) to be simulated

%--------------------------------------------------------------------------

rounds = size(snrs,2);

%messageLength = round(64800*codeRate);
messageLength = round(64800*codeRate);


for run = 1:1:1

framepattern = [];    
    
snrvalue = snrs(run);

H = dvbs2ldpc(codeRate);

%spy(H);   % Visualize the location of nonzero elements in H.

errors = 0;

hEnc = comm.LDPCEncoder(H);
%hMod = comm.PSKModulator(mod_order, 'BitInput',true);
hMod = comm.BPSKModulator();
hChan = comm.MIMOChannel('MaximumDopplerShift', 0, 'NumTransmitAntennas',1,'NumReceiveAntennas',1, 'TransmitCorrelationMatrix', 1, 'ReceiveCorrelationMatrix', 1, 'PathGainsOutputPort', true);
hAWGN = comm.AWGNChannel('NoiseMethod','Signal to noise ratio (SNR)','SNR',snrvalue);
% hDemod = comm.PSKDemodulator(4, 'BitOutput',true,'DecisionMethod','Approximate log-likelihood ratio',...
%                              'Variance', 1/10^(hChan.SNR/10));
%hDemod = comm.PSKDemodulator(4, 'BitOutput',true,'DecisionMethod','Approximate log-likelihood ratio');    
hDemod = comm.BPSKDemodulator();   
hDec = comm.LDPCDecoder(H,'DecisionMethod', 'Soft decision');
%hError = comm.ErrorRate;
for counter = 1:frames
    receiveddataBits = [];
    data           = logical(randi([0 1], messageLength, 1));
    
    
%    data = randi([0 hMod.ModulationOrder-1], messageLength, 1);
    encodedData    = step(hEnc, data);
 

    
    
    modSignal      = step(hMod, encodedData);
    
    
    % Transmit through Rayleigh and AWGN channels
    [chanOut, pathGains] = step(hChan, modSignal);  
    receivedSignal = step(hAWGN, chanOut);
    demodSignal    = step(hDemod, receivedSignal);
    receivedBits   = step(hDec, demodSignal);
    %errorStats     = step(hError, data, receivedBits);
    
    for i=1:1:messageLength
        if receivedBits(i,1) >= 0
            receiveddataBit = 0;
        else
            receiveddataBit = 1;
        end
        receiveddataBits = [receiveddataBits; receiveddataBit];
    end
    receiveddataBits
    
    newErrors = nnz(receiveddataBits-data);
    errors = errors + newErrors;
    if newErrors == 0
        addFramepattern = 1;
    else
        addFramepattern = 0;
    end
    framepattern = [framepattern addFramepattern];
    
    clc
    run
    counter
    errors
    code_errors = (size(framepattern,2) - nnz(framepattern));
    code_errors
end

SumErrors(run) = errors;
BER(run) = errors/(frames*64800);
FER(run) = (size(framepattern,2) - nnz(framepattern))/size(framepattern,2);

snrvaluestr = num2str(snrvalue);
filename = strcat(snrvaluestr, '.txt');
fid = fopen(filename,'w');
fprintf(fid, '%d ', framepattern);
fclose(fid);
end
clc
SumErrors
BER
FER
%fprintf('Error rate = %1.2f\nNumber of errors = %d\n', errorStats(1), errorStats(2))