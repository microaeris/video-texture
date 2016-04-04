% Implementation of Video Textures
% http://www.cc.gatech.edu/cpl/projects/videotexture/SIGGRAPH2000/videotex.pdf

% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%
INPUT_STRING = 'clock.mpg';       % Input video name
OUTPUT_STRING = 'clock_loop.avi'; % Output video name

% Algorithm settings
RANDOM_PLAY = false;
VIDEO_LOOPS = true;
PRESERVE_MOTION = false;

% Parameters
NEIGHBORS = 2;
SIGMA_MULTIPLE = .05;
OUTPUT_LENGTH_FACTOR = 5;

colormap gray;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

videoFrames = zeros(34, 240*240*3);

%% Find number of frames
videoStream = VideoReader(INPUT_STRING);
numFrames = 0; i = 1;
while hasFrame(videoStream)
  videoFrames(i, :) = reshape(double(readFrame(videoStream)), 240*240*3, 1);
  numFrames = numFrames + 1;
  i = i + 1;
end

%% Construct D, the distance matrix
D = dist2(videoFrames, videoFrames);
D = circshift(D, [0 1]);

%% Preserve dynamics by filtering D
if PRESERVE_MOTION
  % Weight neighboring frames to preserve continuous motion
  W_len = NEIGHBORS * 2;
  W = zeros(1, W_len);
  
  % Binomial coefficient weights
  for i = 1:W_len
    W(i) = nchoosek(W_len, i - 1);
  end
  
  W = diag(W);
  D = imfilter(D, W);
  
  [h, w] = size(D);
  D = D(NEIGHBORS:h - NEIGHBORS, NEIGHBORS:w - NEIGHBORS);
end

%% Construct P
% Smaller values of sigma emphasize just the very best
% transitions, while larger values of sigma allow for
% greater variety at the cost of poorer transitions.
sigma = (sum(nonzeros(D)) ./ nnz(D)) * SIGMA_MULTIPLE;

% Probabilities of jumping from frame i to j
P = exp(-D ./ sigma);

% Normalize probabilities across i so sum of Pij = 1 for all j
sumRows = sum(P, 2);
P = P ./ repmat(sumRows, 1, size(P, 2));

%% Write out the video texture
videoOut = VideoWriter(OUTPUT_STRING);
open(videoOut);
totalFrames = numFrames * OUTPUT_LENGTH_FACTOR;
countFrames = 0;

if RANDOM_PLAY
  curIndex = 1;
  while countFrames < totalFrames
    curFrameIdx = reshape(uint8(videoFrames(curIndex, :)), 240, 240, 3);
    writeVideo(videoOut, curFrameIdx);
    curIndex = discretesample(P(curIndex, :), 1);
    countFrames = countFrames + 1;
  end
elseif VIDEO_LOOPS
  totalFrames = 20; % remove me
  
  videoLoop = findVideoLoop(D, totalFrames, numFrames);
  videoLoop = schedule(videoLoop);
  curFrameIdx = videoLoop(2, 1);
  for i = 1:length(videoLoop)
    curLoop = videoLoop(:, i);
    
    % Loop to the next start
    while curFrameIdx <= curLoop(2)
      curFrame = reshape(uint8(videoFrames(curFrameIdx, :)), ...
        240, 240, 3);
      writeVideo(videoOut, curFrameIdx);
      curFrameIdx = curFrameIdx + 1;
    end
    
    % Jump to the start
    curFrameIdx = curLoop(1);
    
    % Loop to the end
    while curFrameIdx <= curLoop(2)
      curFrame = reshape(uint8(videoFrames(curFrameIdx, :)), ...
        240, 240, 3);
      writeVideo(videoOut, curFrameIdx);
      curFrameIdx = curFrameIdx + 1;
    end
    
    % Go back to start frame
    curFrameIdx = curLoop(1);
  end
end

close(videoOut);
