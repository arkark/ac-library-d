AC_LIBRARY_FILE_NAME:=ac-library.zip
AC_LIBRARY_URL:=https://img.atcoder.jp/practice2/$(AC_LIBRARY_FILE_NAME)
AC_LIBRARY_DIRECTORY:=ac-library

SRC_DIRECTORY:=src

$(AC_LIBRARY_DIRECTORY)/$(AC_LIBRARY_FILE_NAME):
	wget -P $(AC_LIBRARY_DIRECTORY) $(AC_LIBRARY_URL)
	unzip -d $(AC_LIBRARY_DIRECTORY) $(AC_LIBRARY_DIRECTORY)/$(AC_LIBRARY_FILE_NAME)

.PHONY: clean-ac-library
clean-ac-library:
	git clean -x $(AC_LIBRARY_DIRECTORY) --force

.PHONY: download-ac-library
download-ac-library: $(AC_LIBRARY_DIRECTORY)/$(AC_LIBRARY_FILE_NAME)

.PHONY: browse-docs
browse-docs: download-ac-library
	# Required: https://docs.python.org/3/library/http.server.html
	http-server $(AC_LIBRARY_DIRECTORY) -o document_ja

.PHONY: format
format:
	dub run --build=release dfmt -- \
		--inplace \
		--indent_size=2 \
		--brace_style=otbs \
		--template_constraint_style=conditional_newline \
		--keep_line_breaks=true \
		$(SRC_DIRECTORY)

.PHONY: combine
combine:
	@echo "WIP"
