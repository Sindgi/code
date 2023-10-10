
clc
clear all
close all
% Global Variable Declarations
preallocations;

% Initial input plaintext and key
plaintext = '0123456789ABCDEF';
% plaintext = input('Type in an input message (16 characters or less):\n','s');
plaintext = zerofill(plaintext);
key = 'MachinIntllignce';
% key = input('Type in a secret key/password (16 characters or less):\n','s');
key = zerofill(key);

% Key Schedule
round_keys = key_schedule(double(key));
% Message Encryption
ciphertext = aes_encryption(plaintext,round_keys);
% Message Decryption
plaintext_recov = aes_decryption(ciphertext, round_keys);


