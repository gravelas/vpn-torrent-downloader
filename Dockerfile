FROM debian AS build

RUN apt-get update; apt-get install cmake curl libssl-dev libcurl4-openssl-dev zlib1g-dev libevent-dev git; 

RUN git clone --recurse-submodules https://github.com/transmission/transmission transmission; cd transmission; cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo; cd build; cmake --build 

FROM polkaned/expressvpn

COPY --from=build transmission/build/daemon/transmission-daemon transmission/build/utils/tranmission-* /usr/bin/

