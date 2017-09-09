package Crypto::TradeData::ConfigParser;

use IO::File;

sub parse {
    
    my ($self, %args) = @_;

    my $file = $args{file};

    my $fh = IO::File->new($file, '<') or die($!);

    my $vals = {};

    my $hash_haed;

    while (<$fh>) {
    
        chomp;
        
        next if (($_ =~ /^\s*$/) || ($_ =~ /^\#.*/));

        $hash_head = $1 if ($_ =~ /^\[(\S+)\]$/);
        
        if ($_ !~ /^\[.*/) {
            
            my ($key, $value) = split(/\=/, $_);
                
            $value =~ s/\R//g;

            $vals->{$hash_head}->{$key} = $value;

        }            

    }

    return $vals;

}

1;
