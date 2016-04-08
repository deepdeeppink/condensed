classdef Abstract < matlab.mixin.Copyable

	methods (Abstract)

		value = eval(this, argument)
	end
end