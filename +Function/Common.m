classdef Common < Function.Abstract
	
	properties

		nativeFunction
    end

	methods

		function this = Common(nativeFunction)

			this.nativeFunction = nativeFunction;
		end

		function value = eval(this, argument)

			value = this.nativeFunction(argument);
		end
	end
end