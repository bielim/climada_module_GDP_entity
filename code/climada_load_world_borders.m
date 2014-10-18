function borders = climada_load_world_borders(borders)

% load world borders and perform basic checks
% NAME:
%   climada_load_world_borders
% PURPOSE:
%   load world borders and perform basic checks
% CALLING SEQUENCE:
%   borders = climada_load_world_borders(borders)
% EXAMPLE:
%   borders = climada_load_world_borders
% INPUTS:
%   none 
% OPTIONAL INPUT PARAMETERS:
%   borders
% OUTPUTS:
%   borders
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20141016
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables
if ~exist('borders'       , 'var'), borders        = []; end

%init
borders = [];

if isempty(borders) 
    if isfield(climada_global,'map_border_file')
        map_border_file = strrep(climada_global.map_border_file,'.gen','.mat');
    else
        fprintf('no map found\n')
        return
    end
    
    try
       load(map_border_file)
    catch err
        fprintf('0) create and save world borders as mat-file...')
        climada_plot_world_borders
        close   
        fprintf('done\n')
        load(map_border_file)
    end
end

if ~isfield(borders,'region') || ~isfield(borders,'ISO3') || ~isfield(borders,'groupID')
    fprintf('No region, ISO3, or groupID information within border file available. Unable to proceed.\n')
    fprintf('You might \n\t - delete the borders-file/world_50.mat and \n')
    fprintf('\t - check for the file "countryname_ISO3_groupID_region.txt" \n\t - and retry.\n')
    return
end

