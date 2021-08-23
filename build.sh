ARCH=$(arch)

source env.vars

make platform=rpi variant=std arch=$ARCH
make platform=corecell variant=std arch=$ARCH