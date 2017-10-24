
function calculatepca(ifilename)
    action = csvread(ifilename);
    normA = action - min(action(:));
    normA = normA ./ max(normA(:));
    covariance = cov(normA);
    [coeff, score] = pca(covariance,'Algorithm','eig');
    mul = action * coeff;
    plot(mul(:,1));
end
