function pi = projection_operator(v,maxV)
    pi = sign(v).*min(abs(v),maxV);
end