% Implementation of Video Textures
% http://www.cc.gatech.edu/cpl/projects/videotexture/SIGGRAPH2000/videotex.pdf

% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%
INPUT_STRING = 'clock.mpg';       % Input video name
OUTPUT_STRING = 'clock_loop.avi'; % Output video name

% Algorithm settings
RANDOM_PLAY = true;
PRESERVE_MOTION = true;

% Parameters
NEIGHBORS = 2;

colormap gray;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

videoFrames = zeros(34, 240*240*3);

% Find number of frames
videoStream = VideoReader(INPUT_STRING);
frameRate = videoStream.FrameRate;
numFrames = 0;

i = 1;
while hasFrame(videoStream)
  videoFrames(i, :) = reshape(double(readFrame(videoStream)), 240*240*3, 1);
  numFrames = numFrames + 1;
  i = i + 1;
end

D = dist2(videoFrames, videoFrames);
D = circshift(D, [0 1]);

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

% Smaller values of sigma emphasize just the very best
% transitions, while larger values of sigma allow for
% greater variety at the cost of poorer transitions.
sigma = (sum(nonzeros(D)) ./ nnz(D)) * .05;

% Probabilities of jumping from frame i to j
P = exp(-D ./ sigma);

% Normalize probabilities across i so sum of Pij = 1 for all j
sumRows = sum(P, 2);
P = P ./ repmat(sumRows, 1, size(P, 2));


imagesc(P)

if RANDOM_PLAY
  videoOut = VideoWriter(OUTPUT_STRING);
  open(videoOut);
  
  totalFrames = numFrames * 5;
  countFrames = 0;
  curIndex = 1;
  
  while countFrames < totalFrames
    curFrame = reshape(uint8(videoFrames(curIndex, :)), 240, 240, 3);
    
    writeVideo(videoOut, curFrame);
    curIndex = discretesample(P(curIndex, :), 1);
    
    countFrames = countFrames + 1;
  end
end

close(videoOut);







