function entity = climada_entity_GDP(entity_base, GDP, year_start, centroids, borders, check_figure, check_printplot) 

% upscale given base entity (sum of assets is 100, or less if only coastal
% areas) to match the GDP of a specific country for a given year
% NAME:
%   climada_entity_GDP
% PURPOSE:
%   Upscale entity to a GDP of a given country and year, read GDP data from
%   worldbank/IMF, find country for given entity/centroids
% CALLING SEQUENCE:
%   entity = climada_entity_GDP(entity_100, GDP, year_start, centroids,
%   borders, check_figure, check_printplot) 
% EXAMPLE:
%   entity = climada_entity_GDP(entity_100, GDP, 2014, centroids) 
% INPUTS:
%   entity_base: entity with entity.assets.Value sum up to 100 for the
%   entire country (if only coastal areas, sum is less than 100)
% OPTIONAL INPUTS:
%   GDP       : GDP data within a structure, prompted for if not given, loaded
%               automatically from GDP.mat file if existing
%   year_start: year for GDP for a given country, default
%               climada_global.present_reference_year
%   centroids : prompted if not given, centroids with field .country_name
%               for each centroid indicating the country matching with GDP data
%   borders   : border structure (with name, polygon for every country)
%   check_figure   : 1 to visualize figure
%   check_printplot: 1 to print/save figure
% OUTPUTS:
%   entity             : assets upscaled to a GDP of a country and a given year
%   a structure, with
%       assets         : a structure, with
%           Latitude   : the latitude of the values
%           Longitude  : the longitude of the values
%           Value      : the total insurable value
%           Deductible : the deductible
%           Cover      : the cover
%           DamageFunID: the damagefunction curve ID
%       damagefunctions: a structure, with
%           DamageFunID: the damagefunction curve ID
%           Intensity  : the hazard intensity
%           MDD        : the mean damage degree
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20140206
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('entity_base'    , 'var'), entity_base     = [];end
if ~exist('GDP'            , 'var'), GDP             = [];end
if ~exist('year_start'     , 'var'), year_start      = climada_global.present_reference_year;end
if ~exist('centroids'      , 'var'), centroids       = [];end
if ~exist('borders'        , 'var'), borders         = [];end
if ~exist('check_figure'   , 'var'), check_figure    = 1 ;end
if ~exist('check_printplot', 'var'), check_printplot = [];end

silent_mode         = 0;
check_figure_entity = 1;
% set modul data directory
modul_data_dir      = [fileparts(fileparts(mfilename('fullpath'))) filesep 'data'];

if isempty(entity_base)
    entity_base = climada_entity_load;
end

fprintf('Step 1: Base entity to GDP 2010 (latest year of available GDP  information)\n')


%% read/load GDP data per country from 1960 to 2010
if isempty(GDP) 
    GDP_filename   = [modul_data_dir filesep 'World_GDP_current_1960_2010.mat'];
    if exist(GDP_filename,'file')
        load(GDP_filename)
        if ~silent_mode
            fprintf('\t\t GDP per country loaded\n\t\t %s\n',GDP.comment)
        end
    else
        %read xls-file
        xls_filename = [modul_data_dir filesep 'World_GDP_current_1960_2010.xls'];
        if exist(xls_filename,'file')
            if ~silent_mode
                fprintf('\t\t Read GDP and save as mat-file\n')
            end
            GDP = climada_GDP_read(xls_filename, 1, 1, 1);
            if isempty(GDP)
                entity = []; fprintf('GDP data not available.\n'); return
            else
                save(strrep(xls_filename,'.xls','.mat'), 'GDP')
            end
        else
            fprintf('\t\t GDP data %s not found. Unable to proceed. \n', xls_filename)
            entity = []; 
            return
        end
    end
end



%% economic development (asset upscaling)
if year_start>2010
    year_start_ori = year_start;
    year_start     = 2010;
else
    year_start_ori = year_start;
end

% prompt for centroids if not given
if isempty(centroids) % local GUI
    centroids         = [climada_global.system_dir filesep '*.mat'];
    centroids_default = [climada_global.system_dir filesep 'choose centroids.mat'];
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

% prompt for borders if not given
if isempty(borders) 
    if isfield(climada_global,'map_border_file')
        map_border_file = strrep(climada_global.map_border_file,'.gen','.mat');
    else
        fprintf('\t\t no map found\n Unable to proceed.\n')
        return
    end
    try
       load(map_border_file)
    catch err
        fprintf('\t\t create and save world borders as mat-file...')
        climada_plot_world_borders
        close   
        fprintf('done\n')
        load(map_border_file)
    end
end
if ~isfield(borders,'region')
    borders = climada_borders_region(borders,[],0);
end


%% basic check if entity matches with centroids
uni_index = unique(entity_base.assets.centroid_index);
if all(ismember(uni_index,centroids.centroid_ID))
    fprintf('\t\t Assets are all encoded to valid centroids.\n')
else
    fprintf('\t\t Not all assets within entities match with given centroids!\n\t\t Can"t proceed\n')
    entity = [];
    return    
end


%% check if centroids have ISO3 country codes (for each centroid)
country_index = ismember(centroids.centroid_ID, uni_index);
country_uni   = unique(centroids.country_name(country_index));
iscountry     = ~ismember(country_uni,{'buffer' 'grid'});
country_uni   = country_uni(iscountry);
if length(country_uni) == 1 & isempty(country_uni{1})
    fprintf('\t\t No country names for centroids!\n\t\t Unable to proceed.\n')
    entity = [];
    return
end


%% calculate GDP entity_base scale up factors for each country
% loop over countries, mostly just one country within one entity
for c_i = 1:length(country_uni)
    
    %% find centroids and assets within specific country
    c_name  = strcmp(country_uni(c_i), borders.name);
    if any(c_name)
        %fprintf('%s\n',borders.name{c_name})
        if sum(c_name)>1
            c_name = find(c_name,1);
        end
        %fprintf('%s\n',borders.name{c_name})
        c_index = strcmp(borders.name(c_name), GDP.country_names);
    else
        c_index = '';
        fprintf('\t\t No country found for "%s"\n', country_uni{c_i})
    end  
    
    
    if ~any(c_index) %&& ~strcmp(ISO3_uni(c_i),'sea')
        if borders.groupID(c_name)>0
            groupIndex = borders.groupID == borders.groupID(c_name);
        else
            groupIndex = [];
        end
        %group_str = sprintf('%s, ', borders.name{groupIndex}); group_str(end-1:end) = [];
        [a ia] = ismember(borders.name(groupIndex), GDP.country_names);
        c_index = ia(ia>0);
        if length(c_index)>1
            names_str = sprintf('%s, ',GDP.country_names{c_index}); names_str(end-1:end) = [];
            fprintf('\t\t More than one country within group has GDP information (%s)\n',names_str);
            c_index = c_index(1);
            fprintf('\t\t Take GDP information  from %s\n',GDP.country_names{c_index});
            fprintf('\t\t %s is not in GDP database, but in group with %s\n',borders.name{c_name}, GDP.country_names{c_index}) 
        else
            fprintf('\t\t %s is not in GDP database\n',borders.name{c_name}) 
        end     
    end   
    
    %% country identified and GDP data for that country is available
    if any(c_index) & any(~isnan(GDP.value(c_index,:))) & any(nonzeros(GDP.value(c_index,:)))
        
        %% check if requested year is within the forecasted values
        %year_f_index = find(GDP.year == year_forecast);
        year_s_index = find(GDP.year == year_start, 1);
        if isempty(year_s_index); year_s_index = 1; end
        
        % calculate scaleup_factor as 
        % factor = "GDP for a given country and year" / "sum(assets)", whereas sum(assets) is 100 as defined by entity_base
        % factor = "GDP for a given country and year" / 100
        GDP_val        = GDP.value(c_index,year_s_index);
        scaleup_factor = GDP_val / 100;
        entity         = climada_entity_scaleup_factor(entity_base, scaleup_factor); 
        fprintf('\t\t GDP for %s in %d is %2.4g USD (current) \n',GDP.country_names{c_index}, year_start, GDP_val);
        
        if sum(entity_base.assets.Value) >= 99.5 &  sum(entity_base.assets.Value) <= 100.5 
            fprintf('\t\t Entity assets covers %2.1f%% of %s, i.e. GDP for entire %s in %d is %2.4g USD\n',...
                     sum(entity_base.assets.Value), GDP.country_names{c_index}, GDP.country_names{c_index}, year_start, sum(entity.assets.Value));
        elseif sum(entity_base.assets.Value) <100
            fprintf('\t\t Entity assets covers %2.1f%% of %s, i.e. GDP for that region in %d is %2.4g USD\n',...
                     sum(entity_base.assets.Value), GDP.country_names{c_index}, year_start, sum(entity.assets.Value));
        end
    else
        fprintf('\t\t %s: no data available\n',borders.name{c_name})
    end
end


if year_start_ori>year_start
    fprintf('\nStep 2: Entity based on GDP 2010 to entity based on GDP %d\n', year_start_ori)
    GDP_forecast = [];
    entity = climada_entity_scaleup_GDP(entity, GDP_forecast, year_start_ori, year_start, centroids, borders, check_figure, check_printplot);
end

if check_figure_entity
    climada_plot_entity_assets(entity, centroids, country_uni{1}, check_printplot);
end

%%

    
