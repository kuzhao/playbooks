### Useful docker builds
This folder contains sophisticated yet tested Dockerfiles which produce images fitting peculiar purposes.  
Use them like any ordinary Dockerfile: docker build . -t <image:tag> -f <dockerfilename>  
|Script|Synopsis|
|---|---|
|base_toolkit|Pack specified Linux tools, in ubuntu packages, into an image for debug purposes|
|nginx-module|Compile nginx dynamic modules and integrate into the corresponding nginx version|
