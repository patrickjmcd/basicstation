ARCH=$(arch)

source env.vars
echo "building for $ARCH"
make platform=rpi variant=std arch=$ARCH
make platform=corecell variant=std arch=$ARCH