% MATLAB Program to solve NILM using ACO
% Coded by Divya M as a part of EE768 Course Project
clc; clear;
% INPUT parameters
% Smart meter data
%C       = [6 10 5 15 11 7];
C = [210 290 150 420 290];
devices = [1 10; 2 50; 3 90; 4 120; 5 150];
%devices = [1 1; 2 2; 3 3; 4 4; 5 5]; % row corresponds to device numbers and columns corresponds to device power levels
size_device = size(devices,1);
device_power = devices(:,2)';
m       = 5;     % Number of ants should be same as no. of possible devices
Nc_max	= 5;    % Maximum number of iterations
alpha	= 0.5;	% Parameter representing the importance of trail
beta	= 5;	% Parameter representing the importance of visibility
rho		= 0.5;	% Evaporation
Q		= 1;	% A constant
n		= 5;    % Time intervals

soution = zeros(n,m);
 for iter_time = 1:5  %size(C,2)
    eta				= zeros(m,m);   % Visibility 
    eta(:,:) = 0.05;
    VEC = device_power;
    NUM = C(iter_time);
    n = length(VEC);
    finans = zeros(2^n-1,NUM);
    j=1;
    a1=[];
    for i = 1:(2^n - 1)
        ndx = dec2bin(i,n) == '1';
        if sum(VEC(ndx)) == NUM
            l = length(VEC(ndx));
            if size(a1,2)<l
                a1(:,l) = 0;
            end
            a1(j,:)=VEC(ndx);
            j=j+1;
        end
    end
    %a1
    sizeof_a1=size(a1);
    a = zeros(sizeof_a1(1),sizeof_a1(2));
    for i = 1:sizeof_a1(1)
        for j= 1:sizeof_a1(2)
            if a1(i,j)==10
                a(i,j)=1;
            elseif a1(i,j)==50
                a(i,j)=2;
            elseif a1(i,j)==90
                a(i,j)=3;
            elseif a1(i,j)==120
                a(i,j)=4;
            elseif a1(i,j)==150
                a(i,j)=5;
            end
        end
    end
        %a
    for i = 1:size(a,1)
        b1 = find(a(i,:)==0);
        if b1>0
            x = b1(1)-1;
        else
            x= size(a,2);
        end
        for j1 = 1:x-1
            for j2 = j1+1 :x
                eta(a(i,j1),a(i,j2)) = 1;
                eta(a(i,j2),a(i,j1)) =1;
             end
        end
         %eta
    end
    pheromone		= ones(m,m);	% Initializing the pheromeone array
    tabu_list		= zeros(m,m);	% List of devices already visited (barred from visiting this town till next iteration)
    Nc				= 0;			% Beginning of iteration
    rand_position		= [];
    for i=1:ceil(m/m)                   %
        rand_position	= [rand_position,randperm(m)]; % randperm(m) returns a random permutation of the integers 1:m.  
    end 
    tabu_list(:,1)		= (rand_position(1:m))';
    %tabu_list
    for i1 = 1:m
        ant_power(i1) = device_power(tabu_list(i1,1));
    end 
    %ant_power
    while Nc<Nc_max
        for i2 = 1:m
            for i3 = 2:size_device
                %device = i3
                if (ant_power(i2)< C(iter_time))
                    device_considered	= tabu_list(i2,1:(i3-1));
                    device_remained	= zeros(1,(size_device-i3+1));
                    probability		= device_remained;
                    cr				= 1;
                     
                    for i4=1:m
                        if length(find(device_considered==i4))==0
                            device_remained(cr)	= i4;
                            cr					= cr+1;
                        end %if
                    end %i4
                    for i5=1:length(device_remained)
                        probability(i5) 	= (pheromone(device_considered(end),device_remained(i5)))^alpha*(eta(device_considered(end),device_remained(i5)))^beta;
                    end
                    probability			= probability/sum(probability);
                    pcum				= cumsum(probability);
                    select				= find(pcum>= rand);
                    to_visit			= device_remained(select(1));
                    tabu_list(i2,i3)		= to_visit;
                    %tabu_list
                    ant_power(i2) = ant_power(i2)+device_power(tabu_list(i2,i3));
                    %ant_power 
                end
            end
            %end
        end
        delta_pheromone				= zeros(m,m);
        constraint1 = zeros(5,1);
        for i =1:m
            y1 = find(tabu_list(i,:)==0);
            if y1>0
                y = y1(1);
            else
                y = m;
            end
            for  j =1:y-1
                constraint1(i) = constraint1(i) +device_power(tabu_list(i,j));
            end
            constraint_error(i) = abs(6-constraint1(i))+0.25;
            for j=1:(y-2)
                delta_pheromone(tabu_list(i,j),tabu_list(i,j+1))	= delta_pheromone(tabu_list(i,j),tabu_list(i,j+1))+Q/constraint_error(i);
            end            
        end 
        pheromone					= (1-rho).*pheromone+delta_pheromone;
        %tabu_list
        Nc=Nc+1;
    end 
    p2 = min(ant_power);
    p3 = find(ant_power ==p2);        
    solution(iter_time,:)=tabu_list(p3(1),:);
 end %iter_time
 C
 solution
 d1=zeros(1,5);
 d2=zeros(1,5);
 d3=zeros(1,5);
 d4=zeros(1,5);
 d5=zeros(1,5);
 p1=zeros(1,5);
 p2=zeros(1,5);
 p3=zeros(1,5);
 p4=zeros(1,5);
 p5=zeros(1,5);
 
 for i = 1:5
     for j = 1:5
         if find(solution(j,i)==1)
             d1(j)=1;
             p1(j)=10;
         elseif find(solution(j,i)==2)
             d2(j)=2;
             p2(j)=50;
             elseif find(solution(j,i)==3)
             d3(j)=3;
             p3(j)=90;
             elseif find(solution(j,i)==4)
             d4(j)=4;
             p4(j)=120;
             elseif find(solution(j,i)==5)
             d5(j)=5;
             p5(j)=150;
         end
     end
 end
         
 t = [1:5];
 
figure(1)
set(gcf,'Name','NILM using ACO- DEVICE POWER CONSUMPTIONS')
bar(t,C,'k','LineWidth',2)
hold on
bar(t,p5,'r','LineWidth',2)
hold on
bar(t,p4,'b','LineWidth',2)
hold on
bar(t,p3,'g','LineWidth',2)
hold on
bar(t,p2,'m','LineWidth',2)
hold on
bar(t,p1,'y','LineWidth',2)
hold on
xlabel('TIME')
ylabel('POWER(W)')
title('NILM using ACO-Device Power Consumptions');
legend('Smart meter data','Device5','Device4','Device3','Device2','Device1');

figure(2)
set(gcf,'Name','NILM using ACO- DEVICES')
bar(t,d5,'r','LineWidth',2)
hold on
bar(t,d4,'b','LineWidth',2)
hold on
bar(t,d3,'g','LineWidth',2)
hold on
bar(t,d2,'m','LineWidth',2)
hold on
bar(t,d1,'y','LineWidth',2)
hold on
axis([0 6 0 6])
xlabel('TIME')
ylabel('DEVICES')
title('NILM using ACO-Devices');
legend('Device5','Device4','Device3','Device2','Device1');
       
     