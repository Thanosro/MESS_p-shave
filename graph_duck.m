% Generate graph for Optimal Scheduling of J types of K MESS in M
days =7; % number of days
% # of MESS types
% NO_MESS_TYPES = 10;
mg = 10;% 10 micro grids
%% contains cost benefits, mg days MESS_mat 
% clear NO_MESS_TYPES
load('10mg_7days_duck.mat')
% gain_duck

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
reloc_factor = 1;
LA_cost = reloc_factor*LA_dist*cost_per_mile+0.1*eye(mg);
%%
% A0 = [eye(mg) zeros(mg);zeros(mg) reloc_mat];
A0 = [eye(mg) zeros(mg);zeros(mg) LA_cost];
AD0 = kron(eye(days-1),A0);
% spy(AD0)
AD1 = blkdiag(AD0,eye(mg));
AD2 = [zeros((days-1)*2*mg+mg,mg) AD1; zeros(mg) zeros(mg,(days-1)*2*mg+mg)];
% spy(AD2)
Gd = digraph(AD2);
% initial number of edges
init_edges = numedges(Gd);
Gd = addnode(Gd,{'S*'});
Gd = addnode(Gd,{'T*'});
Ed_S0 = table([(2*mg*days+1)*ones(mg,1) (1:mg)'],ones(mg,1),'VariableNames',{'EndNodes','Weight'});
Ed_T0 = table([ ((2*mg*days-mg+1):(2*mg*days))' (2*mg*days+2)*ones(mg,1)],ones(mg,1),'VariableNames',{'EndNodes','Weight'});
Gd = addedge(Gd,Ed_S0);
Gd = addedge(Gd,Ed_T0);
redo = 0;
%% array with benefits / cost reductions from each mess
gain_duck_rsh = reshape(gain_duck,1,70);
%% add edges costs and capacities 
Gd.Edges.Labels = (1:numedges(Gd))';
Gd.Edges.Capacities = ones(numedges(Gd),1);
%---------------------------
% costs from S and T are 0
Gd.Edges.Costs = Gd.Edges.Weight;
Gd.Edges.Costs((numedges(Gd)-2*mg+1):numedges(Gd)) = 0;
%-----------------------------
% assign the benefits to the edges
Gd.Edges.Costs(Gd.Edges.Costs == 1) = gain_duck_rsh';
Gd.Edges.Costs(Gd.Edges.Costs == 0.1) = 0;
mes_cnt = 0;
%% 
Gd.Edges.Weight = Gd.Edges.Costs;
%% ESS benefits for each micro-grid is the sum of each row of gain_duck matrix
ESS_gain = sum(gain_duck,2);
ESS_assign = maxk(abs(ESS_gain),NO_MESS);
%%
% figure(518+loop_count)
figure(518)
% fullscreen figure
% figure('units','normalized','outerposition',[0 0 1 1])
% plot graph with label -------------------------
% h1 =plot(Gd,'EdgeLabel',Gd.Edges.Costs);
% plot graph without label --------------------
h1 = plot(Gd);
% title(['LA Micro-grids Case Study',newline,'No of Mess ',num2str(NO_MESS_TYPES)])
% title(['LA Micro-grids Case Study: Min Cost Flow',newline,'No of Mess ',num2str(NO_MESS_TYPES)])
layout(h1,'layered','Direction','right','Sources', 'S*','Sinks','T*')
% highlight(h1,'Edges',1:10,'EdgeColor','r')
% highlight(h1,'Edges',findedge(G0,add_edge_ind(:,1),add_edge_ind(:,2)),'EdgeColor','r','LineWidth',1.5)
% highlight(h1,1:numnodes(G0),'MarkerSize',4,'NodeColor','r')
micro_names ={"USC" "LAX" "UCLA" 'UC Irv.' 'LB Port' 'UC Riv.' 'Disneyland'....
    'Cal-State LB' 'CalTech' 'Univ. City'};
set(gca, 'Ytick',1:mg,'YTickLabel',micro_names);
%----------------------------------------
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