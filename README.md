# Distortion


## Installation
```
$git clone --recursive https://github.com/radiolok/distortionhdl.git
$ cd distortionhdl
$ sudo docker build -t distortion .
$ sudo docker run --rm -it -v ./vhdl:/var/vhdl --entrypoint /var/vhdl/run.sh distortion
```