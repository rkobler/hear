% Utiliy function to estimate relative distances of the k nearest neighbors
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

function [D] = utl_chaninterpmatrix(file_locs,k)
%   Utiliy function to estimate relative distances of the k nearest neighbors.
%
%   inputs :
%       - file_locs: location file of the eeg channels (csv format with a
%       tabulator (\t) as file separator; no table header)
%       format:
%       channel index \t x \t y \t z \t channel label
%
%       - k: number of nearest "neighbours channels"
%
%   output :
%       - D matrix: matrix of relative distances of the k nearest neighbor
%         channels.

    % read the data table from the file
    if ischar(file_locs)
        load(file_locs, 'chanlocs')
    else % or from the specified channel locations
        chanlocs = file_locs;
    end

    % extract 3D position
    pos = cat(2, [chanlocs.X]', [chanlocs.Y]', [chanlocs.Z]');

    % get the "good chans" positions
    numchans = size(pos,1);

    allchans = 1:numchans;

    % initialize the correction matrix, mimicking the case of no bad channels
    D = zeros(numchans);

    % compute the Euclidean distances between all electrode locations
    for cidx = 1:numchans
        D(cidx,:) = sqrt(sum(bsxfun(@minus, pos, pos(cidx,:)).^2,2)); 

        D(cidx,cidx) = Inf; % distance of the channel to itself is infinite

        % sort the distances in ascending order and keep only the k nearest
        % neighbors
        [~,dist_idxs] = sort(D(cidx,:),'ascend');          
        neighbor_chan_idxs = dist_idxs(1:k);

        % keep only the k closest channels and set the other distances to Inf
        D(cidx, setdiff(allchans,neighbor_chan_idxs)) = Inf;                      

        % convert absolute distances to relative distances
        invdist = 1./D(cidx,:);
        D(cidx,:) = invdist / sum(invdist);

    end

end