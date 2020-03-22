## https://github.com/bstarynk/helpcovid file Makefile

## License:
##    This HelpCovid program is free software: you can redistribute it
##    and/or modify it under the terms of the GNU General Public
##    License as published by the Free Software Foundation, either
##    version 3 of the License, or (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program.  If not, see <http://www.gnu.org/licences>

.PHONY: all clean indent deploy

HELPCOVID_SOURCES := $(wildcard hcv*.cc)
HELPCOVID_OBJECTS := $(patsubst %.cc, %.o, $(HELPCOVID_SOURCES))
HELPCOVID_HEADERS := $(wildcard hcv*.hh)

HELPCOVID_BUILD_CCACHE = ccache
HELPCOVID_BUILD_CC = gcc
HELPCOVID_BUILD_CXX = g++
HELPCOVID_BUILD_DIALECTFLAGS = -std=gnu++17
HELPCOVID_BUILD_WARNFLAGS = -Wall -Wextra
HELPCOVID_BUILD_OPTIMFLAGS = -O0 -g3
HELPCOVID_PKG_CONFIG = pkg-config
HELPCOVID_PKG_NAMES =  jsoncpp libpqxx
HELPCOVID_PKG_CFLAGS:= $(shell $(HELPCOVID_PKG_CONFIG) --cflags $(HELPCOVID_PKG_NAMES))
HELPCOVID_PKG_LIBS:= $(shell $(HELPCOVID_PKG_CONFIG) --libs $(HELPCOVID_PKG_NAMES))


## we link most libraries statically, hoping that the resulting ELF
## executable might run on various Linux distributions
LIBES= -Bstatic $(HELPCOVID_PKG_LIBS) -lunistring  /usr/lib64/libstdc++.a  -Bdynamic -rdynamic -ldl
RM= rm -f
MV= mv
CC = $(HELPCOVID_BUILD_CCACHE) $(HELPCOVID_BUILD_CC)
CXX = $(HELPCOVID_BUILD_CCACHE) $(HELPCOVID_BUILD_CXX)
CXXFLAGS += $(HELPCOVID_BUILD_DIALECTFLAGS) $(HELPCOVID_BUILD_OPTIMFLAGS) \
            $(HELPCOVID_BUILD_CODGENFLAGS) \
	    $(HELPCOVID_BUILD_WARNFLAGS) $(HELPCOVID_BUILD_INCLUDE_FLAGS) \
	    $(HELPCOVID_PKG_CFLAGS) -DHELPCOVID_GITID=\"$(HELPCOVID_GIT_ID)\"
LDFLAGS += -rdynamic -pthread -L /usr/local/lib -L /usr/lib

all:
	if [ -f helpcovid ] ; then  $(MV) -f --backup helpcovid helpcovid~ ; fi
	$(RM) __timestamp.o __timestamp.c
	$(MAKE) $(MAKEFLAGS) helpcovid



## we prefer to link the C++ library statically, some of them are incompatible
## the resulting executable might be more portable to various Linux distro.
helpcovid: $(HELPCOVID_OBJECTS) __timestamp.o
	$(LINK.c) $(HELPCOVID_OBJECTS)  __timestamp.o \
           $(LIBES) -o $@-tmp
	$(MV) --backup $@-tmp $@
	$(MV) --backup __timestamp.c __timestamp.c~
	$(RM) __timestamp.o

__timestamp.c:
	./generate-timestamp.sh > $@-tmp
	$(MV) --backup $@-tmp $@

clean:
	$(RM) *~ *% *.orig *.o helpcovid *tmp core*

indent:
	./indent-cxx-files.sh $(HELPCOVID_SOURCES) $(HELPCOVID_HEADERS)

# The xdg-open call is temporary, meant for showing how the front-end web pages
# currently look. It will be replaced by a call to the helpcovid application
test:
	xdg-open webroot/html/signin.html

