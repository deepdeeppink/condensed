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
			this.flowLimits = [
				sum(cellfun(@(i) i.flowLimits(1), this.items))
				sum(cellfun(@(i) i.flowLimits(2), this.items))
			];
			this.lastStateResult = 0;
		end

		% TODO: remove override
		function instance = clone(this)

			cx = eval(['@' class(this)]);
			instance = cx(this.items{:});
		end

		function dP = nativeFunction(this, Q)

		    reducer = this.createReducer(Q);
		    initialValues = [
		    	this.lastStateResult / C.scale.pressure
		    	ones(length(this.items), 1) * Q / length(this.items) / C.scale.flow
		    ];
		    result = fsolve(reducer, initialValues, C.solverOptions);
		    dP = result(1) * C.scale.pressure;

	    	flows = result(2:end) * C.scale.flow;
	    	mask = true(size(flows));
		    for index = 1:length(flows)

		    	item = this.items{index};
		    	if flows(index) < item.flowLimits(1)

		    		flows(index) = item.flowLimits(1);
		    	elseif item.flowLimits(2) < flows(index)
		    		
		    		flows(index) = item.flowLimits(2);
		    	else

		    		mask(index) = false;
		    	end
		    end

			dPs = arrayfun( ...
				@(i) this.items{i}.stateFunction(flows(i)), ...
				find(mask));
			if ~isempty(dPs) && std(dPs) ~= 0
				error('Humburger: Fixed flows not match')
			end
			
		    if all(mask)
			
				dP = dPs(1);
		    elseif any(mask)

		    	initialValues = [
		    		initialValues(1)
		    		flows(~mask) / C.scale.flow
		    	];
		    	reducer = this.createFixedReducer(Q, flows(mask), mask);
		    	result = fsolve(reducer, initialValues, C.solverOptions);
		    	dP = result(1) * C.scale.pressure;
		    	% TODO: potential issue with dP ~= mean(dPs)
		    end

		    this.lastStateResult = dP;
		end

		% x = [dP Q1 Q2 Q3 Q4 ...]
		function reducer = createFixedReducer(this, Q, flows, mask)

			index = find(~mask);
			reducer = @(x) [
				Q - sum(flows) - sum(x(2:end)) * C.scale.flow
				arrayfun(@(i) ...
					x(1) * C.scale.pressure - this.items{index(i)}.stateFunction(x(i + 1) * C.scale.flow), ...
					1:length(index))'
			];
		end
		function reducer = createReducer(this, Q)

			index = 1:length(this.items);
			reducer = @(x) [
				Q - sum(x(2:end)) * C.scale.flow
				arrayfun(@(i) ...
					x(1) * C.scale.pressure - this.items{i}.stateFunction(x(i + 1) * C.scale.flow), ...
					index)'
			];
		end
	end
end