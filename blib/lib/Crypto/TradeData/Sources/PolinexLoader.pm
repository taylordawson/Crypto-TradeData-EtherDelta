package Crypto::TradeData::Sources::PolinexLoader;

use strict;
use DBI;
use Data::Dumper;
use DateTime;
use Moo;
    
has sth => (
    is => 'ro',
    required => 1,
);

has websocket_sth => (
    is => 'ro',
    required => 1,
);

sub load {
  
    my ($self, %args) = @_;
 
    eval {  
        
        $self->{websocket_sth}->execute();

        while(my @row = $self->{websocket_sth}->fetchrow_array) {
        
            $self->{sth}->execute($args{id}, @row);

        }
    } 
}

1;
