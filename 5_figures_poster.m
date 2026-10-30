%% Script to reproduce my OHBM 2026 poster figures
% Laura Belli, last modification: 30.10.2026
% I chose Schaefer400 denoising model 1 for reference images (methods)

% load FC data
dataDir = 'Schaefer400\results';
Path2Plots = 'Schaefer400\figures';
Path2Parc = 'parcellations';
addpath(dataDir);
FC_3D_ses1 = load('Schaefer400_FC_matrix_sub_001_ses_01_task-rest_run-01_m1.mat');
FC_3D_ses2 = load('Schaefer400_FC_matrix_sub_001_ses_02_task-rest_run-01_m1.mat');
labels = load(fullfile(Path2Parc, '\Schaefer2018_400Parcels_7Networks_reordered.txt'));
N = size(labels, 1);

%% FC figures
n = 512;
% Anchor colors (RGB)
c1 = [1.00 1.00 1.00];   % white
c2 = [0.92 0.88 0.98];   % very light lavender
c3 = [0.75 0.60 0.95];   % soft purple
c4 = [0.45 0.18 0.75];   % elegant deep violet

% Interpolation positions
x  = [0 0.35 0.70 1];

% Smooth interpolation
xi = linspace(0,1,n);

MyList = [ ...
    interp1(x,[c1(1) c2(1) c3(1) c4(1)],xi,'pchip')', ...
    interp1(x,[c1(2) c2(2) c3(2) c4(2)],xi,'pchip')', ...
    interp1(x,[c1(3) c2(3) c3(3) c4(3)],xi,'pchip')'];

% figure for FC session 1
figure('Color','w');
imagesc(FC_3D_ses1.FC_3D(labels(:,1), labels(:,1)));
caxis([-0.8 0.8]);
axis square;

colormap(MyList);
cb = colorbar;
cb.Color = [0.2 0.2 0.2];
cb.FontSize = 11;
cb.LineWidth = 1;

% Labels and title
title('Functional Connectivity Matrix', ...
      'FontSize',16, ...
      'FontWeight','normal');

xlabel('Schaefer 400 ROIs', ...
       'FontSize',13);

% Cleaner appearance
set(gca, ...
    'FontSize',11, ...
    'LineWidth',1, ...
    'TickDir','out', ...
    'Box','off');

save_FC_plot = sprintf('Schaefer400_FC-plot_sub-001_ses-01_task-rest_run-01_m1.png');
saveas(gcf, fullfile(Path2Plots, save_FC_plot));


% figure for FC session 2
figure('Color','w');
imagesc(FC_3D_ses2.FC_3D(labels(:,1), labels(:,1)));
caxis([-0.8 0.8]);
axis square;

colormap(MyList);
cb = colorbar;
cb.Color = [0.2 0.2 0.2];
cb.FontSize = 11;
cb.LineWidth = 1;

% Labels and title
title('Functional Connectivity Matrix', ...
      'FontSize',16, ...
      'FontWeight','normal');

xlabel('Schaefer 400 ROIs', ...
       'FontSize',13);

% For a cleaner appearance
set(gca, ...
    'FontSize',11, ...
    'LineWidth',1, ...
    'TickDir','out', ...
    'Box','off');

save_FC_plot = sprintf('Schaefer400_FC-plot_sub-001_ses-02_task-rest_run-01_m1.png');
saveas(gcf, fullfile(Path2Plots, save_FC_plot));


%% ICC figure
ICC_2D_mat = zeros(N, N);
mask_ut = triu(true(N), 1);
ICC_3D = load('S400_ICC_3D.mat').ICC_3D_all;
ICC_2D = ICC_3D.ICC_3D_all(:, 2, 1); % 2 = ICC computed on ses1-2
ICC_2D_mat(mask_ut) = ICC_2D;
ICC_2D_mat = ICC_2D_mat + ICC_2D_mat';

figure;
imagesc(ICC_2D_mat(labels(:, 1), labels(:,1)));
caxis([-0.8 0.8]);
axis square; colormap(MyList);
colorbar;
title('Intraclass Correlation Coefficient (ICC)', ...
      'FontSize',14, ...
      'FontWeight','normal');
xlabel('Schaefer 400 ROIs', ...
       'FontSize',11);
figname = sprintf('S400_ICC.svg');
saveas(gcf, fullfile(Path2Plots, figname));


%% Average ICC over time
% plot for Schaefer 100
Path2results = 'Schaefer100\results';
load(fullfile(Path2results, "S100_ICC_3D.mat"));
mean_ICC = mean(ICC_3D_all);
mean_ICC = squeeze(mean_ICC);
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

h = gobjects(n_mod,1);   % preallocate handles

for mod = 1:n_mod
    thisColor = ColorList(mod,:);

    % thick lines
    h(mod) = plot(ax, x, mean_ICC(2:10,mod), '-', ...
        'LineWidth',6.0, ...
        'Color',thisColor);

    % large scatter markers
    scatter(ax, x, mean_ICC(2:10,mod), ...
        180, thisColor, 'filled');
end

xlabel(ax,'Sessions','FontSize',30);
ylabel(ax,'Average ICC','FontSize',28);
xlim(ax, [1 9]);      
xticks(ax, 1:9);      
ylim(ax,[0.3 0.55]);

box(ax,'on');
grid(ax,'on');
print('-dpng','-r300');


% plot for Schaefer 400
Path2results = 'Schaefer400\results';
load(fullfile(Path2results, "S400_ICC_avg.mat"));
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

h = gobjects(n_mod,1);   % preallocate handles

for mod = 1:n_mod
    thisColor = ColorList(mod,:);

    % thick lines
    h(mod) = plot(ax, x, mean_ICC(2:10,mod), '-', ...
        'LineWidth',6.0, ...
        'Color',thisColor);

    % large scatter markers
    scatter(ax, x, mean_ICC(2:10,mod), ...
        180, thisColor, 'filled');
end

xlabel(ax,'Sessions','FontSize',30);
ylabel(ax,'Average ICC','FontSize',28);
xlim(ax, [1 9]);      
xticks(ax, 1:9);      
ylim(ax,[0.3 0.55]);

box(ax,'on');
grid(ax,'on');
print('-dpng','-r300');


% plot for Schaefer 1000
Path2results = 'Schaefer1000\figures';
load(fullfile(Path2results, "S1000_ICC_3D.mat"));
mean_ICC = mean(ICC_3D_all);
mean_ICC = squeeze(mean_ICC);
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

h = gobjects(n_mod,1);   % preallocate handles

for mod = 1:n_mod
    thisColor = ColorList(mod,:);

    % thick lines
    h(mod) = plot(ax, x, mean_ICC(2:10,mod), '-', ...
        'LineWidth',6.0, ...
        'Color',thisColor);

    % large scatter markers
    scatter(ax, x, mean_ICC(2:10,mod), ...
        180, thisColor, 'filled');
end

xlabel(ax,'Sessions','FontSize',30);
ylabel(ax,'Average ICC','FontSize',28);
xlim(ax, [1 9]);       
xticks(ax, 1:9);      
ylim(ax,[0.3 0.55]);

box(ax,'on');
grid(ax,'on');
print('-dpng','-r300');


%% Schaefer 400 thresholded ICC matrices
% ICC binary masks plotted together
dataDir = 'Schaefer400\results';
ICC_3D = load(fullfile(dataDir, "S400_ICC_3D.mat"));
n_ses = 10;
n_mod = 8;
n = 10;
N = size(labels, 1);
mask_ut = triu(true(N), 1);
numEdges = sum(sum(mask_ut==1));
binary_mask = zeros(numEdges, n_ses, n_mod);

for mod = 1:n_mod
    for ses = 2:n_ses
        temp_ICC = [];
        temp_ICC = ICC_3D.ICC_3D_all(:, ses, mod);
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

    subplot(2, 4, mod);
    imagesc(binary_matrix(labels(:,1), labels(:,1)));
    caxis([0 9]);
    axis square; colormap(MyList);
    set(gca, 'XTick', [], 'YTick', []);
    ylabel('');
    xlabel(sprintf(' denoising model %d', mod), FontSize=8); 
end
figname = sprintf('S400_ICC_bin.svg');
saveas(gcf, fullfile(Path2Plots, figname));
close;


%% Schaefer 400 ICC matrices model 1 and 7, session 1-2 & 1-6 & 1-10
% figure on the center-left of the poster
% model 1: motion denoised
% session 1-2
plot_A = ICC_3D(:, 2, 1);

% session 1-6
plot_B = ICC_3D(:, 6, 1);

% session 1-10
plot_C = ICC_3D(:, 10, 1);


% model 7: physiologically denoised
% session 1-2
plot_I = ICC_3D(:, 2, 7);

% session 1-6
plot_II = ICC_3D(:, 6, 7);

% session 1-10
plot_III = ICC_3D(:, 10, 7);



%% plot session 1-2
% then I recycled the code for 1-6 and 1-10 changing the first two rows
% Threshold each vector
mask_A = plot_A > prctile(plot_A,95);
mask_I = plot_I > prctile(plot_I,95);

% Reconstruct matrices
mat_C = zeros(N,N);
mat_III = zeros(N,N);

mat_C(mask_ut) = mask_A;
mat_III(mask_ut) = mask_I;

mat_C = mat_C + mat_C';
mat_III = mat_III + mat_III';

% Combined matrix
combined_mat = zeros(N,N);

combined_mat(mat_C==1 & mat_III==0) = 1; % A only
combined_mat(mat_C==0 & mat_III==1) = 2; % I only
combined_mat(mat_C==1 & mat_III==1) = 3; % overlap

% Plot
figure('Color','w');
set(gcf,'Position',[100 100 1100 800]);

imagesc(combined_mat(labels(:,1),labels(:,1)));
axis square;
set(gca,'XTick',[],'YTick',[]);

% Custom colormap:
% white = none
% red   = A only
% blue  = I only
% purple= overlap
colormap([
    1 1 1;      % 0
    1 0 0;      % 1 (A)
    0 0 1;      % 2 (I)
    0.7 0 0.7   % 3 (overlap)
]);

caxis([0 3]);
colorbar('Ticks',[0 1 2 3], ...
         'TickLabels',{'None','A','I','A & I'});
