 #!/usr/bin/perl

use strict;
use warnings;

# UART LogEntry class
package LogEntry;

sub new {
    my ($class, $timestamp, $type, $message, $direction, $raw_line) = @_;
    my $self = {
        timestamp => $timestamp,
        type      => $type,
        message   => $message,
        direction => $direction,
        raw_line  => $raw_line
    };
    bless $self, $class;
    return $self;
}

sub display {
    my ($self) = @_;
    return "[$self->{timestamp}] $self->{type}: $self->{message}";
}

1; # End of package

# Main script
package main;

my $log_file = 'uart_log2.txt';
open(my $fh, '<', $log_file) or die "Cannot open $log_file: $!";

my %log_types = (
    DATA    => [],
    ERROR   => [],
    CONTROL => []
);
# the number of log entries
my $total_entries = 0;
my ($sent_count, $received_count) = (0, 0);
my $latest_error = "";
# reades line by line
while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*$/;
#regex matching
    my ($timestamp) = $line =~ /\[(.*?)\]/;
    my ($type) = $line =~ /\] (\w+):/;
    my ($message) = $line =~ /:\s(.+)$/;
    my $direction = "";
    $direction = "Sent"     if $message =~ /Sent/;
    $direction = "Received" if $message =~ /Received/;

    my $entry = LogEntry->new($timestamp, $type, $message, $direction, $line);
    push @{ $log_types{$type} }, $entry if exists $log_types{$type};

    $sent_count++     if $direction eq "Sent";
    $received_count++ if $direction eq "Received";

    $latest_error = $entry->display() if $type eq "ERROR";
    $total_entries++;
}
close $fh;

# Print Summary Report
print "===== UART LOG SUMMARY =====\n";
print "Total entries: $total_entries\n";
print "DATA messages: " . scalar(@{$log_types{DATA}}) . "\n";
print "CONTROL messages: " . scalar(@{$log_types{CONTROL}}) . "\n";
print "ERROR messages: " . scalar(@{$log_types{ERROR}}) . "\n\n";

print "Most recent ERROR:\n$latest_error\n\n" if $latest_error;
print "Bytes Sent: $sent_count\n";
print "Bytes Received: $received_count\n";

# Optional: save to summary.txt
open(my $out, '>', 'summary.txt') or die "Cannot write summary.txt: $!";
print $out "===== UART LOG SUMMARY =====\n";
print $out "Total entries: $total_entries\n";
print $out "DATA messages: " . scalar(@{$log_types{DATA}}) . "\n";
print $out "CONTROL messages: " . scalar(@{$log_types{CONTROL}}) . "\n";
print $out "ERROR messages: " . scalar(@{$log_types{ERROR}}) . "\n\n";

print $out "Most recent ERROR:\n$latest_error\n\n" if $latest_error;
print $out "Bytes Sent: $sent_count\n";
print $out "Bytes Received: $received_count\n";
close $out;

print "\nSummary saved to summary.txt\n";
