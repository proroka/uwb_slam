% 13.04.2012
% Amanda Prorok
%
% Weight the i-th particle
%
% --In--
% ppar{bs}.m [num_mod,1]
% ppar{bs}.s [num_mod,1]
% ppar{bs}.w [num_mod,1]
% dtdoa{bs}[num_particles,1]
%
%%

function F = f_get_dtdoa_prob(par,dtdoa)

K = length(par{1}.m);
num_bs = length(par)+1;

F = 1;
for bs=1:num_bs-1
    %x = dtdoa{bs}(i);
    x = dtdoa(bs);
    % Create the PDF
    P = zeros(K,1);
    for f=1:K
        %P(f,:) = par{bs}.w(f) .* 1/(sqrt(2*pi)*par{bs}.s(f)) .* exp(-(x-par{bs}.m(f)).^2 ./ (2*par{bs}.s(f)^2));
        P(f) = par{bs}.w(f) * normpdf(x,par{bs}.m(f),par{bs}.s(f));
    end
    F = F * sum(P); % probability over all modes and base-stations
    
end

end