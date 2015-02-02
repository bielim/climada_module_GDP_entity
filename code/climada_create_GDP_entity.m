function [centroids, entity, entity_future] = climada_create_GDP_entity(country_name, polygon, check_figure, no_wbar)
% GDP entity assets
% MODULE:
%   GDP_entity
% NAME:
%   climada_create_GDP_entity
% PURPOSE:
%   create centroids and entity for a specific country, distribute assets
%   and value according to night light intensities and scale up to match 
%   GDP today (see climada_global.present_reference_year) and a future (see
%   climada_global.future_reference_year) scenario 
% CALLING SEQUENCE:
%   [centroids entity entity_future] = climada_create_GDP_entity(country_name, polygon)
% EXAMPLE:
%   [centroids entity entity_future] = climada_create_GDP_entity
%   [centroids entity entity_future] = climada_create_GDP_entity('Mexico')
% INPUTS:
%   country_name: the name of the country or an ISO3 country code (like
%       'CHE'), see climada_country_name
%   polygon: do restrict to centroids in polygon, calls
%       climada_cut_out_GDP_entity, see parameters there.
%   check_figure: set to 1 to visualize figures, default 1
%   no_wbar: 1 to suppress waitbars
%   GDP: GDP data within a structure, prompted for if not given, loaded
%       automatically from economic_indicators_mastertable.mat file if existing
% OUTPUTS:
%   centroids: a structure with fields centroid_ID, Latitude, Longitude,
%       onLand, country_name, comment for each centroid
%   entity         : a structure with fields assets, damagefunctions, measures,
%                    discount. Assets values are based on night light 
%                    intensity and scaled up to todays GDP (e.g. 2014)
%   entity_future  : entity strucure with values scaled to a future GDP
%                    scenario
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20140206
% David N. Bresch, david.bresch@gmail.com, 20141209, country ISO3 enabled
% David N. Bresch, david.bresch@gmail.com, 20141212, migrated to world_50m.gen being local to GDP_entity, as climada moved to admin0.mat
% Melanie Bieli, melanie.bieli@bluewin.ch, 20150125, incorporated climada_entity_value_GDP_adjust to scale up the entity, ... 
%                                                    climada_entity_GDP not used anymore
%
%-

% import/setup global variables
global climada_global
if ~climada_init_vars,return;end;

if ~exist('country_name', 'var'), country_name = []  ; end

% PARAMETERS
% set the parameters according to your needs
asset_resolution_km      = 10;
year_start               = climada_global.present_reference_year;
year_future              = climada_global.future_reference_year;
%
% excel file with GDP information
GDP_xls_filename = [climada_global.data_dir filesep 'system' filesep 'economic_indicators_mastertable.xls'];
%
% GDP in year_future (if not known, it will be extrapolated based on past
% GDP data)
GDP_future=[];
%
% misdat values in GDP table (default: economic_indicators_mastertable.xls) 
misdat_value = -999;

if ~exist('check_figure', 'var'), check_figure = 1; end
if ~exist('no_wbar'     , 'var'), no_wbar      = 1; end
% check_figure             = 1;
% no_wbar                  = 1;
check_printplot          = 0;
check_for_groups         = 0;
hollowout                = 0;

save_on_entity_centroids = 0;
night_light              = ''; 
pp                       = ''; 
borders                  = ''; 
border_mask              = '';
GDP                      = '';


% init
centroids     = [];
entity        = [];
entity_future = [];


%% create entity_base (all values add up to 100 within the specified country) and create the centroids on the required resolution
[centroids_ori, entity_base] = climada_create_centroids_entity_base(country_name, asset_resolution_km, hollowout,...
                                                        check_for_groups,night_light, pp, borders, border_mask, ... 
                                                        check_figure, save_on_entity_centroids, no_wbar);                                           
if isempty(entity_base), return, end
  

% %% scale up entity_base to match GDP of year_start                                                 
% entity          = climada_entity_GDP(entity_base, GDP, year_start , centroids_ori, borders, check_figure, check_printplot);  
% if isempty(entity), return, end


%% save the base entity and prepare GDP adjusted entity (including magic economic factor) today,
% such that the file name can given as an input to climada_entity_value_GDP_adjust
entity = entity_base;
entity_base_file = [climada_global.data_dir filesep 'entities' filesep 'entity_' country_name '_' num2str(asset_resolution_km) 'km_sum100.mat'];
save(entity_base_file,'entity')
fprintf('\t- Base entity (sum 100) saved in \n\t\t %s\n', entity_base_file);

%prepare filename for GDP adjusted entity today
entity_file = [climada_global.data_dir filesep 'entities' filesep 'entity_' country_name '_' num2str(asset_resolution_km) 'km_GDP_adj.mat'];
save(entity_file,'entity')
entity = climada_entity_value_GDP_adjust(entity_file);
% fill in reference year
entity.assets.reference_year = climada_global.present_reference_year;
save(entity_file,'entity')
GDP_adj_factor = sum(entity.assets.Value)/sum(entity_base.assets.Value);
fprintf('\t- Entity today based on GDP adjusted created (total asset value is %4.4g USD, factor used: %4.4g)\n', sum(entity.assets.Value), GDP_adj_factor);


%% generate future entity by scaling up the adjusted entity
% get scale-up factor
fprintf('\t- Entity %d created (based on GDP adjusted today and scale up factor)\n', climada_global.future_reference_year);
[~, scale_up_factor]= climada_entity_scaleup_GDP(entity, GDP_future, year_future, year_start, centroids_ori, borders, check_figure, check_printplot);

% scale up entity with that factor to generate entity_future 
entity_future   = climada_entity_scaleup_factor(entity, scale_up_factor);   
entity_future.assets.reference_year = climada_global.future_reference_year;
entity_future_file = [climada_global.data_dir filesep 'entities' filesep 'entity_' country_name '_' num2str(asset_resolution_km) 'km_GDP_adj_future.mat'];
save(entity_future_file,'entity_future')
fprintf('\t\t saved in \n\t\t %s\n', entity_future_file);


if ~exist('polygon', 'var'), polygon = []  ; end
if ~isempty(polygon)
    if numel(polygon) == 1, polygon = []; end
    [centroids, entity]        = climada_cut_out_GDP_entity(entity       ,centroids_ori,polygon);
    [c,         entity_future] = climada_cut_out_GDP_entity(entity_future,centroids    ,polygon);
else
    centroids = centroids_ori;
end


