function app
%%
% <  init  >
%  --------
%        \   ^__^
%         \  (oo)\_______
%            (__)\       )\/\
%                ||----w |
%                ||     ||
 	clf, clc, clear
 	createReducer

    % solverOptions = optimoptions('fsolve', ...
    % 	'Algorithm', 'levenberg-marquardt', ...
    % 	'MaxIter', Inf, ...
    % 	'TolX', 1e-15, ...
    % 	'TolFun', 1e-15 ...
    % 	... % 'Display', 'off' ...
    % );
    solverOptions = optimoptions('fsolve', ...
    	'Display', 'off' ...
    );

% initial pressure
 	level = [10 12];

 	% случайные распределения
 	coordinateMax = 500;
 	coordinate = 0:C.coordinateStep:coordinateMax;
	peakNum = 5;
	peakCoordinate = coordinate([1 ceil(sort(rand([1 peakNum - 2])) * end) end]);
	[~, uniqueIndex] = unique(peakCoordinate);
	peakPressure = ([1 rand([1 peakNum - 2]) 4] * 2 + 2) * C.airPressure;
	peakPressure([1 end]) = level * C.density * C.gravity;
	peakCoordinate = peakCoordinate(uniqueIndex);
	peakPressure = peakPressure(uniqueIndex);
	pressure = spline(peakCoordinate, peakPressure, coordinate);
	velocity = zeros(size(coordinate));
	pressure(pressure < 0) = 0;
	pressure(pressure > 8e5) = 8e5;
	pressure = 4e5 + zeros(size(coordinate));
	pressure = 4e5 + sin((coordinate - min(coordinate)) / (max(coordinate) - min(coordinate)) * pi * 2) * 2e5;

	F = Line( ...
		'diameter', .5, ...
		'coordinate', coordinate, ...
		'pressure', pressure, ...
		'velocity', velocity);

	coordinate = max(coordinate) + (0:C.coordinateStep:coordinateMax / 2);
	peakNum = 8;
	peakCoordinate = coordinate([1 ceil(sort(rand([1 peakNum - 2])) * end) end]);
	[~, uniqueIndex] = unique(peakCoordinate);
	peakPressure = ([1 rand([1 peakNum - 2]) 4] * 2 + 2) * C.airPressure;
	peakPressure([1 end]) = level * C.density * C.gravity;
	peakCoordinate = peakCoordinate(uniqueIndex);
	peakPressure = peakPressure(uniqueIndex);
	pressure = spline(peakCoordinate, peakPressure, coordinate);
	velocity = zeros(size(coordinate));
	pressure(pressure < 0) = 0;
	pressure(pressure > 8e5) = 8e5;
	pressure = 4e5 + zeros(size(coordinate));
	pressure = 4.1e5 + sin((coordinate - min(coordinate)) / (max(coordinate) - min(coordinate)) * pi ) * .2e5;

	T = Line( ...
		'diameter', 1, ...
		'coordinate', coordinate, ...
		'pressure', pressure, ...
		'velocity', velocity);

	C1 = Bridge.CheckValve;
	C2 = -C1;
	P1 = Bridge.Pump(2e3);
	P2 = -P1;
	S = Bridge.Snake(C1, P1);
	H = Bridge.Humburger(C1, C1);
	% S = Bridge.Snake(C1, P1);

%% >>
	xlim([0 max(coordinate)])
	% ylim([0 8e5])
	hold on

	text = annotation(gcf, 'textbox',...
    	[0.146601617795753 0.767772511848341 0.100112234580384 0.123222748815166],...
    	'String', {'0 s'}, ...
    	'FitBoxToText', 'on', ...
    	'EdgeColor', 'none');

	plot(F, 'Color', [0 0.4470 0.7410]);
	plot(T, 'Color', [0 0.4470 0.7410]);
	% plot(F, 'Color', [0 0.4470 0.7410], 'LineStyle', '--')
	% plot(T, 'Color', [0 0.4470 0.7410], 'LineStyle', '--')
	line([1 1] * min(T.coordinate), get(gca, 'ylim'));
	hF = [];
	hT = [];
	black = [0 0 0];
	white = [1 1 1];
	gray = white * .6;
	color = @(x) (gray - white) .* exp(-x / 15) + white;

	for i = 1:Inf

		set(text, 'String', {[num2str(i * C.timeStep, 2) 's']})
		nextF = F.reduce;
		nextT = T.reduce;

		% 1-й стык
		% v fixed
		% nextF.pressure(1) = reducers.B(F.pressure(2), sum(F.velocity(1:2)) / 2, 0, F.diameter);
		% nextF.velocity(1) = 0;
		% p fixed
		nextF.pressure(1) = 4e5;
		nextF.velocity(1) = fsolve( ...
			@(v) ...
				reducers.B(F.pressure(2), sum(F.velocity(1:2)) / 2, v * C.scale.velocity, F.diameter) - nextF.pressure(1), ...
			F.velocity(1) / C.scale.velocity, ...
			solverOptions ...
		) * C.scale.velocity;

		% последний стык
		% v
		% nextT.pressure(end) = reducers.A(T.pressure(end - 1), sum(T.velocity(end - 1:end)) / 2, 0, T.diameter);
		% nextT.velocity(end) = 0;
		% p
		nextT.pressure(end) = 4.1e5;
		nextT.velocity(end) = fsolve( ...
			@(v) ...
				reducers.A(T.pressure(end - 1), sum(T.velocity(end - 1:end)) / 2, v * C.scale.velocity, T.diameter) - nextT.pressure(end), ...
			T.velocity(end) / C.scale.velocity, ...
			solverOptions ...
		) * C.scale.velocity;


		% главный стык
		result = fsolve(@jointReducer, [
			F.pressure(end) / C.scale.pressure
			T.pressure(1) / C.scale.pressure
			F.velocity(end) / C.scale.velocity
			T.velocity(1) / C.scale.velocity
		], solverOptions);
		% TODO: figure out wtf?
		% result = fsolve(@jointReducer, [0 0 0 0], solverOptions);

		% debug
		% result(3:4) .* [C.scale.velocity C.scale.velocity]
		% result(1:2) .* [C.scale.pressure C.scale.pressure]
		nextF.pressure(end) = result(1) * C.scale.pressure;
		nextT.pressure(1) = result(2) * C.scale.pressure;
		nextF.velocity(end) = result(3) * C.scale.velocity;
		nextT.velocity(1) = result(4) * C.scale.velocity;
			
		F = nextF;
		T = nextT;

		if mod(i, 10) == 0

			if exist('hR')
				delete(hR)
			end
			% hR = plot([F.coordinate(end) T.coordinate(1)], [F.velocity(end) T.velocity(1)], 'Color', 'red', 'LineWidth', 1.5);
			hR = plot([F.coordinate(end) T.coordinate(1)], [F.pressure(end) T.pressure(1)], 'Color', 'red', 'LineWidth', 1.5);
			for j = 1:length(hF)

				set(hF(j), 'Color', color(length(hF) - j), 'LineWidth', .1)
				set(hT(j), 'Color', color(length(hT) - j), 'LineWidth', .1)
			end
			hF(end + 1) = plot(F, 'Color', black, 'LineWidth', 1.5);
			hT(end + 1) = plot(T, 'Color', black, 'LineWidth', 1.5);
			if length(hF) > 50

				delete(hF(1));
				delete(hT(1));
				hF = hF(end - 49:end);
				hT = hT(end - 49:end);
			end
			pause(1e-10);
		end
	end

function f = jointReducer(x)

	% x = [p1 p2 v1 v2]
	pl = F.pressure(end - 1);
	vl = sum(F.velocity(end - 1:end)) / 2;
	pr = T.pressure(2);
	vr = sum(T.velocity(1:2)) / 2;

	dl = F.diameter;
	dr = T.diameter;
	sl = pi * dl^2 / 4;
	sr = pi * dr^2 / 4;

	v1 = x(3) * C.scale.velocity;
	v2 = x(4) * C.scale.velocity;
	p1 = reducers.A(pl, vl, v1, dl);
	p2 = reducers.B(pr, vr, v2, dr);
	f1 = v1 * sl;
	f2 = v2 * sr;

	f = [
		p1 - x(1) * C.scale.pressure,
		p2 - x(2) * C.scale.pressure,
		p2 - p1 - H.stateFunction.eval(f1),
		f1 - f2
	];
end

end