% Generate graph for Optimal Scheduling of J types of K MESS in M
% micro-grids in D days
% mg = 3; 
days =7; % number of days
% # of MESS types
NO_MESS_TYPES = size(MESS_mat,2); % 5 types of MESS
mg = 10;% 10 micro grids
%% contains cost benefits, mg days MESS_mat 
load('10mg_5MESS_7days2.mat')
%% transfer cost matrix for variable mg
%     base_reloc_cost =1;
%     reloc_mat =tril(randi(4,mg));
%     reloc_mat = tril(reloc_mat);
%     reloc_mat =  base_reloc_cost*(reloc_mat+triu(reloc_mat',1));
%% transfer cost matriix for fixed mg = 10
% USC LAX UCLA UC Irv. Long Beach Port UC Riv. Disn. Cal-State LB CalTech
% Univ. City
% mg = 10;
LA_dist = [0 15.0 13.2 43.2 26.9 59.7 28.7 26.5 13.7 10.4; %USC
           0 0.00 10.4 41.6 23.3 71.4 34.5 27.6 25.9 25.5; %LAX
           0 0.00 0.00 50.8 32.7 69.7 42.5 34.9 25.3 16.3; %UCLA
           0 0.00 0.00 0.00 33.7 50.1 14.6 19.2 50.8 51.9; %UC Irv
           0 0.00 0.00 0.00 0.00 66.1 22.1 8.20 36.4 39.0; %Long Beach Port
           0 0.00 0.00 0.00 0.00 0.00 41.4 54.9 52.2 66.4; %UC Riv
           0 0.00 0.00 0.00 0.00 0.00 0.00 13.7 41.1 36.6; %Disneyland
           0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 31.1 35.5; %Cal-State LB
           0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 14.4; %CalTech
           0 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00 0.00]; %Univ. City
LA_dist =  LA_dist+LA_dist';
% per mile cost for 2018
% cost_per_mile = 0.01370*2018 - 25.94; for year 2018
cost_per_mile = 1.7066;
LA_cost = 1.33*LA_dist*cost_per_mile+0.1*eye(mg);
%%
% A0 = [eye(mg) zeros(mg);zeros(mg) reloc_mat];
A0 = [eye(mg) zeros(mg);zeros(mg) LA_cost];
AD0 = kron(eye(days-1),A0);
% spy(AD0)
AD1 = blkdiag(AD0,eye(mg));
AD2 = [zeros((days-1)*2*mg+mg,mg) AD1; zeros(mg) zeros(mg,(days-1)*2*mg+mg)];
% spy(AD2)
G0 = digraph(AD2);
% initial number of edges
init_edges = numedges(G0);
G0 = addnode(G0,{'S*'});
G0 = addnode(G0,{'T*'});
Ed_S0 = table([(2*mg*days+1)*ones(mg,1) (1:mg)'],ones(mg,1),'VariableNames',{'EndNodes','Weight'});
Ed_T0 = table([ ((2*mg*days-mg+1):(2*mg*days))' (2*mg*days+2)*ones(mg,1)],ones(mg,1),'VariableNames',{'EndNodes','Weight'});
G0 = addedge(G0,Ed_S0);
G0 = addedge(G0,Ed_T0);
redo = 0;
%% array with benefits / cost reductions from each mess
    % ben_arr = 9:NO_MESS_TYPES-1+9
%% multiple edges 
% % avoid to run code two times and add twice the no of edges
% assert(redo<1,'Code ran twice')
% % reshape array to find the add nodes indices
% resh_1 = reshape(1:mg*days*2,mg,[]);
% % resh_1 = repmat(resh_1,NO_MESS_TYPES,1)
% % add_edge_ind = sort(reshape(resh_1',2,[])');
% add_edge_ind = reshape(resh_1',2,[])';
% add_edge_ind_rep = repelem(add_edge_ind,NO_MESS_TYPES-1,1);
% add_edge_table = table(add_edge_ind_rep,[ones(length(add_edge_ind_rep),1)],...
%     'VariableNames',{'EndNodes','Weight'});
% G0 = addedge(G0,add_edge_table);
% redo = redo +1;
%% add edges costs and capacities 
G0.Edges.Labels = (1:numedges(G0))';
G0.Edges.Capacities = ones(numedges(G0),1);
%---------------------------
% costs from S and T are 0
G0.Edges.Costs = G0.Edges.Weight;
G0.Edges.Costs((numedges(G0)-2*mg+1):numedges(G0)) = 0;
%-----------------------------
% reloc costs to the same micro-grid are same
G0.Edges.Costs(G0.Edges.Weight == 0.1) = 0;
mes_cnt = 0;
%% assign the benefit costs
MESS_TYPE = 5;
if mes_cnt <1
% find the costs that are equal to 1 
    mg_MESS_indx = find(G0.Edges.Costs == 1);
end
% reshape the index matrix to match the dims of the ben cost mat
mg_MESS_indx_rshp = reshape(ben_cost_mat(:,MESS_TYPE,:),mg,[]);
% assign the values to the Go.Edges.Costs
G0.Edges.Costs(mg_MESS_indx) = ben_cost_mat(:,MESS_TYPE,:);
length(mg_MESS_indx)
mes_cnt = mes_cnt+1;
%%
% reshape(ben_cost_mat(:,MESS_TYPE,:),mg,[])
% reshape(mg_MESS_indx,mg,[])

%% 
G0.Edges.Weight = G0.Edges.Costs;
%% the index for each edge for each MESS type is
    % tic % too long with for loops
    % for MESS_NO = 1:NO_MESS_TYPES% = 2;%,2,3 for MESS number 1, 2, etc
    % % (0:days-1)*(mg*(mg+NO_MESS_TYPES)) + MESS_NO;
    %     for mess_ind = MESS_NO : NO_MESS_TYPES :mg*NO_MESS_TYPES
    %         (0:days-1)*(mg*(mg+NO_MESS_TYPES)) + mess_ind;
    %         highlight(h1,'Edges',[ans],'EdgeColor','r','LineWidth',1.5)
    %     end
    % end
    % toc
%% indexing for each mg for each day for each MESS type
    % MESS_NO = 5;
    % mess_index_mat = zeros(NO_MESS_TYPES,mg,days);
    % % mess_resh(:) = = reshape(mess_index_mat,[],1,1);
    % mess_resh(:) = 1:length(mess_resh);
    % % mess_index_mat = [MESS_NO:NO_MESS_TYPES:mg*NO_MESS_TYPES] 
    % % highlight(h1,'Edges',mess_index_mat,'EdgeColor','r','LineWidth',1.5)
%%
%     % no of edges w/o the ones in S and T numedges(G0)-2*mg
%     no_main_edges = numedges(G0)-2*mg;
%     % mess_index_mat = 1:no_main_edges
%     mess_index_mat = reshape(1:no_main_edges,mg*NO_MESS_TYPES,[])
%     ((mg*NO_MESS_TYPES+1):mg*mg:no_main_edges)
%     % mess_index_mat = reshape(1:no_main_edges,mg*NO_MESS_TYPES,[]);
%     % mess_index_mat = mess_index_mat(:,1:3:size(mess_index_mat,2))
%     % MESS_NO:2*mg*NO_MESS_TYPES:no_main_edges
%% permute 3d array dimensions if needed
%     ben_cost_mat_perm = permute(ben_cost_mat,[2 1 3]);
%     size(ben_cost_mat_perm)
%     cost_no_stor_mat_perm = permute(cost_no_stor_mat,[2 1 3]);
%     size(cost_no_stor_mat_perm)
%     cost_w_stor_mat_perm = permute(cost_w_stor_mat,[2 1 3]);
%     size(cost_w_stor_mat_perm)
%%
figure(518)
% fullscreen figure
% figure('units','normalized','outerposition',[0 0 1 1])
h1 =plot(G0,'EdgeLabel',G0.Edges.Costs);
% title(['LA Micro-grids Case Study',newline,'No of Mess ',num2str(NO_MESS_TYPES)])
title(['LA Micro-grids Case Study: Min Cost Flow',newline,'No of Mess ',num2str(NO_MESS_TYPES)])
layout(h1,'layered','Direction','right','Sources', 'S*','Sinks','T*')
highlight(h1,'Edges',1:numedges(G0),'LineWidth',1.5)
% highlight(h1,'Edges',findedge(G0,add_edge_ind(:,1),add_edge_ind(:,2)),'EdgeColor','r','LineWidth',1.5)
highlight(h1,1:numnodes(G0),'MarkerSize',4,'NodeColor','r')
micro_names ={"USC" "LAX" "UCLA" 'UC Irv.' 'LB Port' 'UC Riv.' 'Disneyland'....
    'Cal-State LB' 'CalTech' 'Univ. City'};
set(gca, 'Ytick',1:mg,'YTickLabel',micro_names);
% test hightlight edges
% highlight(h1,'Edges',[ans],'EdgeColor','r','LineWidth',1.5)
% highlight(h1,'Edges',[1:NO_MESS_TYPES:6],'EdgeColor','r','LineWidth',1.5)
%------------ commands to make the figure pretty------- 
% xd = get(h1, 'XData');
% yd = get(h1, 'YData');
% set(gca,'YTick',[])
% set(gca,'XTick',[])
% set(gca,'Visible','off')
% ax = gca;
% outerpos = ax.OuterPosition;
% ti = ax.TightInset; 
% left = outerpos(1) + ti(1);
% bottom = outerpos(2) + ti(2);
% ax_width = outerpos(3) - ti(1) - ti(3);
% ax_height = outerpos(4) - ti(2) - ti(4);
% ax.Position = [left bottom ax_width ax_height];
% 
% box off
% xlabel('(b)')
% labelnode(h1,[1:numnodes(G0)],'')
% highlight(h1,[1:numnodes(G0)]' ,'NodeColor','r','MarkerSize',6)