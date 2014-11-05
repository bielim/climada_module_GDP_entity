function border_mask = climada_load_border_mask(border_mask, asset_resolution_km)
% load border mask
% NAME:
%   climada_load_border_mask
% PURPOSE:
%   load border mask
% CALLING SEQUENCE:
%   border_mask = climada_load_border_mask(border_mask, asset_resolution_km)
% EXAMPLE:
%   border_mask = climada_load_border_mask
% INPUTS:
%   none
% OPTIONAL INPUT PARAMETERS:
%   border_mask
% OUTPUTS:
%   border_mask
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20141016
%-

%global climada_global
if ~climada_init_vars,return;end % init/import global variables
if ~exist('border_mask'         , 'var'), border_mask         = []; end
if ~exist('asset_resolution_km' , 'var'), asset_resolution_km = []; end

%init
border_mask    = [];

% set modul data directory
modul_data_dir = [fileparts(fileparts(mfilename('fullpath'))) filesep 'data'];


try
    load([modul_data_dir filesep 'border_mask_10km'])
catch err
    try
        load([modul_data_dir filesep 'border_mask_' int2str(asset_resolution_km) 'km'])
    catch err
        cprintf('r','\n\tborder_mask not available\n')
        cprintf('r','\tCreate border mask with function\n')
        cprintf('r','\tborder_mask = climada_polygon2raster(borders, raster_size, save_on)\n')
        qstring = 'border_mask not available, do you want to create it now? This may take 5-20 min, depending on the resolution (~50km, ~10km)';
        choice  = questdlg(qstring,'Create border mask now?');
        if strcmp(choice,'Yes')
            %input_resolution_km = climada_geo_distance(0,0,night_light.resolution_x,0)/1000;
            %input_resolution_km = ceil(input_resolution_km/10)*10;
            %factor              = round(asset_resolution_km/input_resolution_km);
            %raster_size         = round(size(night_light.values)/factor);
            borders             = [];
            %raster_size         = [1680 4320]; %10km
            %raster_size         = [336 864]; %50km
            raster_size         = [168 432]; %100km
            save_on             = 1;
            border_mask         = climada_polygon2raster(borders, raster_size, save_on);
        else
            return
        end
    end
end

end