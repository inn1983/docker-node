FROM cubieboard.info:5000/armv7hf-node-devel:4.0.0

RUN apt-get update
RUN apt-get install -y libopencv-dev python-opencv
#RUN apt-get install -y v4l-utils
RUN ln -s /wkdir/imgdiff/imgdiff /usr/bin/imgdiff

#CMD [ "node" ]
