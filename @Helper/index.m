function ix = index(instance, varargin)

	narginchk(1, 2);
	ix = 1:length(instance);
	if nargin > 1
		ix = ix(varargin{1});
	end
end