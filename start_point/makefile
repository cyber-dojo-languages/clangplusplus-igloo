CXXFLAGS += -I. -std=c++1z -Wall -Wextra -Werror
CXXFLAGS += -Wshadow
CXXFLAGS += -Wfloat-equal
CXXFLAGS += -O
CXXFLAGS += -Wsequence-point
CXXFLAGS += -Wmissing-noreturn
CXXFLAGS += -Wunreachable-code

CXXFLAGS += -fsanitize=leak,address
CXXFLAGS += -fno-sanitize-recover=undefined
CXXFLAGS += -fno-omit-frame-pointer

HPP_FILES = $(wildcard *.hpp)
COMPILED_HPP_FILES = $(patsubst %.hpp,%.compiled_hpp,$(HPP_FILES))
CPP_FILES = $(wildcard *.cpp)

.PHONY: test.output
test.output: test makefile
	@./$<

test: makefile $(CPP_FILES) $(COMPILED_HPP_FILES)
	@$(CXX) $(CXXFLAGS) -O $(CPP_FILES) -o $@

# This rule ensures header files build in their own right.
# The quality of header files is important because header files
# are #included from other files and thus have a large span
# of influence (unlike .cpp files which are not #included)

%.compiled_hpp: %.hpp
	@$(CXX) -x c++ $(CXXFLAGS) -c -o $@ $<
