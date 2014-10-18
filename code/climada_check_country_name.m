function country_name = climada_check_country_name(country_name)

% check country name
% NAME:
%   climada_check_country_name
% PURPOSE:
%   check country name
% CALLING SEQUENCE:
%   country_name = climada_check_country_name(country_name)
% EXAMPLE:
% 	country_name = climada_check_country_name(country_name)
% INPUTS:
%   country_name     : name of country (string)
% OUTPUTS:
%   country_name
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20141016
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables
if ~exist('country_name'       , 'var'), country_name        = []; end

borders = climada_load_world_borders;
if isempty(borders), return, end

if ~sum(strcmp(country_name, borders.name)) == 1
    cprintf([1,0.5,0],'%s is not a valid country name. Unable to proceed.\n', country_name)
    country_name = [];
end




