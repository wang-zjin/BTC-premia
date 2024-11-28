% Set up root and folder paths
rootFolder = pwd;  
qTailFitFolder = fullfile(rootFolder, 'Q_Tail_Fit');
dataFolder = fullfile(rootFolder, 'data');

% List of all scripts in Q_Tail_Fit folder
scripts = {
    'TailFit_GEV_2_8_0_3_Q_from_IV_5day.m',
    'TailFit_GEV_2_8_1_3_Q_from_IV_9day.m',
    'TailFit_GEV_2_8_2_3_Q_from_IV_14day.m',
    'TailFit_GEV_2_8_3_3_Q_from_IV_27day.m',
    'TailFit_GEV_2_9_0_1_QfromIV_5day_merge.m',
    'TailFit_GEV_2_9_1_1_QfromIV_9day_merge.m',
    'TailFit_GEV_2_9_2_1_QfromIV_14day_merge.m',
    'TailFit_GEV_2_9_3_1_QfromIV_27day_merge.m'
};

% Specify the range of scripts to run
startIdx = 1;  
endIdx = 8;    

% Ensure indices are valid
if startIdx < 1 || endIdx > numel(scripts)
    error('Invalid script range!');
end

% Loop scripts and execute
for i = startIdx:endIdx
    scriptName = scripts{i};
    scriptPath = fullfile(qTailFitFolder, scriptName);
    
    % Check if the script exists
    if exist(scriptPath, 'file') == 2
        fprintf('Running script: %s\n', scriptName);
        run(scriptPath);  
    else
        fprintf('Script not found: %s\n', scriptName);
    end
end
