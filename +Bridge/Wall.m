classdef Wall < Bridge.Zero

	methods

		function this = Wall()

			this = this@Bridge.Zero();
			this.flowLimits = [0 0];
		end
	end
end