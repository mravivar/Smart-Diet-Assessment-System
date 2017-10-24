%addHeadersToFile('C:\Users\sdandapa\Desktop\eating_subset.csv')
% function addHeadersToFile(ifilename)
    ifilename = "eating.csv";
    
    f = csvread(ifilename);
    for i=1:size(f)
        toAdd = ["action 1 acc X"
             "action 1 acc Y"
             "action 1 acc Z"
             "action 1 acc W"
             "action 1 gy x"
             "action 1 gy y"
             "action 1 gy z"
             "action 1 ori x"
             "action 1 ori y"
             "action 1 ori z"
             "action 1 emg 1"
             "action 1 emg 2"
             "action 1 emg 3"
             "action 1 emg 4"
             "action 1 emg 5"
             "action 1 emg 6"
             "action 1 emg 7"
             "action 1 emg 8"
            ];
        temp = f(i:i+17,:);
        final = [toAdd temp];
        
        % Find a way to append to csv file or excel file. Just need to
        % write final in every loop!
        %xlswrite("final_eating.xlsx", final);  
        %xlmwrite("final_eating.xlsx", final, 'append');   
    
    end
     
%end