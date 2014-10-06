function [diameter] = dcalc(G, thickness,Sigma)

%Sigma = 11.2; %Solution conductivity in S/m 

diameter = G/(2*Sigma)*(1 + sqrt(1+(16*Sigma*thickness)/(pi*G)));

