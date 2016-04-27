classdef Native < Bridge.Abstract

	properties

		direction = 1
	end

	methods

		function this = Native()

			this.stateFunction = Function.Cached( ...
				@this.directionWrapper, C.tolerance.flow, C.tolerance.pressure);
		end

		function bridge = uminus(this)

			bridge = this.clone();
			bridge.direction = -this.direction;
			bridge.flowLimits = -this.flowLimits(end:-1:1);
		end
	end

	methods (Access=protected)

		function dP = directionWrapper(this, Q)

			dP = this.direction * this.nativeFunction(this.direction * Q);
		end
	end

	methods (Abstract)

		dP = nativeFunction(this, Q)
	end
end