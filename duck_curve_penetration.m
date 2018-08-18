%% DUCK CURVE FIGURE for different solar penetration
load solar_data.mat
disp(str2)
%%
load month_data.mat
%%
% solar penetration percentage
% pen_per = fliplr([0 0.2 0.4 0.6 0.7]);% 0.9]);
pen_per = [0 0.2 0.4 0.6 0.7];
figure(600)
for i_pen = 1:length(pen_per)
% Load scale to 1 MW factor
MW_scale = 1;
day_no = 15; % day of the month
% solar scale to 0.8 MW
% Sol_scale = (mean(solar_data((day_no),:)))*MW_scale;
micro_grid_index = 4;
% load array for day_no for micro_grid_index
Lt_day =MW_scale*monthly_norm_data.Jul((day_no)*24:(day_no+1)*24-1,micro_grid_index);
% solar array for day_no (days are the rows in solar_data array)
Sol_scale = (pen_per(i_pen)/max(solar_data((day_no),:)))*MW_scale;
% penetration with mean --------------------------
% solar_day_init = solar_data((day_no),:);
% Sol_scale1 = mean(solar_day_init(6:20))/mean(Lt_day);
% Sol_scale = pen_per(i_pen)/Sol_scale1
% solar_day = Sol_scale*solar_data((day_no),:);
% ---------------------------
solar_day = Sol_scale*solar_day_init;
% Net load is load - solar
Net_load = Lt_day-solar_day';
plot(Net_load)
hold on
% set(gca, 'XTick', (reloc_ind))
% set(gca,'YGrid','on','LineWidth',1.5)
% set(gca, 'XTickLabel', {num2str(reloc_ind(1)),num2str(reloc_ind(2)),num2str(reloc_ind(3))})
% xticks(h_bar,reloc_ind*100)
% xticklabels(h_bar,{num2str(reloc_ind)})
% title(['Gain percentage',newline,'No of MESS: ',num2str(NO_MESS)])
end
title('Duck Curve for Increase Solar Penetration')
set(gca,'YGrid','on')
xlabel('Time (hours)')
ylabel("Net Load (MW)")
h_leg = legend('show');
title(h_leg,'% Penetration')
xlim([1 24])
legend(string(100*pen_per),'Location','southwest')
%% change the name before resaving
% print('duck_curve_pen','-depsc','-r300')