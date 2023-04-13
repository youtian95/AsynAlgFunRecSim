
function h = HeightExp(hmin,hmax,n)
% randomly generate building height

miu = 100;

p1 = cdf('Exponential',hmin,miu);
p2 = cdf('Exponential',hmax,miu);

p = rand(n).*(p2-p1)+p1;

h = icdf('Exponential',p,miu);

end