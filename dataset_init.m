%% Pre-processing of PJM Load Datasets
cd C:\Users\Thanos\Documents\DeepSolar\BigData\sims\Dataset\zones
%% datasets
micro_grids = string({'hrl_load_metered_RFC_MIDATL_JC_JC.csv'; ...
                'hrl_load_metered_RFC_WEST_ATSI_OE.csv'; ... 
                'hrl_load_metered_RFC_WEST_CE_CE.csv'; ... 
                'hrl_load_metered_RFC_WEST_DEOK_DEOK.csv'; ...
                'hrl_load_metered_RFC_WEST_DUQ_DUQ.csv'; ...
                'hrl_load_metered_RTO_RTO_RTO_RTO.csv'; ...
                'hrl_load_metered_SERC_SOUTH_DOM_DOM.csv'; ...
                'hrl_load_metered_SERC_WEST_EKPC_EKPC.csv'; ...
                'hrl_load_metered_West_AEP_AEPAPT.csv'
    });
%%
micro_grid_array = zeros(8760,length(micro_grids));
for i_read = 1:length(micro_grids)
    micro_grid_array(:,i_read) = import_data(micro_grids(i_read),2,8761)';
end
%% save filename with different name each time to avoid overwrite (with random number)
save('micro_grid_data.mat',['micro_grid_array',num2str(randi(4000,1))])
%% load data
load('micro_grid_data.mat')
%% %% data for each month
month_index = 4;
assert(month_index >= 1 && month_index <= 12,'Not valid month')
hr_ind_end = (sum(eomday(2017, 1:month_index)))*24;
hr_ind_start  = (sum(eomday(2017, 1:month_index-1)))*24+1;
disp(['Data for month ',num2str(month_index)])
%% plot load demand for each month for each micro-grid
micro_grid_index = 3:4;
% assert(micro_grid_index >= 1 && micro_grid_index <= 9,'Not valid micro-grid')
figure(5)
plot(micro_grid_array(hr_ind_start:hr_ind_end,micro_grid_index))
% plot(micro_grid_array(hr_ind_start:hr_day_no_end,micro_grid_index))
title(['Month ',num2str(month_index)])
ylabel('MW')
xlabel('Days')
xlim([0 (hr_ind_end - hr_ind_start+1)])
% ylim([0 744])
xticks(0:5*24:(hr_ind_end - hr_ind_start+1))
xticklabels(0:5:(hr_ind_end - hr_ind_start+1)/24)
%% plot specific number of days after the start of month
no_days = 14;
hr_day_no_end = hr_ind_start+no_days*24;
%% plot load demand for each month for each micro-grid
micro_grid_index = 9;
% assert(micro_grid_index >= 1 && micro_grid_index <= 9,'Not valid micro-grid')
figure(6)
% plot(micro_grid_array(hr_ind_start:hr_ind_end,micro_grid_index))
plot(micro_grid_array(hr_ind_start:hr_day_no_end,micro_grid_index))
title(['Month ',num2str(month_index), ' micro-grid: ',num2str(micro_grid_index)])
ylabel('MW')
xlabel('Days')
xlim([0 no_days*24])
% ylim([0 744])
xticks(0:5*24:no_days*24)
xticklabels(0:5:30)
%% average daily load consumption 
% reshape matrix to 24 and then mean 
%% data for each month
% returns the number of days in each month
mo_days = eomday(2017, 1:12);
% total number of days 
mo_days_tot = cumsum(mo_days);
% total number of hours
hours_tot = mo_days_tot*24;
%% monthly data
Jan_data = micro_grid_array(1:hours_tot(1),:);  
Feb_data = micro_grid_array(hours_tot(1)+1:hours_tot(2),:);
March_data = micro_grid_array(hours_tot(2)+1:hours_tot(3),:);
April_data = micro_grid_array(hours_tot(3)+1:hours_tot(4),:);
May_data = micro_grid_array(hours_tot(4)+1:hours_tot(5),:);
June_data = micro_grid_array(hours_tot(5)+1:hours_tot(6),:);
July_data = micro_grid_array(hours_tot(6)+1:hours_tot(7),:);
Aug_data = micro_grid_array(hours_tot(7)+1:hours_tot(8),:);
Sep_data = micro_grid_array(hours_tot(8)+1:hours_tot(9),:);
Oct_data = micro_grid_array(hours_tot(9)+1:hours_tot(10),:);
Nov_data = micro_grid_array(hours_tot(10)+1:hours_tot(11),:);
Dec_data = micro_grid_array(hours_tot(11)+1:hours_tot(12),:);
%% normalize data
Jan_data_norm = (1./max(Jan_data)).*Jan_data;
Feb_data_norm  = (1./max(Feb_data)).*Feb_data;
March_data_norm  = (1./max(March_data)).*March_data;
April_data_norm  = (1./max(April_data)).*April_data;
May_data_norm  = (1./max(May_data)).*May_data;
June_data_norm  = (1./max(June_data)).*June_data;
July_data_norm = (1./max(July_data)).*July_data;
Aug_data_norm  =  (1./max(Aug_data)).*Aug_data;
Sep_data_norm  = (1./max(Sep_data)).*Sep_data;
Oct_data_norm  = (1./max(Oct_data)).*Oct_data;
Nov_data_norm  = (1./max(Nov_data)).*Nov_data;
Dec_data_norm  = (1./max(Dec_data)).*Dec_data;
%% save in struct
monthly_norm_data.Jan = Jan_data_norm;    
monthly_norm_data.Feb = Feb_data_norm;
monthly_norm_data.Mar = March_data_norm;
monthly_norm_data.Apr = April_data_norm;
monthly_norm_data.May = May_data_norm;
monthly_norm_data.Jun = June_data_norm;
monthly_norm_data.Jul = July_data_norm;
monthly_norm_data.Aug = Aug_data_norm;
monthly_norm_data.Sep = Sep_data_norm;
monthly_norm_data.Oct = Oct_data_norm;
monthly_norm_data.Nov = Nov_data_norm;
monthly_norm_data.Dec = Dec_data_norm;
%%
% save month_data.mat monthly_norm_data
%% plot normalized data
micro_grid_index = 5;
month_norm_index = 2;
assert(month_norm_index >= 1 && month_norm_index <= 12,'Not valid month')
% assert(micro_grid_index >= 1 && micro_grid_index <= 9,'Not valid micro-grid')
figure(7)
% plot(micro_grid_array(hr_ind_start:hr_ind_end,micro_grid_index))
plot(monthly_norm_data.Sep(:,micro_grid_index))
title(['Month ',num2str(month_norm_index), ' micro-grid: ',num2str(micro_grid_index)])
ylabel('MW')
xlabel('Days')
xlim([0 31*24])
ylim([-inf 1.05])
xticks(0:4*24:31*24)
xticklabels(0:4 :31)