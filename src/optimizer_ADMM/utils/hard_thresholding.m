function x = hard_thresholding(v, gamma)
    x = v;
    x(2*gamma>v.^2) = 0;
end