function sv = soft_thresholding(v,lambda)
    sv = zeros(size(v));
    sv(abs(v)>lambda) = v(abs(v)>lambda) - sign(v(abs(v)>lambda))*lambda;
end