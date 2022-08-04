all: README.md UPDATES.rss

README.md: Makefile filter.pl raw-searches.md header.md
	( cat header.md ; echo "" ; ./filter.pl raw-searches.md ) > $@

UPDATES.rss: Makefile dir2rss.pl raw-searches.md
	./gen-rss-feed.sh

clean:
	-rm *~

push: clean README.md UPDATES.rss
	git add . && git commit -m "make on `datestamp`" && git push

open:
	-make push
	open https://github.com/alecmuffett/they-search-for-you
