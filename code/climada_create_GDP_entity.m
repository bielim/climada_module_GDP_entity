function [centroids, entity, entity_forecast] = climada_create_GDP_entity(country_name, polygon)

%%
% create a portfolio for a specific country, consisting of
%   - *centroids* (mat)
%   - base entity (assets sum up to 100 for a given country, mat and
%   xls-file), intermediary step only, entity_base is not an output
%   - *entity* (based on GDP today (e.g. 2014) and future GDP projection (e.g. 2030)
% NAME:
%   climada_create_GDP_entity_all
% PURPOSE:
%   create centroids and entity for a specific country, distribute assets
%   and value according to night light intensities and scale up to match 
%   GDP today and a future scenario
% CALLING SEQUENCE:
%   [centroids entity entity_forecast] = climada_create_GDP_entity(country_name, polygon)
% EXAMPLE:
%   [centroids entity entity_forecast] = climada_create_GDP_entity
%   [centroids entity entity_forecast] = climada_create_GDP_entity('Mexico')
% INPUTS:
% none
% OUTPUTS:
%   centroids      : a structure with fields centroid_ID, Latitude, Longitude,
%                    onLand, country_name, comment for each centroid
%   entity         : a structure with fields assets, damagefunctions, measures,
%                    discount. Assets values are based on night light 
%                    intensity and scaled up to todays GDP (e.g. 2014)
%   entity_forecast: entity strucure with values scaled to a future GDP
%                    scenario
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20140206
%-

if ~exist('country_name', 'var'), country_name = []  ; end

%% set the parameters according to your needs
asset_resolution_km      = 10;
year_start               = 2014;
year_forecast            = 2030;

check_figure             = 1;
check_printplot          = 0;
check_for_groups         = 0;
hollowout                = 0;

save_on_entity_centroids = 1;
night_light              = ''; 
pp                       = ''; 
borders                  = ''; 
border_mask              = '';
GDP                      = '';


%% create entity_base (all values add up to 100 within the specified country) and create the centroids on the required resolution
[centroids_ori, entity_base] = climada_create_centroids_entity_base(country_name, asset_resolution_km, hollowout,...
                                                        check_for_groups,night_light, pp, borders, border_mask, ... 
                                                        check_figure, save_on_entity_centroids);
%% scale up entity_base to match GDP of year_start                                                 
entity          = climada_entity_GDP(entity_base, GDP, year_start   , centroids_ori, borders, check_figure, check_printplot);   

%% scale up entity_base to match GDP of year_forecast
entity_forecast = climada_entity_GDP(entity_base, GDP, year_forecast, centroids_ori, borders, check_figure, check_printplot);   


if ~exist('polygon', 'var'), polygon = []  ; end
if ~isempty(polygon)
    if numel(polygon) == 1, polygon = []; end
    [centroids, entity]          = climada_cut_out_GDP_entity(entity,centroids_ori,polygon);
    [c,         entity_forecast] = climada_cut_out_GDP_entity(entity_forecast,centroids,polygon);
else
    centroids = centroids_ori;
end


