classdef Abstract < Helper

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
			reducer = @(x) [
				dp_(x) - this.stateFunction(q_(x))
				outerFunction(x)
			];

			solve = @() fsolve( ...
				reducer, [
					this.pressureLeft / scale.pressure
					this.pressureRight / scale.pressure
					this.flow / scale.flow
				], C.solverOptions);
			solveLeft = @(flow) fsolve( ...
				@(x) outerFunction([x; flow / scale.flow]), [
					this.pressureLeft / scale.pressure
					this.pressureRight / scale.pressure
				], C.solverOptions);
			solveRight = @(flow) fsolve( ...
				@(x) outerFunction([x; flow / scale.flow]), [
					this.pressureLeft / scale.pressure
					this.pressureRight / scale.pressure
				], C.solverOptions);

			if this.flowLimits(1) == this.flowLimits(2)

				flow = this.flowLimits(1);
				result = [
					solveLeft(flow)
					solveRight(flow)
				];
			else

				result = solve();
				flow = result(3) * scale.flow;
				if flow < this.flowLimits(1)

					flow = this.flowLimits(1);
					result = [
						solveLeft(flow)
						solveRight(flow)
					];
				elseif this.flowLimits(2) < flow

					flow = this.flowLimits(2);
					result = [
						solveLeft(flow)
						solveRight(flow)
					];
				end
			end

			this.flow = flow;
			this.pressureLeft = result(1) * scale.pressure;
			this.pressureRight = result(2) * scale.pressure;
		end
	end
end