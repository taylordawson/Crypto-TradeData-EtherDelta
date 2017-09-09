package Crypto::TradeData::SQL::TableColumns;

use strict;
use Moo;

sub build_table_cols {

    my $self = shift;
    
    my $table_cols = {};

    $table_cols->{bitfinex} = [
        'pair',
        'fcc',
        'bid',
        'bid_size',
        'ask',
        'ask_size',
        'daily_change',
        'daily_change_perc',
        'last_price',
        'volume',
        'high',
        'low',
    ];

    $table_cols->{liqui} = [
        'pair',
        'timestamp',
        'high',
        'low', 
        'avg',
        'vol',
        'vol_cur',
        'last',
        'buy',
        'sell',
    ];
    
    $table_cols->{polinex} = [
        'pair',
        'last',
        'lowest_ask',
        'highest_bid',
        'percent_change',
        'base_volume',
        'quote_volume',
        'is_frozen',
        'twenty_four_hour_high',
        'twenty_four_hour_low',
    ];
    
    $table_cols->{gdax} = [
        'pair',
        'sequence_id',
        'trade_id',
        'price',
        'best_bid',
        'best_ask',
        'side',
        'last_size',
    ];
 
    return $table_cols;

}

1;
