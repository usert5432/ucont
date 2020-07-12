
define expand_file_paths
    awk                                                 \
        -v prefix="$(PREFIX)"                           \
        -v bindir="$(BINDIR)"                           \
        -v sysconfdir="$(SYSCONFDIR)"                   \
        -v libexec="$(LIBEXECDIR)"                      \
        -v libdir="$(LIBDIR)"                           \
        -v datadir="$(DATADIR)"                         \
        -v localstatedir="$(LOCALSTATEDIR)"             \
        -v runstatedir="$(RUNSTATEDIR)"                 \
        '{                                              \
            gsub(/\$${PREFIX}/,        prefix);         \
            gsub(/\$${BINDIR}/,        bindir);         \
            gsub(/\$${SYSCONFDIR}/,    sysconfdir);     \
            gsub(/\$${LIBDIR}/,        libdir);         \
            gsub(/\$${LIBEXECDIR}/,    libexec);        \
            gsub(/\$${DATADIR}/,       datadir);        \
            gsub(/\$${LOCALSTATEDIR}/, localstatedir);  \
            gsub(/\$${RUNSTATEDIR}/,   runstatedir);    \
            print $$0;                                  \
        }' "$(1)" > "$(2)"
endef

define install_and_expand
    @find "$(1)" -type f -printf '%P\n' | while IFS= read -r line ; do \
        path="$(1)/$${line}" ;                                         \
        if [ ! -e "$${path}" ] ; then                                  \
            echo "File $${path} not found. Newlines?" ;                \
            continue ;                                                 \
        fi ;                                                           \
        parent="$$(dirname "$${line}")" ;                              \
        dstdir="$(2)/$${parent}" ;                                     \
        mkdir -p "$${dstdir}" ;                                        \
        dst="$(2)/$${line}" ;                                          \
        tmp="$${dst}.tmp"  ;                                           \
        $(call expand_file_paths,$${path},$${tmp}) ;                   \
        install -m "$(3)" "$${tmp}" "$${dst}" ;                        \
        rm -f "$${tmp}" ;                                              \
    done
endef

install_script_bin: bin/
	@echo Installing binaries
	$(call install_and_expand,$<,$(DESTDIR)$(BINDIR),0755)

install_script_sysconf: etc/
	@echo Installing etc configs
	$(call install_and_expand,$<,$(DESTDIR)$(SYSCONFDIR),0644)

install_script_libexec: libexec/
	@echo Installing libexec
	$(call install_and_expand,$<,$(DESTDIR)$(LIBEXECDIR),0755)

install_script_lib: lib/
	@echo Installing libraries
	$(call install_and_expand,$<,$(DESTDIR)$(LIBDIR),0644)

install_script_data: share/
	@echo Installing libraries
	$(call install_and_expand,$<,$(DESTDIR)$(DATADIR),0644)

