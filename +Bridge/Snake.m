classdef Snake < Bridge.Native

	properties (SetAccess=protected)

		items
	end

	methods

		function this = Snake(varargin)

			this = this@Bridge.Native();
			this.items = varargin;
			this.flowLimits = [
				max(cellfun(@(i) i.flowLimits(1), this.items))
				min(cellfun(@(i) i.flowLimits(2), this.items))
			];
		end

		% TODO: remove override
		function instance = clone(this)

			cx = eval(['@' class(this)]);
			instance = cx(this.items{:});
		end

		function dP = nativeFunction(this, Q)
			
			subFunctions = cellfun(@(bridge) bridge.stateFunction, this.items, 'UniformOutput', false);
			dP = sum(cellfun(@(f) f(Q), subFunctions));
		end
	end
end