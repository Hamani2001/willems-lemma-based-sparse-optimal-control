function Yend = generate_TerminalState(Yf,yDim,cfg)
Yend = Yf(end-cfg.terminalLength*yDim+1:end,:);
end