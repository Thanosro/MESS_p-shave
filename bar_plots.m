%% peak shave dataset
load 10MESS_200rf.mat
disp(str_10MESS_200rf)
%%
reloc_array = linspace(0,2,201);
%%
% number of mess in the plot
% no_mess_pl = 4:6;
no_mess_pl = [4 5 8];
figure(2020+randi(400,1))
% plot(reloc_array,perc_gain_mat(:,no_mess_pl))
reloc_ind = [0.15 0.35 0.75 1.0 1.35];
bar(reloc_ind,perc_gain_mat(reloc_ind*100,no_mess_pl));
set(gca, 'XTick', (reloc_ind))
% set(gca,'YGrid','on','LineWidth',1.5)
set(gca,'YGrid','on')
% set(gca, 'XTickLabel', {num2str(reloc_ind(1)),num2str(reloc_ind(2)),num2str(reloc_ind(3))})
% xticks(h_bar,reloc_ind*100)
% xticklabels(h_bar,{num2str(reloc_ind)})
% title(['Gain percentage',newline,'No of MESS: ',num2str(NO_MESS)])
xlabel('Relocation Factor')
ylabel("Percentage (%)")
% ylim([0.9 3.1])
% xlim([0 200])
h_leg = legend('show');
title(h_leg,'No of MESS')
% legend(num2str(no_mess_pl))
% legend('-DynamicLegend','DisplayName',num2str(no_mess_pl))
legend({num2str(no_mess_pl(1)),num2str(no_mess_pl(2)),num2str(no_mess_pl(3))},'Location','north')
%%
% print('bar_peak_shave','-dpng','-r0')
print('bar_peak_shave','-depsc','-r300')

%%
close all