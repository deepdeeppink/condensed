function l = lambda(velocity, viscosity, diameter)

	Re = abs(velocity) * diameter / viscosity;

	if Re < 10

		l = 6.4;
	elseif Re < 2300

		l = 64 / Re;
	elseif Re >= 2300 && Re < 10000

		k = (Re - 2300) / (10000 - 2300);
		l = (1 - k) * 64 / Re + k * 0.3164 / Re^0.25;
	else

		l = 0.3164 / Re^0.25;
	end
