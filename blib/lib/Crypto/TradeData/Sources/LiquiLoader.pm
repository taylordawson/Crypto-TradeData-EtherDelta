package Crypto::TradeData::Sources::LiquiLoader;

use strict;
use DBI;
use Data::Dumper;
use DateTime;
use Moo;
    
has sth => (
    is => 'ro',
);

has lwp => (
    is => 'ro',
);

has json => (
    is => 'ro',
    required => 1,
);
  
has base_url => (
    is => 'ro',
    required => 1,
);

has table_cols => (
    is => 'ro',
    required => 1,
);

has pairs => (
    is => 'ro',
);

 
sub load {
    
    my ($self, %args) = @_;; 
     
    my $tickers = $self->get_all_tickers();
    
    $self->insert_into_db(tickers => $tickers, id => $args{id});
    
}

sub get_liqui_request {

    my ($self, %args) = @_;
  
    my $param = $args{param};       
    my $url   = $self->{base_url}; 
    my $lwp   = $self->{lwp};
    
    my $us = $lwp->default_headers();
    
    $lwp->agent('Mozilla/4.76');
    
    my $data = $lwp->get($url . $param);  
    
    $data = $self->{json}->decode($data->content());
  
    return $data;

}

sub get_symbols_pairs {

    my $self = shift;
  
    my $data = $self->get_liqui_request(param => 'info'); 
    
    return $data;
 
}

sub get_tickers {

    my ($self, %args) = @_;
  
    my $pair = $args{pair};
    
    my $tickers = {};

    my $data = $self->get_liqui_request(pair => $pair);

    return $tickers; 

}

sub get_all_tickers {
  
    my $self = shift;

    my $symbols = $self->get_symbols_pairs();
  
    my $tickers = {};
  
    foreach my $sym (keys %{$symbols->{pairs}}) {
        
        if($self->{pairs}) {
            
            my $test_sym = $sym;
            
            $test_sym =~ s/\_//g;
 
            next unless (exists($self->{pairs}->{$test_sym}));

        }
 
        my $data = $self->get_liqui_request(param => 'ticker/' . $sym
. "?ignore_invalid=1");
        
        $tickers = {%$tickers, %$data};     
            
    }
    
     
    return $tickers;  

}

sub insert_into_db {

    my ($self, %args) = @_;

    my $tickers = $args{tickers};
    
    foreach my $pair (keys %$tickers) {
            
        my $vals = [];
        
        my $db_pair = $pair;
        
        $db_pair =~ s/\_//g;
            
        push($vals, $db_pair);
        
        eval { 
            
            foreach my $val (@{$self->{table_cols}}) {
            
                next if ($val eq 'pair');        
            
                if ($val eq 'timestamp') {    
                
                    my $dt = DateTime->from_epoch(epoch => $tickers->{$pair}->{updated}, time_zone => 'America/New_York');               
                    
                    $dt->subtract(hours => 3);

                    push($vals, $dt->datetime());

                } else {
                
                    push($vals, $tickers->{$pair}->{$val});        
                
                }
            } 
            
            $self->{sth}->execute($args{id}, @$vals);
        
        }  
    } 
}
1;
