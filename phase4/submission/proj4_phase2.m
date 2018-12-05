%putItAlltogether('eating0_proj4_input.csv', 'eating1_proj4_input.csv','eating2_proj4_input.csv',  'eating3_proj4_input.csv', 'eating4_proj4_input.csv','eating5_proj4_input.csv', 'eating6_proj4_input.csv','eating7_proj4_input.csv','eating8_proj4_input.csv','eating9_proj4_input.csv','eating_train_data_phase2.csv');
%putItAlltogether('noneating0_proj4_input.csv', 'noneating1_proj4_input.csv','noneating2_proj4_input.csv',  'noneating3_proj4_input.csv', 'noneating4_proj4_input.csv','noneating5_proj4_input.csv', 'noneating6_proj4_input.csv','noneating7_proj4_input.csv','noneating8_proj4_input.csv','noneating9_proj4_input.csv','noneating_train_data_phase2.csv');

eating_train = csvread("eating_train_data_phase2.csv");
noneating_train = csvread("noneating_train_data_phase2.csv");
%read from file

%=============================
for id=10:32
    eating_test_file=char(strcat('eating',num2str(id),'_proj4_input.csv'));
    noneating_test_file=char(strcat('noneating',num2str(id),'_proj4_input.csv'));
    disp("-----------")
    disp(eating_test_file);
    disp(noneating_test_file);
    disp("-----------")
    %calculate_dwt(eatingcsv, eatingdwt);
eating_test = csvread(eating_test_file);
noneating_test = csvread(noneating_test_file);

eating_train_y = ones(14400, 1); % eating - 1
eating_test_y = ones(1440, 1); % eating - 1
noneating_train_y = zeros(14400, 1); % noneating - 0
noneating_test_y = zeros(1440, 1); % noneating - 0

X = [eating_train; noneating_train];
X2 = [eating_test; noneating_test];
y = [eating_train_y ;noneating_train_y];
y2 = [eating_test_y; noneating_test_y];
%tc = fitctree(X, y);
%predicted = predict (tc, X2);

%decision_tree(X, y, X2, y2);
svm(X, y, X2, y2);
%neural_net(X, y, X2, y2);
end
%=============


function decision_tree(X, y, X2, y2)
    tc = fitctree(X, y);
    % known, predicted
    predicted = predict (tc, X2);
    confusionMat = confusionmat(y2,predicted);
    precision = confusionMat(1,1) / (confusionMat(1,1) + confusionMat(2,1));
    recall = confusionMat(1,1) / (confusionMat(1,1) + confusionMat(1,2));
    f1score = 2 * (precision * recall)/(precision + recall);
    disp("***********DECISION TREE*************");
    disp("precision:");
    disp(precision);
    disp("Recall:");
    disp(recall);
    disp("F1score:");
    disp(f1score);
    [tpr,fpr,th] = roc(y2',predicted');

    fprintf("ROC TRUE POSITIVE RATE: %s \n", num2str(tpr(2)*100));
    fprintf("ROC FALSE POSITIVE RATE: %s \n", num2str(fpr(2)*100));
    
    res1 = zeros(1,5);
    restpr = tpr(2)*100;
    resfpr = fpr(2)*100;
    res1 = [precision recall f1score restpr resfpr];
    disp("res1")
    disp(res1);
    dlmwrite('phase2_output1.csv',res1,'-append');
    
end

function svm(X, y, X2, y2)
    tc = fitcsvm(X, y);
    % known, predicted
    predicted = predict (tc, X2);
   
    confusionMat = confusionmat(y2,predicted);
    precision = confusionMat(1,1) / (confusionMat(1,1) + confusionMat(2,1));
    recall = confusionMat(1,1) / (confusionMat(1,1) + confusionMat(1,2));
    f1score = 2 * (precision * recall)/(precision + recall);
    disp("***********SVM*************");
    disp("precision:");
    disp(precision);
    disp("Recall:");
    disp(recall);
    disp("F1score:");
    disp(f1score);
    [tpr,fpr,th] = roc(y2',predicted');
    fprintf("ROC TRUE POSITIVE RATE: %s \n", num2str(tpr(2)*100));
    fprintf("ROC FALSE POSITIVE RATE: %s \n", num2str(fpr(2)*100));
    
    
    res2 = zeros(1,5);
    restpr = tpr(2)*100;
    resfpr = fpr(2)*100;
    res2 = [precision recall f1score restpr resfpr];
    dlmwrite('phase2_output2.csv',res2,'-append');
    
end

function [dataTraining, dataTesting] = splitdata(filename)
    dataA = csvread(filename);  % some test data
    p = .6;      % proportion of rows to select for training
    N = size(dataA,1);  % total number of rows 
    tf = false(N,1) ;   % create logical index vector
    tf(1:round(p*N)) = true;     
    tf = tf(randperm(N));   % randomise order
    dataTraining = dataA(tf,:); 
    dataTesting = dataA(~tf,:);
end

function neural_net(X, y, X2, y2)

net = feedforwardnet(1);
%net = configure(net,X',y');
net = train(net,X',y');
predicted = net(X2');
predicted = round(predicted);
predicted = predicted';
confusionMat = confusionmat(y2,predicted);
precision = confusionMat(1,1) / (confusionMat(1,1) + confusionMat(2,1));
recall = confusionMat(1,1) / (confusionMat(1,1) + confusionMat(1,2));
f1score = 2 * (precision * recall)/(precision + recall);
disp("***********NEURAL NETWORK*************");
disp("precision:");
disp(precision);
disp("Recall:");
disp(recall);
disp("F1score:");
disp(f1score);
[tpr,fpr,th] = roc(y2',predicted');
fprintf("ROC TRUE POSITIVE RATE: %s \n", num2str(tpr(2)*100));
fprintf("ROC FALSE POSITIVE RATE: %s \n", num2str(fpr(2)*100));
disp(f1score);

res3 = zeros(1,5);
    restpr = tpr(2)*100;
    resfpr = fpr(2)*100;
    res3 = [precision recall f1score restpr resfpr];
    dlmwrite('phase2_output3.csv',res3,'-append');
    
end



function putItAlltogether(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, outputFileName)
csv0 = csvread(f0);
csv1 = csvread(f1);
csv2 = csvread(f2);
csv3 = csvread(f3);
csv4 = csvread(f4);
csv5 = csvread(f5);
csv6 = csvread(f6);
csv7 = csvread(f7);
csv8 = csvread(f8);
csv9 = csvread(f9);
allCsv = [csv0; csv1; csv2; csv3; csv4; csv5; csv6; csv7; csv8; csv9]; 
csvwrite(outputFileName, allCsv);
end





