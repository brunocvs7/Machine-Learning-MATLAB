clear all 
clc

%%%%%% To read the data %
serie = xlsread('natural_gas.xlsx');
%serie = xlsread('Brasil.xlsx');
   %serie  = xlsread('projetox.xlsx');
%serie = xlsread('petroleo.xlsx');
s = serie';
%load co_p.mat
%s = co_p';
ndec=floor(log10(length(s))); % Choosing the level of decomposition based on the number of observations
[C,L] = wavedec(s,ndec,'dmey');
A = wrcoef('a',C,L,'dmey',ndec); %Approximation
for i=1:ndec
D(i,:) = wrcoef('d',C,L,'dmey',i); % Details
end 
D(ndec+1,:) = A;
D(ndec+2,:) = s; %% Everything together

n = 4; ; % Number of delays, I use the last n values of my variables to predict the price,
% including the last prices itself
NDT = 120; % Number of tests

k = 1;
Yts = s(length(s)-NDT+1:length(s)); % Test targets
Ytr = s(n+1:length(s)- NDT); % Training targets

u = 1; cont = 1; k =0; % Preparing the data
for i =1:(ndec+2)*n
    
   
Xtr(i,:) = D(u,1+k:length(s)-NDT-n+k)
if cont < n
    u = u;
else
    u = u+1;
end

if cont < n
    cont = cont+1;
else 
    cont = 1;
end
if k < n-1
    k = k+1;
else
    k = 0;
end


end


u = 1; cont = 1; k =0;

for i =1:(ndec+2)*n
    
   
Xts(i,:) = D(u,length(s)-NDT-n+1+k:length(s)-n+k)
if cont < n
    u = u;
else
    u = u+1;
end

if cont < n
    cont = cont+1;
else 
    cont = 1;
end
if k < n-1
    k = k+1;
else
    k = 0;
end


end

%Y(t) = f(Y(t-1),Y(t-2),...,Y(t-n), X(t-1),
%X(t-2),...,X(t-n)



% NEural network iniciatilization
net = feedforwardnet(ndec + 3, 'trainbr');

% Training
net = train(net,Xtr,Ytr);
Ytrr = sim(net,Xtr);

% Simulation

Ych = sim(net, Xts);

 % Errors measures 
 ech = gsubtract(Ych,Yts);
rmse = sqrt(mse(ech));
mse(ech);


e = gsubtract(Ytrr,Ytr);
rmse = sqrt(mse(e));
mse(e);

trndata=Ytr;
trnOut=Ytrr;
chkdata=Yts;
chkOut=Ych;


trnRMSE=norm(trnOut-trndata)/sqrt(length(trnOut));

chkRMSE=norm(chkOut-chkdata)/sqrt(length(chkOut));

%% coeficiente de eficiencia (CE)
trnmean=mean(trndata);


chkmean=mean(chkdata);

% NSE-Nash-Sutcliffe efficientcy

somediftrn=sum((trndata-trnOut).^2);
sometrnsummean=sum((trndata-trnmean).^2);
trnNSE=1-somediftrn/sometrnsummean;

somedifchk=sum((chkdata-chkOut).^2);
somechksummean=sum((chkdata-chkmean).^2);
chkNSE=1-somedifchk/somechksummean;

% trnr2 
somediftrnx=sum((trndata-trnOut).^2);
sometrnsummeanx=sum((trnOut-trnmean).^2);
trnr2=1-somediftrnx/sometrnsummeanx;

% trnr2 
somedifchkx=sum((chkdata-chkOut).^2);
somechksummeanx=sum((chkOut-chkmean).^2);
chkr2=1-somedifchkx/somechksummeanx;

S = 0;
for i =1:NDT
    S = S + abs((chkdata(i) - chkOut(i))/chkdata(i));
end


clc
trnRMSE
chkRMSE
trnr2
chkr2
trnNSE
chkNSE


%%%%%%%%%%%%%%%%% Graphics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LtrnOut=length(trnOut);
LchkOut=length(chkOut);
tt=1:LtrnOut;
tttt=1:LchkOut;
subplot(2,2,1);
plot(tt,trnOut,'b-',tt,trndata,'r-')
legend('Simulado','Observado')
title('Treinamento')
xlabel('X')
ylabel('Y')

subplot(2,2,2);

plot(tttt,chkOut,'b-',tttt,chkdata,'r-')
legend('Simulado','Observado')
title('Simulação')
xlabel('x')
ylabel('y')

todosv=[trndata';chkdata'];
todoss=[trnOut';chkOut'];
xx=length(todoss);
x=1:xx;
subplot(2,2,3)
plot(x,todosv,'b-',x,todoss,'r-')
legend('Simulado','Observado')
title('Dados completos')
xlabel('x')
ylabel('y')


% One step-ahead forecasting
xxx = [D(1,length(D)-n+1:length(D)), D(2,length(D)-n+1:length(D)), D(3,length(D)-n+1:length(D)), D(4,length(D)-n+1:length(D)), D(5,length(D)-n+1:length(D))];

xxx = xxx';


yyyyyy = net(xxx);




