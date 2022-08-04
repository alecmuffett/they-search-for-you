#!/usr/bin/perl -w

use feature 'unicode_strings';

use DateTime::Format::Mail;
use DateTime;
use URI::Escape;
use XML::RSS;
use utf8;
use File::Slurp qw(read_file);

my $current = 'none';
my $now = DateTime->now(); # UTC default
my $xml_date =  DateTime::Format::Mail->format_datetime($now);
my $xml_email = 'alec.muffett@gmail.com';
my $xml_name = 'Alec Muffett';
my $xml_title = 'TheySearchForYou Search-Query Updates';
my $root = 'https://raw.githubusercontent.com/alecmuffett/they-search-for-you/main';
my $xml_home = 'https://github.com/alecmuffett/they-search-for-you';
my $rss = XML::RSS->new (version => '2.0');

$rss->channel(
    copyright => 'https://creativecommons.org/licenses/by/4.0/',
    description => $xml_title,
    language => 'en',
    lastBuildDate => $xml_date,
    link => $xml_home,
    managingEditor => $xml_email,
    pubDate => $xml_date,
    title => $xml_title,
    webMaster => $xml_email,
    );

foreach my $path (@ARGV) {
    $content = read_file $path, {binmode => ':utf8'};
    $rss->add_item(
	title => $path,
        description => "<p>updated search query:</p>\n<pre>$content</pre>\n",
        permaLink  => "$root/$path",
	);
}

print($rss->as_string);
