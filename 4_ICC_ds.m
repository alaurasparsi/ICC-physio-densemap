% !/usr/bin/env matlab
% Laura Belli, Sara Stampacchia
% last modification: 15.12.2025
clc
clear
close all

%% 1.0 set paths and constants
addpath('functions\');
Path2results = 'Schaefer400\results';
Path2Parc = 'parcellations';
Path2data = 'Schaefer400\data';
Path2plots = 'Schaefer400\figures';
labels = load(fullfile(Path2Parc, '\Schaefer2018_400Parcels_7Networks_reordered.txt'));
N = size(labels, 1);
mask_ut = triu(true(N), 1);
numEdges = sum(sum(mask_ut==1));
n_sub = 10;
n_ses = 10;
n_mod = 8;
n=10;

%% 2.0 dense-sampling ICC(2,1) edge-wise
load(fullfile(Path2results,"S400_FC_4D.mat"));
ICC_3D_all = NaN(numEdges, n_ses, n_mod);
table_num = NaN(numEdges, n_ses, n_mod);
table_den = NaN(numEdges, n_ses, n_mod);
table_MSR = NaN(numEdges, n_ses, n_mod);
table_MSW = NaN(numEdges, n_ses, n_mod);
table_MSC = NaN(numEdges, n_ses, n_mod);
table_MSE = NaN(numEdges, n_ses, n_mod);

for mod = 1:n_mod
    for ses = 2:n_ses  % iterate over sessions
        ICC_matrix = zeros(N, N);
        ICC_vec = nan(1, numEdges);

        for comp = 1:numEdges
            data_ICC = [];  % initialize for each edge
            temp_data_ICC = FC_4D_mat_all(comp, 1:ses, :, mod);
            tem_data_ICC = squeeze(temp_data_ICC);
            % remove rows with NaNs
            rows2delete = isnan(sum(tem_data_ICC, 1));
            tem_data_ICC(:,rows2delete) = [];

            % compute ICC(2,1) across sessions
            data_ICC = tem_data_ICC';
            ICC_vec(1, comp) = ICC(data_ICC, 'A-1');
            [p, table] = anova_rm(data_ICC, 'off');
            SSR = table{3,2};
            SSE = table{4,2};
            SSC = table{2,2};
            SSW = SSE + SSC;
            MSE = SSE / ((n-1)*(ses-1));
            MSR = SSR / (n-1);
            MSC = SSC / (ses-1);
            MSW = SSW / (n*(ses-1));
            table_num(comp, ses, mod) = MSR - MSE;
            table_den(comp, ses, mod) = (MSR + (ses-1)*MSE + ses*(MSC-MSE)/n);
            table_MSR(comp, ses, mod) = MSR;
            table_MSW(comp, ses, mod) = MSW;
            table_MSC(comp, ses, mod) = MSC;
            table_MSE(comp, ses, mod) = MSE;
        
        end

        %build and save vector and matrix
        ICC_matrix(mask_ut) = ICC_vec;
        ICC_matrix = ICC_matrix + ICC_matrix';
        save_filename = sprintf('Schaefer400_ICC_matrix_ses1-%d_rest_run-01_m%d.mat', ses, mod);
        save(fullfile(Path2results, save_filename), 'ICC_matrix', 'ICC_vec');
        ICC_3D_all(:, ses, mod) = ICC_vec;

        % plot ICC
        figure;
        imagesc(ICC_matrix(labels(:,1), labels(:,1)));
        caxis([0 1]);
        colorbar;
        axis square;
        title(sprintf('ICC on sessions 1 to %d, denoising model %d - Schaefer400 ', ses, mod), 'Interpreter', 'none');

        % save
        save_ICC_plot = sprintf('Schaefer400_ICC_plot_ses1-%d_task-rest_run-01_m%d.png', ses, mod);
        saveas(gcf, fullfile(Path2plots, save_ICC_plot));
        close;
    end
end
save(fullfile(Path2results, 'S400_ICC_3D.mat'), 'ICC_3D_all');
save(fullfile(Path2results, 'S400_table_num.mat'), 'table_num');
save(fullfile(Path2results, 'S400_table_den.mat'), 'table_den');
save(fullfile(Path2results, 'S400_table_MSE.mat'), 'table_MSE');
save(fullfile(Path2results, 'S400_table_MSR.mat'), 'table_MSR');
save(fullfile(Path2results, 'S400_table_MSC.mat'), 'table_MSC');
save(fullfile(Path2results, 'S400_table_MSW.mat'), 'table_MSW');