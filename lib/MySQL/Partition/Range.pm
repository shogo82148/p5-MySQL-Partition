package MySQL::Partition::Range;
use strict;
use warnings;
use utf8;

use parent 'MySQL::Partition';
use Class::Accessor::Lite (
    ro => [qw/catch_all_partition_name/],
);

sub add_catch_all_partition {
    my $self = shift;

    my $sql = $self->build_add_catch_all_partition_sql;
    $self->_execute($sql);
}
sub build_add_catch_all_partition_sql {
    my $self = shift;

    sprintf 'ALTER TABLE %s ADD PARTITION (%s)',
        $self->table, $self->_build_partition_part($self->catch_all_partition_name, 'MAXVALUE');
}

sub reorganize_catch_all_partition {
    my $self = shift;
    die "catch_all_partition_name isn't specified" unless $self->catch_all_partition_name;

    my $sql = $self->build_reorganize_catch_all_partition_sql(@_);
    $self->_execute($sql);
}

sub build_reorganize_catch_all_partition_sql {
    my ($self, @args) = @_;

    sprintf 'ALTER TABLE %s REORGANIZE PARTITION %s INTO (
        %s,
        PARTITION %s VALUES LESS THAN (MAXVALUE)
    )', $self->table, $self->catch_all_partition_name, $self->_build_partition_parts(@args), $self->catch_all_partition_name;
}

sub _build_partition_part {
    my ($self, $partition_name, $value) = shift;

    sprintf 'PARTITION %s VALUES IN (%s)', $partition_name, $value;
}

1;
