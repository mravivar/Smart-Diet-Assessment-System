% task3PCA('eating_features_onept.csv');
% task3PCA('noneating_features_onept.csv');
function task3PCA(ifilename)
    action = csvread(ifilename);
    [coeff, score] = pca(action,'NumComponents',4);
    mul = action * coeff;
%     plot(coeff);
    plot(mul);
    legend('show');
end
