gen_csv('/Users/murali/Desktop/dmdata/1503604109480_IMU.txt', '/Users/murali/Desktop/dmdata/1503604109480_EMG.txt', '/Users/murali/Desktop/dmdata/spoon_ann.txt', 1503604109480, 29.82357802/1000);
gen_csv('/Users/murali/Desktop/dmdata/1503604387983_IMU.txt', '/Users/murali/Desktop/dmdata/1503604387983_EMG.txt', '/Users/murali/Desktop/dmdata/fork_ann.txt', 1503604387983, 29.83359921/1000);

function gen_csv(imu, emg, ann, start_timestamp, frame_rate)

spoon_imu=load(imu);
spoon_emg=load(emg);
spoon_ann=csvread(ann);

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
    ma= max(find(spoon_imu(:,1)>=result(i,1) & spoon_imu(:,1)<=result(i,2)));
    mi= min(find(spoon_imu(:,1)>=result(i,1) & spoon_imu(:,1)<=result(i,2)));
    res= spoon_imu(mi:ma,2:size_imu(2))';
    dlmwrite('eat_tmp.csv',res,'-append') ;
     
    ma= max(find(spoon_emg(:,1)>=result(i,1) & spoon_emg(:,1)<=result(i,2)));
    mi= min(find(spoon_emg(:,1)>=result(i,1) & spoon_emg(:,1)<=result(i,2)));
    res1= spoon_emg(mi:ma,2:size_emg(2))';
    dlmwrite('eat_tmp.csv',res1,'-append') ;
     
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

fin_res = csvread('eat_tmp.csv');
dlmwrite('eating.csv',fin_res,'-append') ;
fin_res = csvread('noneat_tmp.csv');
dlmwrite('noneating.csv',fin_res,'-append') ;
delete 'eat_tmp.csv';
delete 'noneat_tmp.csv';
end



%     Label = splitlines("Eating Action "+i+" Orient X\n" + "Eating Action "+i+" Orient Y\n" + "Eating Action "+i+" orient Z\n" +"Eating Action "+i+" Orient W\n");
%     Label = compose(Label);
%     fprintf(resFileID, '%s', Label);
%     
%     Label = splitlines("Eating Action "+i+" Acc X\n" + "Eating Action "+i+" Acc Y\n" + "Eating Action "+i+" Acc Z\n");
%     Label = compose(Label);
%     fprintf(resFileID, '%s', Label);
%     
%     Label = splitlines("Eating Action "+i+" Gyro X\n" + "Eating Action "+i+" Gyro Y\n" + "Eating Action "+i+" Gyro Z\n");
%     Label = compose(Label);
%     fprintf(resFileID, '%s', Label);
%     fclose(resFileID);
%   
    
    


