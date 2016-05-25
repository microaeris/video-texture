# video-textures

![](http://jmecom.github.io/images/video-textures/city-4.gif)

#### [Full writeup here.](http://jmecom.github.io/projects/computational-photography/video-textures/)

Developed by [Jordan Mecom](http://jmecom.github.io) and [Alice Wang](http://github.com/ahris).

This project implements the paper '’Video Textures’’ by Schodl, Szeliski, Salesin, and Essa. 
The aim is to create a ‘‘new type of medium’’ called a video texture, which is ‘‘somewhere between a photograph and a video’’.
The idea is to input a video which has some repeated motion (the texture), such as a flag waving, rain, or a candle flame. 
The output is a new video that infinitely extends the original video in a seameless way. In practice, the output isn’t really
infinte, but is instead looped using a video player and is sufficiently long as to appear to never repeat.
