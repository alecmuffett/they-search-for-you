README.md: raw-searches.md filter.pl HEADER.md
	( cat HEADER.md ; echo "" ; ./filter.pl raw-searches.md ) > $@

clean:
	rm *~

push: clean README.md
	git add . && git commit -m "make on `datestamp`" && git push
	make open

open: README.md
	open https://github.com/alecmuffett/they-search-for-you
