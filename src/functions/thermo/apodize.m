%%function that return a N-vector that is the profile of a function
%%ax^2+bx^3 with given values (s1, s2) and slopes (t1, t2) at its
%%boudnaries. In this program, one boundary is the border features
%%s1=0 and t1=0, hence the name of the function.
%%-- G. Baffou 20 sept 2013 --

%%The left hand side of the vector is supposed to be zero (i=1)

function A=apodisation(N,s2,t2)

%N=100;

%s2=10;
%t2=0.2;

a=(3*s2-N*t2)/(N*N);
b=(N*t2-2*s2)/(N*N*N);

x=1:N;

A=x.*x.*(a+b*x);


%plot(A)


