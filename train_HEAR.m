%
% HEAR traning demonstration script
%
% by Reinmar Kobler
% University of Technology Graz
% Institute of Neural Engineering
% Laboratory of Brain-Computer Interfaces
% 8010 Graz, Austria

st = dbstack;
if length(st) < 2

    clear all
    close all
    clc

    addpath(genpath('../library'));

    % parameters
    file_name = 'demo_simrest';    
    
    is_causal = false;

    data_root_dir = './';
end

%% load the dataset
EEG = pop_loadset([file_name '.set'], data_root_dir);
[ALLEEG, EEG, CURRENTSET] = eeg_store({}, EEG);
ALL_DS_IDX = CURRENTSET;

EEG = pop_select(EEG, 'trial', 1:8);

EEG.etc = struct;

eeg_chan_idxs = eeg_chantype(EEG, 'EEG');

EEG = pop_select(EEG, 'channel', eeg_chan_idxs);

%% load the channels interpolation distance matrix

EEG = pop_select(EEG, 'channel', eeg_chan_idxs);

D = utl_chaninterpmatrix(EEG.chanlocs, 4);

%% fit HEAR to the calibration data

hear_mdl = HEAR(EEG.srate, is_causal, [], [], D);

hear_mdl.train(EEG.data(:,:));

save([data_root_dir 'mdl_HEAR.mat'], 'hear_mdl');

disp('HEAR successfully trained.');