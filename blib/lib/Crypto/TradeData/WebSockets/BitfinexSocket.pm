package Crypto::TradeData::WebSockets::BitfinexSocket;

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
                
            if ($msg =~ /\"hb\"/) {    
            
            } else {
                
                $self->insert_into_db(message => $msg);              
     
            }          

        });
        
        $tx->send("{\"event\":\"subscribe\", \"channel\":
\"ticker\",\"symbol\":\"$self->{symbol}\"}");
    
    });
   
    Mojo::IOLoop->start;
    
    sleep(10);
    
    print "Attemping to restart websocket: Bitfinex - " . time() . "\n";
 
    goto START;   
  
}

sub insert_into_db {

    my ($self, %args) = @_;

    my $msg = $args{message};
    
    if ($msg =~ /\[/) {
        
        $msg =~ s/\[//g;
        $msg =~ s/\]//g;
    
        my ($fcc, $bid, $bid_size, $ask, $ask_size, $daily_change, $daily_change_perc, $last_price, $volume, $high, $low) = split(/\,/, $msg);
        
        $self->{sth}->execute(lc($self->{symbol}), $fcc, $bid, $bid_size, $ask,
$ask_size, $daily_change, $daily_change_perc, $last_price, $volume, $high, $low); 

    }
}

1;
