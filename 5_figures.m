% !/usr/bin/env matlab
% Laura Belli, Stefano Moia
% last modification: 15.12.2025
clc
clear
close all

%% set paths and constants
addpath('functions\');
Path2results = 'Schaefer400\results';
Path2Parc = 'parcellations';
Path2data = 'Schaefer400\data';
Path2plots = 'Schaefer400\figures';
labels = load(fullfile(Path2Parc, '\Schaefer2018_400Parcels_7Networks_reordered.txt'));
n_ses = 10;
n_mod = 8;
n = 10;
N = size(labels, 1);
mask_ut = triu(true(N), 1);
numEdges = sum(sum(mask_ut==1));
% Viridis-inspired palette
colorList = [
    0.2670, 0.0049, 0.3294;
    0.2832, 0.1411, 0.4588;
    0.2545, 0.2656, 0.5302;
    0.2071, 0.3726, 0.5539;
    0.1649, 0.4714, 0.5580;
    0.1280, 0.5675, 0.5510;
    0.1341, 0.6584, 0.5176;
    0.2667, 0.7485, 0.4406;
    0.4775, 0.8214, 0.3181];


%% plot average ICC values across denoising strategies (figure 2a-c)
load(fullfile(Path2results, "S400_ICC_3D.mat"));
mean_ICC = mean(ICC_3D_all, 1);
mean_ICC = squeeze(round(mean_ICC, 4));
save(fullfile(Path2results, 'S400_ICC_avg.mat'), 'mean_ICC');
ColorList = brewermap(8, 'RdYlBu');
x = 1:10;

figure('Color', 'w'); set(gcf,'Position',[100 100 1100 800]); hold on;
h = gobjects(n_mod,1);
fig_1 = figure('Color','w');
set(fig_1,'Position',[100 2000 2000 800]);

ax = axes(fig_1);
set(ax, ...
    'FontSize',30, ...        
    'LineWidth',3.5, ...     
    'TickLength',[0.015 0.015]);
hold(ax,'on');
h = gobjects(n_mod,1);  

for mod = 1:n_mod
    thisColor = ColorList(mod,:);
    h(mod) = plot(ax, x, mean_ICC(2:10,mod), '-', ...
        'LineWidth',6.0, ...
        'Color',thisColor);
    scatter(ax, x, mean_ICC(2:10,mod), ...
        180, thisColor, 'filled');
end
xlabel(ax,'Sessions','FontSize',30);
ylabel(ax,'Average ICC','FontSize',28);
xlim(ax, [1 9]);
xticks(ax, 1:9);       
ylim(ax,[0.3 0.55]);
title('Average dense-sampling ICC score across denoising models - Schaefer400')

save_FC_plot = sprintf('S400_doit_4theplot.svg');
saveas(gcf, fullfile(Path2plots, save_FC_plot));


%% Mean Squares distribution (figure 2d-f)
% same script for MSC, MSE, MSR
temp_MSC = mean(table_MSC(:, 2:10, :));
data_MSC = squeeze(temp_MSC);
x = 1:9;
ColorList = brewermap(8, 'RdYlBu');
fig_1 = figure('Color','w');
set(fig_1,'Position',[100 2000 2000 800]);

ax = axes(fig_1);
set(ax, ...
    'FontSize',30, ...        
    'LineWidth',3.5, ...  
    'TickLength',[0.015 0.015]);
hold(ax,'on');

h = gobjects(n_mod,1);

for mod = 1:n_mod
    thisColor = ColorList(mod,:);

    % thicker lines
    h(mod) = plot(ax, x, data_MSC(:,mod), '-', ...
        'LineWidth',6.0, ...
        'Color',thisColor);

    % larger scatter markers
    scatter(ax, x, data_MSC(:,mod), ...
        180, thisColor, 'filled');
end

xlabel(ax,'Sessions','FontSize',30);
ylabel(ax,'Average MSC','FontSize',28);
ylim(ax,[0 0.5]);

box(ax,'on');
grid(ax,'on');
print('-dpng','-r300');


%% ICC binary masks plotted together (figure 2g-n)
load(fullfile(Paths2results, "S400_ICC_3D.mat"));
binary_mask = zeros(numEdges, n_ses, n_mod);
for mod = 1:n_mod
    for ses = 2:n_ses
        temp_ICC = [];
        temp_ICC = ICC_3D_all(:, ses, mod);
        binary_mask(:, ses, mod) = temp_ICC > prctile(temp_ICC, 95);
    end
end

figure('Color', 'w'); set(gcf,'Position',[100 100 1100 800]);
title_legenda = sprintf("sum of binarised dense-sampling ICC edges >95th percentile - Schaefer400");
sgtitle(title_legenda, fontsize=12);
for mod = 1:n_mod
    binary_mask_mat = zeros(N, N);
    binary_mask_s = sum(binary_mask, 2);
    binary_mask_mat(mask_ut) = binary_mask_s(:, 1, mod);
    binary_matrix = binary_mask_mat + binary_mask_mat';

    subplot(3, 3, mod);
    imagesc(binary_matrix(labels(:,1), labels(:,1)));
    caxis([0 9]);
    colorbar; axis square; colormap(colorList);
    set(gca, 'XTick', [], 'YTick', []);
    ylabel('');
    xlabel(sprintf(' denoising model %d', mod), FontSize=8); 
end
figname = sprintf('S400_ICC_bin.svg');
saveas(gcf, fullfile(Path2plots, figname));
close;