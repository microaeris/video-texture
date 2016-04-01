% Implementation of Video Textures
% http://www.cc.gatech.edu/cpl/projects/videotexture/SIGGRAPH2000/videotex.pdf

% OPTIONS %%%%%%%%%%%%%%%%%%%%%%%%
INPUT_STRING = 'clock.mpg';       % Input video name
OUTPUT_STRING = 'clock_loop.avi'; % Output video name

% Algorithm settings
RANDOM_PLAY = true;
PRESERVE_MOTION = true;

% Parameters
NEIGHBORS = 1;

colormap gray
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

videoFrames = zeros(34, 240*240*3);

% Find number of frames
videoStream = VideoReader(INPUT_STRING);
frameRate = videoStream.FrameRate;
numFrames = 0;

i = 1;
while hasFrame(videoStream)
  videoFrames(i, :) = reshape(readFrame(videoStream), 1, 240*240*3);
  numFrames = numFrames + 1;
  i = i + 1;
end

% Restart the video
videoStream1 = VideoReader(INPUT_STRING);

% Vectors to create sparse matrix
lenIndex = numFrames * numFrames;
D_i = zeros(1, lenIndex);
D_j = zeros(1, lenIndex);
D_s = zeros(1, lenIndex);

i = 1;
k = 1;

for i = 1:34 %hasFrame(videoStream1)
  %frame1 = double(readFrame(videoStream1));
  frame1 = reshape(videoFrames(i, :), [240 240 3]);
  videoStream2 = VideoReader(INPUT_STRING);
  j = 1;
  
  for j = 1:34 % hasFrame(videoStream2)
    %frame2 = double(readFrame(videoStream2));
    frame2 = reshape(videoFrames(j, :), [240 240 3]);
    dist = sum((frame1(:) - frame2(:)).^2);
    
    D_i(k) = i;
    D_j(k) = j;
    D_s(k) = dist;
    
    j = j + 1;
    k = k + 1;
  end
  
  i = i + 1;
end

% Distance matrix between frames
D = sparse(D_i, D_j, D_s);

imshow(full(D), [0,1]);
% imagesc(full(circshift(D, [-1 0])));

if PRESERVE_MOTION
  % Weight neighboring frames to preserve continuous motion
  W_len = NEIGHBORS * 2;
  W = zeros(1, W_len);
  
  % Binomial coefficient weights
  for i = 1:W_len
    W(i) = nchoosek(W_len, i - 1);
  end
  
  W = diag(W);
  D = sparse(imfilter(full(D), W));
    
  [h, w] = size(D); 
  D = D(NEIGHBORS:h - NEIGHBORS, NEIGHBORS:w - NEIGHBORS);
end

% Smaller values of sigma emphasize just the very best
% transitions, while larger values of sigma allow for
% greater variety at the cost of poorer transitions.
sigma = sum(nonzeros(D)) / nnz(D) * .1;

% Probabilities of jumping from frame i to j
P = exp(-1 * circshift(D, [0 -1]) / sigma);

% Normalize probabilities across i so sum of Pij = 1 for all j
sumRows = sum(P, 2);
P = P ./ repmat(sumRows, 1, size(P, 2));

% imshow(full(D), [0 max(max(D))]);
% imagesc(full(D));
% imagesc(full(P));

if RANDOM_PLAY
  videoOut = VideoWriter(OUTPUT_STRING);
  open(videoOut);
  
  totalFrames = numFrames * 3; % was *5
  countFrames = 0;
  curIndex = 1;
  
  while countFrames < totalFrames
    videoStream = VideoReader(INPUT_STRING);
    videoStream.CurrentTime = curIndex / frameRate;
    curFrame = readFrame(videoStream);
    
    writeVideo(videoOut,curFrame);
    curIndex = discretesample(full(P(curIndex, :)), 1);
    
    countFrames = countFrames + 1;
  end
end

close(videoOut);







