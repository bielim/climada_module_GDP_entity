function [assets, centroids] = climada_assets_encode_centroids(assets, centroids, no_wbar)

% climada assets encode with centroids instead of hazard
% NAME:
%   climada_assets_encode_centroids
% PURPOSE:
%   encode an entity (an already read assets file)
%   eoncoding means: map read data points to calculation centroids of
%   hazard event set
%   normally called from: climada_entity_read
% CALLING SEQUENCE:
%   assets = climada_assets_encode_centroids(assets,centroids)
% EXAMPLE:
%   assets = climada_assets_encode_centroids(assets,centroids)
% INPUTS:
%   assets   : a read assets structure, see climada_entity_read
% OPTIONAL INPUT PARAMETERS:
%   centroids: either a centroid mat-file (struct) or a centroid set file (.mat with a struct)
%              > promted for if not given
%   no_wbar  : set to 1 to suppress waitbar
% OUTPUTS:
%   the encoded assets, means locations mapped to calculation centroids
%   new field assets.centroid_index added
% MODIFICATION HISTORY:
% David N. Bresch, david.bresch@gmail.com, 20091227
% David N. Bresch, david.bresch@gmail.com, 20100107 revised, changed from entity.assets to assets
% Lea Mueller, muellele@gmail.com, 20120730, take centroids from centroids instead of hazard
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('assets'    ,'var'), return        ;end
if ~exist('centroids' ,'var'), centroids = [];end
if ~exist('no_wbar'   ,'var'), no_wbar   = 0 ;end

% PARAMETERS
%
% whether we print all encoded centroids (=1) or not (=0), rather to TEST
verbose=0; % default =0

% prompt for centroids if not given
if isempty(centroids) % local GUI
    centroids         = [climada_global.system_dir filesep '*.mat'];
    centroids_default = [climada_global.system_dir filesep 'choose centroids to encode to.mat'];
    [filename, pathname] = uigetfile(centroids, 'Select centroids to encode to:',centroids_default);
    if isequal(filename,0) || isequal(pathname,0)
        return; % cancel
    else
        centroids = fullfile(pathname,filename);
    end
end
% load the centroids, if a filename has been passed
if ~isstruct(centroids)
    centroids_file = centroids;
    centroids      = [];
    load(centroids_file);
end


% start encoding
n_centroids = length(assets.Value);

if ~no_wbar
    h = waitbar(0,sprintf('Encoding %i records...',n_centroids),'name','Encode assets to centroids');
end

for centroid_i = 1:n_centroids
    if ~no_wbar, waitbar(centroid_i/n_centroids,h), end
    dist_m      = climada_geo_distance(assets.Longitude(centroid_i),assets.Latitude(centroid_i),...
                                       centroids.Longitude, centroids.Latitude);    
    [min_dist,min_dist_index]         = min(dist_m);
    assets.centroid_index(centroid_i) = min_dist_index;
    if verbose,fprintf('%f/%f --> %f/%f\n',assets.Longitude(centroid_i)       , assets.Latitude(centroid_i) ,...
                                           centroids.Longitude(min_dist_index), centroids.Latitude(min_dist_index));end 
end % centroid_i
if ~no_wbar, close(h), end % close waitbar

if isfield(centroids,'comment')
    assets.hazard.comment = centroids.comment;
end

return


