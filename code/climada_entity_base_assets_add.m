function entity_base = climada_entity_base_assets_add(values_distributed, centroids, country_name_str, matrix_hollowout,  X, Y, hollow_name)

% climada add assets to entity base structure, from values_distributed 
% NAME:
%   climada_entity_base_assets_add
% PURPOSE:
%   add assets to entity structure from values_distributed and find the
%   closest calculation centroids (encode assets to centroids)
%   normally called from: climada_create_centroids_entity_base
% CALLING SEQUENCE:
%   entity_base = climada_entity_base_assets_add(values_distributed, centroids, country_name_str, matrix_hollowout,  X, Y)
% EXAMPLE:
%   entity_base = climada_entity_base_assets_add(values_distributed, centroids, country_name_str, matrix_hollowout,  X, Y)
% INPUTS:
%   values_distributed    : structure mat-file with the following fields
%         .values         : distributed values per pixel
%         .lon_range      : range of Longitude
%         .lat_range      : range of Latitude
%         .resolution_x   : resolution in x-direction
%         .resolution_y   : resolution in y-direction
%   centroids             : a centroid mat-file (struct)
%   country_name_str      : country name as string format
%   matrix_hollowout      : coastal area, bufferzone and hollowed out matrix, 
%                           masking 1 for on land, and zero for sea, 2 (max value) for buffer
%   X                     : helper matrix containing Longitude information for plotting matrix
%   Y                     : helper matrix containing Latitude information for plotting matrix
% OUTPUTS:
%   entity_base           : entity with assets from values_distributed. 
%                           Values sum up to 100, or if only coastal areas 
%                           are selected, to less than 100.
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20140205
% david.bresch@gmail.com, 20140216, _2012 replaced by _today
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

entity = [];
% poor man's version to check arguments
if ~exist('values_distributed', 'var'), return        ;end
if ~exist('centroids'         , 'var'), return        ;end
if ~exist('hollow_name'       , 'var'), hollow_name = [];end

% PARAMETERS

% set modul data directory
modul_data_dir = [fileparts(fileparts(mfilename('fullpath'))) filesep 'data'];


%% try to load wildcard entity (wildcard entity) without assets as mat-file
try 
    load([modul_data_dir filesep 'entity_global_without_assets.mat'])
    fprintf('\t a) Load wildcard entity without assets (damagefunctions, measures, discount)\n')
catch err
    % read entity without assets
    fprintf('\t a) Read from excel, entity without assets (damagefunctions, measures, discount) ...\n\t    ')
    entity_filename = [modul_data_dir filesep 'entity_global_without_assets.xls'];
    entity          = climada_entity_read_wo_assets(entity_filename);
end

% rename to entity_base
entity_base = entity; clear entity;


%% take assets from distributed values matrix
fprintf('\t b) Take assets from distributed values matrix\n')
assets                  = [];
assets.filename         = [country_name_str ', ' values_distributed.comment hollow_name];

% mask_index              = logical(country_mask_resolution.values);
% check for buffer value
matrix_hollowout        = double(matrix_hollowout);
buffer_value            = full(max(matrix_hollowout(:)));
if buffer_value == 1;  buffer_value = 2; end
mask_index              = matrix_hollowout >= 1 & matrix_hollowout < buffer_value;
assets.Longitude        = X(mask_index)';
assets.Latitude         = Y(mask_index)';
assets.Value            = full(values_distributed.values(mask_index))';
assets.Deductible       = zeros(1,length(assets.Longitude));
assets.Cover            = full(values_distributed.values(mask_index))';
assets.DamageFunID      = ones(1,length(assets.Longitude));
assets.Value_today       = full(values_distributed.values(mask_index))'; % _2012 replaced by _today

if ~any(assets.Value)%all zeros
    fprintf('\t\t No values within assets for %s\n', country_name_str)
    %centroids = []; entity = []; entity_forecast = [];
    return
end

%% encode assets
fprintf('\t c) Encode assets to centroids\n')
[entity_base.assets centroids] = climada_assets_encode_centroids(assets, centroids);



return


