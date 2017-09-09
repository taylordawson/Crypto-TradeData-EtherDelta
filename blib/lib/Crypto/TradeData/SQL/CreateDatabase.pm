package Crypto::TradeData::SQL::CreateDatabase;

use strict;

sub make_sure_tables_exist {

    my ($self, %args) = @_;

    my $dbh = $args{dbh};

    $self->bitfinex_table(dbh => $dbh);

    $self->polinex_table(dbh => $dbh);

    $self->liqui_table(dbh => $dbh);

    $self->gdax_table(dbh => $dbh);

}

sub bitfinex_table {

    my ($self, %args) = @_;
    
    my $dbh = $args{dbh};
    
    $dbh->do(
        "CREATE TABLE IF NOT EXISTS bitfinex (
            id int(11) primary key not null auto_increment,
            timestamp datetime not null default current_timestamp,
            pair varchar(10) not null,
            fcc decimal(18,9) not null,
            bid decimal(18,9) not null,
            bid_size decimal(18,9) not null,
            ask decimal(18,9) not null,
            ask_size decimal(18,9) not null,
            last_price decimal(18,9) not null,
            volume decimal(18,9) not null,
            high decimal(18,9) not null,
            low decimal(18,9) not null,
            daily_change decimal(18,9) not null,
            daily_change_perc decimal(18,9) not null,
            frozen int(1) not null default 0
        )"    
    ) or die($!);    
    
}

sub polinex_table {

    my ($self, %args) = @_;

    my $dbh = $args{dbh};
    
    $dbh->do(
        "CREATE TABLE IF NOT EXISTS polinex (
            id int(11) primary key not null auto_increment,
            timestamp datetime not null default current_timestamp,
            pair varchar(10) not null,
            last decimal(18,9) not null,
            highest_bid decimal(18,9) not null,
            lowest_ask decimal(18,9) not null,
            base_volume decimal(18,9) not null,
            quote_volume decimal(18,9) not null,
            twenty_four_hour_high decimal(18,9) not null,
            twenty_four_hour_low decimal(18,9) not null,
            percent_change decimal(18,9) not null,
            is_frozen decimal(18,9) not null,
            frozen int(1) not null default 0            
       )"
    ) or die($!);

}

sub liqui_table {

    my ($self, %args) = @_;
    
    my $dbh = $args{dbh};
    
    $dbh->do(
        "CREATE TABLE IF NOT EXISTS liqui (
            id int(11) primary key not null auto_increment,
            timestamp datetime not null default current_timestamp,
            pair varchar(10) not null,
            high decimal(18,9) not null,
            low decimal(18,9) not null,
            buy decimal(18,9) not null,
            sell decimal(18,9) not null,
            avg decimal(18,9) not null,
            last decimal(18,9) not null,
            vol decimal(18,9) not null,
            vol_cur decimal(18,9) not null,
            frozen int(1) not null default 0
        )"    
    ) or die($!);

}

sub gdax_table {

    my ($self, %args) = @_;
    
    my $dbh = $args{dbh};
    
    $dbh->do(
        "CREATE TABLE IF NOT EXISTS gdax (
            id int(11) primary key not null auto_increment,
            timestamp datetime not null default current_timestamp,
            pair varchar(25) not null,
            side varchar(25) not null,
            sequence_id int(11) not null,
            trade_id int(11) not null,
            price decimal(18,9) not null,
            best_bid decimal(18,9) not null,
            best_ask decimal(18,9) not null,
            last_size decimal(18,9) not null,
            frozen int(1) not null default 0
        )"
    ) or die($!);
    
}

1;
