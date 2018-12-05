
fileID = fopen('dmdata/Data/summary.csv');
c= textscan(fileID,'%s%s%s%s%s%s', 1, 'Delimiter', ',');

%{
for tempp=0:7
    for i=0:1
        c= textscan(fileID,'%s%s%s%s%s%s', 1, 'Delimiter', ',');
    end
end
%}


for r=0:32  % team 0 -> 32
    disp(char(strcat('team',num2str(r))))
    
    %if r>=0
        %{
        if id{1}=='1503963533730' 
            continue
        end
        %}
        % for s
        c= textscan(fileID,'%s%s%s%s%s%s', 1, 'Delimiter', ',');
        id = c{2};
        %nb_frames = c{3}; 
        %duration = c{4};
        frame_rate = c{5};
        imu=char(strcat('dmdata/Data/IMU/',id,'_IMU.txt'));
        emg=char(strcat('dmdata/Data/EMG/',id,'_EMG.txt'));
        ann=char(strcat('dmdata/Data/Annotation/',id,'.txt'));
        start_timestamp = str2double(id);
        frame_rate = str2double(frame_rate)/1000; % from this calculate the time taken for 1 frame
        % print fileid
        disp(id{1});
        gen_csv(imu, emg, ann, start_timestamp, frame_rate, r);
        
        c= textscan(fileID,'%s%s%s%s%s%s', 1, 'Delimiter', ',');
        id = c{2};
        %nb_frames = c{3}; 
        %duration = c{4};
        frame_rate = c{5};
        imu=char(strcat('dmdata/Data/IMU/',id,'_IMU.txt'));
        emg=char(strcat('dmdata/Data/EMG/',id,'_EMG.txt'));
        ann=char(strcat('dmdata/Data/Annotation/',id,'.txt'));
        start_timestamp = str2double(id);
        frame_rate = str2double(frame_rate)/1000; % from this calculate the time taken for 1 frame
        % print fileid
        disp(id{1});
        gen_csv(imu, emg, ann, start_timestamp, frame_rate, r);
        
        %consolidate();
        %disp('this line should not be printed')
    %end
end

%{
function consolidate()
    res=[];
    f1=dlmread('eating.csv');
    temp= f1(1:18,:);
    res = horzcat(res, temp);
    dlmwrite('consolidated_eating.csv', res, '-append');
end
%}

fclose(fileID);

disp('Consolidating eating files...')
for i=0:32
        fname=char(strcat('eating',num2str(i),'.csv'));
        file=dlmread(fname);
        dlmwrite('consolidated_eating.csv', file, '-append');
end
disp('done');

disp('Consolidating non-eating files...');
for i=0:32
        fname=char(strcat('noneating',num2str(i),'.csv'));
        file=dlmread(fname);
        dlmwrite('consolidated_noneating.csv', file, '-append');
end
disp('done');

disp('Task1 completed...')

function gen_csv(imu, emg, ann, start_timestamp, frame_rate, team_num)

    spoon_imu=load(imu);
    spoon_emg=load(emg);
    spoon_ann=csvread(ann);
    % 'result' contains timestamp for the frame numbers
    result = zeros(40,2, 'uint64');
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
    % res = zeros(find dimension , 'datatypes')
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

    % commented the below code
    % inorder to make the number of rows same in both eating and non-eating.csv
    %{
    %%% Handling corner case : Entries after last eating frame
    ma= max(find(spoon_imu(:,1)>result(length(result),2)));
    disp(result);
    disp(result);
    mi= min(find(spoon_imu(:,1)>result(length(result),2)));
    res= spoon_imu(mi:ma,2:size_imu(2))';
    dlmwrite('noneat_tmp.csv',res,'-append');

    ma= max(find(spoon_emg(:,1)>result(length(result),2)));
    mi= min(find(spoon_emg(:,1)>result(length(result),2)));
    res= spoon_emg(mi:ma,2:size_emg(2))';
    dlmwrite('noneat_tmp.csv',res,'-append');
    %}

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















