# Distortion


## Installation
```
$git clone --recursive https://github.com/radiolok/distortionhdl.git
$ cd distortionhdl
$ sudo docker build -t distortion .
$ sudo docker run --rm -it -v ./:/var/vhdl --entrypoint /var/vhdl/run.sh distortion
```