classdef Native < Bridge.Abstract

	methods

		function this = Native()

            this.stateFunction = Function.Cached( ...
            	@this.nativeFunction, C.tolerance.velocity, C.tolerance.pressure);
		end

		function bridge = uminus(this)

			bridge = copyElement(this);
			this.stateFunction = @(Q) -this.nativeFunction(-Q);
		end
	end

	methods (Abstract)

		dP = nativeFunction(Q)
	end
end