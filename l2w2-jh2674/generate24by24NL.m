% Finite difference drum/chime 
% Bruce Land, Cornell University, May 2008
% second order scheme from
% http://arxiv.org/PS_cache/physics/pdf/0009/0009068v2.pdf, 
% page 14, eqn 2.18

clear all
clc

%linear dimension of membrane -- bigger is lower pitch
n = 26 ;
u = zeros(n,n); %time t
u1 = zeros(n,n); %time t-1
u2 = zeros(n,n); %time t-2
uHit = zeros(n,n); %input strike

% turncation to simulate fixed point
trun = 100000;

% 0 < rho < 0.5 -- lower rho => lower pitch
% rho = (vel*dt/dx)^2
rho = .2 ;
% eta = damping*dt/2
% higher damping => shorter sound
eta = .0005 ;
% boundary condition -1.0<gain<1.0
% 1.0 is completely free edge
% 0.0 is clamped edge
boundaryGain = 0.0 ;


%sets the amplitude of the stick strike 
ampIn = .5; 
%sets the position of the stick strike: 0<pos<n
x_mid = n/2;
y_mid = n/2;
%sets width of the gaussian strike input 
alpha = .05 ;
%compute the gaussian strike amplitude
for i=2:n-1
    for j=2:n-1
        uHit(i,j) = ampIn*exp(-alpha*(((i-1)-x_mid)^2+((j-1)-y_mid)^2));
    end
end