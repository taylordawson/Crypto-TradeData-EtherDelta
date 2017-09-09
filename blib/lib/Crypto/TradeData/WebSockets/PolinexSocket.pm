package Crypto::TradeData::WebSockets::PolinexSocket;

use strict;
use Mojo::UserAgent;
use Mojo::IOLoop;
use Moo;

has url => (
    is => 'ro',
    required => 1,
);

has symbol => (
    is => 'ro',
    required => 1,
);

has sth => (
    is => 'ro',
    required => 1,
);

sub start_socket {

    my $self = shift;
    
    START:

    my $ua = Mojo::UserAgent->new;
        
    $ua->websocket($self->{url} => sub {
    
        my ($ua, $tx) = @_;
        
        print 'WebSocket handshake failed!' and return unless $tx->is_websocket; 
        
        $tx->on(finish => sub {
            
            my ($tx, $code, $reason) = @_;

            print "WebSocket closed with status $code.\n";            
            
        });
        
        $tx->on(message => sub {
            
            my ($tx, $msg) = @_;
            
            if ($msg =~ /\[121/) { 
            
                $self->insert_into_db(message => $msg);                
                
            }

        });
        
        $tx->send("{\"command\":\"subscribe\", \"channel\": \"1002\"}");
    
    });
   
    Mojo::IOLoop->start;
    
    sleep(10);
    
    print "Attemping to restart websocket: Polinex - " . time() . "\n";
 
    goto START;   
  
}

sub insert_into_db {

    my ($self, %args) = @_;

    my $msg = $args{message};
    
    if ($msg =~ /\[/) {
        
        $msg =~ s/\[//g;
        $msg =~ s/\]//g;
        $msg =~ s/\"//g;
         
        my ($type, $null, $pair, $last, $lowest_ask, $highest_bid,
$percent_change, $base_volume, $quote_volume, $is_frozen,
$twenty_four_hour_high, $twenty_four_hour_low) = split(/\,/, $msg);
        
        $pair = 'btcusdt';

        $self->{sth}->execute($pair, $last, $lowest_ask, $highest_bid,
$percent_change, $base_volume, $quote_volume, $is_frozen,
$twenty_four_hour_high, $twenty_four_hour_low); 

    }
}

1;
