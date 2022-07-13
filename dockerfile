FROM alpine:3.16 AS build

ENV PREFIX="/home/opt/cross"
ENV TARGET=i686-elf
ENV PATH="$PREFIX/bin:$PATH"
WORKDIR /usr/src

RUN apk add --no-cache bison flex g++ make texinfo mpc1-dev mpfr-dev gmp-dev 

RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.38.tar.gz
RUN tar -xzf binutils-2.38.tar.gz

RUN wget https://ftp.gnu.org/gnu/gcc/gcc-12.1.0/gcc-12.1.0.tar.gz
RUN tar -xzf gcc-12.1.0.tar.gz

RUN mkdir build && cd build && ../binutils-2.38/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror \
    && make && make install && cd .. && rm -rf build

RUN mkdir build && cd build && ../gcc-12.1.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers \
    && make all-gcc && make all-target-libgcc && make install-gcc && make install-target-libgcc && cd .. && rm -rf build

FROM alpine:3.16

ENV TARGET=i686-elf
ENV PATH="/opt/cross/bin:$PATH"
WORKDIR /usr/src

COPY --from=build /home/opt/cross /opt/cross
