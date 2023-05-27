FROM quay.io/pypa/manylinux_2_24_x86_64
WORKDIR /root/
ARG NUM_CORES=8

RUN echo deb http://deb.debian.org/debian buster main > /etc/apt/sources.list && \
    echo deb http://deb.debian.org/debian buster-updates main >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y apt-transport-https ca-certificates

RUN echo deb https://mirrors.zju.edu.cn/debian/ buster main contrib non-free > /etc/apt/sources.list && \
   echo deb https://mirrors.zju.edu.cn/debian/ buster-updates main contrib non-free >> /etc/apt/sources.list && \
   echo deb https://mirrors.zju.edu.cn/debian/ buster-backports main contrib non-free >> /etc/apt/sources.list && \
   echo deb https://mirrors.zju.edu.cn/debian-security buster/updates main contrib non-free >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    libgmp-dev \
    libmpfr-dev \
    libgmpxx4ldbl \
    libboost-dev \
    libboost-thread-dev \
    libblas-dev liblapack-dev \
    zip unzip patchelf && \
    apt-get clean && \
    git clone --recursive https://github.com/PyMesh/PyMesh.git

ENV PYMESH_PATH /root/PyMesh
ENV NUM_CORES $NUM_CORES
ENV PATH="/opt/python/cp38-cp38/bin:${PATH}"
WORKDIR $PYMESH_PATH

RUN pip install -r $PYMESH_PATH/python/requirements.txt && \
    python ./setup.py bdist_wheel && \
    rm -rf build_3.8 third_party/build && \
    sed -i 's/not os.path.exists(dep_lib)/not os.path.exists(dep_lib) and "librt" not in dep_lib/' docker/patches/package_dependencies.py && \
    python $PYMESH_PATH/docker/patches/patch_wheel.py dist/pymesh2*.whl && \
    pip install dist/pymesh2*.whl && \
    python -c "import pymesh; pymesh.test()"

RUN sed -i 's/path.endswith(".py")/path.endswith(".py") or "third_party" in path/' /opt/_internal/pipx/venvs/auditwheel/lib/python3.10/site-packages/auditwheel/elfutils.py && \
    auditwheel repair dist/pymesh2*.whl
