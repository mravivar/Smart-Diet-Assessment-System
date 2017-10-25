
fileID = fopen('summary.csv');
c= textscan(fileID,'%s%s%s%s%s%s', 1, 'Delimiter', ',');

for r=8:8  % team 0 -> 32
    disp(char(strcat('team',num2str(r))))
    
    
    %%%%%%%%%%%% Data Collection - Spoon  %%%%%%%%%%%%%%%%
    c= textscan(fileID,'%s%s%s%s%s%s', 1, 'Delimiter', ',');
    id = c{2};
    frame_rate = c{5};
    imu=char(strcat('dmdata/Data/IMU/',id,'_IMU.txt'));
    emg=char(strcat('dmdata/Data/EMG/',id,'_EMG.txt'));
    ann=char(strcat('dmdata/Data/Annotation/',id,'.txt'));
    start_timestamp = str2double(id);
    frame_rate = str2double(frame_rate)/1000; % from this calculate the time taken for 1 frame
    disp(id{1});
    gen_csv(imu, emg, ann, start_timestamp, frame_rate, r);
        
    %%%%%%%%%%%% Data Collection - Fork  %%%%%%%%%%%%%%%%
    c= textscan(fileID,'%s%s%s%s%s%s', 1, 'Delimiter', ',');
    id = c{2};
    frame_rate = c{5};
    imu=char(strcat('dmdata/Data/IMU/',id,'_IMU.txt'));
    emg=char(strcat('dmdata/Data/EMG/',id,'_EMG.txt'));
    ann=char(strcat('dmdata/Data/Annotation/',id,'.txt'));
    start_timestamp = str2double(id);
    frame_rate = str2double(frame_rate)/1000; % from this calculate the time taken for 1 frame
    disp(id{1});
    gen_csv(imu, emg, ann, start_timestamp, frame_rate, r);
end
fclose(fileID);

% to create consolidated_eating.csv
fileres=[];
for actionid=1:80
    res=[];
    disp(actionid);
    for i=8:8
        fname=char(strcat('eating',num2str(i),'.csv'));
        file=dlmread(fname);
        
        [r c] = size(file);
        temp = zeros(18,c);
        
        end_row=actionid*18;
        start_row= end_row-17;
        
        temp(1:18,1:c)= file(start_row:end_row,1:c);
        res = horzcat(res, temp);
    end
    fileres = vertcat(fileres, res);  
end
dlmwrite('csk_eating.csv', fileres, '-append');


% to create consolidated_noneating.csv
fileres=[];
for actionid=1:80
    res=[];
    disp(actionid);
    for i=8:8
        fname=char(strcat('noneating',num2str(i),'.csv'));
        file=dlmread(fname);
        
        [r c] = size(file);
        temp = zeros(18,c);
        
        end_row=actionid*18;
        start_row= end_row-17;

        temp(1:18,1:c)= file(start_row:end_row,1:c);
        res = horzcat(res, temp);
    end
    fileres = vertcat(fileres, res);  
end
dlmwrite('csk_noneating.csv', fileres, '-append');

AddHeaders('csk_eating.csv', 'eating.csv', 'Eating');
AddHeaders('csk_noneating.csv', 'noneating.csv', 'Non eating');


%%%%%%%%%%%% TASK 2%%%%%%%%%%%%%%%%%%%%%%%%
calculate_fft('eating.csv', 'eating_fft.csv');
calculate_fft('noneating.csv', 'noneating_fft.csv');

calculate_dwt('eating.csv', 'eating_dwt.csv');
calculate_dwt('noneating.csv', 'noneating_dwt.csv');

calculate_max('eating.csv', 'eating_max.csv');
calculate_max('noneating.csv', 'noneating_max.csv');

calculate_min('eating.csv', 'eating_min.csv');
calculate_min('noneating.csv', 'noneating_min.csv');

calculate_std('eating.csv', 'eating_std.csv');
calculate_std('noneating.csv', 'noneating_std.csv');

%%%%%%%%%%%%%%%% task 3%%%%%%%%%%%%%%%%%
putItAlltogether('noneating_min.csv', 'noneating_max.csv','noneating_std.csv',  'noneating_fft.csv', 'noneating_dwt.csv','noneating_features.csv');
putItAlltogether('eating_min.csv', 'eating_max.csv','eating_std.csv',  'eating_fft.csv', 'eating_dwt.csv', 'eating_features.csv');

calculatepca('noneating_features.csv');
calculatepca('eating_features.csv');

function gen_csv(imu, emg, ann, start_timestamp, frame_rate, team_num)

    spoon_imu=load(imu);
    spoon_emg=load(emg);
    spoon_ann=csvread(ann);
    result = zeros(40,2, 'uint64');     % 'result' contains timestamp for the frame numbers
    begin_frame = 1;

    for c=1:length(spoon_ann)
        start_fr = spoon_ann(c, 1); 
        end_fr = spoon_ann(c, 2);
        result(c, 1) = start_timestamp + ((start_fr -begin_frame)/frame_rate);
        result(c, 2) = start_timestamp + ((end_fr -begin_frame)/frame_rate);   
    end
    
    size_imu = size(spoon_imu);
    size_emg = size(spoon_emg);

    for i=1:length(result)
        if (result(i,1)~=0)&&(result(i,1)~=0)
            ma= max(find(spoon_imu(:,1)>=result(i,1) & spoon_imu(:,1)<=result(i,2)));
            mi= min(find(spoon_imu(:,1)>=result(i,1) & spoon_imu(:,1)<=result(i,2)));
            res= spoon_imu(mi:ma,2:size_imu(2))';
            dlmwrite('eat_tmp.csv',res,'-append') ;

            ma= max(find(spoon_emg(:,1)>=result(i,1) & spoon_emg(:,1)<=result(i,2)));
            mi= min(find(spoon_emg(:,1)>=result(i,1) & spoon_emg(:,1)<=result(i,2)));
            res1= spoon_emg(mi:ma,2:size_emg(2))';
            dlmwrite('eat_tmp.csv',res1,'-append');
        end
    end

    %%% Handling corner case : Entries before first eating frame
    ma= max(find(spoon_imu(:,1)<result(1,1)));
    mi= min(find(spoon_imu(:,1)<result(1,1)));
    res= spoon_imu(mi:ma,2:size_imu(2))';
    dlmwrite('noneat_tmp.csv',res,'-append');

    ma= max(find(spoon_emg(:,1)<result(i,2)));
    mi= min(find(spoon_emg(:,1)<result(i,2)));
    res1= spoon_emg(mi:ma,2:size_emg(2))';
    dlmwrite('noneat_tmp.csv',res1,'-append') ;

    for i=1:length(result)-1

        % now you are having 39 actions i.e 39x18 rows
        % also include two contditons: (1) less than first start time, (2) greater than last end time
        % if you include one, you will have 40 actions. include both, you
        % will have 41 actions
        ma= max(find(spoon_imu(:,1)>=result(i,2) & spoon_imu(:,1)<=result(i+1,1)));
        mi= min(find(spoon_imu(:,1)>=result(i,2) & spoon_imu(:,1)<=result(i+1,1)));
        res= spoon_imu(mi:ma,2:size_imu(2))';
        dlmwrite('noneat_tmp.csv',res,'-append') ;

        ma= max(find(spoon_emg(:,1)>=result(i,2) & spoon_emg(:,1)<=result(i+1,1)));
        mi= min(find(spoon_emg(:,1)>=result(i,2) & spoon_emg(:,1)<=result(i+1,1)));
        % res = zeros(find dimension , 'datatypes')
        res1= spoon_emg(mi:ma,2:size_emg(2))';
        dlmwrite('noneat_tmp.csv',res1,'-append') ;
    end

    fin_res = csvread('eat_tmp.csv');
    [m n] = size(fin_res);
    fin2_res = zeros(720,n);
    if m>720
        m=720;
    end
    fin2_res(1:m,1:n) = fin_res(1:m,1:n);
    f1name = char(strcat('eating',num2str(team_num),'.csv'));
    dlmwrite(f1name,fin2_res,'-append') ;

    fin_res = csvread('noneat_tmp.csv');
    [m n] = size(fin_res);
    fin2_res = zeros(720,n);
     if m>720
        m=720;
    end
    fin2_res(1:m,1:n) = fin_res(1:m,1:n);
    f2name = char(strcat('noneating',num2str(team_num),'.csv'));
    dlmwrite(f2name,fin2_res,'-append') ;

    delete 'eat_tmp.csv';
    delete 'noneat_tmp.csv';
    
    
end


function AddHeaders(ifilename, ofilename, append_data)

f = csvread(ifilename);
i = 1;
toAdd = [append_data + " " +"action "+i+" acc X"
         append_data + " " +"action "+i+" acc Y"
         append_data + " " +"action "+i+" acc Z"
         append_data + " " +"action "+i+" acc W"
         append_data + " " +"action "+i+" gy x"
         append_data + " " +"action "+i+" gy y"
         append_data + " " +"action "+i+" gy z"
         append_data + " " +"action "+i+" ori x"
         append_data + " " +"action "+i+" ori y"
         append_data + " " +"action "+i+" ori z"
         append_data + " " +"action "+i+" emg 1"
         append_data + " " +"action "+i+" emg 2"
         append_data + " " +"action "+i+" emg 3"
         append_data + " " +"action "+i+" emg 4"
         append_data + " " +"action "+i+" emg 5"
         append_data + " " +"action "+i+" emg 6"
         append_data + " " +"action "+i+" emg 7"
         append_data + " " +"action "+i+" emg 8"
        ];

for i=2:size(f,1)/18
    toAdd = [toAdd ; append_data + " " +"action "+i+" acc X"
         append_data + " " +"action "+i+" acc Y"
         append_data + " " +"action "+i+" acc Z"
         append_data + " " +"action "+i+" acc W"
         append_data + " " +"action "+i+" gy x"
         append_data + " " +"action "+i+" gy y"
         append_data + " " +"action "+i+" gy z"
         append_data + " " +"action "+i+" ori x"
         append_data + " " +"action "+i+" ori y"
         append_data + " " +"action "+i+" ori z"
         append_data + " " +"action "+i+" emg 1"
         append_data + " " +"action "+i+" emg 2"
         append_data + " " +"action "+i+" emg 3"
         append_data + " " +"action "+i+" emg 4"
         append_data + " " +"action "+i+" emg 5"
         append_data + " " +"action "+i+" emg 6"
         append_data + " " +"action "+i+" emg 7"
         append_data + " " +"action "+i+" emg 8"
        ];
end
final = [toAdd f];
cell2csv(ofilename,cellstr(final));
end

function calculate_fft(ifilename,ofilename)
    action=csvread(ifilename);
    dlmwrite(ofilename,fft(action),'w') ;
end

function calculate_dwt(ifilename,ofilename)
    action=csvread(ifilename);
    siz = size(action);
    out_approx = zeros(siz(1),siz(2));
    exact_approx =zeros(siz(1),siz(2));
    for i=1:siz(2)
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
     dlmwrite(ofilename,m,'w') ;
end

function calculate_min(ifilename,ofilename)
     action=csvread(ifilename);
     size_eating = size(action);
     m = zeros(size_eating(1),1);
     for c= 1: size_eating(1)
         m1 = action(c,1:size_eating(2));
         m(c,1) = min(m1(m1~=0))
     end
     dlmwrite(ofilename,m,'w') ;
end

 function calculate_std(ifilename,ofilename)
    action=csvread(ifilename);
    size_eating = size(action);
    m = zeros(size_eating(1),1);
    for c= 1: size_eating(1)
        m1 = action(c,1:size_eating(2));
        m(c,1) = std(m1(m1~=0));
    end
    dlmwrite(ofilename,m,'w') ;
 end
 
 function putItAlltogether(f1, f2, f3, f4, f5, outputFileName)
    csv1 = csvread(f1);
    csv2 = csvread(f2);
    csv3 = csvread(f3);
    csv4 = csvread(f4);
    csv5 = csvread(f5);
    allCsv = [csv1 csv2 csv3 csv4 csv5]; 
    csvwrite(outputFileName, allCsv);
 end

 
function calculatepca(ifilename)
    action = csvread(ifilename);
    normA = action - min(action(:));
    normA = normA ./ max(normA(:));
    covariance = cov(normA);
    [coeff, score] = pca(covariance,'Algorithm','eig');
    mul = action * coeff;
    plot(mul(:,1));
end
