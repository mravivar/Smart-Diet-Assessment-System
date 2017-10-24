ifilename = "eating.csv";
f = csvread(ifilename);
i = 1
toAdd = ["action "+i+" acc X"
         "action "+i+" acc Y"
         "action "+i+" acc Z"
         "action "+i+" acc W"
         "action "+i+" gy x"
         "action "+i+" gy y"
         "action "+i+" gy z"
         "action "+i+" ori x"
         "action "+i+" ori y"
         "action "+i+" ori z"
         "action "+i+" emg 1"
         "action "+i+" emg 2"
         "action "+i+" emg 3"
         "action "+i+" emg 4"
         "action "+i+" emg 5"
         "action "+i+" emg 6"
         "action "+i+" emg 7"
         "action "+i+" emg 8"
        ];

for i=2:size(f,1)/18
    toAdd = [toAdd ; "action "+i+" acc X"
         "action "+i+" acc Y"
         "action "+i+" acc Z"
         "action "+i+" acc W"
         "action "+i+" gy x"
         "action "+i+" gy y"
         "action "+i+" gy z"
         "action "+i+" ori x"
         "action "+i+" ori y"
         "action "+i+" ori z"
         "action "+i+" emg 1"
         "action "+i+" emg 2"
         "action "+i+" emg 3"
         "action "+i+" emg 4"
         "action "+i+" emg 5"
         "action "+i+" emg 6"
         "action "+i+" emg 7"
         "action "+i+" emg 8"
        ];

end

final = [toAdd f];
cell2csv('output3.csv',cellstr(final));

