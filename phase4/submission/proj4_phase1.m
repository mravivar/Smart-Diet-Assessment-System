[eating_train, eating_test] = splitdata('eating_proj4_input.csv');
[noneating_train, noneating_test] = splitdata('noneating_proj4_input.csv');
eating_train_y = ones(864, 1); % eating - 1
eating_test_y = ones(576, 1); % eating - 1
noneating_train_y = zeros(864, 1); % noneating - 0
noneating_test_y = zeros(576, 1); % noneating - 0
X = [eating_train; noneating_train];
X2 = [eating_test; noneating_test];
y = [eating_train_y ;noneating_train_y];
y2 = [eating_test_y; noneating_test_y];
%tc = fitctree(X, y);0.
%predicted = predict (tc, X2);

decision_tree(X, y, X2, y2);
svm(X, y, X2, y2);
neural_net(X, y, X2, y2);



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
    
end

