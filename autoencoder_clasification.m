

    
load dadosdebut.mat
%load DadosFalhas2.mat;
%xxtr = entradafalhadebut;
%yytr = saidafalhadebut;


lims = round((85/100)*length(xxtr))
x = xxtr';
y = yytr';

xtrr = x(:,1:lims);
xtss = x(:, lims+1:length(xxtr));

ytrr= y(:,1:lims);
ytss = y(:,lims+1:length(xxtr));

hiddenSize = 5;

autoenc1 = trainAutoencoder(xtrr,hiddenSize,...
 'EncoderTransferFunction','logsig',...
 'L2WeightRegularization',0.001,...
 'SparsityRegularization',4,...
 'SparsityProportion',0.5,...
 'DecoderTransferFunction','purelin',...
 'ScaleData',false);

features1 = encode(autoenc1,xtrr);


hiddenSize =3;
autoenc2 = trainAutoencoder(features1,hiddenSize,...
    'EncoderTransferFunction','logsig',...
'L2WeightRegularization',0.001,...
'SparsityRegularization',4,...
'SparsityProportion',0.5,...
'DecoderTransferFunction','purelin',...
'ScaleData',false);



features2 = encode(autoenc2,features1);

%hiddenSize =2;
%%autoenc3 = trainAutoencoder(features2,hiddenSize,...
%'L2WeightRegularization',0.001,...
%'SparsityRegularization',4,...
%'SparsityProportion',0.05,...
%'DecoderTransferFunction','purelin',...
%'ScaleData',false);

%features3 = encode(autoenc3,features2);
softnet = trainSoftmaxLayer(features2,ytrr,'LossFunction','mse');

deepnet = stack(autoenc1,autoenc2,softnet); 
deepnet = train(deepnet,xtrr,ytrr);

clasificacao = deepnet(xtss);
 plotconfusion(ytss,clasificacao);