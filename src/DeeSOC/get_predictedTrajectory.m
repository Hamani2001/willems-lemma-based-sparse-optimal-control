function y = get_predictedTrajectory(Yf,g,yDim)
    
trajectVec = Yf*g;
TimeLength = length(trajectVec)/yDim;

y = zeros(TimeLength,yDim);

for index = 1:TimeLength
    for dimNum = 1:yDim
        y(index,dimNum) = trajectVec(yDim*(index-1)+dimNum);
    end
end

y = formatDataAlign(y,TimeLength);
end