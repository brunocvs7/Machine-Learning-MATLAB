clear all 
clc

clear all 
clc

% This script takes a xlsx file with 1 column in which there is a time series

%%%%%%%%%% DATA ACQUISITION AND MANIPULATION %%%%%%%%%%%%%%%%%%%

serie = xlsread('natural_gas.xlsx');

s = serie';

% Applying Discrete Wavelet Transform to extract the high and low frequencies in the time series

ndec=floor(log10(length(s))); % Choosing the level of decomposition based on the number of observations

[C,L] = wavedec(s,ndec,'dmey');

A = wrcoef('a',C,L,'dmey',ndec); % Get Approximation (low frequency)
for i=1:ndec
D(i,:) = wrcoef('d',C,L,'dmey',i); % Get Details (High frequencies)
end 
D(ndec+1,:) = A;
D(ndec+2,:) = s; %% Combining approximation and details components

% Our goal is predict the natural gas price on day ahead. In order to do It, We'll build a neural network
% that will work as an Autoregressive model
%
n = 4; ; % Number of delays, I use the last n values of my variables to predict the price,
% including the last prices itself
NDT = 120; % Length of the test set


k = 1;
Yts = s(length(s)-NDT+1:length(s)); % Test targets
Ytr = s(n+1:length(s)- NDT); % Training targets


% Preparing the matrix of predictors (n past values for each row)

u = 1; cont = 1; k =0; 
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

%%%%%%%%%%%%%%% Modelling phase %%%%%%%%%%%%%%%%%%
%% SVM
Xtr1 = Xtr';
Ytr1 = Ytr';
% Training
svm = fitrsvm(Xtr1,Ytr1,'KernelFunction','polynomial','polynomialOrder', 2, 'KernelScale','auto','Standardize',true); 


%svm = fitrsvm(Xtr1,Ytr1);
Ytrr = predict(svm,Xtr1);

% Simulation
Xts1 = Xts';
Ych = predict(svm, Xts1);

Ych = Ych';
Ytrr = Ytrr';
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

%% Efficiency Coefficient (CE)
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
trnRMSE % RMSE of the training phase
chkRMSE % RMSE of the testing phase
trnr2   % R² of the training phase
chkr2 % R² of the testing phase
trnNSE  % NSE of the training phase
chkNSE % NSE of the testing phase



%%%%%%%%%%%%%%%%% VISUALIZATION OF THE RESULTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LtrnOut=length(trnOut);
LchkOut=length(chkOut);
tt=1:LtrnOut;
tttt=1:LchkOut;
subplot(2,2,1);
plot(tt,trnOut,'b-',tt,trndata,'r-')
legend('Predicted','Real')
title('Training')
xlabel('X')
ylabel('Y')

subplot(2,2,2);

plot(tttt,chkOut,'b-',tttt,chkdata,'r-')
legend('Predicted','Real')
title('Test')
xlabel('x')
ylabel('y')

todosv=[trndata';chkdata'];
todoss=[trnOut';chkOut'];
xx=length(todoss);
x=1:xx;
subplot(2,2,3)
plot(x,todosv,'b-',x,todoss,'r-')
legend('Predicted','Real')
title('All Data')
xlabel('x')
ylabel('y')





