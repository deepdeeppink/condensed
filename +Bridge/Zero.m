classdef Zero < Bridge.Native

	methods

		function this = Zero()

			this = this@Bridge.Native();
		end

		function dP = nativeFunction(~, ~)

			dP = 0;
		end
	end
end