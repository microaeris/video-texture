function [ overlap ] = overlappingLoops( primLoop, compLoop )
% primLoop should is 2*1, (end, start)
% compLoop should already be reshaped. (start; end)

compStart = nonzeros(compLoop(1,:));
compEnd = nonzeros(compLoop(2,:));
primEnd = repmat(primLoop(1), length(compStart), 1);
primStart = repmat(primLoop(2), length(compEnd), 1);

% Beginning of comp loops should start before end of primLoop
test1 = compStart - primEnd;

% End of comp loops should start after start of primLoop
test2 = compEnd - primStart;

% End of comp loop should start after end of primLoop
test3 = compEnd - primEnd;

test4 = compStart - primStart;

overlap = any(test1 < 0) && any(test2 > 0) ... % Center
 || any(test1 < 0) && any(test3 > 0) ...       % Left
 || any(test4 < 0) && any(test2 > 0);          % Right

end

