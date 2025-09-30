


ffmpeg -i DJI_0343.MP4 -vf vidstabdetect=stepsize=6:shakiness=10:accuracy=15:result=transforms.trf -f null -
ffmpeg -i DJI_0343.MP4 -vf vidstabtransform=input=transforms.trf:zoom=5:smoothing=30:optalgo=gauss:maxshift=-1:maxangle=-1:crop=black:invert=0:relative=1:interpol=bilinear output.mp4




ffmpeg -i DJI_0343.MP4 -vf vidstabdetect=stepsize=1:shakiness=10:accuracy=15:result=transforms.trf -f null -
ffmpeg -i DJI_0343.MP4 -vf vidstabtransform=input=transforms.trf:zoom=50:smoothing=120:optalgo=gauss:maxshift=-1:maxangle=-1:crop=black:interpol=bicubic output.mp4
