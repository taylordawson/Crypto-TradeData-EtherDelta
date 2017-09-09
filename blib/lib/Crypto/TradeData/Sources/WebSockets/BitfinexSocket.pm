package Crypto::TradeData::WebSockets::BitfinexSocket;

use strict;
use IO::File;
use Mojo::UserAgent;
use Mojo::IOLoop;
use Data::Dumper;
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
    
    my $ua = Mojo::UserAgent->new;
        
    $ua->websocket($self->{url} => sub {
    
        my ($ua, $tx) = @_;
        
        print 'WebSocket handshake failed!' and return unless $tx->is_websocket; 
        
        $tx->on(finish => sub {
            
            my ($tx, $code, $reason) = @_;

            print "WebSocket closed with status $code.";            
            
        });
        
        $tx->on(message => sub {
            
            my ($tx, $msg) = @_;
                
            if ($msg =~ /\"hb\"/) {    
            
            } else {
                
                $self->insert_into_db(message => $msg);               
     
            }          

        });
        
        $tx->send("{\"event\":\"subscribe\", \"channel\":
\"ticker\",\"symbol\":\"$self->{symbol}\"}");
    
    });
   
    Mojo::IOLoop->start;
    
}

sub insert_into_db {
    
    my ($self, %args) = @_;

    my $msg = $args{message};

    $msg =~ s/\[//g;
    $msg =~ s/\]//g;

    my ($val, $bid, $bid_size, $ask, $ask_size, $daily_change,
$daily_change_perc, $last_price, $volume, $high, $low) = split(/\,/, $msg);
    
    $self->execute(join(',', $val, $bid, $bid_size, $ask, $ask_size,
$daily_change, $daily_change_perc, $last_price, $volume, $high, $low);    

}

1;
