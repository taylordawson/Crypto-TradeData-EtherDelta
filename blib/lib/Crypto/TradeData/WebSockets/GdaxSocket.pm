package Crypto::TradeData::WebSockets::GdaxSocket;

use strict;
use JSON;
use Data::Dumper;
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
    
    my ($db_sym) = lc($self->{symbol});

    $db_sym =~ s/\-//g;    
    
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
                
                $self->insert_into_db(message => $msg, sym => $db_sym);              
     
            }          

        });
        
        $tx->send("{\"type\":\"subscribe\", \"channels\": [{\"name\":
\"ticker\", \"product_ids\":\[\"$self->{symbol}\"\]}]}");
    
    });
   
    Mojo::IOLoop->start;
    
    sleep(10);
    
    print "Attemping to restart websocket: Bitfinex - " . time() . "\n";
 
    goto START;   
  
}

sub insert_into_db {

    my ($self, %args) = @_;

    my $msg = $args{message};
    my $sym = $args{sym};
    
    $msg = decode_json($msg);

    if ($msg->{type} eq 'ticker') {
        
        $self->{sth}->execute($sym, $msg->{sequence}, $msg->{trade_id},
$msg->{price}, $msg->{best_bid}, $msg->{best_ask}, $msg->{side}, $msg->{last_size});

    }
}

1;
