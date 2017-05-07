PREFIX  = /
ETC_DIR = $(PREFIX)/etc
LIB_DIR = $(PREFIX)/var/lib/keengreeper
LOG_DIR = $(PREFIX)/var/log/keengreeper
SHR_DIR = $(PREFIX)/usr/share/keengreeper
SRC_DIR = $(PREFIX)/usr/src/keengreeper
TMP_DIR = $(PREFIX)/var/tmp

deinstall:
	find utils -type f | while read file; \
	    do \
		if cmp $$file $(SHR_DIR)/$$file >/dev/null; then \
		    rm -f $(SHR_DIR)/$$file; \
		fi; \
	    done
	if cmp configure $(SHR_DIR)/configure >/dev/null; then \
	    rm -f $(SHR_DIR)/configure; \
	fi
	if cmp updateModules $(SHR_DIR)/updateModules >/dev/null; then \
	    rm -f $(SHR_DIR)/updateModules; \
	fi
	for d in $(LIB_DIR) $(LOG_DIR) $(SHR_DIR) $(SRC_DIR); \
	do \
	    if test -d "$$d"; then \
		rm -fr "$$d"; \
	    fi; \
	done
	test -f $(ETC_DIR)/keengreeper.conf && rm -f $(ETC_DIR)/keengreeper.conf

genconf:
	test -f $(ETC_DIR)/keengreeper.conf || \
	    ( \
		echo export WORKDIR=$(SRC_DIR); \
		echo export TMPDIR=$(TMP_DIR); \
		echo export LOGDIR=$(LOG_DIR); \
		echo export DBDIR=$(LIB_DIR); \
		echo export CACHETTL=3600; \
	    ) >$(ETC_DIR)/keengreeper.conf

installdeps:
	./utils/installNvm

installdirs:
	test -d $(ETC_DIR)       || mkdir -p $(ETC_DIR)
	test -d $(LIB_DIR)       || mkdir -p $(LIB_DIR)
	test -d $(LOG_DIR)       || mkdir -p $(LOG_DIR)
	test -d $(SHR_DIR)/utils || mkdir -p $(SHR_DIR)/utils
	test -d $(SRC_DIR)       || mkdir -p $(SRC_DIR)
	test -d $(TMP_DIR)       || mkdir -p $(TMP_DIR)

install: installdirs
	find utils -type f | while read file; \
	    do \
		install -c -m 0755 $$file $(SHR_DIR)/$$file; \
	    done
	install -c -m 0755 configure $(SHR_DIR)/configure
	install -c -m 0755 updateModules $(SHR_DIR)/updateModules

reset:
	rm -fr db work tmp log

test:
	test -d db   || mkdir db
	test -d work || mkdir work
	test -d tmp  || mkdir tmp
	test -d log  || mkdir log
	export PATH="`pwd`/utils:$$PATH"; \
	export DBDIR=`pwd`/db; \
	export WORKDIR=`pwd`/work; \
	export TMPDIR=`pwd`/tmp; \
	export LOGDIR=`pwd`/log; \
	for test in 01.repositories 02.ignored-modules 03.cached-modules 04.version; \
	    do \
		if test -x tests/$$test; then \
		    ./tests/$$test || exit 1; \
		fi; \
	    done
