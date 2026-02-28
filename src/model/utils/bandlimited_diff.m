function dy = bandlimited_diff(y, Ts, tau)
%BANDLIMITED_DIFF Band-limited differentiator (dirty derivative).
%
%   dy = bandlimited_diff(y, Ts)
%   dy = bandlimited_diff(y, Ts, tau)
%
% Inputs
%   y   : 1xN (or Nx1) time series (assumed uniformly sampled)
%   Ts  : sampling interval [s] (scalar > 0)
%   tau : time constant [s] of the derivative low-pass (optional)
%         default: tau = 10*Ts
%
% Output
%   dy  : derivative estimate, same size as y
%
% Method (discrete-time):
%   dy(k) = a*dy(k-1) + b*(y(k) - y(k-1))
%   a = tau/(tau+Ts), b = 1/(tau+Ts)
%
% Notes
%   - First sample dy(1) is padded to keep same length (dy(1)=dy(2) if N>=2).
%   - This is a "dirty derivative": finite difference + 1st-order LPF.

    narginchk(2,3);

    % Validate Ts
    if ~isscalar(Ts) || ~isfinite(Ts) || Ts <= 0
        error('Ts must be a positive finite scalar.');
    end

    % Default tau
    if nargin < 3 || isempty(tau)
        tau = 10*Ts;
    end
    if ~isscalar(tau) || ~isfinite(tau) || tau < 0
        error('tau must be a nonnegative finite scalar.');
    end

    % Preserve input shape
    y_is_row = isrow(y);
    y = y(:);              % column
    N = numel(y);

    dy = zeros(N,1);

    if N == 0
        dy = reshape(dy, size(y)); %#ok<NASGU>
        return;
    elseif N == 1
        % No difference information; define as zero
        dy(1) = 0;
    else
        a = tau/(tau + Ts);
        b = 1/(tau + Ts);

        % Initialize using raw finite difference
        dy(2) = (y(2) - y(1))/Ts;

        % Recursive filtered derivative
        for k = 3:N
            dy(k) = a*dy(k-1) + b*(y(k) - y(k-1));
        end

        % Pad first sample to match length (hold dy(2))
        dy(1) = dy(2);
    end

    % Restore original shape
    if y_is_row
        dy = dy.';
    end
end
