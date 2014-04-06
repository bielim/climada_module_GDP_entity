function fig = climada_plot_entity_assets(entity, centroids, country_name, check_printplot, printname)

% climada plot assets from entity file and save if needed
% NAME:
%   climada_plot_entity_assets
% PURPOSE:
%   plot assets from entity file on a map with different colors to show the
%   distribution of assets, print if needed
%   normally called from: climada_create_GDP_entity
% CALLING SEQUENCE:
%   fig = climada_plot_entity_assets(entity, centroids, country_name, check_printplot)
% EXAMPLE:
%   climada_plot_entity_assets(entity, centroids, country_name)
% INPUTS:
%   entity          : entity structure, with entity.assets field
%   centroids       : centroids mat-file (struct)
% OPTIONAL INPUT PARAMETERS:
%   country_name_str: country name as string format
%   check_printplot : 1 for printing (save as pdf), set to 0 by default
%   printname       : name for pdf-file, to be saved in .../climada/data/results/Entity_printname.pdf
% OUTPUTS:
%   fig             : figure handle
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20140205
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

fig = [];
% poor man's version to check arguments
if ~exist('entity'          ,'var'), return              ; end
if ~exist('centroids'       ,'var'), return              ; end
if ~exist('country_name'    ,'var'), country_name    = []; end
if ~exist('check_printplot' ,'var'), check_printplot = []; end
if ~exist('printname'       ,'var'), printname       = []; end

if ~iscell(country_name)
    country_name = {country_name};
end

%% calculate figure scaling parameters
scale  = max(centroids.Longitude) - min(centroids.Longitude);
scale2 =(max(centroids.Longitude) - min(centroids.Longitude))/...
        (min(max(centroids.Latitude),80)-max(min(centroids.Latitude),-60));
height = 0.5;
if height*scale2 > 1.2; height = 1.2/scale2; end

% calculate figure characteristics
ax_lim = [min(centroids.Longitude)-scale/30          max(centroids.Longitude)+scale/30 ...
          max(min(centroids.Latitude),-60)-scale/30  min(max(centroids.Latitude),80)+scale/30];    
markersizepp = polyfit([15 62],[5 3],1);
markersize   = polyval(markersizepp,ax_lim(2) - ax_lim(1));
markersize(markersize<2) = 2;


%% create figure
fig = climada_figuresize(height,height*scale2+0.15);
name_str = sprintf('Entity %s', country_name{1});
set(fig,'Name',name_str)
% colormap(flipud(hot))
cbar = plotclr(entity.assets.Longitude, entity.assets.Latitude, entity.assets.Value,'s',markersize,1,...
               [],[],[],[],1);             
set(get(cbar,'ylabel'),'String', 'value per pixel (exponential scale)' ,'fontsize',12);
hold on
box on
climada_plot_world_borders(0.5)
axis(ax_lim)
axis equal
axis(ax_lim)

if sum(entity.assets.Value)<=100.5
    title_str = sprintf('Entity %s (sum of all assets: %10.1f)', entity.assets.hazard.comment, sum(entity.assets.Value));
else %if sum(entity.assets.Value) > 10000
    title_str = sprintf('Entity %s (sum of all assets: %2.4g USD)', entity.assets.hazard.comment, sum(entity.assets.Value));
end
title(title_str)


if check_printplot
    if isempty(printname) %local GUI
        printname_         = [climada_global.data_dir filesep 'results' filesep '*.pdf'];
        printname_default  = [climada_global.data_dir filesep 'results' filesep 'Entity_' country_name{1} '_resolution_km.pdf'];
        [filename, pathname] = uiputfile(printname_,  'Save asset map as figure:',printname_default);
        foldername = [pathname filename];
        if pathname <= 0; return;end
    else
        foldername = [climada_global.data_dir filesep 'results' filesep 'Entity_' printname '_sum100.pdf'];
    end
    print(fig,'-dpdf',foldername)       
    cprintf([255 127 36 ]/255,'\t\t saved 1 FIGURE in folder ..%s \n', foldername);
end


return


