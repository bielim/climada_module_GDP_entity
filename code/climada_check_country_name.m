function [country_name,country_ISO3] = climada_check_country_name(country_name)
% check country name
% NAME:
%   climada_check_country_name
% PURPOSE:
%   check for valid country name or valid ISO3 country code and return both
%   (hence it can also be used to get the respective code or full name)
% CALLING SEQUENCE:
%   country_name = climada_check_country_name(country_name)
% EXAMPLE:
% 	country_name = climada_check_country_name(country_name)
% INPUTS:
%   country_name: name of country (string) or an ISO3 code (needs to be
%       uppercase, like 'CHE')
% OUTPUTS:
%   country_name if valid, empty string else (in case one enters the ISO3
%       code
%   country_ISO3: country ISO3 code (like 'CHE')
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20141016
% David N. Bresch, david.bresch@gmail.com, 20141209, ISO3 country code added
%-

%global climada_global
if ~climada_init_vars,return;end % init/import global variables
if ~exist('country_name'       , 'var'), country_name        = ''; end
if ~exist('country_ISO3'       , 'var'), country_ISO3        = ''; end

borders = climada_load_world_borders;
if isempty(borders), return, end

country_pos=strcmp(country_name, borders.name); % check for name
if ~(sum(country_pos) == 1) % check for full name
    country_pos=strcmp(country_name, borders.ISO3); % check for ISO3
    if ~(sum(country_pos) == 1) % check for full name
        cprintf([1,0.5,0],'%s is not a valid country name. Unable to proceed.\n', country_name)
        country_name = '';
        country_ISO3 = '';
        return
    end
end

% valid country_name, find ISO3
country_name=borders.name{country_pos};
country_ISO3=borders.ISO3{country_pos};

end