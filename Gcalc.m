function [calcG] = Gcalc(D, thickness,Sigma)

%Sigma = 11.2; %Solution conductivity in S/m 

calcG = Sigma / (4*thickness/(pi*D^2) + 1/D);
