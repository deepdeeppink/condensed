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

 	LEFT_V_FIXED = true;
 	RIGHT_V_FIXED = true;

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
		'diameter', 1, ...
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
	% pressure = 4e5 + zeros(size(coordinate));
	pressure = 4e5 + sin((coordinate - min(coordinate)) / (max(coordinate) - min(coordinate)) * pi ) * 2e5;

	T = Line( ...
		'diameter', 1, ...
		'coordinate', coordinate, ...
		'pressure', pressure, ...
		'velocity', velocity);

	c = Bridge.CheckValve;
	P = Bridge.Pump(2e3);
	% S = Bridge.Snake(-C, P);
	% H = Bridge.Humburger(C, C);
	Z = Bridge.Zero();
	W = Bridge.Wall();
	J = c;

%% >>
	subplot(1, 2, 1)
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
	dots = [];
	black = [0 0 0];
	white = [1 1 1];
	gray = white * .6;
	gray1 = [1 .2 .2];
	color = @(x) (gray - white) .* exp(-x / 15) + white;
	color1 = @(x) (gray - gray1) .* exp(-x / 15) + gray1;

	for i = 1:Inf

		set(text, 'String', {[num2str(i * C.timeStep, 2) 's']})
		nextF = F.reduce;
		nextT = T.reduce;

		% первый стык
		if LEFT_V_FIXED

			nextF.pressure(1) = reducers.B( ...
				F.pressure(2), ...
				F.velocity(1), ...
				F.velocity(2), ...
				0, ...
				F.diameter ...
			);
			nextF.velocity(1) = 0;
		else

			nextF.pressure(1) = 4e5;
			nextF.velocity(1) = fsolve( ...
				@(v) ...
					reducers.B( ...
						F.pressure(2), ...
						F.velocity(1), ...
						F.velocity(2), ...
						v * C.scale.velocity, ...
						F.diameter ...
					) - nextF.pressure(1), ...
				F.velocity(1) / C.scale.velocity, ...
				solverOptions ...
			) * C.scale.velocity;
		end

		% последний стык
		if RIGHT_V_FIXED

			nextT.pressure(end) = reducers.A( ...
				T.pressure(end - 1), ...
				T.velocity(end - 1), ...
				T.velocity(end), ...
				0, ...
				T.diameter ...
			);
			nextT.velocity(end) = 0;
		else
			
			nextT.pressure(end) = 4e5;
			nextT.velocity(end) = fsolve( ...
				@(v) ...
					reducers.A( ...
						T.pressure(end - 1), ...
						T.velocity(end - 1), ...
						T.velocity(end), ...
						v * C.scale.velocity, ...
						T.diameter ...
					) - nextT.pressure(end), ...
				T.velocity(end) / C.scale.velocity, ...
				solverOptions ...
			) * C.scale.velocity;
		end

		% главный стык
		J.calculate(@(x) F.rightReducer(x) ^2 + T.leftReducer(x) ^2);
		nextF.pressure(end) = J.pressureLeft;
		nextT.pressure(1) = J.pressureRight;
		nextF.velocity(end) = J.flow / nextF.section;
		nextT.velocity(1) = J.flow / nextT.section;
			
		F = nextF;
		T = nextT;

		% if mod(i, 2) == 0

			subplot(1, 2, 1)
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

		if i > 1

			subplot(1, 2, 2)
			% dP(Q)
			hold on
			for j = 1:length(dots)

				set(dots(j), 'Color', color1(length(dots) - j), 'LineWidth', .1)
			end
			dots(end + 1) = plot(F.velocity(end), T.pressure(1) - F.pressure(end), '.', 'Color', black);
			if length(dots) > 50

				dots = dots(end - 49:end);
			end
			pause(1e-10);
		end
	end
end