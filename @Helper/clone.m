function instance = clone(instance, varargin)

	cx = eval(['@' class(instance)]);
	instance = cx(varargin{:});
end