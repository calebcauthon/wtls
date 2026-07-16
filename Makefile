.PHONY: test install uninstall

PREFIX ?= /usr/local

test:
	./test/test_wtls.sh

install:
	install -d "$(DESTDIR)$(PREFIX)/bin"
	install -m 0755 bin/wtls "$(DESTDIR)$(PREFIX)/bin/wtls"

uninstall:
	rm -f "$(DESTDIR)$(PREFIX)/bin/wtls"
