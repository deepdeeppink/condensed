classdef Abstract < matlab.mixin.Copyable

	properties (SetAccess=protected)

		stateFunction
		flowLimits = [-Inf Inf]
	end

	properties

		pressureLeft = 0
		pressureRight = 0
		flow = 0
	end

	methods

		function calculate(this, outerFunction)

			% outerFunction(x)
			% x = [pin pout q]
			scale = C.scale;
			dp_ = @(x) (x(2) - x(1)) * scale.pressure;
			q_ = @(x) x(3) * scale.flow;
			innerFunction = @(x) (dp_(x) - this.stateFunction(q_(x))) ^2;

			reducer = @(x) innerFunction(x) + outerFunction(x);
			result = fmincon(reducer, ...
				[
					this.pressureLeft / scale.pressure
					this.pressureRight / scale.pressure
					this.flow / scale.flow
				], [], [], [], [], ...
				[0 0 this.flowLimits(1) / scale.flow], ...
				[100 100 this.flowLimits(2) / scale.flow], ...
				[], optimoptions( ...
					'fmincon', ...
			    	'Display', 'off' ...
			    ));
			% result = fsolve(reducer, ...
			% 	[
			% 		this.pressureLeft / scale.pressure
			% 		this.pressureRight / scale.pressure
			% 		this.flow / scale.flow
			% 	], optimoptions( ...
			% 		'fsolve', ...
			%     	'Display', 'off' ...
			%     ));

			this.pressureLeft = result(1) * scale.pressure;
			this.pressureRight = result(2) * scale.pressure;
			this.flow = result(3) * scale.flow;
		end
	end
end