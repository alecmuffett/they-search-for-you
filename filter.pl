#!/usr/bin/perl -w

use feature 'unicode_strings';
use utf8;
use URI::Escape;

$current = 'none';
@titles = ();
%verbiage = ();
%terms = ();

while (<>) {
    s/\s+/ /g;
    s/(^\s|\s$)//g;

    if (/^$/) {
	next;
    }

    if (/^#\s+(.+)/) {
	$current = $1;
	push(@titles, $current);
	next;
    }

    if (/^\*\s+(.*)/) {
	my $ref = $terms{$current};
	my $text = $1;
	$text =~ tr/A-Z/a-z/;
	if ($ref) {
	    push(@{$ref}, $text);
	} else {
	    $terms{$current} = [$text];
	}
	next;
    }

    # else
    my $ref = $verbiage{$current};
    if ($ref) {
	push(@{$ref}, $_);
    } else {
	$verbiage{$current} = [$_];
    }
}

sub Queryify {
    my @stack = ();
    for my $term (sort(@_)) {
	push(@stack, "\"$term\"");
    }
    my $result = join(' OR ', @stack);
    $result = uri_escape($result);
    return $result;
}

sub Anchorify {
    my $anchor = shift(@_);
    $anchor =~ tr/A-Z/a-z/;
    $anchor =~ s/\W/-/go;
    $anchor =~ s/-+/-/go;
    return $anchor;
}

sub SearchURL {
    my $query = shift(@_);
    return "https://www.theyworkforyou.com/search/?q=$query";
}

sub RSSURL {
    my $query = shift(@_);
    return "https://www.theyworkforyou.com/search/rss/?s=$query";
}

print("## Index\n\n");
foreach $current (sort(@titles)) {
    printf("* [%s](#%s)\n",
	  $current,
	  Anchorify($current),
	)
}
print("\n");

foreach $current (sort(@titles)) {
    print("## $current\n\n");

    my $vref = $verbiage{$current};
    if ($vref) {
	print(join(" ", @{$vref}), "\n\n");
    }

    my $qref = $terms{$current};
    if ($qref) {
	my $query = Queryify(@{$qref});
	print("### links\n\n");
	printf("* **search:** [*%s*](%s)\n", $current, SearchURL($query));
	printf("* **rss:** [*%s*](%s)\n", $current, RSSURL($query));
	printf("* **index:** [*%s*](%s)\n", 'top', '#index');
	print("\n");

	print("#### search terms\n\n");
	print("```\n");
	foreach my $term (sort(@{$qref})) {
	    print("* $term\n")
	}
	print("```\n");
	print("\n");
    }
}
