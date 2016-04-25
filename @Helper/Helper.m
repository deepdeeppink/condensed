classdef Helper < handle

	properties (Hidden)

		id
	end

	methods

		function this = Helper()

			this.id = java.rmi.server.UID();
		end
	end
end