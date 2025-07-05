#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use URI;

# Base URL from your integration document
my $base_url = 'https://services.in8.nopaperforms.com/webhooks/v1/13c3db68f26fe3a9997e6164dce63448 ';

# Function to get counsellor from API
sub get_counsellor {
    my ($applicant_no) = @_;

    my $url = "$base_url/getCounsellor?applicant_no=" . URI::Escape::uri_escape($applicant_no);
    my $ua = LWP::UserAgent->new;
    
    # Optional: disable SSL verification if testing
    $ua->ssl_opts(verify_hostname => 0, SSL_verify_mode => 0);

    my $response = $ua->get($url);
    if ($response->is_success) {
        my $data = decode_json($response->decoded_content);
        return $data;
    } else {
        die "API request failed: " . $response->status_line;






        
    }
}

# Function to simulate call routing
sub route_call_to_agent {
    my ($caller_number, $agent_number) = @_;
    
    print "📞 Routing call from $caller_number to agent $agent_number...\n";

    # Here you'd integrate with your telephony system (e.g., Twilio, Meritto, etc.)
    # For now, we'll just simulate it.

    if ($agent_number) {
        print "✅ Call successfully routed to $agent_number\n";
    } else {
        print "❌ No agent found. Playing voicemail or default message.\n";
    }
}

# Function to log call notification (optional)
sub send_call_notification {
    my ($call_id, $agent_no, $applicant_no, $did_no, $call_type) = @_;
    
    my $url = "$base_url/ivrCallNotification";
    my $ua = LWP::UserAgent->new;
    $ua->ssl_opts(verify_hostname => 0, SSL_verify_mode => 0);

    my %params = (
        call_id      => $call_id,
        agent_no     => $agent_no || '',
        applicant_no => $applicant_no,
        did_no       => $did_no || 'DEFAULT_DID',
        call_type    => $call_type || 'inbound'
    );

    my $json = encode_json(\%params);
    my $response = $ua->post($url, Content => $json, Content_Type => 'application/json');

    if ($response->is_success) {
        print "🔔 Call notification sent successfully.\n";
    } else {
        warn "⚠️ Failed to send call notification: " . $response->status_line . "\n";
    }
}

# ======================
# === Main Program ====
# ======================

# Example input: incoming caller number
my $incoming_caller = '+919999999999';  # Replace with dynamic input as needed

print "📥 Incoming call from $incoming_caller\n";

# Step 1: Get assigned counsellor
my $result = get_counsellor($incoming_caller);

if ($result->{status} && scalar @{$result->{data}}) {
    my $agent_number = $result->{data}->[0]->{agent_number};
    route_call_to_agent($incoming_caller, $agent_number);

    # Step 2 (Optional): Notify system of the call
    send_call_notification('call-id-00001', $agent_number, $incoming_caller, 'DID123', 'inbound');
} else {
    print "No counsellor found for this caller.\n";
    route_call_to_agent($incoming_caller, undef);  # Route to default queue
}