classdef Cached < Function.Functor

	properties

		sourceFunction
	end

	properties
	% properties (Hidden)

		arguments
		results
		argumentTolerance
		resultTolerance
		interpolationMask
	end

	methods

		function this = Cached(sourceFunction, argumentTolerance, resultTolerance)

			this.sourceFunction = sourceFunction;
			this.argumentTolerance = argumentTolerance;
			this.resultTolerance = resultTolerance;
		end

		function y = eval(this, x)

			y = this.load(x);

			if isnan(y)

				disp(['non cached ' num2str(x)])
				y = this.sourceFunction(x);
				this.save(x, y);
			end
		end

		function save(this, x, y)

			index = find(this.arguments < x, 1, 'last');
			if ~any(index)
				index = 0;
			end
			this.arguments = [this.arguments(1:index) x this.arguments(index + 1:end)];
			this.results = [this.results(1:index) y this.results(index + 1:end)];
		end

		function y = load(this, x) % from cache

			y = NaN;

			% если в кэше есть минимум две точки
			if length(this.arguments) > 1

				% находим индекс ближайшей точки слева
				index = find(this.arguments <= x, 1, 'last');
				% если таковая есть
				if any(index)

					% если точка совпадает с искомой
					if this.arguments(index) == x

						y = this.results(index);
					% если справа есть точки (искомая точка находится на отрезке)
					elseif index < length(this.arguments)

						% длина отрезка
						dx = this.arguments(index + 1) - this.arguments(index);
						% % высота отрезка
						% dy = this.results(index + 1) - this.results(index);
						% % если отрезок достаточно мал
						% if dx <= this.argumentTolerance && dy <= this.resultTolerance
						if dx <= this.argumentTolerance

							% интерполируем значение в точке!
							y = interp1(this.arguments(index:index + 1), this.results(index:index + 1), x);
						end
					end
				end
			end

			% если точку не нашли и хотя бы одна точка есть
			if isnan(y) && length(this.arguments) > 0

				% найдем ближайшую точку и расстояние до нее
				[dx, index] = min(abs(this.arguments - x));
				% если точка совпадает
				if dx == 0

					y = this.results(index);
				% если точка находится достаточно близко к искомой
				elseif dx < this.argumentTolerance

					% определяем направление до точки
					direction = sign(this.arguments(index) - x);
					% вычисляем значение с запасом
					nx = this.arguments(index) - this.argumentTolerance * direction;
					ny = this.sourceFunction(nx);
					% вычислим высоту полученного отрезка
					dy = abs(ny - this.results(index));
					% % если высота достаточно мала
					% if dy <= this.resultTolerance
						% интерполируем искомое значение
						y = interp1([nx this.arguments(index)], [ny this.results(index)], x);
						% и сохраняем рассчитанное (!обязательно после интерполяции)
						this.save(nx, ny);
					% end
				end
			end
		end
	end
end