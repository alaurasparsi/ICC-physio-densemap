% !/usr/bin/env matlab
% Laura Belli
% last modification: 10.12.2025
clc
clear
close all

%% 1.0 set paths and constants
Path2results = 'Schaefer400\results';
Path2Parc = '\parcellations';
Path2data = 'Schaefer400\data';
Path2plots = 'Schaefer400\figures';
labels = load(fullfile(Path2Parc, '\Schaefer2018_400Parcels_7Networks_reordered.txt'));
N = size(labels, 1);
mask_ut = triu(true(N), 1);
numEdges = sum(sum(mask_ut==1));
n_sub = 10;
n_ses = 10;
n_mod = 8;
FC_4D_mat_all = zeros(numEdges, n_ses, n_sub, n_mod);


%% 2.0 Functional Connectivity (FC) on the 8 denoising models
for s = 1:n_sub
    for ses = 1:n_ses
        for mod = 1:n_mod
            FC_3D = NaN(N, N);
            % build dynamic filename
            data = sprintf('sub-%03d_ses-%02d_task-rest_run-01_Schaefer400_timeseries_m%d.1D', s, ses, mod);
            temp_TS_ROI = load(fullfile(Path2data, data));

            % compute correlation matrix
            FC_3D = corr(temp_TS_ROI);
            % save FC matrix
            save_FC_matrix = sprintf('Schaefer400_FC_matrix_sub_%03d_ses_%02d_task-rest_run-01_m%d.mat', s, ses, mod);
            save(fullfile(Path2results, save_FC_matrix), 'FC_3D');
            FC_4D_mat_all(:, ses, s, mod) = FC_3D(mask_ut);

            % plot connectomes
            figure;
            imagesc(FC_3D(labels(:, 1), labels(:,1)));
            caxis([-0.8 0.8]);
            axis square;
            colorbar;
            title(sprintf('FC sub %03d, ses %02d, denoising model %d - Schaefer400', s, ses, mod), 'Interpreter', 'none');

            % save figure
            save_FC_plot = sprintf('Schaefer400_FC_plot_sub_%03d_ses_%02d_task-rest_run-01_m%d.png', s, ses, mod);
            saveas(gcf, fullfile(Path2plots, save_FC_plot));
            close;
        end
    end
end
save(fullfile(Path2results, 'S400_FC_4D.mat'), 'FC_4D_mat_all');


