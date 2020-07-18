I love small projects, micro services, privacy, and empowering the user. When I saw this tweet I thought that this sounded like a great evening problem to solve; whats the easiest way I could accomplish this?

![Copy of a tweet by @j0hnnyxm4s](https://thepracticaldev.s3.amazonaws.com/i/knxaodb0z5z4gioh4s9b.png)


### Lets Break It Down! 
* Faces can be detected in video and images.
* A video file is a collection of still images. 
* Detected faces can be blurred.
* Images can be combined to video.

This seems like a pretty straight forward method of accomplishing our goal. Not trying to reinvent the wheel I decided to use tried and true tools in addition to some python and bash code.

>FFmpeg is a free and open-source project consisting of a vast software suite of libraries and programs for handling video, audio, and other multimedia files and streams.

Using FFmpeg we're able to quickly and easily explode a video into images and set them up for processing.
```bash
#!/bin/bash
echo "{EXPLODE}"
mkdir -p explode;
FRAMERATE=$(ffmpeg -i $1 2>&1 | sed -n "s/.*, \(.*\) fp.*/\1/p")
ffmpeg -i $1 -r 1 explode/%04d.jpeg -hide_banner;
```
With our video frames pulled out we can process each one through some code that will identify and apply a blurring filter to a face.

```python
frame = cv2.imread(currentFile)
# Resize frame of video to 1/4 size for faster face detection processing
small_frame = cv2.resize(frame, (0, 0), fx=0.25, fy=0.25)
# Find all the faces and face encodings in the current frame of video
face_locations = face_recognition.face_locations(small_frame)
# Display the results

for top, right, bottom, left in face_locations:
	# Scale back up face locations
	top *= 4
	right *= 4
	bottom *= 4
	left *= 4

	# Extract the region of the image that contains the face
	face_image = frame[top:bottom, left:right]

	# Blur the face image
	face_image = cv2.GaussianBlur(face_image, (99, 99), 30)

	# Put the blurred face region back into the frame image
	frame[top:bottom, left:right] = face_image
	
# Write the resulting image
cv2.imwrite("./blur/"+ str(currentFile).split('/')[1] , frame)
```
 > Snippet of [.\.master/blur.py](https://github.com/echohtp/EZ-VideoFaceBlur/blob/master/blur.py)

Nice! We're most of the way there, all we have to do is stitch the video back together and we'll have a video with the faces blurred out. 

Back to using FFmpeg and providing it a folder of processed images we can easily generate a video file. 

```bash
ffmpeg -i ./blur/%04d.jpeg -vcodec mpeg4 -r 25 ./out.avi;
```
![A gif interview of Conor McGregor with faces blurred](https://github.com/echohtp/EZ-VideoFaceBlur/blob/master/output.gif?raw=true)

This method worked well for the proof of concept I wanted to produce. This is not a perfect turn-key method to blur faces from videos. There can be issues with the FFmpeg command based on file input. There are cases where a face is turned to where it fails detection but is still very clearly identifiable. 
