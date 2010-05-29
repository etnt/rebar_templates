include dep.inc

all:
	erl -pa $(GETTEXT_EBIN) -make

# Run this the very first time after creating the project
init:
	-mkdir ebin
	-mkdir dep
	-mkdir -p www/css/
	-mkdir -p www/js
	-mkdir -p www/nitrogen
	-(cd www/nitrogen; ln -s {{nitro_dir}}/apps/nitrogen/www/nitrogen.css .)
	-(cd www/nitrogen; ln -s {{nitro_dir}}/apps/nitrogen/www/nitrogen.js .)
	-(cd www/nitrogen; ln -s {{nitro_dir}}/apps/nitrogen/www/livevalidation.js .)
	-mkdir templates
	-chmod +x ./start.sh
	-(for i in \`ls dep/*\`; do cd \${i}; make; done)
	cp src/{{appid}}.app.src ebin/{{appid}}.app 
	$(MAKE) all

clean:
	rm -rf ./ebin/*.beam


# ----------------------------------------------------------------------
#                       GETTEXT SUPPORT
#                       ---------------
# GETTEXT_EBIN
#  Path to the gettext ebin directory.
#
# GETTEXT_PO_DIR
#  Set this to a directory where we have write access.
#  This directory will hold all po-files and the dets DB file.
#  Example: 'GETTEXT_DIR=$(MY_APP_DIR)/priv'
#
# GETTEXT_DEF_LANG
#  Set the language code of the default language (e.g en,sv,...), 
#  i.e the language you are using in the string arguments to the
#  ?TXT macros. Example: 'GETTEXT_DEF_LANG=en'
#
# GETTEXT_TMP_NAME
#  Set this to an arbitrary name.
#  It will create a subdirectory to $(GETTEXT_DIR) where
#  the intermediary files of this example will end up.
#  Example: 'GETTEXT_TMP_NAME=tmp'
#
gettext: clean $(GETTEXT_PO_DIR)/lang/$(GETTEXT_TMP_NAME)/epot.dets 

$(GETTEXT_PO_DIR)/lang/$(GETTEXT_TMP_NAME)/epot.dets:
	@(export GETTEXT_TMP_NAME=$(GETTEXT_TMP_NAME); \\
	  export GETTEXT_DIR=$(GETTEXT_PO_DIR); \\
	  export GETTEXT_DEF_LANG=$(GETTEXT_DEF_LANG); \\
	  export ERL_COMPILER_OPTIONS="[gettext]"; \\
	  rm -f $(GETTEXT_PO_DIR)/lang/$(GETTEXT_TMP_NAME)/epot.dets; \\
	  erl -pa $(GETTEXT_EBIN) -make; \\
	  erl -noshell -pa $(GETTEXT_EBIN) -s gettext_compile epot2po; \\
	  install -D $(GETTEXT_PO_DIR)/lang/$(GETTEXT_TMP_NAME)/$(GETTEXT_DEF_LANG)/gettext.po $(GETTEXT_PO_DIR)/lang/default/$(GETTEXT_DEF_LANG)/gettext.po; \\
	  rm -rf $(GETTEXT_PO_DIR)/lang/$(GETTEXT_TMP_NAME))

