function climada_entity_save_xls(entity, entity_xls_file)

% climada assets read import without assets
% NAME:
%   climada_entity_save_xls
% PURPOSE:
%   Save entiy as xls file
% CALLING SEQUENCE:
%   climada_entity_save_xls(entity, entity_xls_file)
% EXAMPLE:
%   climada_entity_save_xls(entity)
% INPUTS:
%   entity: entity strucure to write out in excel file
%   entity_xls_file: the filename of the Excel file to be written
% OUTPUTS:
%   excel file
% MODIFICATION HISTORY:
% Lea Mueller, 20130412
%-

global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('entity'         , 'var'), return;end
if ~exist('entity_xls_file', 'var'), entity_xls_file = [];end

warning off MATLAB:xlswrite:AddSheet

% prompt for entity_file if not given
if isempty(entity) % local GUI
    entity = climada_entity_load;
end

% check if number of assets smaller than excel limit
xls_row_limit = 65536;
if length(entity.assets.Longitude)>xls_row_limit
    fprintf('\t\t The number of assets in the entity structure (%d) exceed the number of rows in excel(%d)\n',length(entity.assets.Longitude),xls_row_limit)
    return
end

% prompt for entity_file if not given
if isempty(entity_xls_file) % local GUI
    entity_xls_file    = [climada_global.data_dir filesep 'entities' filesep '*.xls'];
    entity_xls_default = [climada_global.data_dir filesep 'entities' filesep 'type name to save entiy as xls-file.xls'];
    [filename, pathname] = uiputfile(entity_xls_file, 'Save entity as:', entity_xls_default);
    if isequal(filename,0) || isequal(pathname,0)
        return; % cancel
    else
        entity_xls_file = fullfile(pathname,filename);
    end
end

fprintf('Save entity as excel-file\n')

%% assets sheet
fprintf('\t\t - Assets sheet\n')
fields_2 =  fieldnames(entity.assets);
counter  = 0;
matr     = cell(length(entity.assets.Longitude)+1,5);
for row_i = 1:length(fields_2)
    if ~strcmp(fields_2{row_i},'filename') & ~strcmp(fields_2{row_i},'hazard')
        counter         = counter+1;
        matr{1,counter} = fields_2{row_i};
        matr(2:end,counter) = num2cell(getfield(entity.assets, fields_2{row_i})');
    end
end
xlswrite(entity_xls_file, matr, 'assets')

%% vulnerability sheet
fprintf('\t\t - Damagefunctions sheet\n')
fields_2 =  fieldnames(entity.damagefunctions);
counter  = 0;
matr     = cell(length(entity.damagefunctions.DamageFunID)+1,1);
for row_i = 1:length(fields_2)
    if ~strcmp(fields_2{row_i},'filename')
        counter         = counter+1;
        matr{1,counter} = fields_2{row_i};
        matr(2:end,counter) = num2cell(getfield(entity.damagefunctions, fields_2{row_i}));
    end
end
xlswrite(entity_xls_file, matr, 'damagefunctions')

%% measures sheet
fprintf('\t\t - Measures sheet\n')
fields_2 =  fieldnames(entity.measures);
counter  = 0;
matr     = cell(length(entity.measures.name)+1,1);
for row_i = 1:length(fields_2)
    if ~strcmp(fields_2{row_i},'filename') & ~strcmp(fields_2{row_i},'color_RGB') & ~strcmp(fields_2{row_i},'damagefunctions_mapping')
        counter         = counter+1;
        matr{1,counter} = fields_2{row_i};
        if ~isnumeric(getfield(entity.measures, fields_2{row_i})) %is not numeric
            matr(2:end,counter) = getfield(entity.measures, fields_2{row_i});
        else
            matr(2:end,counter) = num2cell(getfield(entity.measures, fields_2{row_i}));
        end
    end
end
xlswrite(entity_xls_file, matr, 'measures')


%% discount sheet
fprintf('\t\t - Discount sheet\n')
fields_2 =  fieldnames(entity.discount);
counter  = 0;
matr     = cell(length(entity.discount.yield_ID)+1,1);
for row_i = 1:length(fields_2)
    if ~strcmp(fields_2{row_i},'filename')
        counter         = counter+1;
        matr{1,counter} = fields_2{row_i};
        if ~isnumeric(getfield(entity.discount, fields_2{row_i})) %is not numeric
            matr(2:end,counter) = getfield(entity.discount, fields_2{row_i});
        else
            matr(2:end,counter) = num2cell(getfield(entity.discount, fields_2{row_i}));
        end
    end
end
xlswrite(entity_xls_file, matr, 'discount')

fprintf('\t\t Save entity as xls file\n')
cprintf([113 198 113]/255,'\t\t %s\n',entity_xls_file)





end

