ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += adv-cmds
DOWNLOAD         += https://opensource.apple.com/tarballs/adv_cmds/adv_cmds-$(ADV-CMDS_VERSION).tar.gz
ADV-CMDS_VERSION := 174.0.1
DEB_ADV-CMDS_V   ?= $(ADV-CMDS_VERSION)

adv-cmds-setup: setup
	$(call EXTRACT_TAR,adv_cmds-$(ADV-CMDS_VERSION).tar.gz,adv_cmds-$(ADV-CMDS_VERSION),adv-cmds)
	mkdir -p $(BUILD_STAGE)/adv-cmds/usr/bin

	# Mess of copying over headers because some build_base headers interfere with the build of Apple cmds.
	mkdir -p $(BUILD_WORK)/adv-cmds/include
	cp -a $(MACOSX_SYSROOT)/usr/include/tzfile.h $(BUILD_WORK)/adv-cmds/include

ifneq ($(wildcard $(BUILD_WORK)/adv-cmds/.build_complete),)
adv-cmds:
	@echo "Using previously built adv-cmds."
else
adv-cmds: adv-cmds-setup ncurses
	cd $(BUILD_WORK)/adv-cmds; \
	$(CXX) $(ARCH) -isysroot $(SYSROOT) $(PLATFORM_VERSION_MIN) -DPLATFORM_iPhoneOS -o $(BUILD_STAGE)/adv-cmds/usr/bin/locale locale/*.cc; \
	$(CC) $(CFLAGS) -L $(BUILD_BASE)/usr/lib -DPLATFORM_iPhoneOS -o $(BUILD_STAGE)/adv-cmds/usr/bin/tabs tabs/*.c -lncursesw; \
	for bin in finger last lsvfs cap_mkdb; do \
    	$(CC) $(ARCH) -isysroot $(SYSROOT) $(PLATFORM_VERSION_MIN) -isystem include -DPLATFORM_iPhoneOS -o $(BUILD_STAGE)/adv-cmds/usr/bin/$$bin $$bin/*.c -D'__FBSDID(x)='; \
	done
	cd $(BUILD_WORK)/adv-cmds/mklocale; \
	yacc -d yacc.y; \
	lex lex.l
	$(CC) $(ARCH) -isysroot $(SYSROOT) $(PLATFORM_VERSION_MIN) -isystem include -DPLATFORM_iPhoneOS -o $(BUILD_STAGE)/adv-cmds/usr/bin/mklocale $(BUILD_WORK)/adv-cmds/mklocale/*.c -D'__FBSDID(x)='
	touch $(BUILD_WORK)/adv-cmds/.build_complete
endif

adv-cmds-package: adv-cmds-stage
	# adv-cmds.mk Package Structure
	rm -rf $(BUILD_DIST)/adv-cmds
	
	# adv-cmds.mk Prep adv-cmds
	cp -a $(BUILD_STAGE)/adv-cmds $(BUILD_DIST)

	# adv-cmds.mk Sign
	$(call SIGN,adv-cmds,general.xml)
	
	# adv-cmds.mk Make .debs
	$(call PACK,adv-cmds,DEB_ADV-CMDS_V)
	
	# adv-cmds.mk Build cleanup
	rm -rf $(BUILD_DIST)/adv-cmds

.PHONY: adv-cmds adv-cmds-package
