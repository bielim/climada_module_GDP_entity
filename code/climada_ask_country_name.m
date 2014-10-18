function country_name = climada_ask_country_name

% ask for a country name through a pop up gui
% NAME:
%   climada_ask_country_name
% PURPOSE:
%   ask for a country name through a pop up gui
% CALLING SEQUENCE:
%   country_name = climada_ask_country_name
% EXAMPLE:
%   country_name = climada_ask_country_name
% INPUTS:
%   none
% OUTPUTS:
%   country_name
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20141016
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

%init
country_name = [];


borders              = climada_load_world_borders;
valid_countries_indx = ~strcmp(borders.ISO3,'-');
valid_countries      = borders.name(valid_countries_indx);
[liststr sort_index] = sort(valid_countries);
[s,v]                = listdlg('PromptString','Select exactly one country:',...
                      'ListString',liststr,'SelectionMode','single');
pause(0.1)              
if ~isempty(s)
    country_name = valid_countries{sort_index(s)};
else
    fprintf('No country chosen\n')
    return
end
    
    
    
    
