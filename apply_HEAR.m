% HEAR application demonstration script
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

    clearvars
    close all
    clc

    % parameters
    file_name = 'demo_simreach';
    
    show_plots = true;

    data_root_dir = './';
end

%% load the dataset
EEG = pop_loadset([file_name '.set'], data_root_dir);
[ALLEEG, EEG, CURRENTSET] = eeg_store({}, EEG);
ALL_DS_IDX = CURRENTSET;

eeg_chan_idxs = eeg_chantype(EEG, 'EEG');

EEG = pop_select(EEG, 'channel', eeg_chan_idxs);
%% load the artifact detection model

load([data_root_dir 'mdl_HEAR.mat'], 'hear_mdl');

%% 3. apply the artifact detection models

% backup the uncorrected data
data2 = EEG.data;

% detect and remove transient, high variance artifacts
[p_art, p_confidence, EEG.data] = hear_mdl.apply(EEG.data(:,:));

% adjust to epoched datasets (optionally)
EEG.data = reshape(EEG.data, EEG.nbchan, EEG.pnts, EEG.trials);
p_art = reshape(p_art, 1, EEG.pnts, EEG.trials);
p_confidence = reshape(p_confidence, 1, EEG.pnts, EEG.trials);

EEG.chanlocs(end+1).labels = 'p art';
EEG.chanlocs(end).type = 'ART';
EEG.chanlocs(end).urchan = [];
EEG.chanlocs(end).ref = [];

EEG.chanlocs(end+1).labels = 'confidence';
EEG.chanlocs(end).type = 'ART';
EEG.chanlocs(end).urchan = [];
EEG.chanlocs(end).ref = [];

EEG.data = cat(1, EEG.data, p_art*100, p_confidence*100);
EEG.nbchan = EEG.nbchan + 2;

data2 = cat(1, data2, zeros(2, EEG.pnts, EEG.trials));

eeg_chan_idxs = eeg_chantype(EEG, 'EEG');

%% plotting

if show_plots

    if EEG.trials > 1
        winlen = 2; % trials
    else
        winlen = 15; %s
    end

    pop_eegplot( EEG, 1, 1, 1, [], 'ploteventdur', 'off', 'winlength', winlen, 'spacing', 105, 'data2', data2);
    uiwait(gcf);
end

%% save the result
pop_saveset(EEG, 'filename', [file_name '_corrected.set'], 'filepath', data_root_dir);