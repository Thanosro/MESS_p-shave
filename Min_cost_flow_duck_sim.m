% min cost flow for graph Gd for NO_MESS number of mess
cost_v = Gd.Edges.Costs';
NO_MESS = 6;
tic;
cvx_begin quiet
cvx_solver gurobi
variable fl(numedges(Gd),1)  %integer
% maximize sum(cost_v*fl)
minimize cost_v*fl
subject to 
    incidence(Gd)*fl == [zeros(numnodes(Gd)-2,1); -NO_MESS; NO_MESS];
    0 <= fl <= Gd.Edges.Capacities;
cvx_end
toc;
[fl cost_v'];
disp(['Total cost reduction with MESS: ',num2str(cost_v*fl)])
%%
highlight(h1,'Edges',find(fl>0),'EdgeColor','r','LineWidth',1.5)
title(['LA Micro-grids Case Study: Min Cost Flow',newline,'No of Mess ',num2str(NO_MESS)...
    ,newline,'Dist. Fac: ',num2str(reloc_factor)])
% title(['',newline,num2str(cost_v*fl)])
xlabel(['Days',newline,'Benefit: ',num2str(abs(cost_v*fl))])
set(gca,'YTick',[])
set(gca,'XTick',[])
%--------------------------------------------
% highlight(h1,'Edges',find(fl>0),'EdgeColor','r','LineWidth',3.5)
% title(['',newline,num2str(cost_v*fl)])
% xlabel(['Days',newline,'Benefit: ',num2str(abs(cost_v*fl))])