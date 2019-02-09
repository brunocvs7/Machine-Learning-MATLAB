clear all
clc
%load 'ar.mat'
%s=co_ar'
% Numero de niveis de decomposicao- ndec = parte inteira do log10 do numero
% de pontos
s = xlsread('diarios.xlsx')';

ndec=floor(log10(length(s)));
% db5 nome da wavvelet- pode mudar
[C,L] = wavedec(s,ndec,'coif3');
A = wrcoef('a',C,L,'coif3',ndec);
for i=1:ndec;
D(i,:) = wrcoef('d',C,L,'coif3',i);
end 
% como alternativa somei a 
D(ndec+1,:)=A;
Entrada=D;
AA=Entrada;
B=s;
[LE,CE]=size(AA);
[LS,CS]=size(B);
% para retirar o primeiro termo da saída
k=0;
for i=2:CS
    k=k+1;
    b(k)=B(i);
end

for ii=1:LE
    k=0;
for i=1:CE-1
    k=k+1;
    a(ii,k)=AA(ii,i);
end  
k=0;
end
x=a;
t=b;
%Ate aqui veio de programa1xvazãotrabr
% preparacao
x=x';
t=t';
junta=[x t];
Data=junta;
[TL  TC]=size(Data);
endt=TL;
% numero de anos para dados de chek
%%% adaptando para LU
Anostesteemdias=1;
%caso dados dias brasil de teste-NDT
NDT=54
ends=TL-Anostesteemdias*(NDT);
%break
%%%% particao de dados %%%%%%%%%%%%%C
trndata=Data(1:ends, :);
endss=ends+1;
chkdata=Data(endss:endt, :);
numMFs=3;
%mfType='gbellmf';
%mouyType='constant';
mfType='gbellmf';
mouyType='constant';
fismat=genfis1(trndata,numMFs,mfType,mouyType);
numEpochs=20;
[fismat1,trnErr,ss,fismat2,chkErr]=anfis(trndata,fismat,numEpochs,NaN,chkdata);
disp('RMSE UNIDADE');
trnOut=evalfis(trndata(:,1:ndec+1),fismat1);
trnRMSE=norm(trnOut-trndata(:,ndec+2))/sqrt(length(trnOut));
chkOut=evalfis(chkdata(:,1:ndec+1),fismat2);
chkRMSE=norm(chkOut-chkdata(:,ndec+2))/sqrt(length(chkOut));

% implementando os outros critérios de erro
% NSE-Nash-Sutcliffe efficientcy
disp('Nash-Sutcliffe efficientcy trnNSE');
trnmean=mean(trndata(:,ndec+2));
somediftrn=sum((trndata(:,ndec+2)-trnOut).^2);
sometrnsummean=sum((trndata(:,ndec+2)-trnmean).^2);
trnNSE=1-somediftrn/sometrnsummean;

disp('Nash-Sutcliffe efficientcy chkNSE');
chkmean=mean(chkdata(:,ndec+2));
somedifchk=sum((chkdata(:,ndec+2)-chkOut).^2);
somechksummean=sum((chkdata(:,ndec+2)-chkmean).^2);
chkNSE=1-somedifchk/somechksummean;


disp('trnr2 ');
% trnr2 
somediftrnx=sum((trndata(:,ndec+2)-trnOut).^2);
sometrnsummeanx=sum((trnOut-trnmean).^2);
trnr2=1-somediftrnx/sometrnsummeanx;

disp('chk2');
% chk2 
somedifchkx=sum((chkdata(:,ndec+2)-chkOut).^2);
somechksummeanx=sum((chkOut-chkmean).^2);
chkr2=1-somedifchkx/somechksummeanx;


% plotar
tt=1:ends;
ttt=ends+1:endt;
%tttt=1:Anostesteemdias*(365);
% Adaptando para LU e linkando com as linhas 48 e 49
tttt=1:Anostesteemdias*(NDT);
ttrei=t(1:ends);
tcheck=t(ends+1:endt);
subplot(2,2,1);
plot(tt,trnOut,'b-',tt,trndata(:,ndec+2),'r-')
legend('Computed','Observed')
title('Training')
xlabel('Time (days)')
ylabel('Streamflow m3/s')
%aqui é somente para afzer o grafico como o programa original
subplot(2,2,2);
plot(tttt,chkOut,'b-',tttt,chkdata(:,ndec+2),'r-')
legend('Computed','Observed')
title('Testing')
xlabel('Time (days)')
ylabel('Streamflow m3/s')
todosv=[trndata(:,ndec+2);chkdata(:,ndec+2)];
todoss=[trnOut;chkOut];
xx=length(todoss);
x=1:xx;
subplot(2,2,3)
plot(x,todoss,'b-',x,todosv,'r-')
legend('Computed','Observed')
xlabel('Time (days)')
ylabel('Streamflow m3/s')

trnRMSE
chkRMSE
trnr2
chkr2
trnNSE
chkNSE

% Obs: Você pode implementar qualquer tipo de erro lembrando que
%temos:
%trnOut= saida do modelo dados treinamento
%trndata(:,ndec+2)= dados treinamento

%chkOut=saida do modelo dados para os dados de check
%chkdata(:,ndec+2)= dados de check 

