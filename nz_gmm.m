function[mu,sigma,phi]=nz_gmm(data, K)






m = size(data, 1);

k = K;  % The number of clusters.
n = size(data,2)  % The vector lengths.

% Randomly select k data points to serve as the initial means.
indeces = randperm(m);
mu = data(indeces(1:k), :);

sigma = [];

% Use the overal covariance of the dataset as the initial variance for each cluster.
for (j = 1 : k)
    sigma{j} = cov(data);
end

% Assign equal prior probabilities to each cluster.
phi = ones(1, k) * (1 / k);

%%===================================================
%% STEP 3: Run Expectation Maximization

% Matrix to hold the probability that each data point belongs to each cluster.
% One row per data point, one column per cluster.
W = zeros(m, k);

% Loop until convergence.
for (iter = 1:10)
    
    fprintf('  EM Iteration %d\n', iter);

    %%===============================================
    %% STEP 3a: Expectation
    %
    % Calculate the probability for each data point for each distribution.
    
    % Matrix to hold the pdf value for each every data point for every cluster.
    % One row per data point, one column per cluster.
    pdf = zeros(m, k);
    
    % For each cluster...
    for (j = 1 : k)
        
        % Evaluate the Gaussian for all data points for cluster 'j'.
        pdf(:, j) = gaussianND(data, mu(j, :), sigma{j});
    end
    
    % Multiply each pdf value by the prior probability for cluster.
    %    pdf  [m  x  k]
    %    phi  [1  x  k]   
    %  pdf_w  [m  x  k]
    pdf_w = bsxfun(@times, pdf, phi);
    
    % Divide the weighted probabilities by the sum of weighted probabilities for each cluster.
    %   sum(pdf_w, 2) -- sum over the clusters.
    W = bsxfun(@rdivide, pdf_w, sum(pdf_w, 2));
    
    %%===============================================
    %% STEP 3b: Maximization
    %%
    %% Calculate the probability for each data point for each distribution.

    % Store the previous means.
    prevMu = mu;    
    
    % For each of the clusters...
    for (j = 1 : k)
    
        % Calculate the prior probability for cluster 'j'.
        phi(j) = mean(W(:, j), 1);
        
        % Calculate the new mean for cluster 'j' by taking the weighted
        % average of all data points.
        mu(j, :) = weightedAverage(W(:, j), data);

        % Calculate the covariance matrix for cluster 'j' by taking the 
        % weighted average of the covariance for each training example. 
        
        sigma_k = zeros(n, n);
        
        % Subtract the cluster mean from all data points.
        Xm = bsxfun(@minus, data, mu(j, :));
        
        % Calculate the contribution of each training example to the covariance matrix.
        for (i = 1 : m)
            sigma_k = sigma_k + (W(i, j) .* (Xm(i, :)' * Xm(i, :)));
        end
        
        % Divide by the sum of weights.
        sigma{j} = sigma_k ./ sum(W(:, j));
    end
    
    % Check for convergence.
    if (mu == prevMu)
        break
    end
            
% End of Expectation Maximization    
end






end