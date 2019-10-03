M1 = csvread('/home/hanshalbe/Desktop/FunctionDescriptions/data/funcs.csv');

mucollect=[];
nlogcollect=[];
for h=1:40
    y =M1(:, h);
    x=(1:101)' 
    y=y+rand(length(y),1)*0.01;
    
    likfunc = @likGauss;
    %SQE
    csqe = {'covMaterniso',1};  hypsqe = log([0.5;2]);    % isotropic Gaussian
    %SQE alone
    covfunc = csqe; 
    hyp2.cov = hypsqe;% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml1 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    %SQE
    csqe = {'covMaterniso',3};  hypsqe = log([0.5;2]);    % isotropic Gaussian
    %SQE alone
    covfunc = csqe; 
    hyp2.cov = hypsqe;% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml2 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    %SQE
    csqe = {'covMaterniso',5};  hypsqe = log([0.5;2]);    % isotropic Gaussian
    covfunc = csqe; 
    hyp2.cov = hypsqe;% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml3 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    nall=[nlml1, nlml2,nlml3];
    nlogcollect=[nlogcollect,nall];
end
csvwrite('/home/hanshalbe/Desktop/FunctionDescriptions/data/neglokfuncssmooth.csv',nlogcollect);
