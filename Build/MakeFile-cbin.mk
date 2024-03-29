$(PRE_CBIN_MkFiles):
	@mkdir -p $(BUILD_DIR)/$(notdir $(@D))
	@bash $(BUILD_DIR)/generateSrcInc.sh $(notdir $(@D)) c $(BUILD_DIR)/$(notdir $(@D))
	@bash $(BUILD_DIR)/renamePREREQ.sh $(notdir $(@D))
	@echo "# "$(TM) >$@
	@echo "" >>$@
	@echo "TARGET_$(notdir $(@D)) := $(notdir $(@D))" >>$@
	@echo "TARGET_DIR_$(notdir $(@D)) := $(@D)" >>$@
	@echo "TARGET_SRC_DIR_$(notdir $(@D)) := $(PWD)/$(notdir $(@D))" >>$@
	@echo "" >>$@
	@echo "#ifdef \$$(REVISION)" >>$@
	@echo "#REVISION_$(notdir $(@D)) := \$$(REVISION)" >>$@
	@echo "#else" >>$@
	@echo "#REVISION_$(notdir $(@D)) := \$$(bash $(BUILD_DIR)/getrevision.sh \$$(TARGET_DIR_$(notdir $(@D))))" >>$@
	@echo "#endif" >>$@
	@echo "#\$$(info $(notdir $(@D)) revision : \$$(REVISION_$(notdir $(@D))))" >>$@
	@echo "" >>$@
	@echo "include \$$(wildcard \$$(TARGET_SRC_DIR_$(notdir $(@D)))/prere*)" >>$@
	@echo "include \$$(wildcard \$$(TARGET_SRC_DIR_$(notdir $(@D)))prere*)" >>$@
	@echo "" >>$@
	@echo "include \$$(wildcard \$$(TARGET_DIR_$(notdir $(@D)))/localmak*)" >>$@
	@echo "include \$$(wildcard \$$(TARGET_DIR_$(notdir $(@D)))localmak*)" >>$@
	@echo "" >>$@
	@echo "ifdef PREREQ_$(notdir $(@D))" >>$@
	@echo "PREBUILDLIB_$(notdir $(@D)) := \$$(addprefix -l,\$$(PREREQ_$(notdir $(@D))))" >>$@
	@echo "PREBUILDREQ_$(notdir $(@D)) := \$$(addsuffix .so,\$$(addprefix \$$(BUILD_LIB)/lib,\$$(PREREQ_$(notdir $(@D)))))" >>$@
	@echo "else" >>$@
	@echo "endif" >>$@
	@echo "" >>$@
	@echo "ifdef PREREQ_H_$(notdir $(@D))" >>$@
	@echo "PRECOMPILEREQ_$(notdir $(@D)) := \$$(addprefix \$$(BUILD_INC)/, \$$(notdir \$$(wildcard \$$(addsuffix /include/*.h, \$$(PWD)/\$$(PREREQ_H_$(notdir $(@D)))))))" >>$@
	@echo "endif" >>$@
	@echo "" >>$@
	@echo "ifndef LOCALPRECOMPILE_$(notdir $(@D))" >>$@
	@echo "endif" >>$@
	@echo "" >>$@
	@echo "ifndef LOCALPREBUILD_$(notdir $(@D))" >>$@
	@echo "endif" >>$@
	@echo "" >>$@
	@echo "#SRC_$(notdir $(@D)) := \$$(wildcard \$$(TARGET_DIR_$(notdir $(@D)))/src/*.c)" >>$@
	@if [ "$(BUILDTYPE)" == "debug" ]; then \
		echo "LDFLAGS_$(notdir $(@D)) += -Wl,-O0" >>$@ ; \
	else \
		echo "LDFLAGS_$(notdir $(@D)) += -Wl,-O1" >>$@ ; \
	fi
	@echo "" >>$@
	@echo "" >>$@
	@echo "########################################################################################################################" >>$@
	@echo "" >>$@
	@echo "" >>$@
	@echo "DOBJ_$(notdir $(@D)) := \$$(patsubst %.c,%.d,\$$(addprefix \$$(sort \$$(addsuffix /Build/$(notdir $(@D))/,\$$(patsubst %/$(notdir $(@D))/src/,%,\$$(dir \$$(SRC_$(notdir $(@D))))))),\$$(notdir \$$(SRC_$(notdir $(@D))))))">>$@
	@echo "OBJ_$(notdir $(@D)) := \$$(DOBJ_$(notdir $(@D)):.d=.o)">>$@
	@echo "BINNAME_$(notdir $(@D)) := \$$(TARGET_DIR_$(notdir $(@D)))/$(notdir $(@D))" >>$@
	@echo "" >>$@
	@echo "$(notdir $(@D)): \$$(BUILD_BIN)/$(notdir $(@D))" >>$@
	@echo "\$$(BUILD_BIN)/$(notdir $(@D)): \$$(BINNAME_$(notdir $(@D)))" >>$@
	@echo -e "\t@cp \$$(TARGET_DIR_$(notdir $(@D)))/$(notdir $(@D)) \$$(BUILD_BIN)" >>$@
	@echo "" >>$@
	@echo "\$$(BINNAME_$(notdir $(@D))): \$$(PREBUILDREQ_$(notdir $(@D))) \$$(OBJ_$(notdir $(@D))) \$$(LOCALPREBUILD_$(notdir $(@D)))" >>$@
	@echo -e "\t@echo LD  \$$@ " >>$@
	@echo -e "\t@ln -sf \$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log \$$(SYSROOT_LOG)/err-$(notdir $(@D)).log" >>$@
	@echo -e "\t@\$$(CC) \$$(LDFLAGS) \$$(LDFLAGS_$(notdir $(@D))) -L\$$(BUILD_LIB) -o \$$@ \$$(OBJ_$(notdir $(@D))) \$$(PREBUILDLIB_$(notdir $(@D))) \$$(LDLIBS_$(notdir $(@D))) 2>>\$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log" >>$@
	@echo "" >>$@
	@echo "cclean-$(notdir $(@D)): \$$(LOCALPRECLEAN_$(notdir $(@D)))" >>$@
	@echo -e "\t@rm -f \$$(TARGET_DIR_$(notdir $(@D)))/prebuild \$$(DOBJ_$(notdir $(@D))) \$$(OBJ_$(notdir $(@D))) \$$(TARGET_DIR_$(notdir $(@D)))/*i \$$(TARGET_DIR_$(notdir $(@D)))/*s *~ core \$$(BINNAME_$(notdir $(@D)))">>$@
	@echo -e "\t@rm -rf \$$(TARGET_DIR_$(notdir $(@D)))" >>$@
	@echo "" >>$@
	@echo "\$$(OBJ_$(notdir $(@D))): \$$(SRC_$(notdir $(@D))) \$$(PRECOMPILEREQ_$(notdir $(@D))) \$$(LOCALPRECOMPILE_$(notdir $(@D)))" >>$@
	@echo -e "\t@\$$(eval CV := \$$(patsubst %.o,%.c,\$$(addprefix \$$(sort \$$(addsuffix /$(notdir $(@D))/src/,\$$(patsubst %/Build/$(notdir $(@D))/,%,\$$(dir \$$@)))),\$$(notdir \$$@))))" >>$@
	@echo -e "\t@echo CC \$$(CV)" >>$@
	@echo -e "\t@ln -sf \$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log \$$(SYSROOT_LOG)/err-$(notdir $(@D)).log" >>$@
	@if [ "$(BUILDTYPE)" == "virtual_debug" ]; then \
		echo -e "\t@\$$(CC) -D'VIRTUAL_DEBUG=1' -D'DEBUG' -D'REVISION=\"\$$(REVISION_$(notdir $(@D)))\"' \$$(CFLAGS) \$$(CFLAGS_$(notdir $(@D))) -O0 -g3 -I\$$(BUILD_INC) \$$(INC_$(notdir $(@D))) -c -o \$$@ \$$(CV) 2>>\$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log" >>$@ ; \
	elif [ "$(BUILDTYPE)" == "debug" ]; then \
		echo -e "\t@\$$(CC) -D'DEBUG' -D'REVISION=\"\$$(REVISION_$(notdir $(@D)))\"' \$$(CFLAGS) \$$(CFLAGS_$(notdir $(@D))) -O0 -g3 -I\$$(BUILD_INC) \$$(INC_$(notdir $(@D))) -c -o \$$@ \$$(CV) 2>>\$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log" >>$@ ; \
	else \
		echo -e "\t@\$$(CC) -D'REVISION=\"\$$(REVISION_$(notdir $(@D)))\"' \$$(CFLAGS) \$$(CFLAGS_$(notdir $(@D))) -O3 -feliminate-unused-debug-types -I\$$(BUILD_INC) \$$(INC_$(notdir $(@D))) -c -o \$$@ \$$(CV) 2>>\$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log" >>$@ ; \
	fi
	@echo "" >>$@
	@echo "" >>$@


