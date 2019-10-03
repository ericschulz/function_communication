M1 = csvread('/home/hanshalbe/Desktop/FunctionDescriptions/data/funcs.csv');

mucollect=[];
nlogcollect=[];
for h=1:40
    y =M1(:, h);
    x=(1:101)' 
    y=y+rand(length(y),1)*0.01;
    
    likfunc = @likGauss;
    %SQE
    csqe = {'covSEiso'};  hypsqe = log([0.9;2]);    % isotropic Gaussian
    %Periodic
    cper = {'covPeriodic'}; p = 2; hypper = log([0.9;2;2]);   % periodic
    %Linear
    clin  = {@covLIN};hyplin = []; % linear is parameter-free

    %linear alone
    covfunc = clin; 
    hyp2.cov = hyplin;% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml1 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
    %periodic alone
    covfunc = cper; 
    hyp2.cov = hypper;% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml2 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
    %SQE alone
    covfunc = csqe; 
    hyp2.cov = hypsqe;% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml3 = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    
    %linear + periodic
    covfunc = {'covSum',{clin,cper}}; 
    hyp2.cov = [hyplin;hypper];% sum
    hyp2.lik = log(0.01);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml4 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
    %linear + sqe
    covfunc = {'covSum',{clin,csqe}}; 
    hyp2.cov = [hyplin;hypsqe];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml5 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
    %per + sqe
    covfunc = {'covSum',{cper,csqe}}; 
    hyp2.cov = [hypper;hypsqe];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml6 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
    %linearXperiodic
    covfunc={@covProd,{clin,cper}};
    hyp2.cov = [hyplin;hypper];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml7 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
    %linearXsqe
    covfunc={@covProd,{clin,csqe}}; 
    hyp2.cov = [hyplin;hypsqe];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml8 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);

    %perXsqe
    covfunc={@covProd,{cper,csqe}}; 
    hyp2.cov = [hypper;hypsqe];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml9 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
    %per + sqe + lin
    covfunc = {'covSum',{cper,csqe, clin}}; 
    hyp2.cov = [hypper;hypsqe;hyplin];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml10 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
    %per*sqe + lin
    covfunc1={@covProd,{cper,csqe}}; 
    hyp1=[hypper;hypsqe];
    covfunc = {'covSum',{covfunc1,clin}}; 
    hyp2.cov = [hyp1;hyplin];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml11 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
    %per*lin + sqe
    covfunc1={@covProd,{cper,clin}}; 
    hyp1=[hypper;hyplin];
    covfunc = {'covSum',{covfunc1,csqe}}; 
    hyp2.cov = [hyp1;hypsqe];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml12 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
    %per*sqe + lin
    covfunc1={@covProd,{cper,csqe}}; 
    hyp1=[hypper;hypsqe];
    covfunc = {'covSum',{covfunc1,clin}}; 
    hyp2.cov = [hyp1;hyplin];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml13 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
    %per*sqe*lin
    covfunc={@covProd,{cper,csqe,clin}}; 
    hyp2.cov = [hypper;hypsqe;hyplin];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml14 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
    
%     Q = 4; w = ones(Q,1)/Q; m = rand(1,Q); v = rand(1,Q);
%     covfunc = {@covSM,Q}; 
%     hypsm = log([w;m(:);v(:)]);
%     hyp2.cov = hypsm;% sum
%     hyp2.lik = log(0.1);
%     hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
%     nlml15 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y);
%     m15 = gp(hyp2, @infVB,[], covfunc, likfunc, x, y, z);

    nall=[nlml1, nlml2,nlml3,nlml4,nlml5,nlml6,nlml7,nlml8,nlml9,nlml10,nlml11,nlml12,nlml13,nlml14];
    nlogcollect=[nlogcollect,nall];
end
csvwrite('/home/hanshalbe/Desktop/FunctionDescriptions/data/neglokfuncs.csv',nlogcollect);
