% MATLAB Program to solve Identification of Conforming loads using ACO
% Coded by Divya M as a part of EE768 Course Project
clc; clear;
% INPUT parameters
%C = xlsread('sample_data.xlsx'); % excel sheet containing n customers and t demands 
C1 = xlsread('annual_average_load_total_load.xlsx');
C = [C1(1,:); C1(4,:); C1(12,:); C1(127,:); C1(168,:); C1(219,:); C1(252,:); C1(305,:); C1(313,:); 
    C1(324,:); C1(326,:); C1(328,:); C1(352,:); C1(371,:); C1(395,:); C1(427,:); C1(462,:); 
    C1(463,:); C1(496,:); C1(505,:); C1(515,:); C1(518,:); C1(535,:); C1(539,:); C1(567,:); 
    C1(589,:); C1(655,:); C1(661,:); C1(664,:); C1(709,:)];
sizeof_C = size(C);

%Tuning parameters
n = sizeof_C(1); %Number of towns
Nc_max	= 5;  % Maximum number of iterations
alpha	= 0.5;	% Parameter representing the importance of trail
beta	= 10;	% Parameter representing the importance of visibility
rho		= 0.05;	% Evaporation
Q		= 100;	% A constant
m		= (n-1); % Number of ants
t       =sizeof_C(2); % time data size

% Calculation of the ddiversity factor dij
D		= ones(n,n);	% Initializing the Diversity_factor array
for i = 1:n
    num1 = max(C(i,:));
    for j = 1:n
        if i<j
            for k = 1:t
            den1(k)=C(i,k)+C(j,k);                
            end
            den = max(den1);
            num2 = max(C(j,:));
            num = num1+num2;
            div =num/den;
            D(i,j) = num/den;
        end
        D(j,i)			= D(i,j);
    end
end

eta				= 1./D;        % Visibility -which says that lower diversity factors should be chosen with high probability
pheromone = eta; % Initializing the pheromeone array
tabu_list		= zeros(m,n);	% List of customers already visited
Nc				= 0;			% Beginning of iteration
routh_best		= zeros(Nc_max,n);
length_best		= ones(Nc_max,1);
length_average	= ones(Nc_max,1);

% Start of iterations
while Nc<Nc_max
    tabu_list(:,1)		= ones;
    rand_position		= [];
    for i=1:ceil(m/(n-1))                   %
        rand_position	= [rand_position,randperm(m)]; % randperm(n) returns a random permutation of the integers 1:n.  
    end
    tabu_list(:,2)		= (rand_position(1:m)+1)';
    
    %pheromone					= (1-rho).*pheromone+rho;

    for j=3:n
        for i=1:m
            customer_visited	= tabu_list(i,1:(j-1));
            customer_remained	= zeros(1,(n-j+1));
            probability		= customer_remained;
            cr				= 1;
            for k=1:n
                if length(find(customer_visited==k))==0
                    customer_remained(cr)	= k;
                    cr					= cr+1;
                end
            end
            for k=1:length(customer_remained)
                probability(k) 	= ((pheromone(customer_visited(end),customer_remained(k)))^alpha)*((eta(customer_visited(end),customer_remained(k)))^beta);
            end
            probability			= probability/sum(probability);
            pcum				= cumsum(probability);
            select				= find(pcum>= rand);
            if numel(select)==0
            to_visit			= customer_remained(1);
            else   
            to_visit			= customer_remained(select(1));
            end
            tabu_list(i,j)		= to_visit;
        end
            %pheromone					= (1-rho).*pheromone+rho;
        
    end
    if Nc>0
        tabu_list(1,:)			= routh_best(Nc,:); 
    end
   
    total_length				= zeros(m,1);
    for i=1:m
        r						= tabu_list(i,:);
        for j=1:(n-1)
            total_length(i)		= total_length(i)+D(r(j),r(j+1));
        end
        end
    length_best(Nc+1)			= min(total_length);
    position					= find(total_length==length_best(Nc+1));
    routh_best(Nc+1,:)			= tabu_list(position(1),:);
    length_average(Nc+1)		= mean(total_length);
    Nc							= Nc+1;
    delta_pheromone				= zeros(n,n);
    for i=1:m
        for j=1:(n-1)
            delta_pheromone(tabu_list(i,j),tabu_list(i,j+1))	= delta_pheromone(tabu_list(i,j),tabu_list(i,j+1))+Q/total_length(i);
        end
        delta_pheromone(tabu_list(i,n),tabu_list(i,1))			= delta_pheromone(tabu_list(i,n),tabu_list(i,1))+Q/total_length(i);
    end
    pheromone					= (1-rho).*pheromone+delta_pheromone;
    tabu_list					= zeros(m,n);
end

position		= find(length_best==min(length_best));
shortest_path	= routh_best(position(1),:)
shortest_length	= length_best(position(1))

Data=C1;
total_load_normalized = Data(1,:);
x_axis = [1:48];
figure(1)
set(gcf,'Name','Ant Colony Optimization¡ª¡ªFigure of length_best and length_average')
plot(length_best,'ro')
hold on
plot(length_average,'k','LineWidth',2)
xlabel('No. of iterations')
ylabel('Distance')
legend('Minimum distance','Average distance travelled');

figure(2)
set(gcf,'Name','Examples of Conforming Loads-correlation','Color','w')
plot(x_axis,Data(352,:),'r','LineWidth',3)   
hold on;
plot(x_axis,Data(462,:),'b','LineWidth',3)
hold on;
plot(x_axis,Data(567,:),'c','LineWidth',4)
hold on;
plot(x_axis,Data(655,:),'m','LineWidth',3)   
hold on;
plot(x_axis,Data(371,:),'g','LineWidth',4)
hold on;
plot(x_axis,total_load_normalized,'k','LineWidth',3)
hold on;
title('Some conforming loads- Concept of Correlation');
hold on;
xlabel('TIME')
ylabel('LOAD')
legend('Customer351','Customer461','Customer566','Customer654','Customer370','Total load_normalized');

figure(3)
set(gcf,'Name','Examples of Conforming Loads-difference method','Color','w')
plot(x_axis,Data(168,:),'r','LineWidth',3)   
hold on;
plot(x_axis,Data(709,:),'b','LineWidth',3)
hold on;
plot(x_axis,Data(505,:),'c','LineWidth',4)
hold on;
plot(x_axis,Data(127,:),'m','LineWidth',3)   
hold on;
plot(x_axis,Data(324,:),'g','LineWidth',4)
hold on;
plot(x_axis,total_load_normalized,'k--','LineWidth',3)
hold on;
title('Some conforming loads- Concept of Difference method');
hold on;
xlabel('TIME')
ylabel('LOAD')
legend('Customer167','Customer708','Customer504','Customer126','Customer323','Total load_normalized');

figure(4)
set(gcf,'Name','Examples of Conforming Loads-ACO','Color','w')
plot(x_axis,Data(127,:),'r','LineWidth',3)   
hold on;
plot(x_axis,Data(168,:),'b','LineWidth',3)
hold on;
plot(x_axis,Data(324,:),'c','LineWidth',4)   
hold on;
plot(x_axis,Data(326,:),'m','LineWidth',3)
hold on;
plot(x_axis,Data(505,:),'g','LineWidth',4)
hold on;
plot(x_axis,total_load_normalized,'k--','LineWidth',3)
hold on;
title('Some conforming loads- Concept of Optimization using ACO');
hold on;
xlabel('TIME')
ylabel('LOAD')
legend('Customer126','Customer167','Customer323','Customer325','Customer504','Total load_normalized');

