classdef CheckValve < Bridge.Zero

	methods

		function this = CheckValve()

			this = this@Bridge.Zero();
			this.flowLimits = [0 Inf];
		end
	end
end