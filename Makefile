PREFIX = /usr/

all: install

install:
	install -Dm 755 instantsupport.sh ${DESTDIR}${PREFIX}bin/instantsupport
	install -Dm 755 supportclient.sh ${DESTDIR}${PREFIX}bin/supportclient

uninstall:
	rm ${DESTDIR}${PREFIX}bin/supportclient
	rm ${DESTDIR}${PREFIX}bin/instantsupport
