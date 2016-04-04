function convertToAVI(videoString, outputString)
% CONVERTTOAVI
% Converts a video to avi. Useful if you have
% a video editor that can't handle .mp4, but you'd
% like to, say, crop it manually before you 
% do some computation on it.

v = VideoReader(videoString);
o = VideoWriter(outputString);
open(o);
while hasFrame(v)
  f = readFrame(v);
  writeVideo(o, f);
end
close(o);
