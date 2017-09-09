package Crypto::TradeData::SQL::SQLDatabase;

use strict;
use Crypto::TradeData::SQL::CreateDatabase;
use DBI;
use Data::Dumper;
use Moo;

sub build_database_connection {

    my ($self, %args) = @_;
  
    my $dsn = 'DBI:' . $args{driver} . ':database=' . $args{database} . ';host=' . $args{hostname} . ';port=' . $args{port};
  
    my $dbh = DBI->connect($dsn, $args{username}, $args{password}, {RaiseError
=> 1, mysql_auto_reconnect => 1});
 
    Crypto::TradeData::SQL::CreateDatabase->make_sure_tables_exist(dbh => $dbh);

    return $dbh;  

}

sub build_sth_connections {
    
    my ($self, %args) = @_;

    my $dbh = $args{dbh};
    my $table_cols = $args{table_cols};
    
    my $sth_connections = {};

    foreach my $table_name (keys %$table_cols) {
        
        my $sth = $self->prepare_insert_for_db_table(
            dbh => $dbh,
            table_name => $table_name,
            table_cols => $table_cols->{$table_name},
            id => $args{id}, 
        );
    
        $sth_connections->{$table_name} = $sth; 
        
    }
    
    return $sth_connections;

}

sub build_sth_select {
    
    my ($self, %args) = @_;

    my $dbh = $args{dbh};
    my $table_cols = $args{table_cols};

    my $sth_connections = {};

    foreach my $table_name (keys %$table_cols) {
    
        my $sth = $self->prepare_selects_for_db_table(
            dbh => $dbh,
            table_name => $table_name,
            table_cols => $table_cols->{$table_name},
        );
    
        $sth_connections->{$table_name} = $sth; 
        
    }
    
    return $sth_connections;

}

sub get_starting_id_val {

    my ($self, %args) = @_;

    my $dbh = $args{dbh};
    my $table_cols = $args{table_cols};

    my $id = 0;

    foreach my $table_name (keys %$table_cols) {
        
        my $test_ids = $dbh->selectcol_arrayref("SELECT id FROM $table_name ORDER BY id DESC LIMIT 1");
   
        if ($test_ids->[0]) {
            
            my $test_id = $test_ids->[0];

            $id = $test_id if ($test_id > $id);

        }
    }
    
    $id++;
    
    return $id;

}

sub prepare_selects_for_db_table {

    my ($self, %args) = @_;
    
    my $dbh        = $args{dbh};
    my $table_name = $args{table_name};
    my $table_cols = $args{table_cols};
   
    $table_cols = join(',', @$table_cols);

    my $sth = $dbh->prepare("SELECT $table_cols FROM $table_name ORDER BY
id DESC LIMIT 1"); 
   
    return $sth;
 
}

sub prepare_insert_for_db_table {

    my ($self, %args) = @_;
  
    my $dbh        = $args{dbh};
    my $table_name = $args{table_name};
    my $table_cols = $args{table_cols};
    my $id         = $args{id};
    
    my $num_of_cols = scalar(@$table_cols);
     
    $num_of_cols++ if ($id);
 
    my @bind_params = ('?') x $num_of_cols;     
    
    my $bind_params = join(',', @bind_params);

    $table_cols = join(',', @$table_cols);
        
    my $sth = ($id) ? $dbh->prepare("INSERT INTO $table_name (id, $table_cols) VALUES
($bind_params)") : $dbh->prepare("INSERT INTO $table_name ($table_cols)
VALUES ($bind_params)");
    
    return $sth;
 
}

sub build_websocket_watcher {

    my ($self, %args) = @_;

    my $dbh        = $args{dbh};
    my $table_cols = $args{table_cols};
    my $col_name   = $args{col_name};
 
    my $sth_connections = {};
        
    foreach my $table_name (keys %$table_cols) {
        
        next if ($table_name eq 'liqui');  
 
        my $sth = $dbh->prepare("SELECT id FROM $table_name ORDER BY id desc LIMIT 1");
        
        my $sth2 = $dbh->prepare("UPDATE $table_name SET $col_name = 1 WHERE id = ?"); 
        
        $sth_connections->{$table_name} = { select => $sth, insert => $sth2 };
       
    }

    return $sth_connections;

}

1;
