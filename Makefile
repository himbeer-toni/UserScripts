SHELL = /bin/bash
TARGETS = smop crnupdate fetch-missing-ca
UTARGETS = 

BINDIR	= ~/bin
OWNER		= pi
GROUP		= pi

USRBIN	= /usr/local/bin
UOWNER	= root
UGROUP	= root

all: bins usrs

bins: $(TARGETS)
	@for n in $(TARGETS);\
	do \
	if [ -e $$n ];then \
	  diff -q $$n $(BINDIR)/$$n > /dev/null;\
	fi;\
	if [ "$$?" != "0"	];then \
	   echo installing $(BINDIR)/$$n;\
	   install -o $(OWNER) -g $(GROUP) -m 755 -t $(BINDIR) $$n;\
	fi;\
	done

usrs: $(UTARGETS)
	@for n in $(UTARGETS);\
	do \
	if [ -e $$n ];then \
	  diff -q $$n $(USRBIN)/$$n > /dev/null;\
	fi;\
	if [ "$$?" != "0"	];then \
	   echo installing $(USRBIN)/$$n;\
	   sudo install -o $(UOWNER) -g $(UGROUP) -m 755 -t $(USRBIN) $$n;\
	fi;\
	done

copyright: $(TARGETS) $(UTARGETS)
	@for n in $(TARGETS) $(UTARGETS);\
	do \
	echo crnupdate -r $$n;\
	crnupdate -r $$n;\
	done

usage:
	@echo "please use"
	@echo "  make"
	@echo "  or"
	@echo "  make copyright"
