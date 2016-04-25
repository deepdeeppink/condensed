classdef C

	properties (Constant)
		
		airPressure = 101325
		vaporPressure = .3 *  C.airPressure
		soundSpeed = 1.1e+3
		gravity = 9.81 
		viscosity = 1e-5
		height = 0
		slope = 0
		density = 850
		coordinateStep = 2
		timeStep = C.coordinateStep / C.soundSpeed

		scale = struct( ...
			'velocity', 10, ...
			'flow', 10, ...
			'pressure', 1e+10)

		tolerance = struct( ...
			'velocity', 2, ...
			'flow', 1, ...
			'pressure', 100)

		solverOptions = optimoptions( ...
			@fsolve, ...
			'Algorithm', 'levenberg-marquardt', ...
	    	'Display', 'off' ...
	    )
	end

	methods (Static)

		l = lambda(velocity, viscosity, diameter)
	end
end