clear all;
clc;
load iterinfo
x1=snr;
x2=rl;
y=iter;

X=[ones(size(x1)) x1 x2 x1.*x2];
b = regress(y,X);
snr=30;
rel=0.3;
it=b(1)+b(2)*snr+ b(3)*rel+b(4);
it