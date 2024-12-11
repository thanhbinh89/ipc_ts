###############################################################################
# author: Thanhbinh89
# date: 17/04/2024
###############################################################################
NAME_MODULE	= ipc_ts
CROSS		= 
SYS_ROOT	= /
CXX			= $(CROSS)g++
CC			= $(CROSS)gcc
STRIP		= $(CROSS)strip
OBJ_DIR		= build_$(NAME_MODULE)

OPTIMIZE_OPTION	=	-g -s -O3
WARNNING_OPTION	+=	#-Werror -W -Wno-missing-field-initializers

-include deps/Makefile.mk
-include src/Makefile.mk

# CXX compiler option
CXXFLAGS	+=\
		$(OPTIMIZE_OPTION)	\
		$(WARNNING_OPTION)	\
		-std=c++17			\
		-Wall				\
		-pipe				\
		-ggdb				\
		-I$(SYS_ROOT)usr/include
# Library paths
LDFLAGS	+= -Wl,-Map=$(OBJ_DIR)/$(NAME_MODULE).map
LDFLAGS += -L$(SYS_ROOT)usr/lib -Wl,-rpath-link,$(SYS_ROOT)usr/lib

#Library libs
LDLIBS	+= ./deps/live555/UsageEnvironment/libUsageEnvironment.a
LDLIBS	+= ./deps/live555/groupsock/libgroupsock.a
LDLIBS	+= ./deps/live555/liveMedia/libliveMedia.a
LDLIBS	+= ./deps/live555/BasicUsageEnvironment/libBasicUsageEnvironment.a
		
all: create live555 $(OBJ_DIR)/$(NAME_MODULE)
	@ls -alh $(OBJ_DIR)/$(NAME_MODULE)

create:
	@echo mkdir -p $(OBJ_DIR)
	@mkdir -p $(OBJ_DIR)

live555: deps/live555/UsageEnvironment/libUsageEnvironment.a
	cd deps/live555 && make -j2

$(OBJ_DIR)/%.o: %.cpp
	@echo CXX $<
	@$(CXX) -c -o $@ $< $(CXXFLAGS) $(LDFLAGS)

$(OBJ_DIR)/%.o: %.c
	@echo CXX $<
	@$(CC) -c -o $@ $< $(CXXFLAGS) $(LDFLAGS)

$(OBJ_DIR)/$(NAME_MODULE): $(OBJ)
	@echo ---------- START LINK PROJECT ----------
	@echo $(CXX) -o $@ $^ $(CXXFLAGS)
	@$(CXX) -o $@ $^ $(CXXFLAGS) $(LDFLAGS) $(LDLIBS)

.PHONY: flash
flash:
	@sudo LD_LIBRARY_PATH=/usr/local/lib/ $(OBJ_DIR)/$(NAME_MODULE)

.PHONY: debug
debug:
	sudo gdb $(OBJ_DIR)/$(NAME_MODULE)

.PHONY: install
install:
	cp $(OBJ_DIR)/$(NAME_MODULE) /usr/local/bin

.PHONY: clean
clean:
	@echo rm -rf $(OBJ_DIR)
	@rm -rf $(OBJ_DIR)

.PHONY: strip
strip:
	@echo 'Before strip'
	@ls -alh $(OBJ_DIR)/$(NAME_MODULE)
	@$(STRIP) $(OBJ_DIR)/$(NAME_MODULE)
	@echo 'After strip'
	@ls -alh $(OBJ_DIR)/$(NAME_MODULE)