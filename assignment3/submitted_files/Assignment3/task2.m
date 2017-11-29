
% calculate_dwt('eating.csv', 'eating_dwt.csv');
% calculate_dwt('noneating.csv', 'noneating_dwt.csv');
% 
% calculate_fft('eating.csv', 'eating_fft_onept.csv');
% calculate_fft('noneating.csv', 'noneating_fft_onept.csv');
% 
% calculate_max('eating.csv', 'eating_max.csv');
% calculate_max('noneating.csv', 'noneating_max.csv');
% 
% calculate_min('eating.csv', 'eating_min.csv');
% calculate_min('noneating.csv', 'noneating_min.csv');

% calculate_std('eating.csv', 'eating_std.csv');
% calculate_std('noneating.csv', 'noneating_std.csv');

% putItAlltogether('noneating_min.csv', 'noneating_max.csv','noneating_std.csv',  'noneating_fft_onept.csv', 'noneating_dwt.csv', 'noneating_features_onept.csv');
% putItAlltogether('eating_min.csv', 'eating_max.csv','eating_std.csv',  'eating_fft_onept.csv', 'eating_dwt.csv', 'eating_features_onept.csv');
% calculate_subplot('eating_features_onept.csv', 'noneating_features_onept.csv');


function calculate_fft(ifilename,ofilename)
    action=csvread(ifilename);
    dlmwrite(ofilename,fft(action,1,2),',') ;
end


function calculate_dwt(ifilename,ofilename)
    action=csvread(ifilename);
    siz = size(action);
    out_approx = zeros(siz(1),siz(2));
    exact_approx =zeros(siz(1),siz(2));
    for i=1:siz(1)
        [out, out1] = dwt(action(i,:), 'db1');
        [e,f] = size(out);
        [g,h] = size(out1);
        out_approx(i,1:f) = out;
        exact_approx(i,1:h) = out1;
    end
    fin_dwt = [out_approx, exact_approx];
    dlmwrite(ofilename, fin_dwt ,',') ;
end

 function calculate_max(ifilename,ofilename)
     action=csvread(ifilename);
     size_eating = size(action);
     m = zeros(size_eating(1),1);
     for c= 1: size_eating(1)
         m(c,1) = max(action(c,1:size_eating(2)));
     end
     dlmwrite(ofilename,m,',') ;
 end
 function calculate_min(ifilename,ofilename)
     action=csvread(ifilename);
     size_eating = size(action);
     m = zeros(size_eating(1),1);
     for c= 1: size_eating(1)
         m1 = action(c,1:size_eating(2));
         t = m1(m1~=0);
         if size(t,2)~=0
         m(c,1) = min(t);
         else
             m(c,1) = 0;
         end
     end
     dlmwrite(ofilename,m,',') ;
 end

 function calculate_std(ifilename,ofilename)
    action=csvread(ifilename);
    size_eating = size(action);
    m = zeros(size_eating(1),1);
    for c= 1: size_eating(1)
        m1 = action(c,1:size_eating(2));
         t = m1(m1~=0);
         if size(t,2)~=0
         m(c,1) = min(t);
         else
             m(c,1) = 0;
         end
    end
    dlmwrite(ofilename,m,',') ;
end
%}



function calculate_subplot(ifilename1, ifilename2)
feature1 = csvread(ifilename1);
feature2 = csvread(ifilename2);

feature = [feature1(:,1), feature2(:,1)];
subplot(2,3,1);
plot(feature);
title('FFT Feature');
linspace(1,100);
xlabel('Accelerometer, Gyroscope, Orientation, EMG');
ylabel('Data Points');


subplot(2,3,2);
feature = [feature1(:,2), feature2(:,2)];
plot(feature);
title('DWT Feature');
linspace(1,100);
xlabel('Accelerometer, Gyroscope, Orientation, EMG');
ylabel('Data Points');

subplot(2,3,3);
feature = [feature1(:,3), feature2(:,3)];
plot(feature);
title('Min Feature');
linspace(1,100);
xlabel('Accelerometer, Gyroscope, Orientation, EMG');
ylabel('Data Points');

subplot(2,3,4);
feature = [feature1(:,4), feature2(:,4)];
plot(feature);
title('Max Feature');
linspace(1,100);
xlabel('Accelerometer, Gyroscope, Orientation, EMG');
ylabel('Data Points');

subplot(2,3,5);
feature = [feature1(:,5), feature2(:,5)];
plot(feature);
title('Standard Deviation Feature');
linspace(1,100);
xlabel('Accelerometer, Gyroscope, Orientation, EMG');
ylabel('Data Points');

end



%%%%%%%%%%%%%%%% task 3%%%%%%%%%%%%%%%%%


function putItAlltogether(f1, f2, f3, f4, f5, outputFileName)
    csv1 = csvread(f1);
    csv2 = csvread(f2);
    csv3 = csvread(f3);
    csv4 = csvread(f4);
    csv5 = csvread(f5);

    allCsv = [csv1 csv2 csv3 csv4 csv5]; 
    csvwrite(outputFileName, allCsv);
end
% {
% calculate_pca('noneating_features.csv', 'noneating_pca.csv');
% function calculate_pca(f1, outputFilename)
%     action = csvread(f1);
%     
%     [X,Y, latent] = pca(action);
%     csvwrite(outputFilename, X);
%     csvwrite('tmp_pca_vector.csv', Y);
%     csvwrite('tmp_pca_latent.csv', latent);
% end
% }

