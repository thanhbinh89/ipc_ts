LDLIBS	+= ./deps/live555/UsageEnvironment/libUsageEnvironment.a
LDLIBS	+= ./deps/live555/groupsock/libgroupsock.a
LDLIBS	+= ./deps/live555/liveMedia/libliveMedia.a
LDLIBS	+= ./deps/live555/BasicUsageEnvironment/libBasicUsageEnvironment.a

CXXFLAGS	+= -I./deps/live555/UsageEnvironment/include
CXXFLAGS	+= -I./deps/live555/groupsock/include
CXXFLAGS	+= -I./deps/live555/liveMedia/include
CXXFLAGS	+= -I./deps/live555/BasicUsageEnvironment/include
