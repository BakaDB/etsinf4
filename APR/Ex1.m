#!/usr/bin/octave -qf

if (nargin != 7)
    printf("Usage: pcaexp.m <trdata> <trlabels> <tedata> <telabels> <mink> <stepk> <maxk>\n");
    exit(1);
end

arg_list = argv();
trdata = arg_list{1};
trlabs = arg_list{2};
tedata = arg_list{3};
telabs = arg_list{4};
mink = str2num(arg_list{5});
stepk = str2num(arg_list{6});
maxk = str2num(arg_list{7});

load(trdata);
load(trlabs);
load(tedata);
load(telabs);

aux = [];

for alfa = [0.1, 0.2, 0.5, 0.7, 0.9, 0.95, 0.99, 1.0],
    printf("Valor de alfa:\n%f\n", alfa);
    printf("Valor de k:\t\tValor de err: \n");
    col = [];
    for i = [mink:stepk:maxk],

        XR = W(:,1:k)'*(X-m)';
        YR = W(:,1:k)'*(Y-m)';
        err = gaussian(XR', xl, YR', yl, kk);
        
        col=[col; err];
        
        printf("%f\t\t%f\n", i, err);

    endfor
    aux = [aux, col];
endfor

plot([mink:stepk:maxk], aux);
xlabel("Dimensionalidad espacio PCA");
ylabel("Error (%)");
axis([mink, maxk, 2, 12]);
legend("a = 0.1", "a = 0.2", "a = 0.5", "a = 0.9", "a = 0.95", "a = 0.99", "a = 1.0", );
refresh();
input("Press key");
print -djpg señor.jpg;

%Command to execute:
%./Ex1.m trdata.mat.gz trlabels.mat.gz tedata.mat.gz telabels.mat.gz 10 10 100