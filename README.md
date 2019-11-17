diskimage-builder
=================

This directory contains a toolset to create qcow2 images with the help of a container which runs the diskimage builder of the  OpenStack project (https://diskimage-builder.readthedocs.io/en/latest/index.html).


```
+-------+         +-----------+         +-------+
| image |         |   DIB     |         | qcow2 |
| .yml  | ------> | container | ------> | image |
+-------+         +-----------+         +-------+
```

License: Apache License 2.0
Author: Bernard Tsai (bernard@tsai.eu)
Date: 2019-11-17

---

Creating the diskimage builder container
----------------------------------------

Following prequisites have to be met:

a) access to the internet
b) docker installed

Change into the **docker** subdirectory and invoke the script **build_diskimage_builder_container.sh** which will create an image with the name **tsai/diskimage-builder** in the local docker image repository:

```
> cd docker
> build_diskimage_builder_container.sh
```

This docker image provides a runtime environment for creating images, e.g. the following command:

```
docker run -i --privileged tsai/diskimage-builder /bin/bash < image.sh
```

will take the commands defined in the file **image.sh** and create an image with the name "image.qcow2" in the directory **/opt/builder** of the container.

---

Creating a qcow2 image
----------------------

The script **create_qcow_image.sh** takes a filename of a yaml configuration file as input and creates a qcow2 image with the name **image.qcow2** in the **work** subdirectory.

```
> create_qcow_image.sh <image.yaml>
```

The input file is basically a yaml file with a set of key/value pairs. These are converted into a set of environment variables embedded into a script (**image.sh**) located in the **work** subdirectory.
 This script then serves as input for the diskimage builder container as described above.

Following variables are supported:

- **ELEMENTS**: a list of diskimage builder elements to be used,
- **PARAMETERS**: parameters for the diskimage create command and
- **DIB_...**: environment variables for configuring the build process of the elements.

Example image yaml definition files can be found in the **images** subdirectory.

Custom scripts can be integrated into the build process by adding scripts to the **custom** subdirectory and adding the "custom" element to the list of elements in the **ELEMENTS** environment variable.

---

Debugging
---------

The creation of a qcow2 image may fail for several reasons. In order to facilitate the debugging of any errors add following line to the input file:

```
DIB_DEBUG_TRACE: "1"
```

It instructs diskimage builder to capture tracing information which will be captured in a log file **image.log** in the **work** subdirectory.

---
