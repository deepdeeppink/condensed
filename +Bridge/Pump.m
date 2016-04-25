classdef Pump < Bridge.Native

	properties (SetAccess=protected)

		rate
	end

	methods

		function this = Pump(rate)

			this = this@Bridge.Native();
			this.rate = rate;
			this.flowLimits = [0 Inf];
		end

		% TODO: remove override
		function instance = clone(this)

			cx = eval(['@' class(this)]);
			instance = cx(this.rate);
		end

		function dP = nativeFunction(this, Q)

			N = this.rate;
			Ro = C.density;
			a_0 = 1.33;
			a_1 = -2.522;
			a_2 = -520.369;
			a_3 = -37.509;
			dP_0 = C.airPressure;
			Q_0 = 3.6 / 60;
			if N < 1e-2

				dP = 0;
			elseif Q < 0

				dP = Ro * a_0 * N^2 + dP_0 * (exp(- Q / Q_0) - 1);
			else

				Q_N = Q / N;
				a = @(q) Ro * (a_0 + a_1 * q + a_2 * q^2 + a_3 * q^3) * N^2;
				dP = a(Q_N);
				if dP < 0
					
					dP = 0;
				else

					D = 4 * a_2 - 12 * a_1 * a_3; 
					if D >= 0

						Q_Nl = (-2 * a_2 - sqrt(D)) / 2 / a_1;
						Q_Nr = (-2 * a_2 + sqrt(D)) / 2 / a_1;
						dP_l = a(Q_Nl);
						dP_r = a(Q_Nr);
						if dP_r > dP_l && Q_Nr > Q_N && dP_r > dP

							dP = dP_r;
						else
							
							dP = dP_l;
						end
					end
				end
			end
		end
	end
end