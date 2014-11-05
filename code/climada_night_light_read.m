function night_light = climada_night_light_read(png_filename, check_figure, check_printplot, save_on)
% read stable night lights, 2010 (resolution ~10km)
% http://www.ngdc.noaa.gov/dmsp/downloadV4composites.html 
% http://www.ngdc.noaa.gov/dmsp/data/web_data/v4composites/F182010.v4.tar 
% Version 4 DMSP-OLS Nighttime Lights Time Series
% NAME:
%   climada_night_light_read
% PURPOSE:
%   read stable night lights (2010) from NOAA
%   previous: diverse
%   next: climada_GDP_distribute
% CALLING SEQUENCE:
%   night_light = climada_night_light_read(png_filename, check_figure, check_printplot, save_on)
% EXAMPLE:
%   night_light = climada_night_light_read
% INPUTS:
% OPTIONAL INPUT PARAMETERS:
%   png_filename     :  the filename (location) of the png-file
%                      (default night_light_2010_10km.png)
%   check_figure     :  set to 1 to show figure of night light
%   check_printplot  :  set to 1 to save figure
%   save_on          :  set to 1 to save night_light.mat
% OUTPUTS:
%   night_light: a struct, with following fields
%         .value        : GDP value in USD per country
%         .lon_range    : range of Longitude
%         .lat_range    : range of Latitude
%         .resolution_x : resolution in x-direction
%         .resolution_y : resolution in y-direction
%         .comment      : information about night light data
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20120730
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables
if ~exist('png_filename'   , 'var'), png_filename    = []; end
if ~exist('check_figure'   , 'var'), check_figure    = 1 ; end
if ~exist('check_printplot', 'var'), check_printplot = []; end
if ~exist('save_on'        , 'var'), save_on         = []; end

% set modul data directory
modul_data_dir = [fileparts(fileparts(mfilename('fullpath'))) filesep 'data'];


% prompt for png_filename if not given
if isempty(png_filename) % local GUI
    png_filename         = [modul_data_dir filesep '*.png'];
    png_filename_default = [modul_data_dir filesep 'Select night lights .png'];
    [filename, pathname] = uigetfile(png_filename, 'Select night lights .png:',png_filename_default);
    if isequal(filename,0) || isequal(pathname,0)
        return; % cancel
    else
        png_filename = fullfile(pathname,filename);
    end
end


values                   = flipud(double(imread(png_filename)));  
values(isnan(values))    = 0; 
x_range                  = [-180 180];
y_range                  = [ -65  75];
resolution_x             = sum(abs(x_range))/size(values,2);
resolution_y             = sum(abs(y_range))/size(values,1);
    
night_light.values       = sparse(values);
night_light.lon_range    = x_range;
night_light.lat_range    = y_range;
night_light.resolution_x = resolution_x;
night_light.resolution_y = resolution_y;
night_light.comment      = 'Night time lights, 2010';
         
                  
% plot image  
if check_figure
    % colormap from green to red
    colormap_green_red = [summer(20);
                          flipud(autumn(80))];
                  
    fig_width       = 162+180;
    fig_height      = 60+77;
    fig_relation    = fig_height/fig_width;
    fig_height_     = 1.2;
    fig             = climada_figuresize(fig_height_*fig_relation,fig_height_);

    im = imagesc(x_range-resolution_x/2, y_range-resolution_y/2, night_light.values);
    % set(im,'alphadata',~isnan(values))
    set(gca,'ydir','normal')
    hold on
    colormap(flipud(hot))
    % caxis([1 max(night_light(:))])
    t = colorbar;
    colorbar_label = night_light.comment;
    set(get(t,'ylabel'),'String', colorbar_label,'fontsize',14);

    climada_plot_world_borders(0.5)
    axis equal
    % axis([-162 180 -60 77])
    % set(gca,'xlim',[-162 180],'ylim',[-60 77])
    % set(gca,'xlim',[-162 180],'ylim',[-60 77],'ytick',[],'xtick',[])

    if check_printplot %(>=1)   
        foldername = [filesep 'results' filesep 'night_lights_2010_10km.pdf'];
        print(fig,'-dpdf',[climada_global.data_dir foldername])
        %close
        cprintf([255 127 36 ]/255, '\t\t saved 1 FIGURE in folder %s \n', foldername);
    end
end

if save_on
    foldername = [modul_data_dir filesep 'night_light_2010_10km.mat'];
    save(foldername,'night_light')
    cprintf([113 198 113]/255, '\t\t saved 1 mat-file in folder %s \n',foldername)
end

    
% foldername = [filesep 'results' filesep 'night_time_lights_2010_Europe_.pdf'];
% print(fig,'-dpdf',[climada_global.data_dir foldername])
        

% plot(centroids.Longitude, centroids.Latitude, '+b')

end
