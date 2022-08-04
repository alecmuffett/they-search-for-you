README.md: raw-searches.md filter.pl intro.md Makefile
	( cat intro.md ; echo "" ; ./filter.pl raw-searches.md ) > $@
	./gen-rss-feed.sh

clean:
	-rm *~

push: clean README.md
	git add . && git commit -m "make on `datestamp`" && git push

open:
	-make push
	open https://github.com/alecmuffett/they-search-for-you
