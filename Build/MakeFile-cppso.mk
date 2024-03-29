$(PRE_CPPSO_MkFiles):
	@mkdir -p $(BUILD_DIR)/$(notdir $(@D))
	@bash $(BUILD_DIR)/generateSrcInc.sh $(notdir $(@D)) cpp $(BUILD_DIR)/$(notdir $(@D))
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
	@echo "#SRC_$(notdir $(@D)) := \$$(wildcard \$$(TARGET_DIR_$(notdir $(@D)))/src/*.cpp)" >>$@
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
	@echo "SODOBJ_$(notdir $(@D)) := \$$(patsubst %.cpp,%.d,\$$(filter %.cpp,\$$(addprefix \$$(sort \$$(addsuffix /Build/$(notdir $(@D))/,\$$(patsubst %/$(notdir $(@D))/src/,%,\$$(dir \$$(SRC_$(notdir $(@D))))))),\$$(notdir \$$(SRC_$(notdir $(@D)))))))" >>$@
	@echo "SODOBJC_$(notdir $(@D)) += \$$(patsubst %.c,%.d,\$$(filter %.c,\$$(addprefix \$$(sort \$$(addsuffix /Build/$(notdir $(@D))/,\$$(patsubst %/$(notdir $(@D))/src/,%,\$$(dir \$$(SRC_$(notdir $(@D))))))),\$$(notdir \$$(SRC_$(notdir $(@D)))))))" >>$@
	@echo "SOOBJ_$(notdir $(@D)) := \$$(SODOBJ_$(notdir $(@D)):.d=SO.o)">>$@
	@echo "SOOBJC_$(notdir $(@D)) := \$$(SODOBJC_$(notdir $(@D)):.d=SO.o)">>$@
	@echo "SONAME_$(notdir $(@D)) := \$$(TARGET_DIR_$(notdir $(@D)))/lib$(notdir $(@D)).so" >>$@
	@echo "" >>$@
	@echo "lib$(notdir $(@D)): \$$(BUILD_LIB)/lib$(notdir $(@D)).so" >>$@
	@echo "\$$(BUILD_LIB)/lib$(notdir $(@D)).so: \$$(SONAME_$(notdir $(@D)))" >>$@
	@echo -e "\t@cp \$$(TARGET_DIR_$(notdir $(@D)))/lib$(notdir $(@D)).so \$$(BUILD_LIB)" >>$@
	@echo "" >>$@
	@echo "\$$(SONAME_$(notdir $(@D))): \$$(PREBUILDREQ_$(notdir $(@D))) \$$(SOOBJ_$(notdir $(@D))) \$$(SOOBJC_$(notdir $(@D))) \$$(LOCALPREBUILD_$(notdir $(@D)))" >>$@
	@echo -e "\t@echo LD  \$$@ " >>$@
	@echo -e "\t@ln -sf \$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log \$$(SYSROOT_LOG)/err-$(notdir $(@D)).log" >>$@
	@echo -e "\t@\$$(CXX) \$$(LDFLAGS) \$$(LDFLAGS_$(notdir $(@D))) -L\$$(BUILD_LIB) -shared -fPIC -Wl,-soname,lib$(notdir $(@D)).so -o \$$@ \$$(SOOBJ_$(notdir $(@D))) \$$(SOOBJC_$(notdir $(@D))) \$$(PREBUILDLIB_$(notdir $(@D))) \$$(LDLIBS_$(notdir $(@D))) 2>>\$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log" >>$@
	@echo "" >>$@
	@echo "soclean-$(notdir $(@D)): \$$(LOCALPRECLEAN_$(notdir $(@D)))" >>$@
	@echo -e "\t@rm -f \$$(TARGET_DIR_$(notdir $(@D)))/prebuild \$$(SODOBJ_$(notdir $(@D))) \$$(SODOBJC_$(notdir $(@D))) \$$(SOOBJ_$(notdir $(@D))) \$$(SOOBJC_$(notdir $(@D))) \$$(TARGET_DIR_$(notdir $(@D)))/*i \$$(TARGET_DIR_$(notdir $(@D)))/*s *~ core \$$(SONAME_$(notdir $(@D)))">>$@
	@echo -e "\t@rm -rf \$$(TARGET_DIR_$(notdir $(@D)))" >>$@
	@echo "" >>$@
	@echo "\$$(SOOBJ_$(notdir $(@D))): \$$(SRC_$(notdir $(@D))) \$$(PRECOMPILEREQ_$(notdir $(@D))) \$$(LOCALPRECOMPILE_$(notdir $(@D)))" >>$@
	@echo -e "\t@\$$(eval CV := \$$(patsubst %SO.o,%.cpp,\$$(addprefix \$$(sort \$$(addsuffix /$(notdir $(@D))/src/,\$$(patsubst %/Build/$(notdir $(@D))/,%,\$$(dir \$$@)))),\$$(notdir \$$@))))" >>$@
	@echo -e "\t@echo CXX  \$$(CV)" >>$@
	@echo -e "\t@ln -sf \$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log \$$(SYSROOT_LOG)/err-$(notdir $(@D)).log" >>$@
	@if [ "$(BUILDTYPE)" == "debug" ]; then \
		echo -e "\t@\$$(CXX) -D'DEBUG' -D'REVISION=\"\$$(REVISION_$(notdir $(@D)))\"' \$$(CXXFLAGS) \$$(CFLAGS_$(notdir $(@D))) -O0 -g3 -I\$$(BUILD_INC) \$$(INC_$(notdir $(@D))) -fPIC -c -o \$$@ \$$(CV) 2>>\$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log" >>$@ ; \
	else \
		echo -e "\t@\$$(CXX) -D'REVISION=\"\$$(REVISION_$(notdir $(@D)))\"' \$$(CXXFLAGS) \$$(CFLAGS_$(notdir $(@D))) -O3 -feliminate-unused-debug-types -I\$$(BUILD_INC) \$$(INC_$(notdir $(@D))) -shared -fPIC -c -o \$$@ \$$(CV) 2>>\$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log" >>$@ ; \
	fi
	@echo "" >>$@
	@echo "\$$(SOOBJC_$(notdir $(@D))): \$$(SRC_$(notdir $(@D))) \$$(PRECOMPILEREQ_$(notdir $(@D))) \$$(LOCALPRECOMPILE_$(notdir $(@D)))" >>$@
	@echo -e "\t@\$$(eval CV := \$$(patsubst %SO.o,%.c,\$$(addprefix \$$(sort \$$(addsuffix /$(notdir $(@D))/src/,\$$(patsubst %/Build/$(notdir $(@D))/,%,\$$(dir \$$@)))),\$$(notdir \$$@))))" >>$@
	@echo -e "\t@echo CXX  \$$(CV)" >>$@
	@echo -e "\t@ln -sf \$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log \$$(SYSROOT_LOG)/err-$(notdir $(@D)).log" >>$@
	@if [ "$(BUILDTYPE)" == "virtual_debug" ]; then \
		echo -e "\t@\$$(CXX) -D'VIRTUAL_DEBUG=1' -D'DEBUG' -D'REVISION=\"\$$(REVISION_$(notdir $(@D)))\"' \$$(CXXFLAGS) \$$(CFLAGS_$(notdir $(@D))) -O0 -g3 -I\$$(BUILD_INC) \$$(INC_$(notdir $(@D))) -fPIC -c -o \$$@ \$$(CV) 2>>\$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log" >>$@ ; \
	elif [ "$(BUILDTYPE)" == "debug" ]; then \
		echo -e "\t@\$$(CXX) -D'DEBUG' -D'REVISION=\"\$$(REVISION_$(notdir $(@D)))\"' \$$(CXXFLAGS) \$$(CFLAGS_$(notdir $(@D))) -O0 -g3 -I\$$(BUILD_INC) \$$(INC_$(notdir $(@D))) -fPIC -c -o \$$@ \$$(CV) 2>>\$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log" >>$@ ; \
	else \
		echo -e "\t@\$$(CXX) -D'REVISION=\"\$$(REVISION_$(notdir $(@D)))\"' \$$(CXXFLAGS) \$$(CFLAGS_$(notdir $(@D))) -O3 -feliminate-unused-debug-types -I\$$(BUILD_INC) \$$(INC_$(notdir $(@D))) -shared -fPIC -c -o \$$@ \$$(CV) 2>>\$$(BUILD_LOG)/err-$(notdir $(@D))-\$$(TM).log" >>$@ ; \
	fi
	@echo "" >>$@
	@for ff in `ls $(PWD)/$(notdir $(@D))/include/*.h`; do \
			bff=$$(basename $$ff) ; \
			echo "\$$(BUILD_INC)/$$bff: \$$(BUILD_INC)" >>$@ ; \
			echo -e "\t@ln -f $$ff \$$(BUILD_INC)/$$bff" >>$@ ; \
			echo "" >>$@ ; \
		done
	@echo "" >>$@
	@echo "" >>$@


