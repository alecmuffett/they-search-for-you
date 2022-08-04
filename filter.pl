#!/usr/bin/perl -w

use feature 'unicode_strings';
use utf8;
use URI::Escape;
use XML::OPML;

$current = 'none';
$feeds = 'FEEDS.opml';
$url_improvement = '../../issues/new';
$xml_date = 'Mon, 1 Jan 2022 00:00:00 GMT';
$xml_email = 'alec.muffett@gmail.com';
$xml_name = 'Alec Muffett';
$xml_title = 'TheySearchForYou';

@titles = ();
%verbiage = ();
%terms = ();
$opml = new XML::OPML(version => "1.1"); # https://metacpan.org/pod/XML::OPML

$opml->head(
    dateCreated => $xml_date,
    dateModified => $xml_date,
    ownerEmail => $xml_email,
    ownerName => $xml_name,
    title => $xml_title,
    );

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

sub ShareURL {
    return '';
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

    my $xml_description = '';

    my $vref = $verbiage{$current};
    if ($vref) {
	my $description = join(' ', @{$vref});
	print($description, "\n\n");
	$xml_description = $description;
    }

    my $qref = $terms{$current};
    if ($qref) {
	my $query = Queryify(@{$qref});
	my $url_web = SearchURL($query);
	my $url_rss = RSSURL($query);
	#my $url_share = ShareURL($query);
	print("### links\n\n");
	printf("* :point_right: [Search: %s](%s)\n", $current, $url_web);
	printf("* :repeat: [RSS Feed: %s](%s)\n", $current, $url_rss);
	printf("* :arrow_up: [%s](%s)\n", 'Return to Index', '#index');
	#printf("* :heart: [Share '%s' in a Tweet!](%s)\n", $current, $url_share);
	printf("* :bulb: [%s](%s)\n", 'Suggest an Improvement', $url_improvement);
	print("\n");

	print("#### search terms\n\n");
	print("```\n");
	foreach my $term (sort(@{$qref})) {
	    print("* $term\n")
	}
	print("```\n");
	print("\n");

	$opml->add_outline(
	    title => $current,
	    text => $current,
	    description => $xml_description,
	    type => 'rss',
	    version => 'RSS',
	    htmlUrl => $url_web,
	    xmlUrl => $url_rss,
	    );
    }
}

$opml->save($feeds);
