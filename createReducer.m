function createReducer

	soundSpeed = C.soundSpeed;
	gravity = C.gravity; 
	viscosity = C.viscosity;
	height = C.height;
	slope = C.slope;
	density = C.density;
	time_step = C.timeStep;

	g = gravity;
	c = soundSpeed;
	r = density;
	% d = diameter;
	dt = time_step;
	s = sin(slope);

	gs = g * s;
	rc = r * c;

%% символы
	%    n
	%  / | \
	% l--0--r
	%    |
	%    p
	syms v_n v_l v_0 v_r v_p p_n p_l p_0 p_r h_0 h_n u d
	dp = p_n - p_0;
	dv = v_n - v_0;
	dh = h_n - h_0;

	v = [v_l v_0 v_r];
	p = [p_l p_0 p_r];
	h = h_0;

	Re = @(velocity) abs(velocity) * d / viscosity;
												  % debug
	lambda = @(velocity) .3164 / Re(velocity)^.25 * 2e3;
	head = @(pressure) pressure ./ gravity ./ density + height;
	p2 = @(v) v * abs(v);

%% уравнения
	A = p_n + rc * v_n == p_l + rc * v_l - ( lambda(v_l) * p2(v_l) / 2 / d + gs ) * rc * dt;
	B = p_n - rc * v_n == p_r - rc * v_r + ( lambda(v_r) * p2(v_r) / 2 / d + gs ) * rc * dt;

%% экспорт
	unknowns = [p_n v_n];
	outputs = {'p_n' 'v_n'};

	% AB
	solve([A B], unknowns);
	matlabFunction(simplify(ans.p_n), simplify(ans.v_n), 'Vars', {p_l p_r v_l v_r d}, 'Outputs', outputs, 'File', '+reducers/AB');

	% A
	matlabFunction(simplify(solve(A, p_n)), 'Vars', {p_l v_l v_n d}, 'Outputs', {'p'}, 'File', '+reducers/A');
	
	% B
	matlabFunction(simplify(solve(B, p_n)), 'Vars', {p_r v_r v_n d}, 'Outputs', {'p'}, 'File', '+reducers/B');