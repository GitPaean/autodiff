function J = gmm_objective_d_man(alphas,means,inv_cov_factors,x,hparams)
% GMM_OBJECTIVE  Evaluate GMM negative log likelihood for one point
%             ALPHAS 
%                1 x k vector of logs of mixture weights (unnormalized), so
%                weights = exp(log_alphas)/sum(exp(log_alphas))
%             MEANS
%                d x k matrix of component means
%             INV_COV_FACTORS 
%                (d*(d+1)/2) x k matrix, parametrizing 
%                lower triangular square roots of inverse covariances
%                log of diagonal is first d params
%             X 
%               are data points (d x n vector)
%             HPARAMS
%                [gamma, m] wishart distribution parameters
%         Output ERR is the sum of errors over all points
%      To generate params given covariance C:
%           L = inv(chol(C,'lower'));
%           inv_cov_factor = [log(diag(L)); L(au_tril_indices(d,-1))]

p = size(x,1);
k = size(alphas,2);
n = size(x,2);
gamma = hparams(1);
m = hparams(2);

lower_triangle_indices = tril(ones(p,p), -1) ~= 0;

Aterm = zeros(k,n,'like',alphas);
Bterm = zeros(p,k,'like',alphas);
Cterm = zeros(p,k,'like',alphas);
for ik=1:k
    % Unpack L parameters into d*d matrix.
    Lparams = inv_cov_factors(:,ik);
    % Set L's diagonal
    logLdiag = Lparams(1:p);
    L = diag(exp(logLdiag));
    % And set lower triangle
    L(lower_triangle_indices) = Lparams(p+1:end);
    
    mahal = L*(x - repmat(means(:,ik),1,n));
%     mahal = L*bsxfun(@minus,means(:,ik),x); % bsxfun does not work with AdiMat
    
    Aterm(ik,:) = alphas(ik) + sum(logLdiag) - 0.5 * sum(mahal.^2,1);
    Bterm(:,ik) = sum(mahal'*L,1);
    for i = 1:n
        Cterm(:,ik) = Cterm(:,ik)' +  1 - mahal(:,i)'*...
            diag(exp(logLdiag).*(x(:,i)-means(:,ik)));
    end
end

eAterm = exp(Aterm);

seAterm = sum(eAterm,1);
eAterm = bsxfun(@rdivide,eAterm,seAterm);

ealphas = exp(alphas);
Jalphas = sum(eAterm,2)' - n*ealphas/sum(ealphas);

Jmeans = bsxfun(@times,Bterm,sum(eAterm,2)');

tmp = inv_cov_factors(1:p,:);
Jq = bsxfun(@times,Cterm,sum(eAterm,2)') + gamma^2*(exp(tmp).^2) - m*ones(p,k);

J = [Jalphas Jmeans(:)' Jq(:)'];

end

