clear all;
M = csvread('/home/hanshalbe/Desktop/FunctionDescriptions/data/recoveredgp.csv');
dall=zeros(300,31);

for k=1:300;
    current=M(M(:,2)==k,:);
    x=current(:,3);
    y=current(:,4);
    yt=current(:,5);
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
    nlml1a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml1b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    %periodic alone
    covfunc = cper; 
    hyp2.cov = hypper;
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml2a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml2b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    %SQE alone
    covfunc = csqe; 
    hyp2.cov = hypsqe;
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml3a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml3b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    %linear + periodic
    covfunc = {'covSum',{clin,cper}}; 
    hyp2.cov = [hyplin;hypper];% sum
    hyp2.lik = log(0.01);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml4a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml4b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    %linear + sqe
    covfunc = {'covSum',{clin,csqe}}; 
    hyp2.cov = [hyplin;hypsqe];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml5a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml5b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    %per + sqe
    covfunc = {'covSum',{cper,csqe}}; 
    hyp2.cov = [hypper;hypsqe];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml6a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml6b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    %linearXperiodic
    covfunc={@covProd,{clin,cper}};
    hyp2.cov = [hyplin;hypper];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml7a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml7b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);



    %linearXsqe
    covfunc={@covProd,{clin,csqe}}; 
    hyp2.cov = [hyplin;hypsqe];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml8a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml8b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);


    %perXsqe
    covfunc={@covProd,{cper,csqe}}; 
    hyp2.cov = [hypper;hypsqe];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml9a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml9b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    %per + sqe + lin
    covfunc = {'covSum',{cper,csqe, clin}}; 
    hyp2.cov = [hypper;hypsqe;hyplin];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml10a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml10b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    %per*sqe + lin
    covfunc1={@covProd,{cper,csqe}}; 
    hyp1=[hypper;hypsqe];
    covfunc = {'covSum',{covfunc1,clin}}; 
    hyp2.cov = [hyp1;hyplin];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml11a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml11b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    %per*lin + sqe
    covfunc1={@covProd,{cper,clin}}; 
    hyp1=[hypper;hyplin];
    covfunc = {'covSum',{covfunc1,csqe}}; 
    hyp2.cov = [hyp1;hypsqe];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml12a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml12b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    %per*sqe + lin
    covfunc1={@covProd,{cper,csqe}}; 
    hyp1=[hypper;hypsqe];
    covfunc = {'covSum',{covfunc1,clin}}; 
    hyp2.cov = [hyp1;hyplin];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml13a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml13b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);


    %per*sqe*lin
    covfunc={@covProd,{cper,csqe,clin}}; 
    hyp2.cov = [hypper;hypsqe;hyplin];% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml14a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml14b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    %spectral
    Q = 4; w = ones(Q,1)/Q; m = rand(1,Q); v = rand(1,Q);
    covfunc = {@covSM,Q}; 
    hypsm = log([w;m(:);v(:)]);
    hyp2.cov = hypsm;% sum
    hyp2.lik = log(0.1);
    hyp2 = minimize(hyp2, @gp, -100, @infVB, [], covfunc, likfunc, x, y);
    nlml15a = gp(hyp2, @infExact,[], covfunc, likfunc, x, y);
    nlml15b = gp(hyp2, @infExact,[], covfunc, likfunc, x, yt);

    nalla=[nlml1a, nlml2a, nlml3a, nlml4a, nlml5a, nlml6a, nlml7a, nlml8a, nlml9a, nlml10a, nlml11a, nlml12a, nlml13a, nlml14a, nlml15a];
    nallb=[nlml1b, nlml2b, nlml3b, nlml4b, nlml5b, nlml6b, nlml7b, nlml8b, nlml9b, nlml10b, nlml11b, nlml12b, nlml13b, nlml14b, nlml15b];
    collect=[k, nalla, nallb];
    dall(k,:)=collect;    
end
csvwrite('/home/hanshalbe/Desktop/FunctionDescriptions/data/gprating.csv', dall);
