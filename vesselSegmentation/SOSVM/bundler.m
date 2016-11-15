
function state = bundler(state, a, b, soft)
%   BUNDLER
%
%   Solves the problem
%
%    min_{w,xi} lambda/2 |w|^2 + xi,  xi >= b_t - <a_t, w>  for t = 1, ..., T
%
%   Optionally, it also enforces additional hard constraints
%
%    <a_p,w> >= b_p,  p = 1, ..., P
%
%   The algorithm uses the dual to do so. Introducing Lagrange
%   multipliers alpha_i, beta_j:
%
%   max_{alpha>=0} min_w \lambda/2 |w|^2
%                        + xi
%                        + sum_t alpha_t (b_t - <a_t,w> - xi)
%                        + sum_p alpha_p (b_p - <a_p,w>)
%
%   Minimizing w.r.t. xi yields the condition sum_t alpha_t = 1 (if
%   the domain is restricted to xi >=0 in the beginning, then this
%   becomes sum_t alpha_t <= 1). Then
%
%   w = 1/lambda sum_i alpha_i a_i
%
%   where i spans both the indexes t of the soft constraints and p
%   of the hard constraints. Hence the dual problem is
%
%   max_{alpha>=0}  1/lambda [ lambda sum_i alpha_i b_i  - 1/2 alpha' K alpha]
%
%       s.t. sum_t alpha_t <= 1
%
%   where K = A'A, A = [... a_i ...] is the kernel matrix. Note that
%   the upper bound on the sum of alphas involves only the soft
%   constraints, and this is the only way they are distinguished in
%   the dual.
    
    if (~exist('soft','var'))
        opts.soft = true;
    else
        opts.soft = soft;
    end
    opts.soft = double(opts.soft);

    if nargin == 0
      state.lambda = 1;
      state.a = [];
      state.b = [];
      state.softVariables = [];
      state.dualVariables = [];
      state.dualAge = [];
      state.dualObjective = -inf;
      state.K = [];
      state.f = [];
      state.w = [];
      state.quadProgOpts = optimset('Algorithm', 'active-set', 'Display', 'off', 'MaxIter', 1000);
      return;
    end

    dimension = size(state.w,1);
    numNewConstraints = size(a,2);
    if isempty(state.a)
        state.a = zeros(dimension, 0);
    end;

    % add new constraints to the pool
    state.dualVariables = [state.dualVariables ; zeros(numNewConstraints,1)];
    state.softVariables = [state.softVariables ; opts.soft];
    state.dualAge       = [state.dualAge ; 0];

    % add missing part of kernel matrix
    K11 = state.K;
    K12 = state.a' * a;
    K22 = a' * a;
    state.K = [K11 K12 ; K12' K22];
    state.f = [state.f ; state.lambda * b'];
    state.a = [state.a, a];
    state.b = [state.b, b];

    % solve quad prog
    [state.dualVariables, state.dualObjective] = quadprog(state.K, -state.f, ...
                                                          state.softVariables', 1, ...
                                                          [],[], ...
                                                          zeros(length(state.dualVariables), 1), [], ...
                                                          state.dualVariables, ...
                                                          state.quadProgOpts);
    state.dualObjective = - state.dualObjective / state.lambda ;

    % remove idle variables
    state.dualAge = state.dualAge + 1;
    active = state.dualVariables > 1e-5 | ~state.softVariables;
    state.dualAge(active) = 0;
    keep = state.dualAge < 20;

    state.dualVariables = state.dualVariables(keep);
    state.softVariables = state.softVariables(keep);
    state.dualAge = state.dualAge(keep);
    state.K = state.K(keep,keep);
    state.f = state.f(keep);
    state.a = state.a(:,keep);
    state.b = state.b(keep);

    % update the model
    state.w = state.a * (state.dualVariables / state.lambda);
