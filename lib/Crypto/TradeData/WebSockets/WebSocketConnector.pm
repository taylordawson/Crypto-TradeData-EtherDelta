package Crypto::TradeData::WebSockets::WebSocketConnector;

use strict;
use Data::Dumper;
use Moo;
use Crypto::TradeData::SQL::TableColumns;
use Crypto::TradeData::SQL::SQLDatabase; 
use Crypto::TradeData::WebSockets::BitfinexSocket;
use Crypto::TradeData::WebSockets::GdaxSocket;
use Crypto::TradeData::WebSockets::PolinexSocket;
use Crypto::TradeData::WebSockets::Watcher;

has url => (
    is => 'ro',
    required => 1,
);

has symbol => (
    is => 'ro',
    required => 1,
);

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
    required => 1,
);

sub start_socket {

    my $self = shift;
    
    my $table_cols = Crypto::TradeData::SQL::TableColumns->build_table_cols();
    
    my $sql = Crypto::TradeData::SQL::SQLDatabase->new();
  
    my $dbh = $sql->build_database_connection(
        driver   => $self->{driver},
        username => $self->{username},
        password => $self->{password},
        database => $self->{database},
        port     => $self->{port},
        hostname => $self->{hostname},
    ) or die($!);

    my $sth_connections = $sql->build_sth_connections(
        table_cols => $table_cols,
        dbh => $dbh,
    );    

    my $forks = 0;
        
    foreach my $exch (@{$self->{exchanges}}) {
        
        my $pid = fork();
        die if not defined $pid;
        
        print "Child PID: $pid\n";

        if ($pid) {
            
            $forks++;            
            
            if (lc($exch) eq 'bitfinex') {
                
                my $socket = Crypto::TradeData::WebSockets::BitfinexSocket->new(
                    sth    => $sth_connections->{bitfinex},
                    url    => 'wss://api.bitfinex.com/ws',
                    symbol => 'BTCUSD',
                );    
   
                $socket->start_socket();
         
            }
            
            if ($exch eq 'gdax') {

                my $socket = Crypto::TradeData::WebSockets::GdaxSocket->new(
                    sth    => $sth_connections->{gdax},
                    url    => 'wss://ws-feed.gdax.com',
                    symbol => 'BTC-USD',
                ); 
                
                $socket->start_socket();

            }

            if (lc($exch) eq 'polinex') {
                
                my $socket = Crypto::TradeData::WebSockets::PolinexSocket->new(
                    sth    => $sth_connections->{polinex},
                    url    => 'wss://api2.poloniex.com',
                    symbol => 'BTC_USD',
                ); 
                
                $socket->start_socket();                

            }

            if (lc($exch) eq 'gdax') {

                my $socket = Crypto::TradeData::WebSockets::GdaxSocket->new(
                    sth    => $sth_connections->{gdax},
                    url    => 'wss://ws-feed.gdax.com', 
                    symbol => 'BTC-USD', 
                );

                $socket->start_socket();                

            }
        }
    }
    
    #my $watcher = Crypto::TradeData::WebSockets::Watcher->new(
    #    dbh         => $dbh,
    #    sql         => $sql,
    #    table_cols  => $table_cols,
    #    col_name    => 'frozen',
    #    check_every => 10,
    #);

    #$watcher->start(); 
        
    while(1) {
        sleep(10);
    }
} 

1;
