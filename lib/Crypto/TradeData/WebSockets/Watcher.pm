package Crypto::TradeData::WebSockets::Watcher;

use strict;
use Data::Dumper;
use Moo;

has dbh => (
    is => 'ro',
    required => 1,
);

has sql => (
    is => 'ro',
    required => 1,
);

has table_cols => (
    is => 'ro',
    required => 1,
);

has col_name => (
    is => 'ro',
    required => 1,
);

has check_every => (
    is => 'ro',
    required => 1,
);

sub start {
    
    my $self = shift;

    my $sth_connections = $self->{sql}->build_websocket_watcher(
        dbh        => $self->{dbh},
        table_cols => $self->{table_cols},
        col_name   => $self->{col_name},
    );
    
    my $ids = {};
    
    while (1 < 2) {
        
        sleep($self->{check_every});
        
        foreach my $table_name (keys %$sth_connections) {
            
            if(exists($ids->{$table_name})) {
                
                $sth_connections->{$table_name}->{select}->execute();
                
                if ($sth_connections->{$table_name}->{select}->execute() == 1) { 
                    
                    my ($test_if_frozen) = $sth_connections->{$table_name}->{select}->fetchrow_array();
                
                    if ($ids->{$table_name} == $test_if_frozen) {
                    
                        $sth_connections->{$table_name}->{insert}->execute($test_if_frozen);
                
                    } else {;
                    
                        $ids->{$table_name} = $test_if_frozen;
                    
                    }
                }
                    
            } else {
                
                $sth_connections->{$table_name}->{select}->execute();
                
                if ($sth_connections->{$table_name}->{select}->execute() == 1) {     
                    
                    my ($id) = $sth_connections->{$table_name}->{select}->fetchrow_array(); 
                    
                    $ids->{$table_name} = $id;
            
                }
            }
        }               
    }
}

1;
