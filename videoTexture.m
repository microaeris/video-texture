% Implementation of the Video Textures
% http://www.cc.gatech.edu/cpl/projects/videotexture/SIGGRAPH2000/videotex.pdf

VIDEO_STRING = 'clock.mpg';

% Find number of frames
videoStream = VideoReader(VIDEO_STRING);
frameRate = videoStream.FrameRate;
numFrames = 0;
while hasFrame(videoStream) 
  readFrame(videoStream); 
  numFrames = numFrames + 1;
end

% Restart the video
videoStream1 = VideoReader(VIDEO_STRING);

% Info to create sparse matrix 
lenIndex = numFrames * numFrames;
D_i = zeros(1, lenIndex);
D_j = zeros(1, lenIndex);
D_s = zeros(1, lenIndex);

i = 1;
while hasFrame(videoStream1)
  frame1 = double(readFrame(videoStream1));
  videoStream2 = VideoReader(VIDEO_STRING);
  
  j = 1;
  while hasFrame(videoStream2)
    frame2 = double(readFrame(videoStream2));
    dist = sqrt(sum((frame1(:) - frame2(:)) .^ 2));
    
    curIndex = (j-1) * numFrames + i;
    D_i(curIndex) = i;
    D_j(curIndex) = j;
    D_s(curIndex) = dist;
    
    j = j + 1;
  end
  
  i = i + 1;
end

% Distance matrix between frames
D = sparse(D_i, D_j, D_s);

% Smaller values of σ emphasize just the
% very best transitions, while larger 
% values ofσ allow for greater variety
% at the cost of poorer transitions.
sigma = sum(nonzeros(D)) / nnz(D);


% Probabilities of jumping from frame i to j
P = exp(-1 * circshift(D, [0 -1]) / sigma);

% Normalize probabilities across i so sum of Pij = 1 for all j
sumRows = sum(P, 2);
P = P ./ repmat(sumRows, 1, numFrames);
% sum(P, 2)

% Random Play %%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose which frames to skip to
% Create a video that's twice the length
videoOut = VideoWriter('clock_loop.avi');
open(videoOut);

totalFrames = numFrames * 5;
countFrames = 0;
curIndex = 1;

while countFrames < totalFrames
  videoStream = VideoReader(VIDEO_STRING);
  videoStream.CurrentTime = curIndex / frameRate;
  curFrame = readFrame(videoStream);
  
  writeVideo(videoOut,curFrame);
  curIndex = discretesample(full(P(curIndex, :)), 1);
  
  countFrames = countFrames + 1;
end

close(videoOut);







