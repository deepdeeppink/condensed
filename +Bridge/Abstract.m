classdef Abstract < matlab.mixin.Copyable

	properties (SetAccess=private)

		stateFunction
	end

	methods (Hidden)

		function setStateFunction(this, newStateFunction)

			this.stateFunction = newStateFunction;
		end

		function setNativeFunction(this, newNativeFunction)

			this.setStateFunction(Function.Common(newNativeFunction));
		end
	end
end