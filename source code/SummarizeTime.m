function F_t = SummarizeTime(T)
% Parameters:
% <T> - Nsim x N cell - recording recovery time for each building. T{i,j}
% is a 1xM vector, where M is the number of functional states. All
% buildings should have the same maximum functional states
% 
% Returns:
% <F_t> - 1 x Nsim cell - F_t{i} is a (2M) x n matrix. The 2i th row is the
% percent of buildings that have reached different functional states. The
% 2i-1 th rows is the corresponding time when the percent is reached.

M = numel(T{1,1});
Nsim = size(T,1);
N = size(T,2);
F_t = cell(1,Nsim);

Ttemp = zeros(Nsim,N,M);
for i=1:Nsim
    for j=1:N
      Ttemp(i,j,:) = T{i,j};
    end
end
T = Ttemp;

Q = quantile(T,(0:1:100)./100,2);
for i=1:Nsim
    temp = zeros(2*M,size(Q,2));
    temp(1:2:end,:) = reshape(Q(i,:,:),[],M)';
    temp(2:2:end,:) = repmat((0:1:100)./100,M,1);
    F_t{i} = temp;
end

end

