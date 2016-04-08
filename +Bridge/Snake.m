classdef Snake < Bridge.Native

	properties (SetAccess=protected)

		items
	end

	methods

		function this = Snake(varargin)

			this = this@Bridge.Native();
			this.items = varargin;
		end

		function dP = nativeFunction(this, Q)
			
			subFunctions = cellfun(@(bridge) bridge.stateFunction, this.items, 'UniformOutput', false);
			dP = sum(cellfun(@(f) f(Q), subFunctions));
		end
	end
end