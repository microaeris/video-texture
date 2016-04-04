function [ scheduled ] = schedule( compoundLoop )
% Reshape compoundLoop
compoundLoop = double(nonzeros(compoundLoop));
compoundLoop = reshape(compoundLoop, 2, length(compoundLoop)/2, 1)

numScheduled = 1;
scheduled = zeros(2, size(compoundLoop, 2));
[~, last] = max(compoundLoop(2, :));
scheduled(:, numScheduled) = compoundLoop(:, last);
numScheduled = numScheduled + 1;
j = scheduled(1, 1);
compoundLoop(:, last) = [];

for k = 1:size(scheduled, 2) - 1
  % Find min end index that starts after j
  minEnd = scheduled(2, 1); % last possible frame
  minCompLoopIdx = 0;
  
  for i = 1:size(compoundLoop, 2)
    if compoundLoop(2, i) >= j && compoundLoop(2, i) <= minEnd
      minCompLoopIdx = i;
      minEnd = compoundLoop(2, i);
    end
  end
  
  % Schedule this loop, since it's the first loop
  % that has an end > j
  scheduled(:, numScheduled) = compoundLoop(:, minCompLoopIdx);
  numScheduled = numScheduled + 1;
  % Remove the loop from compoundLoop
  j = compoundLoop(1, minCompLoopIdx);
  compoundLoop(:, minCompLoopIdx) = [];
end

