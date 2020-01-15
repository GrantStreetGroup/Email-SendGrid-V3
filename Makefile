SHARE_DIR := $(shell \
	carton exec perl -Ilib -MFile::ShareDir=dist_dir -e \
		'print eval { dist_dir("Dist-Zilla-PluginBundle-Author-GSG") }')

ifneq ($(SHARE_DIR),)
include $(SHARE_DIR)/Makefile.inc
endif

# Copy the SHARE_DIR Makefile over this one:
# Making it .PHONY will force it to copy even if this one is newer.
.PHONY: Makefile
Makefile: $(SHARE_DIR)/Makefile.inc
	cp $< $@

# Seems something went wrong and SHARE_DIR is empty,
# that means we need to complain and bail out.
# Hopefully the shell command above provided a useful message.
/Makefile.inc:
	@echo Something went wrong, make sure you followed the instructions >&2
	@echo 'to install carton and run "carton install".' >&2
	@false
