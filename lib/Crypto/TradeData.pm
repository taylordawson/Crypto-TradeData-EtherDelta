package Crypto::TradeData;

use strict;
use JSON;
use Data::Dumper;
use LWP::UserAgent;
use Crypto::TradeData::SQL::SQLDatabase;
use Crypto::TradeData::SQL::TableColumns;
use Crypto::TradeData::Sources::LiquiLoader;
use Crypto::TradeData::Sources::BitfinexLoader;
use Crypto::TradeData::Sources::PolinexLoader;
use Crypto::TradeData::Sources::GdaxLoader;
use Moo;

has driver => (
    is => 'ro',
    required => 1,
);

has username => (
    is => 'ro',
    required => 1,
);

has password => (
    is => 'ro',
    required => 1,
);

has database => ( 
    is => 'ro',
    required => 1,
);

has port => (
    is => 'ro',
    required => 1,
);

has hostname => (
    is => 'ro',
    required => 1,
);

has exchanges => (
    is => 'ro',
);

has pairs => (
    is => 'ro',
);

has websocket_username => (
    is => 'ro',
    required => 1,
);

has websocket_password => (
    is => 'ro',
    required => 1,
);

has websocket_database => ( 
    is => 'ro',
    required => 1,
);

has websocket_port => (
    is => 'ro',
    required => 1,
);

has websocket_hostname => (
    is => 'ro',
    required => 1,
);

sub run {

    my $self = shift;
  
    my $sql = Crypto::TradeData::SQL::SQLDatabase->new();
    
    my $dbh = $sql->build_database_connection(
        driver   => $self->{driver},
        username => $self->{username},
        password => $self->{password},
        database => $self->{database},
        port     => $self->{port},
        hostname => $self->{hostname},
    ) or die($!);
  
    my $websocket_dbh = $sql->build_database_connection(
        driver   => $self->{driver},
        username => $self->{websocket_username},
        password => $self->{websocket_password},
        database => $self->{websocket_database},
        port     => $self->{websocket_port},
        hostname => $self->{websocket_hostname},
    ) or die($!);

    my $lwp = LWP::UserAgent->new() or die($!);
   
    my $json = JSON->new->allow_nonref;
    
    $json->allow_unknown;
    
    my $table_columns = Crypto::TradeData::SQL::TableColumns->new();

    my $table_cols = $table_columns->build_table_cols();
    
    my $sth_connections = $sql->build_sth_connections(
        table_cols => $table_cols,
        id         => 1,
        dbh        => $dbh,
    );
    
    my $sth_select = $sql->build_sth_select(
        table_cols => $table_cols,
        dbh        => $websocket_dbh,
    );

    my $websocket_sth_connections = $sql->build_sth_connections(
        table_cols => $table_cols,
        dbh        => $websocket_dbh,
    );
  
    my $pairs = $self->get_pairs();
    
    my $id = $sql->get_starting_id_val(
        dbh        => $dbh, 
        table_cols => $table_cols,
    );
    
    my $bitfinex = Crypto::TradeData::Sources::BitfinexLoader->new(
        sth           => $sth_connections->{bitfinex},
        websocket_sth => $sth_select->{bitfinex},
    );

    my $polinex = Crypto::TradeData::Sources::PolinexLoader->new(
        sth           => $sth_connections->{polinex},
        websocket_sth => $sth_select->{polinex},
    );
    
    my $liqui = Crypto::TradeData::Sources::LiquiLoader->new(
        sth        => $sth_connections->{liqui},
        lwp        => $lwp,
        json       => $json,
        pairs      => $pairs,
        table_cols => $table_cols->{liqui},
        base_url   => 'https://api.liqui.io/api/3/',
    );
    
    my $gdax = Crypto::TradeData::Sources::GdaxLoader->new(
        sth           => $sth_connections->{gdax},
        websocket_sth => $sth_select->{gdax},
    );
  
    my $run_time = time();

    while (1) {    
        
        if (time() > $run_time) {     
            
            $run_time = time() + 1;
   
            foreach my $exchange (@{$self->{exchanges}}) {

                $liqui->load(id => $id) if (uc($exchange) eq 'LIQUI');
            
                $gdax->load(id => $id) if (uc($exchange) eq 'GDAX');

                $bitfinex->load(id => $id) if (uc($exchange) eq 'BITFINEX');
            
                $polinex->load(id => $id) if (uc($exchange) eq 'POLINEX');
                   
            } 
        
            $id++;
        
            print "$id\n";

        }
    }  
}

sub get_pairs {

    my $self = shift;
    
    my $pairs = {};

    foreach my $pair (@{$self->{pairs}}) {
        
        $pairs->{$pair} = 1;

    }
 
    return $pairs;

}

1;
