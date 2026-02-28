function x = firm_thresholding(y, c1, c2)
    % solve arg_min_x{1/2||y-x||_2^2 + \gambda \tilda{\labmbda}||x||_MC}
    % c_1 : zero threshold
    % c_2 : Gradient Threshold

    if c2 - c1 <= 0
        error('firm_thresholding :< c1はc2より大きくしてください')
    end

    x = zeros(size(y));

    % if c1<|y|<=c2
    index = c1<abs(y) & abs(y)<=c2;
    x(index) = sign(y(index)).*(abs(y(index))-c1)*c2/(c2-c1);

    % if |y|>c2
    index = abs(y)>c2;
    x(index) = y(index);
end