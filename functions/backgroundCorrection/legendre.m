function [val,dx] = legendre(x,n)
arguments
    x = []
    n (1,1) {mustBeInteger(n)} = 10 % order of the polynomial
end

if isempty(x)
    clear x
    syms x
    n=10;
end
val=0;

for k=0:n
    val = val + nchoosek(n,k)*nchoosek(n,k)*(x-1).^(n-k).*(x+1).^k;
end

dx=x(2)-x(1);

val=val/2^n*sqrt((2*n+1)/2);
