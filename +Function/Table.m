classdef Table < Function.Abstract
	
	properties

		values
	end

	methods

		function this = Table(arguments, values)

			this = this@Function.Abstract(arguments);
			this.values = values;
		end

		function value = eval(this, argument)

			value = interp1(this.arguments, this.values, argument);
		end

		function plot(this, varargin)

			plot(this.arguments, this.values, varargin{:});
		end
	end
end