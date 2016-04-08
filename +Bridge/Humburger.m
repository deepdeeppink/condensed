classdef Humburger < Bridge.Native

	properties (SetAccess=protected)

		items
	end
	properties (Access=protected)

		lastStateResult
	end

	methods

		function this = Humburger(varargin)

			this = this@Bridge.Native();
			this.items = varargin;
			this.lastStateResult = 0;
		end

		function dP = nativeFunction(this, Q)

			solverOptions = optimoptions('fsolve', ...
		    	'Display', 'off' ...
		    );
		    reducer = this.createReducer(Q);
		    initialValues = [ this.lastStateResult / C.scale.pressure ones(1, length(this.items)) * Q / C.scale.velocity / length(this.items)];
		    res = fsolve(reducer, initialValues, solverOptions);
		    dP = res(1) * C.scale.pressure;
		    this.lastStateResult = dP;
		end

		function reducer = createReducer(this, Q)

			% x = [dP Q1 Q2 Q3 Q4 ...]
			index = 1:length(this.items);
			reducer = @(x) [
				Q - sum(arrayfun(@(i) x(i + 1), index)) ...
				arrayfun(@(i) ...
					x(1) - this.items{i}.stateFunction.eval(x(i + 1)), ...
					index)
			];
		end
	end
end