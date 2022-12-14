#!/usr/bin/perl -w

use feature 'unicode_strings';

use DateTime::Format::Mail;
use DateTime;
use URI::Escape qw(uri_escape_utf8);
use URL::Encode qw(url_encode_utf8);
use XML::OPML;
use utf8;

$current = 'none';
$feeds = 'ALL-RSS-FEEDS.opml';
$url_improvement = '../../issues/new';
$now = DateTime->now(); # UTC default
$xml_date =  DateTime::Format::Mail->format_datetime($now);
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
	unless ($text =~ /\s([A-Z]{2,})\s/) { # infix UPPERCASEWORD prevents lowercasing, because OPERATORS
	    $text =~ tr/A-Z/a-z/;
	}
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
	unless ($term =~ /[\"\(\)]/) { # using dquot or parens excludes the term from wrapping
	    $term = "\"$term\"";
	}
	push(@stack, $term);
    }
    my $result = join(' OR ', @stack);
    $result = url_encode_utf8($result);
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

	my $tweet_intent = 'https://twitter.com/intent/tweet?text';
	my $tweet_root = 'https://github.com/alecmuffett/they-search-for-you';
	my $tweet_anchor = Anchorify($current);
	my $tweet_text = "Search \@TheyWorkForYou for '$current' with a ready-made query at:\n\n$tweet_root#$tweet_anchor";
	my $tweet_url = sprintf("%s=%s", $tweet_intent, uri_escape_utf8($tweet_text));

	print("### links\n\n");
	printf("* :point_right: [Search: %s](%s)\n", $current, $url_web);
	printf("* :repeat: [RSS Feed: %s](%s)\n", $current, $url_rss);
	printf("* :heart: [Share '%s' in a Tweet!](%s)\n", $current, $tweet_url);
	printf("* :bulb: [%s](%s)\n", 'Suggest an Improvement', $url_improvement);
	printf("* :arrow_up: [%s](%s)\n", 'Return to Index', '#index');
	print("\n");

	print("#### search terms\n\n");
	print("```\n");
	foreach my $term (sort(@{$qref})) {
	    print("* $term\n")
	}
	print("```\n");
	print("\n");

	$opml->add_outline(
	    title => "TheySearchForYou: $current", # probably redundant, but set it anyway
	    text => $current,
	    description => $xml_description,
	    type => 'rss',
	    version => 'RSS',
	    htmlUrl => $url_web,
	    xmlUrl => $url_rss,
	    );
    }
}

# updates feed
$tsfy_title = 'TheySearchForYou Status - Search Updates';
$opml->add_outline(
    title => $tsfy_title,
    text => $tsfy_title,
    description => $tsfy_title,
    type => 'rss',
    version => 'RSS',
    htmlUrl => 'https://github.com/alecmuffett/they-search-for-you',
    xmlUrl => 'https://raw.githubusercontent.com/alecmuffett/they-search-for-you/main/UPDATES.rss',
    );

$opml->save($feeds);
