#!/usr/bin/octave -qf
pkg load statistics
if (nargin != 2)
    printf("Usage: Ex1.m <trdata> <trlabels>");
    exit(1);
endif

arg_list = argv();
trdata = arg_list{1};
trlabels = arg_list{2};

load(trdata);
load(trlabels);

res = svmtrain(trlabels, tr, '-t 2 -c 1');


theta = res.sv_coef'*res.SVs; % obtener theta para saber el gradiente
theta0 = sign(full(res.SVs(1,:))) - vpesos'*full(res.SVs(1,:)); % obtener theta cero, la interseccion
gradiente = vpesos(2)/vpesos(1); % rise / run

margen = 1/(theta * theta');











% Obtener 3 rectas
% Plotearlos el margen y tal tal tal

% Vector para guardar tipo de punto y markersize

% Clase 1
%plot(tr(:,1), tr(:,2), ".r", "markersize", 20);
% Clase 2
%plot(tr(:,1), tr(:,2), ".b", "markersize", 20);
% SV
%plot(tr(:,1), tr(:,2), "sk", "markersize", 10);
% SV erroneos
%plot(tr(:,1), tr(:,2), "sk", "markersize", 10);

%text(1, 5, strcat("Margen = ", num2str(margen)));
%refresh();
%input("Press key");
%print -djpg señor.jpg;