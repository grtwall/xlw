#Describes the xll 
BUILD=DEBUG
LIBRARY = LoggerDemo
LIBTYPE=SHARE
LIBPREFIX=
EXT_SHARE=xll

#Describes the Linker details
ifeq ($(PLATFORM), x64)
LIBDIRS = ../../../lib/x64
else
LIBDIRS = ../../../lib
endif
ifeq ($(BUILD),DEBUG)
LIBS=xlw-gcc-s-gd-5_0_0a3
else
LIBS=xlw-gcc-s-5_0_0a3
endif 

#Describes the Compiler details
INCLUDE_DIR =../common_source  ../../../include
CXXFLAGS = 


#The source
SRC_DIR=../common_source
LIBSRC = xlwLogger.cpp \
		 Test.cpp \
		 xlwTest.cpp 
		
MAKEDIR = ../../../make
include $(MAKEDIR)/make.rules
include $(MAKEDIR)/make.targets