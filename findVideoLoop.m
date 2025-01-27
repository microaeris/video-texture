function [ videoLoop ] = findVideoLoop( D, primitiveLoops, L, numFrames )

% primitiveLoops = [];
% for i = 1:numFrames
%   for j = 1:numFrames
%     if i >= j 
%       primitiveLoops = [primitiveLoops [i; j]];
%     end
%   end
% end

% Build the DP table to find the optimal compound loop
dp = zeros(L, length(primitiveLoops), L*2 + 1);

% dp is a cube where the first slice is the cost, and the remaining
% slices are indicies into primitiveLoops. You can retreieve the compound
% loop using these indicies.

% First, initialize the top row of dp
for cell = 1:size(dp, 2)
  i = primitiveLoops(1, cell);
  j = primitiveLoops(2, cell);
  
  if i - j == 1 % The length must be 1 in the first row
    % Store the cost and primitive loop (i, j) in DP
    dp(1, cell, 1) = D(i,j);
    dp(1, cell, 2) = j;
    dp(1, cell, 3) = i;
  end
end

% Rdp(1, 2, 2:end);
% comploop = reshape(dp(1, 2, 2:end), 2, length(dp(1, 2, 2:end))/2)
% sum(diff(comploop, 2))

% Now fill in the rest
for i = 2:size(dp, 1)
  [i size(dp, 1)]
  for j = 1:size(dp, 2)
    column = dp(1:i-1, j, :);
    minCost = inf;
    minMatchedCol = -1;
    minMatchedRow = -1;
    minRow = -1;
    
    % Try all compound loops of shorter length in the same column
    for k = size(column, 1):-1:1
      compoundLoop = dp(k, j, 2:end);
      compoundLoop = reshape(compoundLoop, 2, length(compoundLoop)/2);
      compoundLoopCost = dp(k, j, 1);
      compoundLoopLen = sum(compoundLoop(2,:)-compoundLoop(1,:));
      
      % -----------------------------------------------------
      
      % Check the edge case where our only match is our own
      % primative loop
      p_end = primitiveLoops(1, j);
      p_start = primitiveLoops(2, j);
      primLoopLen = p_end - p_start;
      
      
      if compoundLoopLen == 0 && i == primLoopLen
        % Add primative loop as new comp loop
        dp(i,j,1) = D(p_start, p_end);
        dp(i,j,2) = p_start;
        dp(i,j,3) = p_end;
        break
      end
      
      % -----------------------------------------------------
      
      % Catch the case where we want to append the primitive
      % loop to the current compound loop
      if compoundLoopLen + primLoopLen == i
        minCost = D(p_start, p_end) + compoundLoopCost;
        dp(i,j,1) = minCost;
        baseLoop = nonzeros(dp(k,j,2:end));
        
        newLoop = [baseLoop; p_start; p_end];
%         reshape(newLoop,1,1,length(newLoop));
        dp(i,j,2:length(newLoop)+1) = reshape(newLoop,1,1,length(newLoop));
      end
      
      % -----------------------------------------------------
      
      % Try to combine with compound loops from columns
      % whose primitive loops have ranges that overlap that of
      % of the column being considered
      
      for m = 1:size(dp, 2)
        % Overlap checks if the first pair (i, j)
        % from the primitive loop overlaps with any
        % primitive loop (i', j') from the compound loop
        if overlappingLoops(primitiveLoops(:, m), compoundLoop)
          
          % Cost of the potential match of prim loop m
          matchedLen = i - compoundLoopLen;
          matchedCost = dp(matchedLen, m, 1);
          totalCost = matchedCost + compoundLoopCost;
          
          if matchedCost ~= 0 && totalCost < minCost
            minCost = totalCost;
            minMatchedCol = m;
            minMatchedRow = matchedLen;
            minRow = k;
          end
        end
      end
    end
    
    % -----------------------------------------------------
    
    if minMatchedCol ~= -1
      matchedLoop = dp(minMatchedRow, minMatchedCol, 2:end);
      matchedLoopLen = size(matchedLoop, 3);
      matchedLoop = reshape(matchedLoop, 1, matchedLoopLen);
      
      baseLoop = dp(minRow, j, 2:end);
      
      % Save the new cost and compound loop
      dp(i,j,1) = dp(minMatchedRow, minMatchedCol, 1) + dp(minRow, j, 1);
      baseLoopLen = length(nonzeros(baseLoop));
      
      reshape((nonzeros(baseLoop)), 2, length(nonzeros(baseLoop))/2);
      reshape((matchedLoop), 2, length(dp(i, j, 2:end))/2);
      
      newLoop = [nonzeros(baseLoop); matchedLoop(1:end-baseLoopLen)'];
      dp(i,j,2:end) = reshape(newLoop, 1,1,length(newLoop));
    end
  end
end

for i = 1:size(primitiveLoops, 2)
  if dp(L,i,1) == 0
    dp(L,i,1) = inf;
  end
end
% dp(L,:,1)

% Get the min compound loop out
[~, index] = min(dp(L,:,1));
videoLoop = dp(L,index,2:end);