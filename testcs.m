clear, close all, clc
A = imread('lenagray.jpg');

A=rgb2gray(A);

A=imresize(A,[64 64]);

r=size(A,1);
c=size(A,2);

%A = A([50:99],[50:99]);

x = double(A(:));
n = length(x);
%___MEASUREMENT MATRIX___
m = 250; % NOTE: small error still present after increasing m to 1500;
Phi = randn(m,n);
    %__ALTERNATIVES TO THE ABOVE MEASUREMENT MATRIX___ 
    %Phi = (sign(randn(m,n))+ones(m,n))/2; % micro mirror array (mma) e.g. single
    %pixel camera Phi = orth(Phi')'; % NOTE: See Candes & Romberg, l1
    %magic, Caltech, 2005.
%___COMPRESSION___
y = Phi*x;
%___THETA___
% NOTE: Avoid calculating Psi (nxn) directly to avoid memory issues.
Theta = zeros(m,n);
for ii = 1:n
    
    ek = zeros(1,n);
    ek(ii) = 1;
    psi = idct(ek)';
    Theta(:,ii) = Phi*psi;
end
%___l2 NORM SOLUTION___ s2 = Theta\y; %s2 = pinv(Theta)*y
s2 = pinv(Theta)*y;
%___BP SOLUTION___
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



