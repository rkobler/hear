% HEAR traning demonstration script
% Copyright (C) 2019 Reinmar Kobler, Graz University of Technology, Austria
% <reinmar.kobler@tugraz.at>
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published 
% by the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
% 

st = dbstack;
if length(st) < 2

    clear all
    close all
    clc

    % parameters
    file_name = 'demo_simrest';    
    
    is_causal = true;

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

D = utl_chaninterpmatrix(EEG.chanlocs, 4);

%% fit HEAR to the calibration data

hear_mdl = HEAR(EEG.srate, is_causal, [], [], D);

hear_mdl.train(EEG.data(:,:));

save([data_root_dir 'mdl_HEAR.mat'], 'hear_mdl');

disp('HEAR successfully trained.');